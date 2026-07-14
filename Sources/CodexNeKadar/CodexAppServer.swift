import AppKit
import Foundation

actor CodexAppServer {
    private var process: Process?
    private var input: FileHandle?
    private var output: FileHandle?
    private var lineBuffer = Data()
    private var nextRequestID = 1
    private var rateLimitHandler: (@Sendable (RateLimitsResponse) -> Void)?
    private var accountHandler: (@Sendable (AccountResponse) -> Void)?
    private var failureHandler: (@Sendable (String) -> Void)?

    func setHandlers(
        rateLimits: @escaping @Sendable (RateLimitsResponse) -> Void,
        account: @escaping @Sendable (AccountResponse) -> Void,
        failure: @escaping @Sendable (String) -> Void
    ) {
        rateLimitHandler = rateLimits
        accountHandler = account
        failureHandler = failure
    }

    func start() {
        guard process == nil || process?.isRunning == false else { return }

        guard let executable = Self.findExecutable() else {
            failureHandler?("Codex uygulaması bulunamadı. ChatGPT/Codex masaüstü uygulamasını yükleyin.")
            return
        }

        let process = Process()
        let stdin = Pipe()
        let stdout = Pipe()
        let stderr = Pipe()
        process.executableURL = executable
        process.arguments = ["app-server", "--stdio"]
        process.standardInput = stdin
        process.standardOutput = stdout
        process.standardError = stderr

        stdout.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            Task { await self?.consume(data) }
        }
        process.terminationHandler = { [weak self] completed in
            Task { await self?.terminated(status: completed.terminationStatus) }
        }

        do {
            try process.run()
            self.process = process
            input = stdin.fileHandleForWriting
            output = stdout.fileHandleForReading
            sendInitialize()
        } catch {
            failureHandler?("Codex başlatılamadı: \(error.localizedDescription)")
        }
    }

    func refresh() {
        guard process?.isRunning == true else {
            start()
            return
        }
        send(method: "account/rateLimits/read", params: NSNull())
    }

    func stop() {
        output?.readabilityHandler = nil
        process?.terminate()
        process = nil
        input = nil
        output = nil
    }

    private func sendInitialize() {
        send(method: "initialize", id: 0, params: [
            "clientInfo": [
                "name": "codex_ne_kadar",
                "title": "Codex Ne Kadar",
                "version": "1.0.1"
            ]
        ])
        sendNotification(method: "initialized", params: [:])
        send(method: "account/read", params: ["refreshToken": false])
        refresh()
    }

    private func send(method: String, id: Int? = nil, params: Any) {
        let requestID = id ?? nextRequestID
        if id == nil { nextRequestID += 1 }
        write(["method": method, "id": requestID, "params": params])
    }

    private func sendNotification(method: String, params: Any) {
        write(["method": method, "params": params])
    }

    private func write(_ object: [String: Any]) {
        guard let input,
              let encoded = try? JSONSerialization.data(withJSONObject: object) else { return }
        input.write(encoded + Data([0x0A]))
    }

    private func consume(_ data: Data) {
        lineBuffer.append(data)
        while let newline = lineBuffer.firstIndex(of: 0x0A) {
            let line = lineBuffer.prefix(upTo: newline)
            lineBuffer.removeSubrange(...newline)
            decode(line: Data(line))
        }
    }

    private func decode(line: Data) {
        guard let object = try? JSONSerialization.jsonObject(with: line) as? [String: Any] else { return }

        if let result = object["result"] as? [String: Any] {
            if result["rateLimits"] != nil,
               let payload = try? JSONSerialization.data(withJSONObject: result),
               let response = try? JSONDecoder().decode(RateLimitsResponse.self, from: payload) {
                rateLimitHandler?(response)
                return
            }
            if result["account"] != nil,
               let payload = try? JSONSerialization.data(withJSONObject: result),
               let response = try? JSONDecoder().decode(AccountResponse.self, from: payload) {
                accountHandler?(response)
                return
            }
        }

        if object["method"] as? String == "account/rateLimits/updated" {
            // Bu bildirim eksik (sparse) alanlar içerebilir; tam bir anlık görüntü iste.
            refresh()
        }
    }

    private func terminated(status: Int32) {
        guard process != nil else { return }
        process = nil
        input = nil
        output = nil
        failureHandler?("Codex bağlantısı kapandı (çıkış kodu \(status)). Yeniden denenecek.")
    }

    private static func findExecutable() -> URL? {
        var candidates: [URL] = []
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.openai.codex") {
            candidates.append(appURL.appending(path: "Contents/Resources/codex"))
        }
        candidates += [
            URL(fileURLWithPath: "/Applications/ChatGPT.app/Contents/Resources/codex"),
            URL(fileURLWithPath: "/Applications/Codex.app/Contents/Resources/codex")
        ]
        let pathEntries = (ProcessInfo.processInfo.environment["PATH"] ?? "").split(separator: ":")
        candidates += pathEntries.map { URL(fileURLWithPath: String($0)).appending(path: "codex") }

        return candidates.first { FileManager.default.isExecutableFile(atPath: $0.path) }
    }
}

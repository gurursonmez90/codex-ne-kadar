import Foundation
import UserNotifications

@MainActor
final class LimitMonitor: ObservableObject {
    @Published private(set) var windows: [DisplayWindow] = []
    @Published private(set) var planType: String?
    @Published private(set) var lastUpdated: Date?
    @Published private(set) var errorMessage: String?
    @Published private(set) var accountEmail: String?
    @Published private(set) var accountType: String?
    @Published private(set) var hasCredits: Bool = false
    @Published private(set) var creditsBalance: String?
    @Published private(set) var creditsUnlimited: Bool = false

    private let server = CodexAppServer()
    private var refreshTask: Task<Void, Never>?
    private var evaluator = AlertEvaluator()
    private var hasBaseline = false
    private var hasStarted = false

    private var thresholds: [Int] {
        Thresholds.parse(UserDefaults.standard.string(forKey: "thresholdsText") ?? Thresholds.defaultText)
    }

    private var refreshInterval: TimeInterval {
        let minutes = UserDefaults.standard.integer(forKey: "refreshMinutes")
        return TimeInterval((minutes == 0 ? 2 : minutes) * 60)
    }

    var statusBarTitle: String {
        guard !windows.isEmpty else { return "--%" }
        return windows.prefix(2).map { "\($0.remainingPercent)%" }.joined(separator: " / ")
    }

    var statusBarHelp: String {
        guard !windows.isEmpty else { return "Codex limitleri bekleniyor" }
        return windows.prefix(2).map { window in
            "\(window.label): %\(window.remainingPercent) kaldı"
        }.joined(separator: "\n")
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        UserDefaults.standard.register(defaults: [
            "thresholdsText": Thresholds.defaultText,
            "refreshMinutes": 2,
            "alertsEnabled": false
        ])

        Task { [weak self] in
            guard let self else { return }
            await server.setHandlers(
                rateLimits: { [weak self] response in
                    Task { @MainActor in self?.received(response) }
                },
                account: { [weak self] response in
                    Task { @MainActor in self?.receivedAccount(response) }
                },
                failure: { [weak self] message in
                    Task { @MainActor in self?.failed(message) }
                }
            )
            await server.start()
        }

        refreshTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(refreshInterval))
                guard !Task.isCancelled else { return }
                await server.refresh()
            }
        }
    }

    func refresh() {
        Task { await server.refresh() }
    }

    func restartPolling() {
        refreshTask?.cancel()
        refreshTask = nil
        startPolling()
    }

    private func startPolling() {
        refreshTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(refreshInterval))
                guard !Task.isCancelled else { return }
                await server.refresh()
            }
        }
    }

    private func received(_ response: RateLimitsResponse) {
        let newWindows = LimitNormalizer.displayWindows(from: response)
        guard !newWindows.isEmpty else {
            errorMessage = "Bu Codex oturumunda gösterilecek kullanım limiti bulunamadı."
            return
        }

        let alerts = hasBaseline ? evaluator.alerts(for: newWindows, thresholds: thresholds) : []
        if !hasBaseline {
            evaluator.seed(with: newWindows)
            hasBaseline = true
        }

        windows = newWindows
        planType = response.rateLimits.planType
        lastUpdated = Date()
        errorMessage = nil

        if let credits = response.rateLimits.credits {
            hasCredits = credits.hasCredits
            creditsBalance = credits.balance
            creditsUnlimited = credits.unlimited
        } else {
            hasCredits = false
            creditsBalance = nil
            creditsUnlimited = false
        }

        if UserDefaults.standard.bool(forKey: "alertsEnabled") {
            for window in alerts {
                NotificationManager.shared.sendLowLimitNotification(for: window)
            }
        }
    }

    private func receivedAccount(_ response: AccountResponse) {
        accountEmail = response.account?.email
        accountType = response.account?.type
        if let plan = response.account?.planType {
            planType = plan
        }
    }

    private func failed(_ message: String) {
        errorMessage = message
    }
}

@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func sendLowLimitNotification(for window: DisplayWindow) {
        let content = UNMutableNotificationContent()
        content.title = "Codex limiti azalıyor"
        content.body = "\(window.label): %\(window.remainingPercent) kaldı. \(window.resetDescription.capitalized) sıfırlanacak."
        content.sound = .default
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }

    nonisolated func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

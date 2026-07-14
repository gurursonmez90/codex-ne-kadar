import Foundation

struct RateLimitsResponse: Decodable, Sendable {
    let rateLimits: RateLimitSnapshot
    let rateLimitsByLimitId: [String: RateLimitSnapshot]?
}

struct RateLimitSnapshot: Decodable, Sendable {
    let limitId: String?
    let limitName: String?
    let planType: String?
    let primary: RateLimitWindow?
    let secondary: RateLimitWindow?
    let rateLimitReachedType: String?
    let credits: CreditsInfo?
}

struct AccountResponse: Decodable, Sendable {
    let account: AccountInfo?
    let requiresOpenaiAuth: Bool?
}

struct AccountInfo: Decodable, Sendable {
    let type: String?
    let email: String?
    let planType: String?
}

struct CreditsInfo: Decodable, Sendable, Equatable {
    let hasCredits: Bool
    let unlimited: Bool
    let balance: String
}

struct RateLimitWindow: Decodable, Sendable, Equatable {
    let usedPercent: Int
    let resetsAt: Int?
    let windowDurationMins: Int?
}

struct DisplayWindow: Identifiable, Hashable, Sendable {
    enum Slot: String, Sendable {
        case primary
        case secondary
    }

    let bucketID: String
    let bucketName: String?
    let slot: Slot
    let usedPercent: Int
    let resetAt: Date?
    let durationMinutes: Int?

    var id: String {
        "\(bucketID)|\(slot.rawValue)|\(Int(resetAt?.timeIntervalSince1970 ?? 0))"
    }

    var remainingPercent: Int {
        min(100, max(0, 100 - usedPercent))
    }

    var label: String {
        guard let durationMinutes else { return slot == .primary ? "Ana limit" : "Ek limit" }

        if durationMinutes % 1_440 == 0 {
            let days = durationMinutes / 1_440
            return days == 1 ? "Günlük limit" : "\(days) günlük limit"
        }
        if durationMinutes % 60 == 0 {
            return "\(durationMinutes / 60) saatlik limit"
        }
        return "\(durationMinutes) dakikalık limit"
    }

    var resetDescription: String {
        resetDescription(relativeTo: Date())
    }

    func resetDescription(relativeTo referenceDate: Date) -> String {
        guard let resetAt else { return "Sıfırlanma zamanı bilinmiyor" }
        let diffSeconds = resetAt.timeIntervalSince(referenceDate)
        if diffSeconds <= 0 {
            return "Şimdi"
        }
        let diffMinutes = Int(ceil(diffSeconds / 60))
        if diffMinutes < 60 {
            return "\(diffMinutes) dakika sonra"
        }
        if diffMinutes < 1440 {
            let hours = diffMinutes / 60
            let mins = diffMinutes % 60
            if mins == 0 {
                return "\(hours) saat sonra"
            }
            return "\(hours) saat \(mins) dakika sonra"
        }
        let days = diffMinutes / 1440
        let remainingMins = diffMinutes % 1440
        let hours = remainingMins / 60
        if hours == 0 {
            return "\(days) gün sonra"
        }
        return "\(days) gün \(hours) saat sonra"
    }
}

enum LimitNormalizer {
    static func displayWindows(from response: RateLimitsResponse) -> [DisplayWindow] {
        let buckets = response.rateLimitsByLimitId ?? [response.rateLimits.limitId ?? "codex": response.rateLimits]
        let selectedBuckets: [(String, RateLimitSnapshot)]

        if let codex = buckets["codex"] {
            selectedBuckets = [("codex", codex)]
        } else {
            selectedBuckets = buckets.sorted { $0.key < $1.key }
        }

        return selectedBuckets.flatMap { bucketID, snapshot in
            var windows: [DisplayWindow] = []
            if let primary = snapshot.primary {
                windows.append(makeWindow(bucketID: bucketID, snapshot: snapshot, slot: .primary, window: primary))
            }
            if let secondary = snapshot.secondary {
                windows.append(makeWindow(bucketID: bucketID, snapshot: snapshot, slot: .secondary, window: secondary))
            }
            return windows
        }
    }

    private static func makeWindow(
        bucketID: String,
        snapshot: RateLimitSnapshot,
        slot: DisplayWindow.Slot,
        window: RateLimitWindow
    ) -> DisplayWindow {
        DisplayWindow(
            bucketID: bucketID,
            bucketName: snapshot.limitName,
            slot: slot,
            usedPercent: window.usedPercent,
            resetAt: window.resetsAt.map { Date(timeIntervalSince1970: TimeInterval($0)) },
            durationMinutes: window.windowDurationMins
        )
    }
}

struct AlertKey: Codable, Hashable {
    let windowID: String
    let resetTimestamp: Int
    let threshold: Int
}

struct AlertEvaluator {
    private(set) var previousWindows: [String: DisplayWindow] = [:]
    private(set) var sentAlerts: Set<AlertKey> = []

    mutating func seed(with windows: [DisplayWindow]) {
        previousWindows = Dictionary(uniqueKeysWithValues: windows.map { ($0.id, $0) })
    }

    mutating func alerts(for windows: [DisplayWindow], thresholds: [Int]) -> [DisplayWindow] {
        defer { previousWindows = Dictionary(uniqueKeysWithValues: windows.map { ($0.id, $0) }) }

        var triggered: [DisplayWindow] = []
        for window in windows {
            guard let previous = previousWindows[window.id],
                  let resetAt = window.resetAt else { continue }

            for threshold in thresholds where previous.remainingPercent > threshold && window.remainingPercent <= threshold {
                let key = AlertKey(windowID: window.id, resetTimestamp: Int(resetAt.timeIntervalSince1970), threshold: threshold)
                if sentAlerts.insert(key).inserted {
                    triggered.append(window)
                }
            }
        }
        return triggered
    }
}

enum Thresholds {
    static let defaultText = "50, 25, 10"

    static func parse(_ text: String) -> [Int] {
        Array(Set(text.split(separator: ",").compactMap { part in
            guard let value = Int(part.trimmingCharacters(in: .whitespaces)), (0...100).contains(value) else {
                return nil
            }
            return value
        })).sorted(by: >)
    }
}

enum LimitSummary {
    static func text(for windows: [DisplayWindow], relativeTo referenceDate: Date = Date()) -> String? {
        guard !windows.isEmpty else { return nil }

        let details = windows.map { window in
            var detail = "\(window.label): %\(window.remainingPercent) kaldı"
            if window.resetAt != nil {
                detail += " (\(window.resetDescription(relativeTo: referenceDate)) sıfırlanır)"
            }
            return detail
        }

        return "Codex kullanım özeti — " + details.joined(separator: " • ")
    }
}

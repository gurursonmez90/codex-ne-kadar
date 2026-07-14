import Foundation

enum SelfTest {
    static func run() {
        precondition(Thresholds.parse("25, 101, 50, 25, nope, 10") == [50, 25, 10])

        var evaluator = AlertEvaluator()
        evaluator.seed(with: [window(remaining: 51)])
        precondition(evaluator.alerts(for: [window(remaining: 50)], thresholds: [50, 25]) == [window(remaining: 50)])
        precondition(evaluator.alerts(for: [window(remaining: 49)], thresholds: [50, 25]).isEmpty)
        precondition(evaluator.alerts(for: [window(remaining: 25)], thresholds: [50, 25]) == [window(remaining: 25)])

        var resetEvaluator = AlertEvaluator()
        resetEvaluator.seed(with: [window(remaining: 10, reset: 1_800_000_000)])
        precondition(resetEvaluator.alerts(for: [window(remaining: 10, reset: 1_900_000_000)], thresholds: [10]).isEmpty)

        let reference = Date(timeIntervalSince1970: 1_800_000_000)
        let resetDescription = window(remaining: 80, reset: 1_800_003_600).resetDescription(relativeTo: reference)
        precondition(!resetDescription.isEmpty)

        let summary = LimitSummary.text(
            for: [window(remaining: 80, reset: 1_800_003_600)],
            relativeTo: reference
        )
        precondition(summary == "Codex kullanım özeti — 5 saatlik limit: %80 kaldı (1 saat sonra sıfırlanır)")
        precondition(LimitSummary.text(for: [], relativeTo: reference) == nil)

        print("Core self-test passed")
    }

    private static func window(remaining: Int, reset: TimeInterval = 1_800_000_000) -> DisplayWindow {
        DisplayWindow(
            bucketID: "codex",
            bucketName: nil,
            slot: .primary,
            usedPercent: 100 - remaining,
            resetAt: Date(timeIntervalSince1970: reset),
            durationMinutes: 300
        )
    }
}

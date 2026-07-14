import AppKit
import ServiceManagement
import SwiftUI

private enum AvantPalette {
    static let canvas = Color(red: 0.065, green: 0.071, blue: 0.066)
    static let surface = Color(red: 0.105, green: 0.112, blue: 0.104)
    static let raised = Color(red: 0.145, green: 0.153, blue: 0.141)
    static let ink = Color(red: 0.94, green: 0.95, blue: 0.91)
    static let muted = Color(red: 0.59, green: 0.61, blue: 0.56)
    static let line = Color.white.opacity(0.12)
    static let acid = Color(red: 0.72, green: 0.90, blue: 0.24)
    static let warning = Color(red: 0.98, green: 0.63, blue: 0.19)
    static let danger = Color(red: 0.96, green: 0.31, blue: 0.25)
}

struct SparkIcon: View {
    let color: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                path.move(to: CGPoint(x: w * 0.5, y: h * 0.15))
                path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.85))
                path.move(to: CGPoint(x: w * 0.15, y: h * 0.5))
                path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.5))
                path.move(to: CGPoint(x: w * 0.25, y: h * 0.25))
                path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.75))
                path.move(to: CGPoint(x: w * 0.75, y: h * 0.25))
                path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.75))
            }
            .stroke(color, lineWidth: 1.5)
        }
    }
}

struct UserAvatarIcon: View {
    let color: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                path.addEllipse(in: CGRect(x: w * 0.3, y: h * 0.18, width: w * 0.4, height: h * 0.4))
                path.move(to: CGPoint(x: w * 0.15, y: h * 0.85))
                path.addQuadCurve(to: CGPoint(x: w * 0.85, y: h * 0.85), control: CGPoint(x: w * 0.5, y: h * 0.55))
            }
            .stroke(color, lineWidth: 1.8)
        }
    }
}

struct CoinIcon: View {
    let color: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                path.addEllipse(in: CGRect(x: w * 0.15, y: h * 0.15, width: w * 0.7, height: h * 0.7))
                path.move(to: CGPoint(x: w * 0.5, y: h * 0.3))
                path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.7))
                path.move(to: CGPoint(x: w * 0.38, y: h * 0.42))
                path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.42), control: CGPoint(x: w * 0.44, y: h * 0.34))
                path.addQuadCurve(to: CGPoint(x: w * 0.62, y: h * 0.58), control: CGPoint(x: w * 0.56, y: h * 0.50))
                path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.58), control: CGPoint(x: w * 0.56, y: h * 0.66))
            }
            .stroke(color, lineWidth: 1.5)
        }
    }
}

struct SpeedGaugeIcon: View {
    let color: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                path.addArc(
                    center: CGPoint(x: w * 0.5, y: h * 0.55),
                    radius: w * 0.35,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: false
                )
                path.move(to: CGPoint(x: w * 0.5, y: h * 0.55))
                path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.35))
            }
            .stroke(color, lineWidth: 2)
        }
    }
}

struct GearIcon: View {
    let color: Color
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                let center = CGPoint(x: w * 0.5, y: h * 0.5)
                let rInner = w * 0.2
                let rOuter = w * 0.35
                path.addEllipse(in: CGRect(x: center.x - rInner, y: center.y - rInner, width: rInner*2, height: rInner*2))
                for i in 0..<8 {
                    let angle = Double(i) * .pi / 4.0
                    let nextAngle = angle + .pi / 16.0
                    let p1 = CGPoint(x: center.x + CGFloat(cos(angle)) * rOuter, y: center.y + CGFloat(sin(angle)) * rOuter)
                    let p2 = CGPoint(x: center.x + CGFloat(cos(nextAngle)) * rOuter, y: center.y + CGFloat(sin(nextAngle)) * rOuter)
                    path.move(to: center)
                    path.addLine(to: p1)
                    path.addLine(to: p2)
                }
            }
            .stroke(color, lineWidth: 1.8)
        }
    }
}

struct CircularLimitGauge: View {
    let percent: Int
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(AvantPalette.line, lineWidth: 6)
                .frame(width: 86, height: 86)
            Circle()
                .trim(from: 0.0, to: CGFloat(percent) / 100.0)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.7), color],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 86, height: 86)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.8), value: percent)
            SpeedGaugeIcon(color: color)
                .frame(width: 32, height: 32)
                .offset(y: -2)
        }
        .frame(width: 96, height: 96)
    }
}

@MainActor
final class SettingsWindowManager: NSObject, NSWindowDelegate {
    static let shared = SettingsWindowManager()

    private var window: NSWindow?

    func show(monitor: LimitMonitor) {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView(monitor: monitor)
        let hostingController = NSHostingController(rootView: settingsView)

        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 560),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        newWindow.title = "Codex Ne Kadar - Ayarlar"
        newWindow.contentViewController = hostingController
        newWindow.delegate = self
        newWindow.isReleasedWhenClosed = false
        newWindow.center()

        newWindow.backgroundColor = NSColor(red: 0.065, green: 0.071, blue: 0.066, alpha: 1.0)
        newWindow.titlebarAppearsTransparent = true
        newWindow.titleVisibility = .hidden
        newWindow.styleMask.insert(.fullSizeContentView)

        newWindow.makeKeyAndOrderFront(nil)
        newWindow.makeFirstResponder(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = newWindow
    }

    func windowWillClose(_ notification: Notification) {
        window = nil
    }
}

struct StatusBarLabel: View {
    @ObservedObject var monitor: LimitMonitor

    var body: some View {
        HStack(spacing: 5) {
            CodexMenuBadge()
                .frame(width: 17, height: 17)
                .accessibilityHidden(true)

            Text(monitor.statusBarTitle)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(Color.black)
        }
        .help(monitor.statusBarHelp)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Codex kalan limitleri: \(monitor.statusBarTitle)")
    }
}

private struct CodexMenuBadge: View {
    private let red = Color(red: 0.93, green: 0.12, blue: 0.15)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(red)

            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .stroke(Color.black, lineWidth: 1.25)
                        .frame(width: 10, height: 5)
                        .rotationEffect(.degrees(Double(index) * 60))
                }

                Circle()
                    .fill(Color.black)
                    .frame(width: 2.5, height: 2.5)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(Color.black.opacity(0.75), lineWidth: 0.8)
        }
    }
}

struct LimitPopover: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject var monitor: LimitMonitor
    @State private var refreshRotation = 0.0
    @State private var contentVisible = false
    @State private var copiedSummary = false

    private var lowestRemaining: Int? {
        monitor.windows.map(\.remainingPercent).min()
    }

    private var headlineColor: Color {
        guard let lowestRemaining else { return AvantPalette.muted }
        switch lowestRemaining {
        case ...10: return AvantPalette.danger
        case ...25: return AvantPalette.warning
        default: return AvantPalette.acid
        }
    }

    private var accountCard: some View {
        Group {
            if let email = monitor.accountEmail {
                HStack(spacing: 12) {
                    UserAvatarIcon(color: AvantPalette.muted)
                        .frame(width: 24, height: 24)
                        .padding(6)
                        .background(AvantPalette.raised)
                        .cornerRadius(6)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(email)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AvantPalette.ink)
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            Text(monitor.planType?.uppercased() ?? "FREE")
                                .font(.system(size: 8, weight: .black, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AvantPalette.acid.opacity(0.15))
                                .cornerRadius(3)
                                .foregroundStyle(AvantPalette.acid)

                            if monitor.hasCredits {
                                HStack(spacing: 3) {
                                    CoinIcon(color: AvantPalette.warning)
                                        .frame(width: 10, height: 10)
                                    Text(monitor.creditsUnlimited ? "LİMİTSİZ" : monitor.creditsBalance ?? "0")
                                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                                        .foregroundStyle(AvantPalette.warning)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding(10)
                .background(AvantPalette.surface.opacity(0.5))
                .overlay(Rectangle().stroke(AvantPalette.line, lineWidth: 1))
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
    }

    var body: some View {
        ZStack {
            AvantPalette.canvas.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header
                accountCard
                summary

                Group {
                    if monitor.windows.isEmpty {
                        EmptyLimitState(message: monitor.errorMessage)
                    } else {
                        limitPanels
                    }
                }
                .padding(.top, 14)

                if let errorMessage = monitor.errorMessage, !monitor.windows.isEmpty {
                    InlineError(message: errorMessage)
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                }

                footer
            }
        }
        .frame(width: 382)
        .preferredColorScheme(.dark)
        .task { monitor.start() }
        .onAppear {
            monitor.refresh()
            if reduceMotion {
                contentVisible = true
            } else {
                withAnimation(.easeOut(duration: 0.28)) {
                    contentVisible = true
                }
            }
        }
    }

    @ViewBuilder
    private var limitPanels: some View {
        if monitor.windows.count > 3 {
            ScrollView {
                limitPanelStack
            }
            .frame(height: 320)
        } else {
            limitPanelStack
        }
    }

    private var limitPanelStack: some View {
        VStack(spacing: 8) {
            ForEach(Array(monitor.windows.enumerated()), id: \.element.id) { index, window in
                LimitPanel(window: window, index: index)
                    .opacity(contentVisible ? 1 : 0)
                    .offset(y: contentVisible ? 0 : 8)
                    .animation(
                        reduceMotion ? nil : .easeOut(duration: 0.32).delay(Double(index) * 0.06),
                        value: contentVisible
                    )
            }
        }
        .padding(.horizontal, 16)
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("CODEX / KALAN")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(1.4)
                    .foregroundStyle(AvantPalette.ink)

                Text(monitor.planType?.uppercased() ?? "CANLI LİMİT")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .tracking(1.1)
                    .foregroundStyle(AvantPalette.muted)
            }

            Spacer()

            Button {
                if reduceMotion {
                    refreshRotation = 0
                } else {
                    withAnimation(.easeInOut(duration: 0.45)) {
                        refreshRotation += 360
                    }
                }
                monitor.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AvantPalette.ink)
                    .frame(width: 30, height: 30)
                    .background(AvantPalette.raised)
                    .overlay(Rectangle().stroke(AvantPalette.line, lineWidth: 1))
                    .rotationEffect(.degrees(refreshRotation))
            }
            .buttonStyle(.plain)
            .keyboardShortcut("r", modifiers: .command)
            .help("Şimdi yenile")
            .accessibilityLabel("Limitleri şimdi yenile")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AvantPalette.line)
                .frame(height: 1)
        }
    }

    private var summary: some View {
        HStack(spacing: 16) {
            CircularLimitGauge(percent: lowestRemaining ?? 0, color: headlineColor)
                .padding(.vertical, 8)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    if let lowestRemaining {
                        Text("%\(lowestRemaining)")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(headlineColor)
                    } else {
                        Text("%--")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(AvantPalette.muted)
                    }
                    Text("KALDI")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(AvantPalette.ink)
                }

                Text(summaryCaption)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(headlineColor.opacity(0.12))
                    .cornerRadius(4)
                    .foregroundStyle(headlineColor)

                if let firstLabel = monitor.windows.first?.label {
                    Text(firstLabel.uppercased())
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(AvantPalette.muted)
                        .padding(.top, 2)
                }
            }

            Spacer()

            SparkIcon(color: headlineColor.opacity(0.6))
                .frame(width: 32, height: 32)
                .padding(.trailing, 8)
        }
        .padding(14)
        .background(AvantPalette.surface)
        .overlay(Rectangle().stroke(AvantPalette.line, lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    private var summaryCaption: String {
        guard let lowestRemaining else { return "VERİ BEKLENİYOR" }
        switch lowestRemaining {
        case ...10: return "KRİTİK SEVİYE"
        case ...25: return "SINIRA YAKLAŞIYOR"
        default: return "KULLANIMA HAZIR"
        }
    }

    private var footer: some View {
        HStack(spacing: 10) {
            TimelineView(.periodic(from: .now, by: 30)) { context in
                Text(lastUpdatedText(relativeTo: context.date))
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(AvantPalette.muted)
            }

            Spacer()

            Button {
                copySummary()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: copiedSummary ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 9, weight: .bold))
                    Text(copiedSummary ? "KOPYALANDI" : "KOPYALA")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(copiedSummary ? AvantPalette.acid : AvantPalette.ink)
            }
            .buttonStyle(.plain)
            .disabled(monitor.windows.isEmpty)
            .opacity(monitor.windows.isEmpty ? 0.45 : 1)
            .keyboardShortcut("c", modifiers: [.command, .shift])
            .help("Kişisel bilgi içermeyen limit özetini kopyala")
            .accessibilityLabel(copiedSummary ? "Limit özeti kopyalandı" : "Limit özetini kopyala")

            Button {
                SettingsWindowManager.shared.show(monitor: monitor)
            } label: {
                HStack(spacing: 4) {
                    GearIcon(color: AvantPalette.ink)
                        .frame(width: 11, height: 11)
                    Text("AYARLAR")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(AvantPalette.ink)
                }
            }
            .buttonStyle(.plain)
            .help("Ayarlar")

            Rectangle()
                .fill(AvantPalette.line)
                .frame(width: 1, height: 12)

            Button("ÇIKIŞ") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundStyle(AvantPalette.muted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AvantPalette.line)
                .frame(height: 1)
        }
        .padding(.top, 14)
    }

    private func copySummary() {
        guard let summary = LimitSummary.text(for: monitor.windows) else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(summary, forType: .string)
        copiedSummary = true

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            copiedSummary = false
        }
    }

    private func lastUpdatedText(relativeTo referenceDate: Date) -> String {
        guard let lastUpdated = monitor.lastUpdated else { return "SENKRON BEKLENİYOR" }
        let elapsed = max(0, referenceDate.timeIntervalSince(lastUpdated))
        if elapsed < 60 {
            return "GÜNCEL ŞİMDİ"
        }
        if elapsed < 3_600 {
            return "GÜNCEL \(Int(elapsed / 60)) DK ÖNCE"
        }
        return "GÜNCEL \(lastUpdated.formatted(date: .omitted, time: .shortened))"
    }
}

private struct LimitPanel: View {
    let window: DisplayWindow
    let index: Int

    private var color: Color {
        switch window.remainingPercent {
        case ...10: return AvantPalette.danger
        case ...25: return AvantPalette.warning
        default: return AvantPalette.acid
        }
    }

    private func resetText(relativeTo referenceDate: Date) -> String {
        guard let resetAt = window.resetAt else { return window.resetDescription.uppercased() }
        if resetAt <= referenceDate {
            return "ŞİMDİ YENİLENİYOR"
        }
        return "\(window.resetDescription(relativeTo: referenceDate).uppercased()) SIFIRLANIR"
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            panel(resetText: resetText(relativeTo: context.date))
        }
    }

    private func panel(resetText: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(window.label.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(AvantPalette.ink)
                    Text(resetText)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(AvantPalette.muted)
                        .lineLimit(2)
                }

                Spacer()

                Text("%\(window.remainingPercent)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(color)
            }

            SegmentedLimitBar(value: window.remainingPercent, color: color)
                .frame(height: 8)
        }
        .padding(14)
        .background(index.isMultiple(of: 2) ? AvantPalette.surface : AvantPalette.raised.opacity(0.78))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(color)
                .frame(width: 3)
        }
        .overlay(Rectangle().stroke(AvantPalette.line, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(window.label), yüzde \(window.remainingPercent) kaldı, \(resetText.lowercased())")
    }
}

private struct SegmentedLimitBar: View {
    let value: Int
    let color: Color
    private let segmentCount = 24

    var body: some View {
        GeometryReader { proxy in
            let gap: CGFloat = 2
            let segmentWidth = max(1, (proxy.size.width - CGFloat(segmentCount - 1) * gap) / CGFloat(segmentCount))
            let filledSegments = Int(ceil(Double(value) / 100 * Double(segmentCount)))

            HStack(spacing: gap) {
                ForEach(0..<segmentCount, id: \.self) { segment in
                    Rectangle()
                        .fill(segment < filledSegments ? color : AvantPalette.line)
                        .frame(width: segmentWidth)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

private struct EmptyLimitState: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let message: String?
    @State private var pulse = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { index in
                    Rectangle()
                        .fill(index == 0 ? AvantPalette.acid : AvantPalette.line)
                        .frame(height: 7)
                        .opacity(index == 0 && pulse ? 0.35 : 1)
                }
            }

            Text(message == nil ? "LİMİTLER OKUNUYOR" : "BAĞLANTI KURULAMADI")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(AvantPalette.ink)

            Text(message ?? "Codex hesabındaki güncel kullanım verisi bekleniyor.")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(message == nil ? AvantPalette.muted : AvantPalette.warning)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .leading)
        .background(AvantPalette.surface)
        .overlay(Rectangle().stroke(AvantPalette.line, lineWidth: 1))
        .padding(.horizontal, 16)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

private struct InlineError: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AvantPalette.warning)
            Text(message)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(AvantPalette.warning)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AvantPalette.warning.opacity(0.08))
        .overlay(Rectangle().stroke(AvantPalette.warning.opacity(0.35), lineWidth: 1))
    }
}

struct SettingsView: View {
    @AppStorage("thresholdsText") private var thresholdsText = Thresholds.defaultText
    @AppStorage("alertsEnabled") private var alertsEnabled = false
    @AppStorage("refreshMinutes") private var refreshMinutes = 2
    @AppStorage("launchAtLogin") private var launchAtLogin = true
    @State private var launchError: String?
    @ObservedObject var monitor: LimitMonitor

    var body: some View {
        ZStack {
            AvantPalette.canvas.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AYARLAR")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(AvantPalette.ink)
                        Text("Uyarı eşiği ve senkron ritmi")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(AvantPalette.muted)
                    }

                    SettingsSection(title: "UYARILAR") {
                        Toggle("Sistem bildirimi gönder", isOn: $alertsEnabled)
                            .tint(AvantPalette.acid)
                            .onChange(of: alertsEnabled) { enabled in
                                if enabled { NotificationManager.shared.requestAuthorization() }
                            }

                        VStack(alignment: .leading, spacing: 7) {
                            Text("EŞİKLER")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundStyle(AvantPalette.muted)
                            TextField("50, 25, 10", text: $thresholdsText)
                                .textFieldStyle(.plain)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .padding(10)
                                .background(AvantPalette.canvas)
                                .overlay(Rectangle().stroke(AvantPalette.line, lineWidth: 1))

                            HStack(spacing: 8) {
                                ForEach([50, 25, 10, 5], id: \.self) { pct in
                                    let parsed = Thresholds.parse(thresholdsText)
                                    let isSelected = parsed.contains(pct)
                                    Button {
                                        var current = parsed
                                        if isSelected {
                                            current.removeAll { $0 == pct }
                                        } else {
                                            current.append(pct)
                                        }
                                        current.sort(by: >)
                                        thresholdsText = current.map(String.init).joined(separator: ", ")
                                    } label: {
                                        HStack(spacing: 5) {
                                            ZStack {
                                                Circle()
                                                    .stroke(isSelected ? (pct <= 10 ? AvantPalette.danger : (pct == 25 ? AvantPalette.warning : AvantPalette.acid)) : AvantPalette.line, lineWidth: 1.5)
                                                    .frame(width: 12, height: 12)
                                                if isSelected {
                                                    Circle()
                                                        .fill(pct <= 10 ? AvantPalette.danger : (pct == 25 ? AvantPalette.warning : AvantPalette.acid))
                                                        .frame(width: 6, height: 6)
                                                }
                                            }
                                            Text("%\(pct)")
                                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                .foregroundStyle(isSelected ? AvantPalette.ink : AvantPalette.muted)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(isSelected ? AvantPalette.raised : AvantPalette.canvas)
                                        .overlay(
                                            Rectangle()
                                                .stroke(isSelected ? (pct <= 10 ? AvantPalette.danger : (pct == 25 ? AvantPalette.warning : AvantPalette.acid)) : AvantPalette.line, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 4)

                            Text("Yüzdeleri virgülle ayırın veya yukarıdaki eşik butonlarını kullanın. Her eşik, limit döngüsü başına yalnızca bir kez bildirilir.")
                                .font(.system(size: 10))
                                .foregroundStyle(AvantPalette.muted)
                            if Thresholds.parse(thresholdsText).isEmpty {
                                Text("En az bir 0-100 arası yüzde girin.")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(AvantPalette.danger)
                            }
                        }
                    }

                    SettingsSection(title: "GÜNCELLEME") {
                        Picker("Kontrol sıklığı", selection: $refreshMinutes) {
                            Text("1 dakika").tag(1)
                            Text("2 dakika").tag(2)
                            Text("5 dakika").tag(5)
                            Text("15 dakika").tag(15)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: refreshMinutes) { _ in
                            monitor.restartPolling()
                            monitor.refresh()
                        }
                    }

                    SettingsSection(title: "UYGULAMA") {
                        Toggle("Girişte başlat", isOn: $launchAtLogin)
                            .tint(AvantPalette.acid)
                            .onChange(of: launchAtLogin) { enabled in
                                configureLoginItem(enabled: enabled)
                            }
                        if let launchError {
                            Text(launchError)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(AvantPalette.danger)
                        }
                    }
                }
                .padding(24)
            }
        }
        .frame(width: 460, height: 560)
        .preferredColorScheme(.dark)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private func configureLoginItem(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            launchError = nil
        } catch {
            launchError = "Girişte başlatma ayarlanamadı: \(error.localizedDescription)"
            launchAtLogin = !enabled
        }
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(AvantPalette.acid)
                    .frame(width: 18, height: 3)
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundStyle(AvantPalette.ink)
            }

            VStack(alignment: .leading, spacing: 14) {
                content
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AvantPalette.surface)
            .overlay(Rectangle().stroke(AvantPalette.line, lineWidth: 1))
        }
    }
}

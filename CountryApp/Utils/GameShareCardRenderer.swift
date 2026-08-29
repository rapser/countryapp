//
//  GameShareCardRenderer.swift
//  CountryApp
//

import UIKit

/// Genera una imagen lista para compartir con el resultado de una partida.
struct GameShareCardRenderer {
    let summary: GameSummary
    /// Nombre del modo de juego, p. ej. "Adivina la bandera" o "Adivina la capital".
    let gameModeName: String

    // MARK: - Constants

    private let cardW: CGFloat = 360
    private let cardH: CGFloat = 420
    private let margin: CGFloat = 28
    private let accent = AppColor.primary
    private let ink = AppColor.textPrimary
    private let inkSecondary = AppColor.textSecondary

    // MARK: - Public

    func render() -> UIImage {
        let size = CGSize(width: cardW, height: cardH)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            drawCard(bounds: CGRect(origin: .zero, size: size))
        }
    }

    // MARK: - Card drawing

    private func drawCard(bounds: CGRect) {
        // Fondo claro
        AppColor.background.setFill()
        UIRectFill(bounds)

        // Barra de acento morada arriba
        accent.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: bounds.width, height: 6))

        var y: CGFloat = 24

        // ── Header ─────────────────────────────────────────────
        draw("🌍", at: CGPoint(x: margin, y: y), font: .systemFont(ofSize: 34))
        draw("CountryApp", origin: CGPoint(x: margin + 48, y: y + 2), font: AppFont.rounded(20, .bold), color: ink)
        draw(gameModeName, origin: CGPoint(x: margin + 48, y: y + 28), font: AppFont.rounded(12, .medium), color: inkSecondary)
        y += 72

        separator(at: y, in: bounds)
        y += 24

        // ── Score ───────────────────────────────────────────────
        let total = summary.correctCount + summary.wrongCount + summary.skippedCount
        drawCentered("\(summary.score)", y: y, width: bounds.width, font: AppFont.rounded(46, .heavy), color: accent)
        y += 58
        drawCentered("puntos", y: y, width: bounds.width, font: AppFont.rounded(15, .semibold), color: inkSecondary)
        y += 28
        drawCentered("\(summary.correctCount) / \(total) correctas", y: y, width: bounds.width,
                     font: AppFont.rounded(16, .semibold), color: ink)
        y += 40

        // ── Stat boxes ─────────────────────────────────────────
        drawStatBoxes(y: y, in: bounds)
        y += 96

        // ── Time ────────────────────────────────────────────────
        drawCentered("⏱  \(formatDuration(summary.duration))", y: y, width: bounds.width,
                     font: AppFont.rounded(14, .medium), color: inkSecondary)
        y += 42

        separator(at: y, in: bounds)
        y += 22

        // ── Call to action ──────────────────────────────────────
        drawCentered("¿Puedes superarlo? 🌍", y: y, width: bounds.width,
                     font: AppFont.rounded(16, .bold), color: ink)
    }

    // MARK: - Stat boxes

    private func drawStatBoxes(y: CGFloat, in bounds: CGRect) {
        let items: [(icon: String, value: Int, color: UIColor, label: String)] = [
            ("✓", summary.correctCount, AppColor.feedbackCorrect, "Aciertos"),
            ("✗", summary.wrongCount, AppColor.feedbackWrong, "Fallos"),
            ("⏭", summary.skippedCount, inkSecondary, "Saltadas"),
        ]
        let boxW: CGFloat = 96
        let boxH: CGFloat = 76
        let spacing: CGFloat = 10
        let startX = (bounds.width - (boxW * 3 + spacing * 2)) / 2

        for (i, item) in items.enumerated() {
            let bx = startX + CGFloat(i) * (boxW + spacing)
            let boxRect = CGRect(x: bx, y: y, width: boxW, height: boxH)

            let path = UIBezierPath(roundedRect: boxRect, cornerRadius: 14)
            item.color.withAlphaComponent(0.12).setFill()
            path.fill()

            let valueStr = "\(item.icon)  \(item.value)"
            drawCentered(valueStr, y: y + 10, width: boxW, xOffset: bx, font: AppFont.rounded(20, .bold), color: item.color)
            drawCentered(item.label, y: y + 44, width: boxW, xOffset: bx, font: AppFont.rounded(11, .medium), color: inkSecondary)
        }
    }

    // MARK: - Drawing helpers

    private func drawCentered(_ text: String, y: CGFloat, width: CGFloat, xOffset: CGFloat = 0, font: UIFont, color: UIColor) {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: style,
        ]
        let rect = CGRect(x: xOffset, y: y, width: width, height: 60)
        text.draw(in: rect, withAttributes: attrs)
    }

    private func draw(_ text: String, at point: CGPoint, font: UIFont, color: UIColor = .white) {
        text.draw(at: point, withAttributes: [.font: font, .foregroundColor: color])
    }

    private func draw(_ text: String, origin: CGPoint, font: UIFont, color: UIColor) {
        text.draw(at: origin, withAttributes: [.font: font, .foregroundColor: color])
    }

    private func separator(at y: CGFloat, in bounds: CGRect) {
        AppColor.divider.setFill()
        UIRectFill(CGRect(x: margin, y: y, width: bounds.width - margin * 2, height: 1))
    }

    // MARK: - Helpers

    private func formatDuration(_ t: TimeInterval) -> String {
        let total = max(0, Int(t.rounded()))
        let m = total / 60
        let s = total % 60
        if m == 0 { return "\(s) s" }
        return String(format: "%d min %02d s", m, s)
    }
}

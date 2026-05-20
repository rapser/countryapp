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
    private let accent = UIColor(red: 0.95, green: 0.80, blue: 0.22, alpha: 1)

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
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        // Background gradient
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bgColors = [
            UIColor(red: 0.02, green: 0.05, blue: 0.22, alpha: 1).cgColor,
            UIColor(red: 0.04, green: 0.14, blue: 0.40, alpha: 1).cgColor,
        ] as CFArray
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0, 1]) {
            ctx.drawLinearGradient(
                gradient,
                start: CGPoint(x: bounds.midX, y: 0),
                end: CGPoint(x: bounds.midX, y: bounds.maxY),
                options: []
            )
        }

        // Yellow accent bar at top
        accent.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: bounds.width, height: 5))

        let cx = bounds.midX
        var y: CGFloat = 22

        // ── Header ─────────────────────────────────────────────
        draw("🌍", at: CGPoint(x: margin, y: y), font: .systemFont(ofSize: 34))
        draw(
            "CountryApp",
            origin: CGPoint(x: margin + 48, y: y + 2),
            font: .boldSystemFont(ofSize: 20),
            color: .white
        )
        draw(
            gameModeName,
            origin: CGPoint(x: margin + 48, y: y + 26),
            font: .systemFont(ofSize: 12, weight: .medium),
            color: UIColor(white: 1, alpha: 0.60)
        )
        y += 70

        separator(at: y, in: bounds)
        y += 22

        // ── Score ───────────────────────────────────────────────
        let total = summary.correctCount + summary.wrongCount + summary.skippedCount
        let headline = "\(summary.correctCount) / \(total) correctas"
        drawCentered(headline, y: y, width: bounds.width, font: .boldSystemFont(ofSize: 38), color: accent)
        y += 54

        let scoreSubline = "★ \(summary.score) puntos"
        drawCentered(scoreSubline, y: y, width: bounds.width, font: .systemFont(ofSize: 16, weight: .semibold), color: UIColor(white: 1, alpha: 0.75))
        y += 38

        // ── Stat boxes ─────────────────────────────────────────
        drawStatBoxes(y: y, in: bounds)
        y += 96

        // ── Time ────────────────────────────────────────────────
        drawCentered(
            "⏱  \(formatDuration(summary.duration))",
            y: y,
            width: bounds.width,
            font: .systemFont(ofSize: 14, weight: .medium),
            color: UIColor(white: 1, alpha: 0.75)
        )
        y += 42

        separator(at: y, in: bounds)
        y += 20

        // ── Call to action ──────────────────────────────────────
        drawCentered(
            "¿Puedes superarlo? 🌍",
            y: y,
            width: bounds.width,
            font: .boldSystemFont(ofSize: 16),
            color: .white
        )
    }

    // MARK: - Stat boxes

    private func drawStatBoxes(y: CGFloat, in bounds: CGRect) {
        let items: [(icon: String, value: Int, color: UIColor, label: String)] = [
            ("✓", summary.correctCount, UIColor(red: 0.20, green: 0.72, blue: 0.36, alpha: 1), "Aciertos"),
            ("✗", summary.wrongCount,   UIColor(red: 0.85, green: 0.26, blue: 0.22, alpha: 1), "Fallos"),
            ("⏭", summary.skippedCount, UIColor(white: 1, alpha: 0.55),                        "Saltadas"),
        ]
        let boxW: CGFloat = 96
        let boxH: CGFloat = 76
        let spacing: CGFloat = 10
        let startX = (bounds.width - (boxW * 3 + spacing * 2)) / 2

        for (i, item) in items.enumerated() {
            let bx = startX + CGFloat(i) * (boxW + spacing)
            let boxRect = CGRect(x: bx, y: y, width: boxW, height: boxH)

            let path = UIBezierPath(roundedRect: boxRect, cornerRadius: 14)
            UIColor(white: 1, alpha: 0.08).setFill()
            path.fill()

            // Thin border
            UIColor(white: 1, alpha: 0.12).setStroke()
            path.lineWidth = 1
            path.stroke()

            let valueStr = "\(item.icon)  \(item.value)"
            drawCentered(valueStr, y: y + 10, width: boxW, xOffset: bx, font: .boldSystemFont(ofSize: 20), color: item.color)
            drawCentered(item.label, y: y + 44, width: boxW, xOffset: bx, font: .systemFont(ofSize: 11, weight: .medium), color: UIColor(white: 1, alpha: 0.50))
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
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
        ]
        text.draw(at: point, withAttributes: attrs)
    }

    private func draw(_ text: String, origin: CGPoint, font: UIFont, color: UIColor) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
        ]
        text.draw(at: origin, withAttributes: attrs)
    }

    private func separator(at y: CGFloat, in bounds: CGRect) {
        UIColor(white: 1, alpha: 0.14).setFill()
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

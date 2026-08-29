//
//  SummaryCardFactory.swift
//  CountryApp
//
//  Tarjetas del resumen de partida, compartidas por FlagGame y CapitalGame.
//

import UIKit

enum SummaryCardFactory {

    /// Tarjeta destacada con la puntuación total de la ronda.
    static func heroScoreCard(summary: GameSummary) -> UIView {
        let card = CardView(fillColor: AppColor.primary)

        let scoreLabel = UILabel()
        scoreLabel.text = "\(summary.score)"
        scoreLabel.font = AppFont.score
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center

        let unitLabel = UILabel()
        unitLabel.text = "puntos"
        unitLabel.font = AppFont.caption
        unitLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        unitLabel.textAlignment = .center

        let total = summary.correctCount + summary.wrongCount + summary.skippedCount
        let detailLabel = UILabel()
        detailLabel.text = "\(summary.correctCount)/\(total) correctas · \(formatDuration(summary.duration))"
        detailLabel.font = AppFont.bodyBold
        detailLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [scoreLabel, unitLabel, detailLabel])
        stack.axis = .vertical
        stack.spacing = AppMetrics.spacing1
        stack.setCustomSpacing(AppMetrics.spacing3, after: unitLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: AppMetrics.spacing6, left: AppMetrics.spacing5,
                                           bottom: AppMetrics.spacing6, right: AppMetrics.spacing5)

        card.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor)
        ])
        return card
    }

    /// Tarjeta de sección con barra de acento y lista de banderas (o estado vacío).
    static func sectionCard(title: String, subtitle: String?, accentColor: UIColor, rows: [SummaryFlagRow]) -> UIView {
        let card = CardView()

        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = accentColor
        bar.layer.cornerRadius = 2

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.headline
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.numberOfLines = 0

        let headerRow = UIStackView(arrangedSubviews: [bar, titleLabel])
        headerRow.axis = .horizontal
        headerRow.spacing = AppMetrics.spacing3
        headerRow.alignment = .center
        NSLayoutConstraint.activate([
            bar.widthAnchor.constraint(equalToConstant: 4),
            bar.heightAnchor.constraint(equalToConstant: 22)
        ])

        let outer = UIStackView(arrangedSubviews: [headerRow])
        outer.axis = .vertical
        outer.spacing = AppMetrics.spacing3
        outer.alignment = .fill
        outer.translatesAutoresizingMaskIntoConstraints = false
        outer.isLayoutMarginsRelativeArrangement = true
        outer.layoutMargins = UIEdgeInsets(top: AppMetrics.spacing4, left: AppMetrics.spacing4,
                                           bottom: AppMetrics.spacing4, right: AppMetrics.spacing4)

        if let subtitle {
            let sub = UILabel()
            sub.text = subtitle
            sub.font = AppFont.caption
            sub.textColor = AppColor.textSecondary
            sub.numberOfLines = 0
            outer.addArrangedSubview(sub)
        }

        if rows.isEmpty {
            let empty = UILabel()
            empty.text = "Ninguno en esta partida."
            empty.textColor = AppColor.textSecondary
            empty.font = AppFont.body
            outer.addArrangedSubview(empty)
        } else {
            let rowsStack = UIStackView()
            rowsStack.axis = .vertical
            rowsStack.spacing = AppMetrics.spacing3
            for row in rows {
                rowsStack.addArrangedSubview(flagRow(row))
            }
            outer.addArrangedSubview(rowsStack)
        }

        card.contentView.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            outer.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor),
            outer.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor)
        ])
        return card
    }

    private static func flagRow(_ row: SummaryFlagRow) -> UIStackView {
        let flag = UIImageView(image: UIImage(named: row.flagAssetCode))
        flag.contentMode = .scaleAspectFit
        flag.clipsToBounds = true
        flag.layer.cornerRadius = 6
        flag.layer.borderWidth = 1
        flag.layer.borderColor = AppColor.divider.cgColor
        flag.backgroundColor = AppColor.divider
        flag.accessibilityLabel = "Bandera de \(row.countryName)"
        flag.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            flag.widthAnchor.constraint(equalToConstant: 80),
            flag.heightAnchor.constraint(equalToConstant: 52)
        ])

        let name = UILabel()
        name.text = row.countryName
        name.font = AppFont.body
        name.textColor = AppColor.textPrimary
        name.numberOfLines = 0
        name.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let h = UIStackView(arrangedSubviews: [flag, name])
        h.axis = .horizontal
        h.spacing = AppMetrics.spacing3
        h.alignment = .center
        h.distribution = .fill
        return h
    }

    static func formatDuration(_ t: TimeInterval) -> String {
        let total = max(0, Int(t.rounded()))
        let m = total / 60
        let s = total % 60
        if m == 0 { return "\(s) s" }
        return String(format: "%d min %02d s", m, s)
    }
}

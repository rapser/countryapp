//
//  StatTilesView.swift
//  CountryApp
//
//  Fila de métricas (valor grande + etiqueta) dentro de una tarjeta. Historial y Perfil.
//

import UIKit

final class StatTilesView: UIView {
    struct Tile {
        let value: String
        let label: String
    }

    private let card = CardView()
    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center

        addSubview(card)
        card.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: AppMetrics.spacing4),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -AppMetrics.spacing4),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: AppMetrics.spacing2),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -AppMetrics.spacing2)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ tiles: [Tile]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tile in tiles {
            let value = UILabel()
            value.text = tile.value
            value.font = AppFont.rounded(22, .heavy, relativeTo: .title2)
            value.textColor = AppColor.primary
            value.textAlignment = .center
            value.adjustsFontSizeToFitWidth = true
            value.minimumScaleFactor = 0.6

            let label = UILabel()
            label.text = tile.label
            label.font = AppFont.caption
            label.textColor = AppColor.textSecondary
            label.textAlignment = .center

            let column = UIStackView(arrangedSubviews: [value, label])
            column.axis = .vertical
            column.spacing = 2
            column.isAccessibilityElement = true
            column.accessibilityLabel = "\(tile.label): \(tile.value)"
            stack.addArrangedSubview(column)
        }
    }
}

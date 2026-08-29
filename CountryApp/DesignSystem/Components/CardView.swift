//
//  CardView.swift
//  CountryApp
//
//  Superficie blanca redondeada con sombra suave. Dos capas para que la sombra no se recorte:
//  la vista externa dibuja la sombra, `contentView` recorta el contenido.
//

import UIKit

final class CardView: UIView {

    /// Contenedor para los hijos de la tarjeta.
    let contentView = UIView()

    /// Radio de las esquinas del contenido.
    var cornerRadius: CGFloat = AppMetrics.cardRadius {
        didSet { contentView.layer.cornerRadius = cornerRadius; setNeedsLayout() }
    }

    init(fillColor: UIColor = AppColor.surface) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        layer.shadowColor = AppMetrics.Shadow.color.cgColor
        layer.shadowOpacity = AppMetrics.Shadow.opacity
        layer.shadowRadius = AppMetrics.Shadow.radius
        layer.shadowOffset = AppMetrics.Shadow.offset

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = fillColor
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.shadowColor = AppMetrics.Shadow.color.cgColor
    }
}

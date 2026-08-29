//
//  PillButton.swift
//  CountryApp
//
//  Botón principal en forma de cápsula. Reemplaza los factories de `UIButton.Configuration`
//  duplicados en instrucciones / quiz / resumen.
//

import UIKit

final class PillButton: UIButton {

    enum Style {
        /// Relleno morado, texto blanco.
        case primary
        /// Fondo claro con borde morado, texto morado.
        case secondary
    }

    private let style: Style

    init(title: String, style: Style = .primary) {
        self.style = style
        super.init(frame: .zero)
        configure(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.85 : 1 }
    }

    private func configure(title: String) {
        translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.filled()
        config.title = title
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = AppFont.button
            return outgoing
        }

        switch style {
        case .primary:
            config.baseBackgroundColor = AppColor.primary
            config.baseForegroundColor = AppColor.textOnPrimary
        case .secondary:
            config.baseBackgroundColor = AppColor.surface
            config.baseForegroundColor = AppColor.primary
            config.background.strokeColor = AppColor.primary
            config.background.strokeWidth = 1.5
        }

        configuration = config
        heightAnchor.constraint(greaterThanOrEqualToConstant: AppMetrics.controlMinHeight).isActive = true
    }

    func setTitleText(_ title: String) {
        configuration?.title = title
    }
}

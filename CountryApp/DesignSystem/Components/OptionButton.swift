//
//  OptionButton.swift
//  CountryApp
//
//  Botón de opción de respuesta con identidad multicolor fija (tipo Kahoot) y estados de revelado.
//  Encapsula la lógica de recoloreado que antes estaba duplicada en los quiz view controllers.
//

import UIKit

final class OptionButton: UIButton {

    enum OptionState {
        /// Sin tocar: color de su índice.
        case idle
        /// Seleccionada sin confirmar: anillo blanco.
        case selected
        /// Revelado: era la correcta.
        case revealedCorrect
        /// Revelado: la elegí y era incorrecta.
        case revealedWrong
        /// Revelado: no relevante, se atenúa.
        case dimmed
    }

    /// Índice 0...3 que fija el color base de la opción.
    let colorIndex: Int
    private(set) var optionState: OptionState = .idle

    init(title: String, colorIndex: Int) {
        self.colorIndex = colorIndex
        super.init(frame: .zero)
        configure(title: title)
        setState(.idle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var baseColor: UIColor { AppColor.option(at: colorIndex) }

    private func configure(title: String) {
        translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.filled()
        config.title = title
        config.titleLineBreakMode = .byWordWrapping
        config.titleAlignment = .center
        config.baseForegroundColor = .white
        config.background.cornerRadius = AppMetrics.optionRadius
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        config.imagePadding = 10
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = AppFont.bodyBold
            return outgoing
        }
        configuration = config

        layer.cornerRadius = AppMetrics.optionRadius
        layer.borderColor = UIColor.white.cgColor
        layer.shadowColor = AppColor.primary.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        heightAnchor.constraint(greaterThanOrEqualToConstant: AppMetrics.optionMinHeight).isActive = true
        accessibilityTraits = .button
    }

    func setState(_ newState: OptionState) {
        optionState = newState
        guard var config = configuration else { return }

        alpha = 1
        layer.borderWidth = 0
        layer.shadowOpacity = 0
        transform = .identity
        config.image = nil

        switch newState {
        case .idle:
            config.baseBackgroundColor = baseColor
            accessibilityValue = nil
        case .selected:
            config.baseBackgroundColor = baseColor
            config.image = UIImage(
                systemName: "checkmark.circle.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
            )
            config.imagePlacement = .leading
            layer.borderWidth = 4
            layer.shadowOpacity = 0.35
            layer.shadowRadius = 10
            transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
            accessibilityValue = "seleccionado"
        case .revealedCorrect:
            config.baseBackgroundColor = AppColor.feedbackCorrect
            config.image = UIImage(systemName: "checkmark.circle.fill")
            config.imagePlacement = .trailing
            accessibilityValue = "correcto"
        case .revealedWrong:
            config.baseBackgroundColor = AppColor.feedbackWrong
            config.image = UIImage(systemName: "xmark.circle.fill")
            config.imagePlacement = .trailing
            accessibilityValue = "incorrecto"
        case .dimmed:
            config.baseBackgroundColor = baseColor
            alpha = 0.4
            accessibilityValue = nil
        }

        configuration = config
    }
}

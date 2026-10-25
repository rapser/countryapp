//
//  FormTextField.swift
//  CountryApp
//
//  Campo de texto con etiqueta, para los formularios de login, registro y perfil.
//

import UIKit

final class FormTextField: UIView {

    enum Kind {
        case text
        case name
        case nickname
        case email
        case newPassword
        case password
    }

    let textField = PaddedTextField()
    private let titleLabel = UILabel()

    var text: String {
        get { textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
        set { textField.text = newValue }
    }

    init(title: String, placeholder: String, kind: Kind = .text) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = AppFont.caption
        titleLabel.textColor = AppColor.textSecondary

        textField.placeholder = placeholder
        textField.font = AppFont.body
        textField.textColor = AppColor.textPrimary
        textField.backgroundColor = AppColor.surface
        textField.layer.cornerRadius = AppMetrics.buttonRadius
        textField.layer.cornerCurve = .continuous
        textField.layer.borderWidth = 1
        textField.layer.borderColor = AppColor.divider.cgColor
        textField.clearButtonMode = .whileEditing
        textField.heightAnchor.constraint(greaterThanOrEqualToConstant: AppMetrics.controlMinHeight).isActive = true
        apply(kind)

        let stack = UIStackView(arrangedSubviews: [titleLabel, textField])
        stack.axis = .vertical
        stack.spacing = AppMetrics.spacing1
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func apply(_ kind: Kind) {
        switch kind {
        case .text:
            break
        case .name:
            textField.textContentType = .name
            textField.autocapitalizationType = .words
        case .nickname:
            textField.textContentType = .username
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        case .email:
            textField.textContentType = .emailAddress
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        case .newPassword:
            textField.textContentType = .newPassword
            textField.isSecureTextEntry = true
        case .password:
            textField.textContentType = .password
            textField.isSecureTextEntry = true
        }
    }
}

/// UITextField con margen interno horizontal.
final class PaddedTextField: UITextField {
    private let inset = UIEdgeInsets(top: 0, left: AppMetrics.spacing4, bottom: 0, right: AppMetrics.spacing3)

    override func textRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: inset) }
    override func editingRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: inset) }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: inset) }
}

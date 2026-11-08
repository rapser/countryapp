//
//  EmptyStateView.swift
//  CountryApp
//
//  Ícono + título + mensaje + botón opcional, para listas vacías, invitado o errores.
//

import UIKit

final class EmptyStateView: UIView {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = PillButton(title: "", style: .primary)
    private var action: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        iconView.tintColor = AppColor.primary
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 52, weight: .semibold)

        titleLabel.font = AppFont.title
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.font = AppFont.body
        messageLabel.textColor = AppColor.textSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, messageLabel, actionButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = AppMetrics.spacing3
        stack.alignment = .fill
        stack.setCustomSpacing(AppMetrics.spacing6, after: messageLabel)
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppMetrics.spacing8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppMetrics.spacing8),
            stack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: AppMetrics.spacing4),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -AppMetrics.spacing4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(symbol: String, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        iconView.image = UIImage(systemName: symbol)
        titleLabel.text = title
        messageLabel.text = message
        self.action = action
        if let actionTitle {
            actionButton.setTitleText(actionTitle)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }

    @objc private func actionTapped() {
        action?()
    }
}

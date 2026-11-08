//
//  ScoreStatusCardView.swift
//  CountryApp
//
//  Tarjeta del resumen que indica si la partida se guardó en el ranking.
//

import UIKit

final class ScoreStatusCardView: UIView {
    var onLoginTapped: (() -> Void)?

    private let card = CardView()
    private let iconView = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let loginButton = PillButton(title: "Iniciar sesión", style: .primary)

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(_ status: ScoreSubmissionStatus) {
        isHidden = status == .hidden
        loginButton.isHidden = true
        spinner.stopAnimating()
        iconView.isHidden = false

        switch status {
        case .hidden:
            break
        case .saving:
            iconView.isHidden = true
            spinner.startAnimating()
            titleLabel.text = "Guardando partida…"
            subtitleLabel.text = nil
        case .saved(let rank):
            setIcon("checkmark.seal.fill", color: AppColor.feedbackCorrect)
            titleLabel.text = "Puntaje guardado"
            subtitleLabel.text = rank.map { "Vas #\($0) en el ranking" } ?? "Ya cuenta para el ranking"
        case .requiresLogin(let points):
            setIcon("trophy.fill", color: AppColor.optionOrange)
            titleLabel.text = "Guarda tus \(points) puntos"
            subtitleLabel.text = "Inicia sesión para entrar al ranking y llevar tu historial."
            loginButton.isHidden = false
        case .offline:
            setIcon("icloud.slash.fill", color: AppColor.textSecondary)
            titleLabel.text = "Sin conexión"
            subtitleLabel.text = "Guardamos tu partida y la enviaremos cuando vuelvas a tener red."
        }
        subtitleLabel.isHidden = subtitleLabel.text == nil
    }

    private func setIcon(_ name: String, color: UIColor) {
        iconView.image = UIImage(systemName: name)
        iconView.tintColor = color
    }

    private func setupLayout() {
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        spinner.hidesWhenStopped = true

        titleLabel.font = AppFont.headline
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.numberOfLines = 0
        subtitleLabel.font = AppFont.caption
        subtitleLabel.textColor = AppColor.textSecondary
        subtitleLabel.numberOfLines = 0

        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labels.axis = .vertical
        labels.spacing = AppMetrics.spacing1

        let row = UIStackView(arrangedSubviews: [iconView, spinner, labels])
        row.axis = .horizontal
        row.spacing = AppMetrics.spacing3
        row.alignment = .center

        let stack = UIStackView(arrangedSubviews: [row, loginButton])
        stack.axis = .vertical
        stack.spacing = AppMetrics.spacing3
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(card)
        card.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: AppMetrics.spacing4),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: AppMetrics.spacing4),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -AppMetrics.spacing4),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -AppMetrics.spacing4)
        ])
        apply(.hidden)
    }

    @objc private func loginTapped() {
        onLoginTapped?()
    }
}

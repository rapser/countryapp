//
//  QuizHeaderView.swift
//  CountryApp
//
//  Cabecera del quiz: contador "3 / 20" + título + botón "···", y una barra de progreso propia
//  (redondeada, con color de marca) en lugar de `UIProgressView`.
//

import UIKit

final class QuizHeaderView: UIView {

    /// Se dispara al pulsar el botón "···".
    var onMenuTapped: (() -> Void)?

    private let countLabel = UILabel()
    private let titleLabel = UILabel()
    private let menuButton = UIButton(type: .system)
    private let track = UIView()
    private let fill = UIView()
    private var fillWidthConstraint: NSLayoutConstraint?
    private var fraction: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        translatesAutoresizingMaskIntoConstraints = false

        countLabel.font = AppFont.caption
        countLabel.textColor = AppColor.textSecondary
        countLabel.setContentHuggingPriority(.required, for: .horizontal)

        titleLabel.font = AppFont.headline
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8

        var menuConfig = UIButton.Configuration.plain()
        menuConfig.image = UIImage(systemName: "ellipsis")
        menuConfig.baseForegroundColor = AppColor.textSecondary
        menuConfig.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        menuButton.configuration = menuConfig
        menuButton.setContentHuggingPriority(.required, for: .horizontal)
        menuButton.accessibilityLabel = "Opciones de la partida"
        menuButton.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)

        let row = UIStackView(arrangedSubviews: [countLabel, titleLabel, menuButton])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = AppMetrics.spacing2
        row.translatesAutoresizingMaskIntoConstraints = false

        track.translatesAutoresizingMaskIntoConstraints = false
        track.backgroundColor = AppColor.divider
        track.layer.cornerRadius = 4
        track.clipsToBounds = true

        fill.translatesAutoresizingMaskIntoConstraints = false
        fill.backgroundColor = AppColor.primary
        fill.layer.cornerRadius = 4
        track.addSubview(fill)

        addSubview(row)
        addSubview(track)

        let fw = fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: 0)
        fillWidthConstraint = fw

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),

            track.topAnchor.constraint(equalTo: row.bottomAnchor, constant: AppMetrics.spacing3),
            track.leadingAnchor.constraint(equalTo: leadingAnchor),
            track.trailingAnchor.constraint(equalTo: trailingAnchor),
            track.heightAnchor.constraint(equalToConstant: 8),
            track.bottomAnchor.constraint(equalTo: bottomAnchor),

            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fw
        ])
    }

    // MARK: - API

    func configure(title: String) {
        titleLabel.text = title
    }

    func setCount(_ text: String) {
        countLabel.text = text
    }

    func setProgress(_ fraction: CGFloat, animated: Bool) {
        let clamped = max(0, min(1, fraction))
        self.fraction = clamped

        fillWidthConstraint?.isActive = false
        let newConstraint = fill.widthAnchor.constraint(
            equalTo: track.widthAnchor,
            multiplier: max(clamped, 0.001)
        )
        newConstraint.isActive = true
        fillWidthConstraint = newConstraint

        let apply = { self.layoutIfNeeded() }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: apply)
        } else {
            apply()
        }
    }

    @objc private func menuTapped() {
        onMenuTapped?()
    }
}

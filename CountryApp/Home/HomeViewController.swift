//
//  HomeViewController.swift
//  CountryApp
//

import UIKit

final class HomeViewController: UIViewController, HomeViewProtocol {
    private let presenter: HomePresenterProtocol
    var interactor: HomeInteractorProtocol?

    private var gradientLayer: CAGradientLayer?

    private let headerTitleLabel = UILabel()
    private let headerSubtitleLabel = UILabel()
    private let statusRow = UIStackView()
    private let statusSpinner = UIActivityIndicatorView(style: .medium)
    private let statusLabel = UILabel()

    private let cardsStack = UIStackView()
    private let rootStack = UIStackView()

    init(presenter: HomePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CountryApp"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground

        configureUI()

        Task { [weak self] in
            await self?.bootstrap()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }

    private func configureUI() {
        if gradientLayer == nil {
            let g = CAGradientLayer()
            g.colors = [
                UIColor(red: 0.98, green: 0.99, blue: 1.00, alpha: 1).cgColor,
                UIColor(red: 0.93, green: 0.96, blue: 1.00, alpha: 1).cgColor,
                UIColor(red: 0.90, green: 0.94, blue: 0.99, alpha: 1).cgColor,
            ]
            g.locations = [0, 0.45, 1]
            g.startPoint = CGPoint(x: 0.2, y: 0)
            g.endPoint = CGPoint(x: 0.9, y: 1)
            view.layer.insertSublayer(g, at: 0)
            gradientLayer = g
        }

        headerTitleLabel.text = "¿Qué quieres practicar hoy?"
        headerTitleLabel.font = .preferredFont(forTextStyle: .title2)
        headerTitleLabel.textColor = .label
        headerTitleLabel.numberOfLines = 0

        headerSubtitleLabel.text = "Elige un modo y te preparo una ronda rápida de 20 preguntas."
        headerSubtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        headerSubtitleLabel.textColor = .secondaryLabel
        headerSubtitleLabel.numberOfLines = 0

        statusRow.axis = .horizontal
        statusRow.spacing = 10
        statusRow.alignment = .center
        statusRow.translatesAutoresizingMaskIntoConstraints = false

        statusSpinner.hidesWhenStopped = true
        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 2
        statusLabel.text = "Listo para empezar."

        statusRow.addArrangedSubview(statusSpinner)
        statusRow.addArrangedSubview(statusLabel)

        cardsStack.axis = .vertical
        cardsStack.spacing = 12
        cardsStack.alignment = .fill
        cardsStack.translatesAutoresizingMaskIntoConstraints = false

        cardsStack.addArrangedSubview(
            makeCard(
                symbol: "list.bullet.rectangle.portrait",
                title: "Explorar países",
                subtitle: "Busca y revisa información: capital, región, fronteras y mapa.",
                action: #selector(tapList)
            )
        )
        cardsStack.addArrangedSubview(
            makeCard(
                symbol: "flag.checkered.2.crossed",
                title: "Adivinar banderas",
                subtitle: "Ves la bandera y eliges el país correcto (con resumen por dudas).",
                action: #selector(tapGame)
            )
        )
        cardsStack.addArrangedSubview(
            makeCard(
                symbol: "building.columns",
                title: "Adivinar capitales",
                subtitle: "Ves la bandera y el país; eliges la capital correcta.",
                action: #selector(tapCapitalGame)
            )
        )

        rootStack.axis = .vertical
        rootStack.spacing = 18
        rootStack.alignment = .fill
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        rootStack.isLayoutMarginsRelativeArrangement = true
        rootStack.layoutMargins = UIEdgeInsets(top: 22, left: 16, bottom: 22, right: 16)

        rootStack.addArrangedSubview(headerTitleLabel)
        rootStack.addArrangedSubview(headerSubtitleLabel)
        rootStack.addArrangedSubview(statusRow)
        rootStack.addArrangedSubview(cardsStack)

        view.addSubview(rootStack)

        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func makeCard(symbol: String, title: String, subtitle: String, action: Selector) -> UIControl {
        let card = UIControl()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 16
        card.layer.cornerCurve = .continuous
        // UIControl no tiene tamaño intrínseco: una altura mínima evita que el stack lo colapse a 0.
        card.heightAnchor.constraint(greaterThanOrEqualToConstant: 92).isActive = true
        card.setContentHuggingPriority(.required, for: .vertical)
        card.setContentCompressionResistancePriority(.required, for: .vertical)

        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 6)

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .systemBlue
        icon.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labels.axis = .vertical
        labels.spacing = 4
        labels.alignment = .fill
        labels.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = .tertiaryLabel

        let h = UIStackView(arrangedSubviews: [icon, labels, chevron])
        h.axis = .horizontal
        h.spacing = 12
        h.alignment = .center
        h.translatesAutoresizingMaskIntoConstraints = false
        h.isUserInteractionEnabled = false

        card.addSubview(h)
        NSLayoutConstraint.activate([
            h.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            h.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            h.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            h.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            icon.widthAnchor.constraint(equalToConstant: 36),
            icon.heightAnchor.constraint(equalToConstant: 36),

            chevron.widthAnchor.constraint(equalToConstant: 12),
        ])

        card.addTarget(self, action: action, for: .touchUpInside)
        card.accessibilityTraits = .button
        card.accessibilityLabel = "\(title). \(subtitle)"
        return card
    }

    private func bootstrap() async {
        await MainActor.run {
            statusSpinner.startAnimating()
            statusLabel.text = "Actualizando países…"
            cardsStack.isUserInteractionEnabled = false
            cardsStack.alpha = 0.75
        }

        await interactor?.bootstrapCountriesIfNeeded()

        await MainActor.run {
            statusSpinner.stopAnimating()
            statusLabel.text = "Listo para empezar."
            cardsStack.isUserInteractionEnabled = true
            cardsStack.alpha = 1
        }
    }

    @objc private func tapList() {
        presenter.didTapCountryList(from: self)
    }

    @objc private func tapGame() {
        presenter.didTapFlagGame(from: self)
    }

    @objc private func tapCapitalGame() {
        presenter.didTapCapitalGame(from: self)
    }
}

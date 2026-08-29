//
//  HomeViewController.swift
//  CountryApp
//

import UIKit

final class HomeViewController: UIViewController, HomeViewProtocol {
    private let presenter: HomePresenterProtocol
    var interactor: HomeInteractorProtocol?

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
        view.backgroundColor = AppColor.background

        configureUI()

        Task { [weak self] in
            await self?.bootstrap()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationController.applyLightAppTheme(to: navigationController)
    }

    private func configureUI() {
        headerTitleLabel.text = "¿Qué quieres practicar hoy?"
        headerTitleLabel.font = AppFont.title
        headerTitleLabel.textColor = AppColor.textPrimary
        headerTitleLabel.numberOfLines = 0

        headerSubtitleLabel.text = "Elige un modo y te preparo una ronda rápida de 20 preguntas."
        headerSubtitleLabel.font = AppFont.body
        headerSubtitleLabel.textColor = AppColor.textSecondary
        headerSubtitleLabel.numberOfLines = 0

        statusRow.axis = .horizontal
        statusRow.spacing = AppMetrics.spacing2
        statusRow.alignment = .center
        statusRow.translatesAutoresizingMaskIntoConstraints = false

        statusSpinner.hidesWhenStopped = true
        statusSpinner.color = AppColor.primary
        statusLabel.font = AppFont.caption
        statusLabel.textColor = AppColor.textSecondary
        statusLabel.numberOfLines = 2
        statusLabel.text = "Listo para empezar."

        statusRow.addArrangedSubview(statusSpinner)
        statusRow.addArrangedSubview(statusLabel)

        cardsStack.axis = .vertical
        cardsStack.spacing = AppMetrics.spacing3
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
        rootStack.spacing = AppMetrics.spacing5
        rootStack.alignment = .fill
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        rootStack.isLayoutMarginsRelativeArrangement = true
        rootStack.layoutMargins = UIEdgeInsets(top: AppMetrics.spacing6, left: AppMetrics.screenMargin,
                                               bottom: AppMetrics.spacing6, right: AppMetrics.screenMargin)

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
        let card = CardControl()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true
        card.setContentHuggingPriority(.required, for: .vertical)
        card.setContentCompressionResistancePriority(.required, for: .vertical)

        let iconBackground = UIView()
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.backgroundColor = AppColor.primary.withAlphaComponent(0.12)
        iconBackground.layer.cornerRadius = 12
        iconBackground.layer.cornerCurve = .continuous

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = AppColor.primary
        icon.contentMode = .scaleAspectFit
        iconBackground.addSubview(icon)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.headline
        titleLabel.textColor = AppColor.textPrimary
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = AppFont.caption
        subtitleLabel.textColor = AppColor.textSecondary
        subtitleLabel.numberOfLines = 0

        let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labels.axis = .vertical
        labels.spacing = AppMetrics.spacing1
        labels.alignment = .fill
        labels.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = AppColor.primary

        let h = UIStackView(arrangedSubviews: [iconBackground, labels, chevron])
        h.axis = .horizontal
        h.spacing = AppMetrics.spacing3
        h.alignment = .center
        h.translatesAutoresizingMaskIntoConstraints = false
        h.isUserInteractionEnabled = false

        card.contentView.addSubview(h)
        NSLayoutConstraint.activate([
            h.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: AppMetrics.spacing4),
            h.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: AppMetrics.spacing4),
            h.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -AppMetrics.spacing4),
            h.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -AppMetrics.spacing4),

            iconBackground.widthAnchor.constraint(equalToConstant: 44),
            iconBackground.heightAnchor.constraint(equalToConstant: 44),
            icon.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),

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

/// `UIControl` con la misma superficie/sombra que `CardView` para las tarjetas tocables del Home.
private final class CardControl: UIControl {
    let contentView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        layer.shadowColor = AppMetrics.Shadow.color.cgColor
        layer.shadowOpacity = AppMetrics.Shadow.opacity
        layer.shadowRadius = AppMetrics.Shadow.radius
        layer.shadowOffset = AppMetrics.Shadow.offset

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = AppColor.surface
        contentView.layer.cornerRadius = AppMetrics.cardRadius
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        contentView.isUserInteractionEnabled = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: AppMetrics.cardRadius).cgPath
    }

    override var isHighlighted: Bool {
        didSet { contentView.alpha = isHighlighted ? 0.7 : 1 }
    }
}

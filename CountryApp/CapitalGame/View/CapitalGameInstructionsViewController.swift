//
//  CapitalGameInstructionsViewController.swift
//  CountryApp
//

import UIKit

protocol CapitalGameInstructionsViewProtocol: AnyObject {}

final class CapitalGameInstructionsViewController: UIViewController, CapitalGameInstructionsViewProtocol {
    private let presenter: CapitalGameInstructionsPresenterProtocol

    private let scrollView = UIScrollView()
    private let bodyStack = UIStackView()
    private let card = CardView()
    private let playButton = PillButton(title: "Bueno, a jugar", style: .primary)

    init(presenter: CapitalGameInstructionsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Adivina la capital"
        view.backgroundColor = AppColor.background

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        bodyStack.axis = .vertical
        bodyStack.spacing = AppMetrics.spacing4
        bodyStack.translatesAutoresizingMaskIntoConstraints = false

        let intro = makeLabel(
            text: """
            Responde \(FlagGameRound.questionsPerRound) preguntas viendo la bandera y el país.

            • Cada pregunta tiene 4 opciones de capitales.
            • Elige una opción y pulsa «Confirmar» para registrar tu respuesta.
            • Aciertas más puntos cuanto más rápido respondes.
            • El resumen te dirá qué banderas repasar y qué acertaste con dudas (más de \(Int(FlagGameTiming.doubtAnswerThresholdSeconds)) s).
            """
        )

        let cardStack = UIStackView(arrangedSubviews: [intro])
        cardStack.axis = .vertical
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardStack.isLayoutMarginsRelativeArrangement = true
        cardStack.layoutMargins = UIEdgeInsets(
            top: AppMetrics.spacing5, left: AppMetrics.spacing5,
            bottom: AppMetrics.spacing5, right: AppMetrics.spacing5
        )
        card.contentView.addSubview(cardStack)
        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            cardStack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            cardStack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor),
            cardStack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor)
        ])

        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

        bodyStack.addArrangedSubview(card)
        bodyStack.addArrangedSubview(playButton)

        scrollView.addSubview(bodyStack)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            bodyStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: AppMetrics.spacing5),
            bodyStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: AppMetrics.screenMargin),
            bodyStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -AppMetrics.screenMargin),
            bodyStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -AppMetrics.spacing6)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationController.applyLightAppTheme(to: navigationController)
    }

    private func makeLabel(text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.textColor = AppColor.textPrimary
        l.font = AppFont.body
        l.numberOfLines = 0
        return l
    }

    @objc private func playTapped() {
        presenter.didTapPlay(from: self)
    }
}

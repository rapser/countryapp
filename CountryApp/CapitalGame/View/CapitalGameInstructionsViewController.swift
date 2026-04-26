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
    private let playButton = UIButton(type: .system)

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
        view.backgroundColor = UIColor(red: 0.04, green: 0.08, blue: 0.22, alpha: 1)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        bodyStack.axis = .vertical
        bodyStack.spacing = 14
        bodyStack.translatesAutoresizingMaskIntoConstraints = false

        let intro = makeLabel(
            text: """
            Responde \(FlagGameRound.questionsPerRound) preguntas viendo la bandera y el país.

            • Cada pregunta tiene 4 opciones de capitales.
            • Elige una opción y pulsa «Siguiente» para confirmar.
            • El resumen te dirá qué banderas repasar y qué acertaste con dudas (más de \(Int(FlagGameTiming.doubtAnswerThresholdSeconds)) s).
            """,
            style: .body
        )

        playButton.configuration = Self.playButtonConfiguration()
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

        bodyStack.addArrangedSubview(intro)
        bodyStack.addArrangedSubview(playButton)

        scrollView.addSubview(bodyStack)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            bodyStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            bodyStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            bodyStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            bodyStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Pantalla oscura: nav en blanco para legibilidad (aquí es donde aterrizas desde Home).
        guard let navBar = navigationController?.navigationBar else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.tintColor = .white
    }

    private static func playButtonConfiguration() -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = "Bueno, a jugar"
        config.baseForegroundColor = .black
        config.baseBackgroundColor = UIColor(red: 0.75, green: 0.55, blue: 0.12, alpha: 1)
        config.background.cornerRadius = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .boldSystemFont(ofSize: 18)
            return outgoing
        }
        return config
    }

    private func makeLabel(text: String, style: UIFont.TextStyle) -> UILabel {
        let l = UILabel()
        l.text = text
        l.textColor = .white
        l.font = .preferredFont(forTextStyle: style)
        l.numberOfLines = 0
        return l
    }

    @objc private func playTapped() {
        presenter.didTapPlay(from: self)
    }
}


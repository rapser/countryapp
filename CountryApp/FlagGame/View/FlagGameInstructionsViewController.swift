//
//  FlagGameInstructionsViewController.swift
//  CountryApp
//

import UIKit

protocol FlagGameInstructionsViewProtocol: AnyObject {
    /// Deshabilita el botón de jugar mientras se prepara la ronda (solo SwiftData, sin red).
    func setPrepareInProgress(_ inProgress: Bool)
    func showError(message: String)
}

final class FlagGameInstructionsViewController: UIViewController, FlagGameInstructionsViewProtocol {
    private let presenter: FlagGameInstructionsPresenterProtocol
    private let scrollView = UIScrollView()
    private let bodyStack = UIStackView()
    private let playButton = UIButton(type: .system)

    init(presenter: FlagGameInstructionsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Adivina la bandera"
        view.backgroundColor = UIColor(red: 0.04, green: 0.08, blue: 0.22, alpha: 1)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        bodyStack.axis = .vertical
        bodyStack.spacing = 14
        bodyStack.translatesAutoresizingMaskIntoConstraints = false

        let intro = makeLabel(
            text: """
            Responde 30 preguntas viendo la bandera en pantalla.

            • Cada pregunta tiene 4 nombres de países en orden aleatorio.
            • Elige una opción y pulsa «Siguiente» para confirmar.
            • Puedes terminar antes: el resumen usará lo respondido hasta ese momento.

            Puntuación: +10 por acierto, −5 por error.
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
            bodyStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
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

    func setPrepareInProgress(_ inProgress: Bool) {
        playButton.isEnabled = !inProgress
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "No se pudo preparar el juego", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

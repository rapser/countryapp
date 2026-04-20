//
//  FlagGameQuizViewController.swift
//  CountryApp
//

import UIKit

protocol FlagGameQuizViewProtocol: AnyObject {
    func configureQuizChrome()
    func showQuestion(flagAssetCode: String, options: [String], progress: String)
    func setOptionsEnabled(_ enabled: Bool)
    func setFinalAnswerEnabled(_ enabled: Bool)
    func highlightSelectedOption(index: Int)
    func revealAnswer(selectedIndex: Int, correctIndex: Int, isCorrect: Bool)
    func clearAnswerHighlight()
}

final class FlagGameQuizViewController: UIViewController, FlagGameQuizViewProtocol {
    private let presenter: FlagGameQuizPresenterProtocol
    /// Referencia directa al router del juego: «Terminar partida» debe mostrar el resumen aunque falle otra ruta del presenter.
    private let gameRouter: FlagGameRouterProtocol
    private var gradientLayer: CAGradientLayer?

    private let progressLabel = UILabel()
    private let flagContainer = UIView()
    private let flagImageView = UIImageView()
    private let optionsStack = UIStackView()
    private var optionButtons: [UIButton] = []
    private let finalAnswerButton = UIButton(type: .system)
    private let finishButton = UIButton(type: .system)

    init(presenter: FlagGameQuizPresenterProtocol, gameRouter: FlagGameRouterProtocol) {
        self.presenter = presenter
        self.gameRouter = gameRouter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "¿De qué país es?"
        navigationItem.largeTitleDisplayMode = .never

        progressLabel.textColor = .white
        progressLabel.font = .monospacedDigitSystemFont(ofSize: 16, weight: .semibold)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false

        flagContainer.backgroundColor = UIColor(red: 0.03, green: 0.12, blue: 0.35, alpha: 1)
        flagContainer.layer.cornerRadius = 12
        flagContainer.layer.borderWidth = 2
        flagContainer.layer.borderColor = UIColor(white: 1, alpha: 0.22).cgColor
        flagContainer.translatesAutoresizingMaskIntoConstraints = false

        flagImageView.contentMode = .scaleAspectFit
        flagImageView.clipsToBounds = true
        flagImageView.translatesAutoresizingMaskIntoConstraints = false
        flagContainer.addSubview(flagImageView)

        optionsStack.axis = .vertical
        optionsStack.spacing = 10
        optionsStack.translatesAutoresizingMaskIntoConstraints = false

        finalAnswerButton.configuration = Self.primaryButtonConfiguration(
            title: "Siguiente",
            font: .systemFont(ofSize: 18, weight: .bold)
        )
        finalAnswerButton.isEnabled = false
        finalAnswerButton.addTarget(self, action: #selector(finalAnswerTapped), for: .touchUpInside)

        finishButton.configuration = Self.secondaryButtonConfiguration(
            title: "Terminar partida",
            font: .systemFont(ofSize: 16, weight: .semibold)
        )
        finishButton.addTarget(self, action: #selector(finishTapped), for: .touchUpInside)

        let bottomStack = UIStackView(arrangedSubviews: [finalAnswerButton, finishButton])
        bottomStack.axis = .vertical
        bottomStack.spacing = 10
        bottomStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(progressLabel)
        view.addSubview(flagContainer)
        view.addSubview(optionsStack)
        view.addSubview(bottomStack)

        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            flagContainer.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 16),
            flagContainer.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            flagContainer.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            flagContainer.heightAnchor.constraint(equalToConstant: 220),

            flagImageView.topAnchor.constraint(equalTo: flagContainer.topAnchor, constant: 8),
            flagImageView.bottomAnchor.constraint(equalTo: flagContainer.bottomAnchor, constant: -8),
            flagImageView.leadingAnchor.constraint(equalTo: flagContainer.leadingAnchor, constant: 12),
            flagImageView.trailingAnchor.constraint(equalTo: flagContainer.trailingAnchor, constant: -12),

            optionsStack.topAnchor.constraint(equalTo: flagContainer.bottomAnchor, constant: 20),
            optionsStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            optionsStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            bottomStack.topAnchor.constraint(equalTo: optionsStack.bottomAnchor, constant: 20),
            bottomStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            bottomStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear(from: self)
    }

    func configureQuizChrome() {
        if gradientLayer == nil {
            let g = CAGradientLayer()
            g.colors = [
                UIColor(red: 0.01, green: 0.04, blue: 0.20, alpha: 1).cgColor,
                UIColor(red: 0.03, green: 0.10, blue: 0.35, alpha: 1).cgColor,
                UIColor(red: 0.01, green: 0.03, blue: 0.16, alpha: 1).cgColor
            ]
            g.locations = [0, 0.5, 1]
            g.startPoint = CGPoint(x: 0.2, y: 0)
            g.endPoint = CGPoint(x: 0.8, y: 1)
            view.layer.insertSublayer(g, at: 0)
            gradientLayer = g
        }
        gradientLayer?.frame = view.bounds
    }

    func showQuestion(flagAssetCode: String, options: [String], progress: String) {
        progressLabel.text = "Pregunta \(progress)"
        flagImageView.image = UIImage(named: flagAssetCode)

        optionButtons.forEach { $0.removeFromSuperview() }
        optionButtons.removeAll()
        optionsStack.arrangedSubviews.forEach { optionsStack.removeArrangedSubview($0); $0.removeFromSuperview() }

        for (i, title) in options.enumerated() {
            let b = makeOptionButton(title: title, tag: i)
            optionButtons.append(b)
            optionsStack.addArrangedSubview(b)
        }
    }

    private func makeOptionButton(title: String, tag: Int) -> UIButton {
        let b = UIButton(type: .system)
        b.tag = tag
        b.configuration = Self.optionButtonConfiguration(title: title)
        b.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        return b
    }

    private static func optionButtonConfiguration(title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.titleLineBreakMode = .byWordWrapping
        config.titleAlignment = .center
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(red: 0.06, green: 0.20, blue: 0.52, alpha: 1)
        config.background.cornerRadius = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 12, bottom: 14, trailing: 12)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        return config
    }

    private static func secondaryButtonConfiguration(title: String, font: UIFont) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(red: 0.03, green: 0.12, blue: 0.35, alpha: 1)
        config.background.cornerRadius = 12
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
        return config
    }

    private static func primaryButtonConfiguration(title: String, font: UIFont) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = .black
        // Mostaza / amarillo tipo concurso
        config.baseBackgroundColor = UIColor(red: 0.95, green: 0.80, blue: 0.22, alpha: 1)
        config.background.cornerRadius = 12
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
        return config
    }

    private func applyOptionColors(button: UIButton, background: UIColor, foreground: UIColor) {
        guard var config = button.configuration else { return }
        config.baseBackgroundColor = background
        config.baseForegroundColor = foreground
        button.configuration = config
    }

    @objc private func optionTapped(_ sender: UIButton) {
        presenter.didSelectOption(index: sender.tag, from: self)
    }

    @objc private func finalAnswerTapped() {
        presenter.didTapFinalAnswer(from: self)
    }

    @objc private func finishTapped() {
        AppLog.trace("FlagGameQuizVC Terminar partida → pushSummary")
        gameRouter.pushSummary(from: self)
    }

    func setOptionsEnabled(_ enabled: Bool) {
        optionButtons.forEach { $0.isEnabled = enabled }
        finishButton.isEnabled = enabled
    }

    func setFinalAnswerEnabled(_ enabled: Bool) {
        finalAnswerButton.isEnabled = enabled
    }

    func highlightSelectedOption(index: Int) {
        let normalBlue = UIColor(red: 0.06, green: 0.20, blue: 0.52, alpha: 1)
        let selectGreen = UIColor(red: 0.2, green: 0.65, blue: 0.3, alpha: 1)
        for (i, b) in optionButtons.enumerated() {
            if i == index {
                applyOptionColors(button: b, background: selectGreen, foreground: .white)
            } else {
                applyOptionColors(button: b, background: normalBlue, foreground: .white)
            }
        }
    }

    func revealAnswer(selectedIndex: Int, correctIndex: Int, isCorrect: Bool) {
        let green = UIColor(red: 0.2, green: 0.65, blue: 0.3, alpha: 1)
        let red = UIColor(red: 0.75, green: 0.15, blue: 0.12, alpha: 1)
        for (i, b) in optionButtons.enumerated() {
            if i == correctIndex {
                applyOptionColors(button: b, background: green, foreground: .white)
            } else if i == selectedIndex && !isCorrect {
                applyOptionColors(button: b, background: red, foreground: .white)
            }
        }
    }

    func clearAnswerHighlight() {
        let normalBlue = UIColor(red: 0.06, green: 0.20, blue: 0.52, alpha: 1)
        for b in optionButtons {
            applyOptionColors(button: b, background: normalBlue, foreground: .white)
        }
    }
}

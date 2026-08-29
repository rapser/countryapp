//
//  CapitalGameQuizViewController.swift
//  CountryApp
//

import UIKit

final class CapitalGameQuizViewController: UIViewController, CapitalGameQuizViewProtocol {
    private let presenter: CapitalGameQuizPresenterProtocol
    private let gameRouter: CapitalGameRouterProtocol

    private let header = QuizHeaderView()
    private let flagCard = CardView()
    private let flagImageView = UIImageView()
    private let countryLabel = UILabel()
    private let optionsStack = UIStackView()
    private var optionButtons: [OptionButton] = []
    private let finalAnswerButton = PillButton(title: "Confirmar", style: .primary)
    private var highlightedIndex: Int?

    init(presenter: CapitalGameQuizPresenterProtocol, gameRouter: CapitalGameRouterProtocol) {
        self.presenter = presenter
        self.gameRouter = gameRouter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = AppColor.background

        header.configure(title: "¿Cuál es la capital?")
        header.translatesAutoresizingMaskIntoConstraints = false
        header.onMenuTapped = { [weak self] in self?.finishTapped() }

        flagImageView.contentMode = .scaleAspectFit
        flagImageView.clipsToBounds = true
        flagImageView.translatesAutoresizingMaskIntoConstraints = false
        flagCard.contentView.addSubview(flagImageView)

        countryLabel.textColor = AppColor.textPrimary
        countryLabel.font = AppFont.headline
        countryLabel.numberOfLines = 0
        countryLabel.textAlignment = .center
        countryLabel.translatesAutoresizingMaskIntoConstraints = false

        optionsStack.axis = .vertical
        optionsStack.spacing = AppMetrics.spacing3
        optionsStack.translatesAutoresizingMaskIntoConstraints = false

        finalAnswerButton.isEnabled = false
        finalAnswerButton.addTarget(self, action: #selector(finalAnswerTapped), for: .touchUpInside)

        view.addSubview(header)
        view.addSubview(flagCard)
        view.addSubview(countryLabel)
        view.addSubview(optionsStack)
        view.addSubview(finalAnswerButton)

        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppMetrics.spacing3),
            header.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: margins.trailingAnchor),

            flagCard.topAnchor.constraint(equalTo: header.bottomAnchor, constant: AppMetrics.spacing5),
            flagCard.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            flagCard.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            flagCard.heightAnchor.constraint(equalToConstant: 200),

            flagImageView.topAnchor.constraint(equalTo: flagCard.contentView.topAnchor, constant: AppMetrics.spacing3),
            flagImageView.bottomAnchor.constraint(equalTo: flagCard.contentView.bottomAnchor, constant: -AppMetrics.spacing3),
            flagImageView.leadingAnchor.constraint(equalTo: flagCard.contentView.leadingAnchor, constant: AppMetrics.spacing4),
            flagImageView.trailingAnchor.constraint(equalTo: flagCard.contentView.trailingAnchor, constant: -AppMetrics.spacing4),

            countryLabel.topAnchor.constraint(equalTo: flagCard.bottomAnchor, constant: AppMetrics.spacing3),
            countryLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            countryLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),

            optionsStack.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: AppMetrics.spacing4),
            optionsStack.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            optionsStack.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            optionsStack.bottomAnchor.constraint(lessThanOrEqualTo: finalAnswerButton.topAnchor, constant: -AppMetrics.spacing5),

            finalAnswerButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            finalAnswerButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            finalAnswerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -AppMetrics.spacing4)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationController.applyLightAppTheme(to: navigationController)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear(from: self)
    }

    func showQuestion(flagAssetCode: String, countryName: String, options: [String], progress: String) {
        header.setCount(progress)
        flagImageView.image = UIImage(named: flagAssetCode)
        countryLabel.text = countryName

        highlightedIndex = nil
        optionButtons.forEach { $0.removeFromSuperview() }
        optionButtons.removeAll()
        optionsStack.arrangedSubviews.forEach { optionsStack.removeArrangedSubview($0); $0.removeFromSuperview() }

        for (i, title) in options.enumerated() {
            let b = OptionButton(title: title, colorIndex: i)
            b.tag = i
            b.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            optionButtons.append(b)
            optionsStack.addArrangedSubview(b)
        }
    }

    func setProgress(fraction: Float) {
        header.setProgress(CGFloat(fraction), animated: true)
    }

    func setOptionsEnabled(_ enabled: Bool) {
        optionButtons.forEach { $0.isEnabled = enabled }
    }

    func setFinalAnswerEnabled(_ enabled: Bool) {
        finalAnswerButton.isEnabled = enabled
    }

    func highlightSelectedOption(index: Int) {
        guard index >= 0, index < optionButtons.count, highlightedIndex != index else { return }
        highlightedIndex = index
        UIView.animate(withDuration: 0.15) {
            for (i, button) in self.optionButtons.enumerated() {
                button.setState(i == index ? .selected : .dimmed)
                button.layoutIfNeeded()
            }
        }
    }

    func presentFeedback(_ result: QuizFeedbackResult, onContinue: @escaping () -> Void) {
        let feedback = QuizFeedbackViewController(result: result) { [weak self] in
            self?.dismiss(animated: true) { onContinue() }
        }
        present(feedback, animated: true)
    }

    @objc private func optionTapped(_ sender: UIButton) {
        presenter.didSelectOption(index: sender.tag, from: self)
    }

    @objc private func finalAnswerTapped() {
        presenter.didTapFinalAnswer(from: self)
    }

    private func finishTapped() {
        let alert = UIAlertController(
            title: "¿Terminar partida?",
            message: "Se mostrará el resumen con lo respondido hasta ahora.",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Terminar", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.gameRouter.pushSummary(from: self)
        })
        present(alert, animated: true)
    }
}

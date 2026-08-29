//
//  QuizFeedbackViewController.swift
//  CountryApp
//
//  Pantalla de resultado a pantalla completa tras confirmar una respuesta.
//  Cabecera a sangre (verde/roja) con badge de puntos, bandera + pregunta + respuestas, y
//  un botón pill para continuar. Se presenta modal (`.fullScreen`, `.crossDissolve`) desde el quiz.
//

import UIKit

final class QuizFeedbackViewController: UIViewController {

    private let result: QuizFeedbackResult
    private let onContinue: () -> Void

    private let pointsBadgeLabel = UILabel()

    init(result: QuizFeedbackResult, onContinue: @escaping () -> Void) {
        self.result = result
        self.onContinue = onContinue
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        view.accessibilityViewIsModal = true
        buildLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        announceResult()
        animatePointsCountUp()
    }

    // MARK: - Layout

    private func buildLayout() {
        let accent = result.isCorrect ? AppColor.feedbackCorrect : AppColor.feedbackWrong

        // Cabecera a sangre completa.
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = accent

        let resultLabel = UILabel()
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.text = result.isCorrect ? "¡Correcto!" : "¡Incorrecto!"
        resultLabel.font = AppFont.largeTitle
        resultLabel.textColor = .white
        resultLabel.textAlignment = .center

        let badge = UIView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = .white
        badge.layer.cornerRadius = 22
        badge.layer.cornerCurve = .continuous

        pointsBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        pointsBadgeLabel.text = "+\(result.awardedPoints)"
        pointsBadgeLabel.font = AppFont.scoreBadge
        pointsBadgeLabel.textColor = accent
        badge.addSubview(pointsBadgeLabel)

        header.addSubview(resultLabel)
        header.addSubview(badge)

        // Contenido inferior.
        let flagCard = CardView()
        let flagImageView = UIImageView(image: UIImage(named: result.flagAssetCode))
        flagImageView.translatesAutoresizingMaskIntoConstraints = false
        flagImageView.contentMode = .scaleAspectFit
        flagImageView.accessibilityLabel = "Bandera de \(result.correctAnswer)"
        flagCard.contentView.addSubview(flagImageView)
        NSLayoutConstraint.activate([
            flagImageView.topAnchor.constraint(equalTo: flagCard.contentView.topAnchor, constant: AppMetrics.spacing3),
            flagImageView.bottomAnchor.constraint(equalTo: flagCard.contentView.bottomAnchor, constant: -AppMetrics.spacing3),
            flagImageView.leadingAnchor.constraint(equalTo: flagCard.contentView.leadingAnchor, constant: AppMetrics.spacing4),
            flagImageView.trailingAnchor.constraint(equalTo: flagCard.contentView.trailingAnchor, constant: -AppMetrics.spacing4),
            flagImageView.heightAnchor.constraint(equalToConstant: 150)
        ])

        let promptLabel = UILabel()
        promptLabel.text = result.questionPrompt
        promptLabel.font = AppFont.headline
        promptLabel.textColor = AppColor.textPrimary
        promptLabel.numberOfLines = 0
        promptLabel.textAlignment = .center

        let answerStack = UIStackView()
        answerStack.axis = .vertical
        answerStack.spacing = AppMetrics.spacing1
        answerStack.alignment = .center
        answerStack.addArrangedSubview(
            makeAnswerLine(caption: "Tu respuesta", value: result.yourAnswer,
                           color: result.isCorrect ? AppColor.feedbackCorrect : AppColor.feedbackWrong)
        )
        if !result.isCorrect {
            answerStack.addArrangedSubview(
                makeAnswerLine(caption: "Respuesta correcta", value: result.correctAnswer,
                               color: AppColor.feedbackCorrect)
            )
        }

        let continueButton = PillButton(
            title: result.isLastQuestion ? "Ver resumen" : "Siguiente",
            style: .primary
        )
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        let contentStack = UIStackView(arrangedSubviews: [flagCard, promptLabel, answerStack])
        contentStack.axis = .vertical
        contentStack.spacing = AppMetrics.spacing5
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(header)
        view.addSubview(contentStack)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            resultLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppMetrics.spacing6),
            resultLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: AppMetrics.spacing5),
            resultLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -AppMetrics.spacing5),

            badge.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: AppMetrics.spacing4),
            badge.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            badge.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -AppMetrics.spacing6),
            badge.heightAnchor.constraint(equalToConstant: 44),

            pointsBadgeLabel.topAnchor.constraint(equalTo: badge.topAnchor, constant: 2),
            pointsBadgeLabel.bottomAnchor.constraint(equalTo: badge.bottomAnchor, constant: -2),
            pointsBadgeLabel.leadingAnchor.constraint(equalTo: badge.leadingAnchor, constant: AppMetrics.spacing5),
            pointsBadgeLabel.trailingAnchor.constraint(equalTo: badge.trailingAnchor, constant: -AppMetrics.spacing5),

            contentStack.topAnchor.constraint(greaterThanOrEqualTo: header.bottomAnchor, constant: AppMetrics.spacing6),
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: AppMetrics.spacing8),
            contentStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            continueButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -AppMetrics.spacing4)
        ])
    }

    private func makeAnswerLine(caption: String, value: String, color: UIColor) -> UIView {
        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = AppFont.caption
        captionLabel.textColor = AppColor.textSecondary
        captionLabel.textAlignment = .center

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = AppFont.bodyBold
        valueLabel.textColor = color
        valueLabel.numberOfLines = 0
        valueLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [captionLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        return stack
    }

    // MARK: - Actions

    @objc private func continueTapped() {
        onContinue()
    }

    // MARK: - Effects

    private func announceResult() {
        let verdict = result.isCorrect ? "Correcto" : "Incorrecto"
        UIAccessibility.post(
            notification: .screenChanged,
            argument: "\(verdict). \(result.awardedPoints) puntos. Total \(result.totalPoints)."
        )
    }

    private func animatePointsCountUp() {
        guard result.awardedPoints > 0, !UIAccessibility.isReduceMotionEnabled else { return }
        let target = result.awardedPoints
        let steps = 12
        let stepDuration = 0.4 / Double(steps)
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) { [weak self] in
                let value = Int(Double(target) * Double(step) / Double(steps))
                self?.pointsBadgeLabel.text = "+\(value)"
            }
        }
    }
}

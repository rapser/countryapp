//
//  FlagGameQuizPresenter.swift
//  CountryApp
//

import OSLog
import UIKit

protocol FlagGameQuizPresenterProtocol: AnyObject {
    func viewDidAppear(from viewController: UIViewController)
    /// Solo selecciona una opción (no avanza).
    func didSelectOption(index: Int, from viewController: UIViewController)
    /// Confirma la selección; muestra el feedback a pantalla completa y avanza al continuar.
    func didTapFinalAnswer(from viewController: UIViewController)
    func didTapFinish(from viewController: UIViewController)
}

final class FlagGameQuizPresenter: FlagGameQuizPresenterProtocol {
    private static let log = Logger(subsystem: "CountryApp", category: "FlagGameQuiz")

    weak var view: FlagGameQuizViewProtocol?
    /// Strong like instructions: the router is not owned by the nav stack; weak would drop it if the instructions screen is released while the quiz is visible.
    var router: FlagGameRouterProtocol?
    private let interactor: FlagGameInteractorProtocol
    private var didRecordStart = false
    /// La primera pregunta se muestra desde `viewDidAppear`; las siguientes solo al continuar
    /// desde el feedback, para que el `viewDidAppear` que dispara el cierre del modal no reentre.
    private var didPresentFirstQuestion = false
    /// Evita empujar el resumen dos veces (cierre del modal + reaparición del quiz).
    private var isNavigatingToSummary = false
    private var selectedIndex: Int?
    private var questionShownAt: Date?

    init(interactor: FlagGameInteractorProtocol, router: FlagGameRouterProtocol?) {
        self.interactor = interactor
        self.router = router
    }

    private static func trace(_ message: String) {
        AppLog.trace("FlagGameQuiz \(message)")
        Self.log.info("\(message, privacy: .public)")
    }

    func viewDidAppear(from viewController: UIViewController) {
        Self.trace("viewDidAppear nav=\(viewController.navigationController != nil) presenting=\(viewController.presentingViewController != nil)")
        if !didRecordStart {
            interactor.recordQuizStarted()
            didRecordStart = true
        }
        guard !didPresentFirstQuestion else {
            Self.trace("viewDidAppear: reaparición (cierre de feedback), ignorada")
            return
        }
        didPresentFirstQuestion = true
        presentCurrent(from: viewController)
    }

    private func presentCurrent(from viewController: UIViewController) {
        guard let q = interactor.currentQuestion() else {
            Self.trace("presentCurrent: no hay pregunta actual → intento pushSummary router=\(router != nil)")
            goToSummary(from: viewController)
            return
        }
        selectedIndex = nil
        questionShownAt = Date()
        view?.showQuestion(flagAssetCode: q.flagAssetCode, options: q.options, progress: interactor.currentProgressText())
        view?.setProgress(fraction: interactor.currentProgressFraction())
        view?.setOptionsEnabled(true)
        view?.setFinalAnswerEnabled(false)
    }

    func didSelectOption(index: Int, from viewController: UIViewController) {
        guard interactor.currentQuestion() != nil else {
            Self.trace("didSelectOption(\(index)): currentQuestion nil, ignorado")
            return
        }
        selectedIndex = index
        view?.highlightSelectedOption(index: index)
        view?.setFinalAnswerEnabled(true)
        Self.trace("didSelectOption(\(index)) seleccionado (sin confirmar)")
    }

    func didTapFinalAnswer(from viewController: UIViewController) {
        guard let selectedIndex else {
            Self.trace("didTapFinalAnswer: sin selección, ignorado")
            return
        }
        guard let q = interactor.currentQuestion() else {
            Self.trace("didTapFinalAnswer: currentQuestion nil, ignorado")
            return
        }

        view?.setOptionsEnabled(false)
        view?.setFinalAnswerEnabled(false)

        let elapsed = questionShownAt.map { Date().timeIntervalSince($0) } ?? 0
        let yourAnswer = q.options[selectedIndex]
        let correctAnswer = q.options[q.correctIndex]
        let isCorrect = interactor.submitAnswer(optionIndex: selectedIndex, responseTime: elapsed)
        let result = QuizFeedbackResult(
            isCorrect: isCorrect,
            awardedPoints: interactor.lastAwardedPoints,
            totalPoints: interactor.totalScore,
            flagAssetCode: q.flagAssetCode,
            questionPrompt: "¿De qué país es esta bandera?",
            yourAnswer: yourAnswer,
            correctAnswer: correctAnswer,
            isLastQuestion: !interactor.hasMoreQuestions
        )
        Self.trace("Respuesta final=\(selectedIndex) correct=\(isCorrect) pts=\(interactor.lastAwardedPoints) total=\(interactor.totalScore) hasMore=\(interactor.hasMoreQuestions)")

        view?.presentFeedback(result) { [weak self, weak viewController] in
            guard let self, let vc = viewController else { return }
            if self.interactor.hasMoreQuestions {
                self.presentCurrent(from: vc)
            } else {
                self.goToSummary(from: vc)
            }
        }
    }

    func didTapFinish(from viewController: UIViewController) {
        Self.trace("didTapFinish → pushSummary router=\(router != nil) nav=\(viewController.navigationController != nil)")
        goToSummary(from: viewController)
    }

    private func goToSummary(from viewController: UIViewController) {
        guard !isNavigatingToSummary else {
            Self.trace("goToSummary: ya en curso, ignorado")
            return
        }
        if router == nil {
            Self.trace("goToSummary: ABORT router es nil")
        }
        isNavigatingToSummary = true
        router?.pushSummary(from: viewController)
    }
}

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
    /// Confirma la selección y avanza directo a la siguiente pregunta (o al resumen si era la última).
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
    /// La primera pregunta se muestra desde `viewDidAppear`; evita reentradas si se vuelve a llamar.
    private var didPresentFirstQuestion = false
    /// Evita empujar el resumen más de una vez (p.ej. doble tap en "Terminar partida").
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
        guard interactor.currentQuestion() != nil else {
            Self.trace("didTapFinalAnswer: currentQuestion nil, ignorado")
            return
        }

        view?.setOptionsEnabled(false)
        view?.setFinalAnswerEnabled(false)

        let elapsed = questionShownAt.map { Date().timeIntervalSince($0) } ?? 0
        let isCorrect = interactor.submitAnswer(optionIndex: selectedIndex, responseTime: elapsed)
        Self.trace("Respuesta final=\(selectedIndex) correct=\(isCorrect) pts=\(interactor.lastAwardedPoints) total=\(interactor.totalScore) hasMore=\(interactor.hasMoreQuestions)")

        if interactor.hasMoreQuestions {
            presentCurrent(from: viewController)
        } else {
            goToSummary(from: viewController)
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

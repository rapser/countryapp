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
    /// Confirma la selección (Respuesta final) y avanza.
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
    private var selectedIndex: Int?

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
        presentCurrent(from: viewController)
    }

    private func presentCurrent(from viewController: UIViewController) {
        guard let q = interactor.currentQuestion() else {
            Self.trace("presentCurrent: no hay pregunta actual → intento pushSummary router=\(router != nil)")
            if router == nil {
                Self.trace("presentCurrent: ABORT router es nil, no se puede mostrar resumen")
            }
            router?.pushSummary(from: viewController)
            return
        }
        selectedIndex = nil
        view?.configureQuizChrome()
        view?.showQuestion(flagAssetCode: q.flagAssetCode, options: q.options, progress: interactor.currentProgressText())
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

        let correctIndex = q.correctIndex
        let isCorrect = interactor.submitAnswer(optionIndex: selectedIndex)
        Self.trace("Respuesta final=\(selectedIndex) correct=\(isCorrect) hasMore=\(interactor.hasMoreQuestions)")
        view?.revealAnswer(selectedIndex: selectedIndex, correctIndex: correctIndex, isCorrect: isCorrect)

        // Breve pausa para leer verde/rojo sin notar el juego “atascado” (antes 0,75 s).
        let revealPause: TimeInterval = 0.32
        DispatchQueue.main.asyncAfter(deadline: .now() + revealPause) { [weak self] in
            guard let self else { return }
            self.view?.clearAnswerHighlight()
            self.view?.setOptionsEnabled(true)
            let more = self.interactor.hasMoreQuestions
            if more {
                self.presentCurrent(from: viewController)
            } else {
                self.router?.pushSummary(from: viewController)
            }
        }
    }

    func didTapFinish(from viewController: UIViewController) {
        Self.trace("didTapFinish → pushSummary router=\(router != nil) nav=\(viewController.navigationController != nil)")
        router?.pushSummary(from: viewController)
    }
}

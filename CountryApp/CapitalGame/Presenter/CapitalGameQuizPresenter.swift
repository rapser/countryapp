//
//  CapitalGameQuizPresenter.swift
//  CountryApp
//

import OSLog
import UIKit

protocol CapitalGameQuizPresenterProtocol: AnyObject {
    func viewDidAppear(from viewController: UIViewController)
    func didSelectOption(index: Int, from viewController: UIViewController)
    func didTapFinalAnswer(from viewController: UIViewController)
    func didTapFinish(from viewController: UIViewController)
}

protocol CapitalGameQuizViewProtocol: AnyObject {
    func showQuestion(flagAssetCode: String, countryName: String, options: [String], progress: String)
    func setProgress(fraction: Float)
    func setOptionsEnabled(_ enabled: Bool)
    func setFinalAnswerEnabled(_ enabled: Bool)
    func highlightSelectedOption(index: Int)
}

final class CapitalGameQuizPresenter: CapitalGameQuizPresenterProtocol {
    private static let log = Logger(subsystem: "CountryApp", category: "CapitalGameQuiz")

    weak var view: CapitalGameQuizViewProtocol?
    var router: CapitalGameRouterProtocol?
    private let interactor: CapitalGameInteractorProtocol
    private var didRecordStart = false
    /// La primera pregunta se muestra desde `viewDidAppear`; evita reentradas si se vuelve a llamar.
    private var didPresentFirstQuestion = false
    /// Evita empujar el resumen más de una vez (p.ej. doble tap en "Terminar partida").
    private var isNavigatingToSummary = false
    private var selectedIndex: Int?
    private var questionShownAt: Date?

    init(interactor: CapitalGameInteractorProtocol, router: CapitalGameRouterProtocol?) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidAppear(from viewController: UIViewController) {
        if !didRecordStart {
            interactor.recordQuizStarted()
            didRecordStart = true
        }
        guard !didPresentFirstQuestion else { return }
        didPresentFirstQuestion = true
        presentCurrent(from: viewController)
    }

    private func presentCurrent(from viewController: UIViewController) {
        guard let q = interactor.currentQuestion() else {
            goToSummary(from: viewController)
            return
        }
        selectedIndex = nil
        questionShownAt = Date()
        view?.showQuestion(
            flagAssetCode: q.flagAssetCode,
            countryName: q.countryName,
            options: q.options,
            progress: interactor.currentProgressText()
        )
        view?.setProgress(fraction: interactor.currentProgressFraction())
        view?.setOptionsEnabled(true)
        view?.setFinalAnswerEnabled(false)
    }

    func didSelectOption(index: Int, from viewController: UIViewController) {
        guard interactor.currentQuestion() != nil else { return }
        selectedIndex = index
        view?.highlightSelectedOption(index: index)
        view?.setFinalAnswerEnabled(true)
    }

    func didTapFinalAnswer(from viewController: UIViewController) {
        guard let selectedIndex else { return }
        guard interactor.currentQuestion() != nil else { return }

        view?.setOptionsEnabled(false)
        view?.setFinalAnswerEnabled(false)

        let elapsed = questionShownAt.map { Date().timeIntervalSince($0) } ?? 0
        _ = interactor.submitAnswer(optionIndex: selectedIndex, responseTime: elapsed)

        if interactor.hasMoreQuestions {
            presentCurrent(from: viewController)
        } else {
            goToSummary(from: viewController)
        }
    }

    func didTapFinish(from viewController: UIViewController) {
        goToSummary(from: viewController)
    }

    private func goToSummary(from viewController: UIViewController) {
        guard !isNavigatingToSummary else { return }
        isNavigatingToSummary = true
        router?.pushSummary(from: viewController)
    }
}

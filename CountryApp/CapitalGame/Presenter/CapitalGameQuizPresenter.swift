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
    func presentFeedback(_ result: QuizFeedbackResult, onContinue: @escaping () -> Void)
}

final class CapitalGameQuizPresenter: CapitalGameQuizPresenterProtocol {
    private static let log = Logger(subsystem: "CountryApp", category: "CapitalGameQuiz")

    weak var view: CapitalGameQuizViewProtocol?
    var router: CapitalGameRouterProtocol?
    private let interactor: CapitalGameInteractorProtocol
    private var didRecordStart = false
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
        presentCurrent(from: viewController)
    }

    private func presentCurrent(from viewController: UIViewController) {
        guard let q = interactor.currentQuestion() else {
            router?.pushSummary(from: viewController)
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
        guard let q = interactor.currentQuestion() else { return }

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
            questionPrompt: "¿Cuál es la capital de \(q.countryName)?",
            yourAnswer: yourAnswer,
            correctAnswer: correctAnswer,
            isLastQuestion: !interactor.hasMoreQuestions
        )

        view?.presentFeedback(result) { [weak self, weak viewController] in
            guard let self, let vc = viewController else { return }
            if self.interactor.hasMoreQuestions {
                self.presentCurrent(from: vc)
            } else {
                self.router?.pushSummary(from: vc)
            }
        }
    }

    func didTapFinish(from viewController: UIViewController) {
        router?.pushSummary(from: viewController)
    }
}

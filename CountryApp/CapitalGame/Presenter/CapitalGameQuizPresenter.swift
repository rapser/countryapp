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
    func configureQuizChrome()
    func showQuestion(flagAssetCode: String, countryName: String, options: [String], progress: String)
    func setOptionsEnabled(_ enabled: Bool)
    func setFinalAnswerEnabled(_ enabled: Bool)
    func highlightSelectedOption(index: Int)
    func revealAnswer(selectedIndex: Int, correctIndex: Int, isCorrect: Bool)
    func clearAnswerHighlight()
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
        view?.configureQuizChrome()
        view?.showQuestion(
            flagAssetCode: q.flagAssetCode,
            countryName: q.countryName,
            options: q.options,
            progress: interactor.currentProgressText()
        )
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
        let correctIndex = q.correctIndex
        let isCorrect = interactor.submitAnswer(optionIndex: selectedIndex, responseTime: elapsed)
        view?.revealAnswer(selectedIndex: selectedIndex, correctIndex: correctIndex, isCorrect: isCorrect)

        let revealPause: TimeInterval = 0.32
        DispatchQueue.main.asyncAfter(deadline: .now() + revealPause) { [weak self] in
            guard let self else { return }
            self.view?.clearAnswerHighlight()
            self.view?.setOptionsEnabled(true)
            if self.interactor.hasMoreQuestions {
                self.presentCurrent(from: viewController)
            } else {
                self.router?.pushSummary(from: viewController)
            }
        }
    }

    func didTapFinish(from viewController: UIViewController) {
        router?.pushSummary(from: viewController)
    }
}


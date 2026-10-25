//
//  CapitalGameSummaryPresenter.swift
//  CountryApp
//

import UIKit

protocol CapitalGameSummaryPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapExit(from viewController: UIViewController)
    func didTapLogin(from viewController: UIViewController)
}

final class CapitalGameSummaryPresenter: CapitalGameSummaryPresenterProtocol {
    var router: CapitalGameRouterProtocol?
    weak var view: GameScoreStatusViewProtocol?

    private let scoreReporter: GameSummaryScoreReporter

    init(router: CapitalGameRouterProtocol?, draft: GameSessionDraft, submitter: GameScoreSubmitterProtocol) {
        self.router = router
        self.scoreReporter = GameSummaryScoreReporter(draft: draft, submitter: submitter)
    }

    func viewDidLoad() {
        scoreReporter.start { [weak self] status in
            self?.view?.showScoreStatus(status)
        }
    }

    func didTapExit(from viewController: UIViewController) {
        router?.exitToHome(from: viewController)
    }

    func didTapLogin(from viewController: UIViewController) {
        router?.presentLogin(from: viewController)
    }
}

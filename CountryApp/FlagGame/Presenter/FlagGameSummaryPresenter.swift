//
//  FlagGameSummaryPresenter.swift
//  CountryApp
//

import UIKit

protocol FlagGameSummaryPresenterProtocol: AnyObject {
    func didTapExit(from viewController: UIViewController)
}

final class FlagGameSummaryPresenter: FlagGameSummaryPresenterProtocol {
    var router: FlagGameRouterProtocol?

    init(router: FlagGameRouterProtocol?) {
        self.router = router
    }

    func didTapExit(from viewController: UIViewController) {
        router?.exitToHome(from: viewController)
    }
}

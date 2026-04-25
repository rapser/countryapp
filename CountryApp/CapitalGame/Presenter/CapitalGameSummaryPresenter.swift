//
//  CapitalGameSummaryPresenter.swift
//  CountryApp
//

import UIKit

protocol CapitalGameSummaryPresenterProtocol: AnyObject {
    func didTapExit(from viewController: UIViewController)
}

final class CapitalGameSummaryPresenter: CapitalGameSummaryPresenterProtocol {
    var router: CapitalGameRouterProtocol?

    init(router: CapitalGameRouterProtocol?) {
        self.router = router
    }

    func didTapExit(from viewController: UIViewController) {
        router?.exitToHome(from: viewController)
    }
}


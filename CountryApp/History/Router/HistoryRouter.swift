//
//  HistoryRouter.swift
//  CountryApp
//

import UIKit

@MainActor
protocol HistoryRouterProtocol: AnyObject {
    func presentLogin(from viewController: UIViewController)
    func showHomeTab(from viewController: UIViewController)
}

@MainActor
final class HistoryRouter: HistoryRouterProtocol {

    static func createModule() -> UIViewController {
        let router = HistoryRouter()
        let presenter = HistoryPresenter(interactor: HistoryInteractor(), router: router)
        let vc = HistoryViewController(presenter: presenter)
        presenter.view = vc
        return vc
    }

    func presentLogin(from viewController: UIViewController) {
        AuthRouter.presentLogin(from: viewController)
    }

    func showHomeTab(from viewController: UIViewController) {
        viewController.tabBarController?.selectedIndex = 0
    }
}

//
//  RankingRouter.swift
//  CountryApp
//

import UIKit

@MainActor
protocol RankingRouterProtocol: AnyObject {
    func presentLogin(from viewController: UIViewController)
}

@MainActor
final class RankingRouter: RankingRouterProtocol {

    static func createModule() -> UIViewController {
        let router = RankingRouter()
        let presenter = RankingPresenter(interactor: RankingInteractor(), router: router)
        let vc = RankingViewController(presenter: presenter)
        presenter.view = vc
        return vc
    }

    func presentLogin(from viewController: UIViewController) {
        AuthRouter.presentLogin(from: viewController)
    }
}

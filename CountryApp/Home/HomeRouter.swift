//
//  HomeRouter.swift
//  CountryApp
//

import SwiftData
import UIKit

final class HomeRouter: HomeRouterProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    static func createModule(modelContext: ModelContext) -> UIViewController {
        let router = HomeRouter(modelContext: modelContext)
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        let service = CountryListServiceManager()
        let interactor = HomeInteractor(persistence: persistence, service: service)
        let presenter = HomePresenter()
        let view = HomeViewController(presenter: presenter)

        presenter.view = view
        presenter.router = router
        view.interactor = interactor

        return view
    }

    func showCountryList(from viewController: UIViewController) {
        let list = CountryListRouter.createModule(modelContext: modelContext)
        viewController.navigationController?.pushViewController(list, animated: true)
    }

    func showFlagGame(from viewController: UIViewController) {
        let nav = viewController.navigationController
        AppLog.trace("HomeRouter showFlagGame nav=\(nav != nil)")
        let game = FlagGameRouter.createModule(modelContext: modelContext, hostingNavigationController: nav)
        nav?.pushViewController(game, animated: true)
    }

    func showCapitalGame(from viewController: UIViewController) {
        let nav = viewController.navigationController
        AppLog.trace("HomeRouter showCapitalGame nav=\(nav != nil)")
        let game = CapitalGameRouter.createModule(modelContext: modelContext, hostingNavigationController: nav)
        nav?.pushViewController(game, animated: true)
    }
}

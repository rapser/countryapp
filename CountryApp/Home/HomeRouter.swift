//
//  HomeRouter.swift
//  CountryApp
//

import SwiftData
import UIKit

final class HomeRouter: HomeRouterProtocol {
    private let modelContext: ModelContext
    weak var coordinator: HomeCoordinatorProtocol?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Module factory

    /// Protocol-required factory. Wires no coordinator (used in legacy callsites / tests).
    static func createModule(modelContext: ModelContext) -> UIViewController {
        createModule(modelContext: modelContext, coordinator: nil)
    }

    /// Primary factory used by HomeCoordinator to inject the coordinator reference.
    static func createModule(modelContext: ModelContext, coordinator: HomeCoordinatorProtocol?) -> UIViewController {
        let router = HomeRouter(modelContext: modelContext)
        router.coordinator = coordinator
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

    // MARK: - Navigation (delegates to coordinator when available)

    func showCountryList(from viewController: UIViewController) {
        if let coordinator {
            coordinator.showCountryList(from: viewController)
        } else {
            let list = CountryListRouter.createModule(modelContext: modelContext)
            viewController.navigationController?.pushViewController(list, animated: true)
        }
    }

    func showFlagGame(from viewController: UIViewController) {
        if let coordinator {
            coordinator.showFlagGame(from: viewController)
        } else {
            let nav = viewController.navigationController
            AppLog.trace("HomeRouter showFlagGame nav=\(nav != nil)")
            let game = FlagGameRouter.createModule(modelContext: modelContext, hostingNavigationController: nav)
            nav?.pushViewController(game, animated: true)
        }
    }

    func showCapitalGame(from viewController: UIViewController) {
        if let coordinator {
            coordinator.showCapitalGame(from: viewController)
        } else {
            let nav = viewController.navigationController
            AppLog.trace("HomeRouter showCapitalGame nav=\(nav != nil)")
            let game = CapitalGameRouter.createModule(modelContext: modelContext, hostingNavigationController: nav)
            nav?.pushViewController(game, animated: true)
        }
    }
}

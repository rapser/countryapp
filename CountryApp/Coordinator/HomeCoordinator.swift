//
//  HomeCoordinator.swift
//  CountryApp
//

import SwiftData
import UIKit

/// Interface consumed by HomeRouter to delegate inter-module navigation.
protocol HomeCoordinatorProtocol: AnyObject {
    func showFlagGame(from viewController: UIViewController)
    func showCapitalGame(from viewController: UIViewController)
    func showCountryList(from viewController: UIViewController)
}

/// Called by HomeCoordinator to request AppCoordinator to open another module.
protocol HomeCoordinatorDelegate: AnyObject {
    func homeCoordinatorWantsToShowFlagGame(_ coordinator: HomeCoordinator)
    func homeCoordinatorWantsToShowCapitalGame(_ coordinator: HomeCoordinator)
    func homeCoordinatorWantsToShowCountryList(_ coordinator: HomeCoordinator)
}

final class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var delegate: HomeCoordinatorDelegate?

    private let navigationController: UINavigationController
    private let modelContext: ModelContext

    init(navigationController: UINavigationController, modelContext: ModelContext) {
        self.navigationController = navigationController
        self.modelContext = modelContext
    }

    func start() {
        let vc = HomeRouter.createModule(modelContext: modelContext, coordinator: self)
        navigationController.setViewControllers([vc], animated: false)
    }
}

extension HomeCoordinator: HomeCoordinatorProtocol {
    func showFlagGame(from viewController: UIViewController) {
        delegate?.homeCoordinatorWantsToShowFlagGame(self)
    }

    func showCapitalGame(from viewController: UIViewController) {
        delegate?.homeCoordinatorWantsToShowCapitalGame(self)
    }

    func showCountryList(from viewController: UIViewController) {
        delegate?.homeCoordinatorWantsToShowCountryList(self)
    }
}

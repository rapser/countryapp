//
//  AppCoordinator.swift
//  CountryApp
//

import SwiftData
import UIKit

/// Root coordinator. Owns the navigation controller and model context.
/// Creates child coordinators and routes inter-module navigation.
final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController
    private let modelContext: ModelContext

    init(navigationController: UINavigationController, modelContext: ModelContext) {
        self.navigationController = navigationController
        self.modelContext = modelContext
    }

    func start() {
        let homeCoordinator = HomeCoordinator(
            navigationController: navigationController,
            modelContext: modelContext
        )
        homeCoordinator.delegate = self
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
    }
}

// MARK: - HomeCoordinatorDelegate

extension AppCoordinator: HomeCoordinatorDelegate {
    func homeCoordinatorWantsToShowFlagGame(_ coordinator: HomeCoordinator) {
        let nav = navigationController
        let vc = FlagGameRouter.createModule(modelContext: modelContext, hostingNavigationController: nav)
        AppLog.trace("AppCoordinator showFlagGame")
        nav.pushViewController(vc, animated: true)
    }

    func homeCoordinatorWantsToShowCapitalGame(_ coordinator: HomeCoordinator) {
        let nav = navigationController
        let vc = CapitalGameRouter.createModule(modelContext: modelContext, hostingNavigationController: nav)
        AppLog.trace("AppCoordinator showCapitalGame")
        nav.pushViewController(vc, animated: true)
    }

    func homeCoordinatorWantsToShowCountryList(_ coordinator: HomeCoordinator) {
        let vc = CountryListRouter.createModule(modelContext: modelContext)
        AppLog.trace("AppCoordinator showCountryList")
        navigationController.pushViewController(vc, animated: true)
    }
}

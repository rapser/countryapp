//
//  AppCoordinator.swift
//  CountryApp
//

import SwiftData
import UIKit

/// Root coordinator. Owns the navigation controller and model context.
/// Creates and manages all child coordinators; routes inter-module navigation.
final class AppCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController
    private let modelContext: ModelContext

    init(navigationController: UINavigationController, modelContext: ModelContext) {
        self.navigationController = navigationController
        self.modelContext = modelContext
    }

    func start() {
        navigationController.delegate = self
        let homeCoordinator = HomeCoordinator(
            navigationController: navigationController,
            modelContext: modelContext
        )
        homeCoordinator.delegate = self
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
        AppLog.trace("AppCoordinator start")
    }
}

// MARK: - HomeCoordinatorDelegate

extension AppCoordinator: HomeCoordinatorDelegate {
    func homeCoordinatorWantsToShowFlagGame(_ coordinator: HomeCoordinator) {
        let child = FlagGameCoordinator(navigationController: navigationController, modelContext: modelContext)
        child.delegate = self
        childCoordinators.append(child)
        child.start()
    }

    func homeCoordinatorWantsToShowCapitalGame(_ coordinator: HomeCoordinator) {
        let child = CapitalGameCoordinator(navigationController: navigationController, modelContext: modelContext)
        child.delegate = self
        childCoordinators.append(child)
        child.start()
    }

    func homeCoordinatorWantsToShowCountryList(_ coordinator: HomeCoordinator) {
        // Replace any existing CountryListCoordinator so we don't accumulate them.
        childCoordinators.removeAll { $0 is CountryListCoordinator }
        let child = CountryListCoordinator(navigationController: navigationController, modelContext: modelContext)
        childCoordinators.append(child)
        child.start()
    }
}

// MARK: - FlagGameCoordinatorDelegate

extension AppCoordinator: FlagGameCoordinatorDelegate {
    func flagGameCoordinatorDidFinish(_ coordinator: FlagGameCoordinator) {
        childDidFinish(coordinator)
        AppLog.trace("AppCoordinator FlagGame finished — childCoordinators=\(childCoordinators.count)")
    }
}

// MARK: - CapitalGameCoordinatorDelegate

extension AppCoordinator: CapitalGameCoordinatorDelegate {
    func capitalGameCoordinatorDidFinish(_ coordinator: CapitalGameCoordinator) {
        childDidFinish(coordinator)
        AppLog.trace("AppCoordinator CapitalGame finished — childCoordinators=\(childCoordinators.count)")
    }
}

// MARK: - UINavigationControllerDelegate (back-button cleanup)

extension AppCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        // Only act when a VC was popped (not pushed).
        guard
            let fromVC = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(fromVC)
        else { return }

        // Find child coordinators whose root was the popped VC and clean them up.
        childCoordinators
            .compactMap { $0 as? CoordinatorTrackable }
            .filter { $0.rootViewController === fromVC }
            .compactMap { $0 as? Coordinator }
            .forEach {
                AppLog.trace("AppCoordinator back-button pop detected — releasing \(type(of: $0))")
                childDidFinish($0)
            }
    }
}

//
//  AppCoordinator.swift
//  CountryApp
//

import SwiftData
import UIKit

/// Root coordinator. Owns the tab bar (Inicio · Ranking · Historial · Perfil) and the model context.
/// The Inicio tab keeps the original flow: Home routes to games and the country list on its own nav stack.
final class AppCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []

    let tabBarController = UITabBarController()
    /// Nav stack of the Inicio tab (Home → juegos / lista / detalle / mapa).
    private let navigationController = UINavigationController()
    private let rankingNavigationController = UINavigationController()
    private let historyNavigationController = UINavigationController()
    private let profileNavigationController = UINavigationController()
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
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

        let tabCoordinators: [Coordinator] = [
            RankingCoordinator(navigationController: rankingNavigationController),
            HistoryCoordinator(navigationController: historyNavigationController),
            ProfileCoordinator(navigationController: profileNavigationController)
        ]
        tabCoordinators.forEach {
            childCoordinators.append($0)
            $0.start()
        }

        configureTab(navigationController, title: "Inicio", symbol: "house")
        configureTab(rankingNavigationController, title: "Ranking", symbol: "trophy")
        configureTab(historyNavigationController, title: "Historial", symbol: "clock.arrow.circlepath", selectedSymbol: "clock.arrow.circlepath")
        configureTab(profileNavigationController, title: "Perfil", symbol: "person.crop.circle")

        tabBarController.viewControllers = [
            navigationController,
            rankingNavigationController,
            historyNavigationController,
            profileNavigationController
        ]
        UITabBarController.applyAppTheme(to: tabBarController)

        MainActor.assumeIsolated { SessionStore.shared.start() }
        AppLog.trace("AppCoordinator start")
    }

    private func configureTab(_ nav: UINavigationController, title: String, symbol: String, selectedSymbol: String? = nil) {
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: symbol),
            selectedImage: UIImage(systemName: selectedSymbol ?? "\(symbol).fill")
        )
        UINavigationController.applyLightAppTheme(to: nav)
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

//
//  TabCoordinators.swift
//  CountryApp
//
//  Coordinators de las tabs Ranking, Historial y Perfil. Cada uno monta su módulo raíz
//  en el nav de su tab; login / registro se presentan como modal desde los routers.
//

import UIKit

final class RankingCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = MainActor.assumeIsolated { RankingRouter.createModule() }
        navigationController.setViewControllers([vc], animated: false)
    }
}

final class HistoryCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = MainActor.assumeIsolated { HistoryRouter.createModule() }
        navigationController.setViewControllers([vc], animated: false)
    }
}

final class ProfileCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = MainActor.assumeIsolated { ProfileRouter.createModule() }
        navigationController.setViewControllers([vc], animated: false)
    }
}

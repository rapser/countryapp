//
//  CapitalGameCoordinator.swift
//  CountryApp
//

import SwiftData
import UIKit

protocol CapitalGameCoordinatorDelegate: AnyObject {
    func capitalGameCoordinatorDidFinish(_ coordinator: CapitalGameCoordinator)
}

final class CapitalGameCoordinator: Coordinator, CoordinatorTrackable {
    var childCoordinators: [Coordinator] = []
    weak var delegate: CapitalGameCoordinatorDelegate?
    private(set) weak var rootViewController: UIViewController?

    private let navigationController: UINavigationController
    private let modelContext: ModelContext

    init(navigationController: UINavigationController, modelContext: ModelContext) {
        self.navigationController = navigationController
        self.modelContext = modelContext
    }

    func start() {
        let vc = CapitalGameRouter.createModule(
            modelContext: modelContext,
            hostingNavigationController: navigationController,
            exitDelegate: self
        )
        rootViewController = vc
        AppLog.trace("CapitalGameCoordinator start")
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - GameCoordinatorExitDelegate

extension CapitalGameCoordinator: GameCoordinatorExitDelegate {
    func gameCoordinatorDidRequestExit() {
        AppLog.trace("CapitalGameCoordinator finish → popToRoot")
        navigationController.popToRootViewController(animated: true)
        delegate?.capitalGameCoordinatorDidFinish(self)
    }
}

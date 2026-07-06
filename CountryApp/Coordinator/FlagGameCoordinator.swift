//
//  FlagGameCoordinator.swift
//  CountryApp
//

import SwiftData
import UIKit

protocol FlagGameCoordinatorDelegate: AnyObject {
    func flagGameCoordinatorDidFinish(_ coordinator: FlagGameCoordinator)
}

final class FlagGameCoordinator: Coordinator, CoordinatorTrackable {
    var childCoordinators: [Coordinator] = []
    weak var delegate: FlagGameCoordinatorDelegate?
    private(set) weak var rootViewController: UIViewController?

    private let navigationController: UINavigationController
    private let modelContext: ModelContext

    init(navigationController: UINavigationController, modelContext: ModelContext) {
        self.navigationController = navigationController
        self.modelContext = modelContext
    }

    func start() {
        let vc = FlagGameRouter.createModule(
            modelContext: modelContext,
            hostingNavigationController: navigationController,
            exitDelegate: self
        )
        rootViewController = vc
        AppLog.trace("FlagGameCoordinator start")
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - GameCoordinatorExitDelegate

extension FlagGameCoordinator: GameCoordinatorExitDelegate {
    func gameCoordinatorDidRequestExit() {
        AppLog.trace("FlagGameCoordinator finish → popToRoot")
        navigationController.popToRootViewController(animated: true)
        delegate?.flagGameCoordinatorDidFinish(self)
    }
}

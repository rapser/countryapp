//
//  Coordinator.swift
//  CountryApp
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    /// Removes a finished child coordinator from the list, releasing it from memory.
    func childDidFinish(_ child: Coordinator) {
        childCoordinators.removeAll { $0 === child }
    }
}

/// Adopted by game coordinators so their Router can request exit without
/// knowing the concrete coordinator type.
protocol GameCoordinatorExitDelegate: AnyObject {
    func gameCoordinatorDidRequestExit()
}

/// Lets AppCoordinator track which VC a child coordinator owns, so it can
/// detect back-button pops and release the coordinator from childCoordinators.
protocol CoordinatorTrackable: AnyObject {
    var rootViewController: UIViewController? { get }
}

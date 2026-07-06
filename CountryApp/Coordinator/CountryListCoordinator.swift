//
//  CountryListCoordinator.swift
//  CountryApp
//

import SwiftData
import UIKit

/// Interface consumed by CountryListRouter to delegate detail navigation.
protocol CountryListCoordinatorProtocol: AnyObject {
    func showCountryDetail(countryName: String, from viewController: UIViewController)
}

final class CountryListCoordinator: Coordinator, CoordinatorTrackable {
    var childCoordinators: [Coordinator] = []
    private(set) weak var rootViewController: UIViewController?

    private let navigationController: UINavigationController
    private let modelContext: ModelContext

    init(navigationController: UINavigationController, modelContext: ModelContext) {
        self.navigationController = navigationController
        self.modelContext = modelContext
    }

    func start() {
        let vc = CountryListRouter.createModule(modelContext: modelContext, coordinator: self)
        rootViewController = vc
        AppLog.trace("CountryListCoordinator start")
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - CountryListCoordinatorProtocol

extension CountryListCoordinator: CountryListCoordinatorProtocol {
    func showCountryDetail(countryName: String, from viewController: UIViewController) {
        let detailVC = CountryDetailRouter.createModule(with: countryName)
        navigationController.pushViewController(detailVC, animated: true)
    }
}

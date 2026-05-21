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

final class CountryListCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    private let navigationController: UINavigationController
    private let modelContext: ModelContext

    init(navigationController: UINavigationController, modelContext: ModelContext) {
        self.navigationController = navigationController
        self.modelContext = modelContext
    }

    func start() {
        let vc = CountryListRouter.createModule(modelContext: modelContext, coordinator: self)
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

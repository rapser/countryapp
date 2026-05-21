//
//  CountryListRouter.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import SwiftData
import UIKit

class CountryListRouter: CountryListRouterProtocol {
    weak var coordinator: CountryListCoordinatorProtocol?

    // MARK: - Module factory

    static func createModule(modelContext: ModelContext) -> UIViewController {
        createModule(modelContext: modelContext, coordinator: nil)
    }

    static func createModule(modelContext: ModelContext, coordinator: CountryListCoordinatorProtocol?) -> UIViewController {
        let router = CountryListRouter()
        router.coordinator = coordinator
        let service = CountryListServiceManager()
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        let interactor = CountryListInteractor(service: service, persistence: persistence)
        let presenter = CountryListPresenter()
        let view = CountryListViewController(presenter: presenter)

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }

    func navigateToCountryDetail(from viewController: UIViewController, countryName: String) {
        if let coordinator {
            coordinator.showCountryDetail(countryName: countryName, from: viewController)
        } else {
            let detailVC = CountryDetailRouter.createModule(with: countryName)
            viewController.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}



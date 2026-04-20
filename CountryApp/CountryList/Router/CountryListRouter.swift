//
//  CountryListRouter.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import UIKit

class CountryListRouter: CountryListRouterProtocol {
    static func createModule() -> UIViewController {
        let router = CountryListRouter()
        let service = CountryListServiceManager()
        let interactor = CountryListInteractor(service: service)
        let presenter = CountryListPresenter()
        let view = CountryListViewController(presenter: presenter)

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }

    func navigateToCountryDetail(from viewController: UIViewController, countryName: String) {
        let countryDetailViewController = CountryDetailRouter.createModule(with: countryName)
        viewController.navigationController?.pushViewController(countryDetailViewController, animated: true)
    }
}



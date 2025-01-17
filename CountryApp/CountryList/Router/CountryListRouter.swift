//
//  CountryListRouter.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import UIKit

class CountryListRouter: CountryListRouterProtocol {
    static func createModule() -> UIViewController {
        let service = CountryListServiceManager()
        let interactor = CountryListInteractor(service: service)
        let presenter = CountryListPresenter()
        let view = CountryListViewController(presenter: presenter)

        presenter.view = view
        presenter.interactor = interactor
        interactor.presenter = presenter

        return view
    }

    static func navigateToCountryDetail(from view: UIViewController, countryName: String) {
        let countryDetailViewController = CountryDetailRouter.createModule(with: countryName)
        view.navigationController?.pushViewController(countryDetailViewController, animated: true)
    }
}



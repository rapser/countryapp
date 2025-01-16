//
//  CountryDetailRouter.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import UIKit

class CountryDetailRouter: CountryDetailRouterProtocol {
    static func createModule(with countryName: String) -> UIViewController {
        let service = CountryDetailServiceManager()
        let interactor = CountryDetailInteractor(service: service)
        let presenter = CountryDetailPresenter()
        let view = CountryDetailViewController(presenter: presenter)

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = CountryDetailRouter()
        interactor.presenter = presenter

        presenter.countryName = countryName

        return view
    }
}



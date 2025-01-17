//
//  CountryDetailRouter.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import UIKit

class CountryDetailRouter: CountryDetailRouterProtocol {
    weak var viewController: UIViewController?

    static func createModule(with countryName: String) -> UIViewController {
        let router = CountryDetailRouter()
        let service = CountryDetailServiceManager()
        let interactor = CountryDetailInteractor(service: service)
        let presenter = CountryDetailPresenter()
        let view = CountryDetailViewController(presenter: presenter)

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.countryName = countryName
        interactor.presenter = presenter
        router.viewController = view

        return view
    }

    func navigateToMap(latitude: Double, longitude: Double, countryName: String) {
        let mapModule = MapRouter.createModule(latitude: latitude, longitude: longitude, countryName: countryName)
        viewController?.navigationController?.pushViewController(mapModule, animated: true)
    }
}



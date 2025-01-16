//
//  MapRouter.swift
//  CountryApp
//
//  Created by miguel tomairo on 16/01/25.
//

import Foundation
import UIKit

protocol MapRouterProtocol {
    func navigateBack()
}

class MapRouter: MapRouterProtocol {
    weak var viewController: UIViewController?

    static func createModule(latitude: Double, longitude: Double, countryName: String) -> UIViewController {
        let view = MapViewController()
        let presenter = MapPresenter(view: view, latitude: latitude, longitude: longitude, countryName: countryName)
        let router = MapRouter()
        
        view.presenter = presenter
        presenter.router = router
        router.viewController = view

        return view
    }

    func navigateBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}

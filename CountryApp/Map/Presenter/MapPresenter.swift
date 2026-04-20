//
//  MapPresenter.swift
//  CountryApp
//
//  Created by miguel tomairo on 16/01/25.
//

import Foundation

protocol MapPresenterProtocol: AnyObject {
    func viewDidLoad()
}

class MapPresenter: MapPresenterProtocol {
    weak var view: MapViewProtocol?
    var interactor: MapInteractorProtocol?
    var router: MapRouterProtocol?

    init(view: MapViewProtocol) {
        self.view = view
    }

    func viewDidLoad() {
        guard let location = interactor?.fetchLocation() else { return }
        view?.showLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            countryName: location.countryName
        )
    }
}

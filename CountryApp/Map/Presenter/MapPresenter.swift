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
    
    private let latitude: Double
    private let longitude: Double
    private let countryName: String

    init(view: MapViewProtocol, latitude: Double, longitude: Double, countryName: String) {
        self.view = view
        self.latitude = latitude
        self.longitude = longitude
        self.countryName = countryName
    }

    func viewDidLoad() {
        view?.showLocation(latitude: latitude, longitude: longitude, countryName: countryName)
    }
}

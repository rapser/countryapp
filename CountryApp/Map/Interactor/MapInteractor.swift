//
//  MapInteractor.swift
//  CountryApp
//
//  Created by miguel tomairo on 16/01/25.
//

import Foundation

protocol MapInteractorProtocol: AnyObject {
    func fetchLocation() -> (latitude: Double, longitude: Double, countryName: String)
}

class MapInteractor: MapInteractorProtocol {
    private let latitude: Double
    private let longitude: Double
    private let countryName: String

    init(latitude: Double, longitude: Double, countryName: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.countryName = countryName
    }

    func fetchLocation() -> (latitude: Double, longitude: Double, countryName: String) {
        (latitude, longitude, countryName)
    }
}

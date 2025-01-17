//
//  MapInteractor.swift
//  CountryApp
//
//  Created by miguel tomairo on 16/01/25.
//

import Foundation

protocol MapInteractorProtocol: AnyObject {
    func fetchMapData()
}

class MapInteractor: MapInteractorProtocol {
    func fetchMapData() {
        // Aquí irían cálculos o llamadas de red si fueran necesarios
    }
}

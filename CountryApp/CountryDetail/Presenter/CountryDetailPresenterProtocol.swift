//
//  CountryDetailPresenterProtocol.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

protocol CountryDetailPresenterProtocol: AnyObject {
    func didFetchCountryDetail(_ countryDetail: CountryDetail)  // Notifica a la vista cuando se obtienen los detalles
    func didFailWithError(_ error: Error)                       // Notifica a la vista cuando ocurre un error
    func fetchCountryDetail() async                             // Inicia la obtención de detalles de un país
}


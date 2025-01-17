//
//  CountryDetailPresenterProtocol.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

protocol CountryDetailPresenterProtocol: AnyObject {
    func didFetchCountryDetail(_ countryDetail: CountryDetail)
    func didFailWithError(_ error: Error)
    func fetchCountryDetail() async
    func showMap()
}


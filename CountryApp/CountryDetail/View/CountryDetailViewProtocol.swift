//
//  CountryDetailViewProtocol.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

protocol CountryDetailViewProtocol: AnyObject {
    func displayCountryDetail(_ countryDetail: CountryDetail)
    func displayError(_ message: String)
    func showLoadingView()
    func hideLoadingView()
}


//
//  CountryListViewProtocol.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

protocol CountryListViewProtocol: AnyObject {
    func displayCountryList(_ countries: Countries)
    func displayFilteredCountries(_ countries: Countries)
    func displayError(_ message: String)
    func showLoadingView()
    func hideLoadingView()
}

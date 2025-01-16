//
//  CountryListRouterProtocol.swift
//  CountryApp
//
//  Created by miguel tomairo on 16/01/25.
//

import UIKit

protocol CountryListRouterProtocol {
    static func createModule() -> UIViewController
    static func navigateToCountryDetail(from view: UIViewController, countryName: String)
}

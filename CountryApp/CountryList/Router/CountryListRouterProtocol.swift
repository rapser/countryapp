//
//  CountryListRouterProtocol.swift
//  CountryApp
//
//  Created by miguel tomairo on 16/01/25.
//

import UIKit

protocol CountryListRouterProtocol {
    static func createModule() -> UIViewController
    func navigateToCountryDetail(from viewController: UIViewController, countryName: String)
}

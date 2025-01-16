//
//  CountryDetailRouterProtocol.swift
//  CountryApp
//
//  Created by miguel tomairo on 16/01/25.
//

import UIKit

protocol CountryDetailRouterProtocol {
    static func createModule(with countryName: String) -> UIViewController
}

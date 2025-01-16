//
//  CountryListService.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

protocol CountryListService {
    func fetchCountryList() async throws -> Countries
}

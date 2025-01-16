//
//  CountryDetailService.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

protocol CountryDetailService {
    func fetchCountryDetail(by name: String) async throws -> CountryDetail
}

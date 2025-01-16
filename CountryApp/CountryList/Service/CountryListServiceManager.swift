//
//  CountryListServiceManager.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

class CountryListServiceManager: CountryListService {
    private let baseURL = "https://restcountries.com/v3.1/all"

    func fetchCountryList() async throws -> Countries {
        guard let url = URL(string: baseURL) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let countries = try JSONDecoder().decode(Countries.self, from: data)
        return countries
    }
}

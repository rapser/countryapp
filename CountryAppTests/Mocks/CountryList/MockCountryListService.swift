//
//  MockCountryListService.swift
//  CountryAppTests
//
//  Created by miguel tomairo on 17/01/25.
//

@testable import CountryApp

final class MockCountryListService: CountryListService {
    var fetchCountryListCalled = false
    var mockedCountries: Countries = []
    var shouldThrowError = false

    func fetchCountryList() async throws -> Countries {
        fetchCountryListCalled = true
        if shouldThrowError {
            throw CountryListError.invalidResponse
        }
        return mockedCountries
    }
}

//
//  MockCountryDetailService.swift
//  CountryAppTests
//
//  Created by miguel tomairo on 16/01/25.
//

@testable import CountryApp

class MockCountryDetailService: CountryDetailService {
    var fetchCountryDetailCalled = false
    var countryDetailToReturn: CountryDetail?
    var errorToThrow: Error?
    
    func fetchCountryDetail(by name: String) async throws -> CountryDetail {
        fetchCountryDetailCalled = true
        if let error = errorToThrow {
            throw error
        }
        
        let countryDetailElement = CountryDetailElement(
            name: Name(common: "Peru", official: "Republic of Peru"),
            capital: ["Lima"],
            region: "America",
            borders: nil,
            flags: Flags(png: "someFlagUrl", svg: "someSvg", alt: "someAlt"),
            latlng: [-12.0,-77.0]
        )
        
        return [countryDetailElement]
    }

}

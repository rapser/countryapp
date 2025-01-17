//
//  MockCountryDetailPresenter.swift
//  CountryAppTests
//
//  Created by miguel tomairo on 16/01/25.
//

@testable import CountryApp

class MockCountryDetailPresenter: CountryDetailPresenterProtocol {
    var didFetchCountryDetailCalled = false
    var didFailWithErrorCalled = false
    var fetchCountryDetailCalled = false
    var showMapCalled = false
    var receivedCountryDetail: CountryDetail?
    var receivedError: Error?
    
    func didFetchCountryDetail(_ countryDetail: CountryDetail) {
        didFetchCountryDetailCalled = true
        receivedCountryDetail = countryDetail
    }
    
    func didFailWithError(_ error: Error) {
        didFailWithErrorCalled = true
        receivedError = error
    }
    
    func fetchCountryDetail() async {
        fetchCountryDetailCalled = true
    }
    
    func showMap() {
        showMapCalled = true
    }
}


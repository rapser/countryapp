//
//  MockCountryListPresenter.swift
//  CountryAppTests
//
//  Created by miguel tomairo on 17/01/25.
//

@testable import CountryApp

final class MockCountryListPresenter: CountryListPresenterProtocol {
    var view: CountryListViewProtocol?
    var interactor: CountryListInteractorProtocol?

    var didFetchCountryListCalled = false
    var didFailWithErrorCalled = false
    var fetchedCountries: Countries = []
    var filteredCountries: Countries = []
    var capturedError: Error?

    func fetchCountryList() async {}

    func filterCountries(by searchText: String) {
        filteredCountries = fetchedCountries.filter {
            $0.name.common.contains(searchText) || $0.name.official.contains(searchText)
        }
    }

    func didFetchCountryList(_ countries: Countries) {
        didFetchCountryListCalled = true
        fetchedCountries = countries
    }

    func didFailWithError(_ error: Error) {
        didFailWithErrorCalled = true
        capturedError = error
    }
}


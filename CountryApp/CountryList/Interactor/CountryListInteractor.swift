//
//  CountryListInteractor.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

class CountryListInteractor: CountryListInteractorProtocol {
    var presenter: CountryListPresenterProtocol?
    private let service: CountryListService

    init(service: CountryListService) {
        self.service = service
    }
    
    func fetchCountryList() async throws {
        do {
            let countries = try await service.fetchCountryList()
            presenter?.didFetchCountryList(countries)
        } catch {
            presenter?.didFailWithError(error)
            throw error
        }
    }
}


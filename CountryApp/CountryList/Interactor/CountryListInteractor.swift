//
//  CountryListInteractor.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

class CountryListInteractor: CountryListInteractorProtocol {
    var presenter: CountryListPresenterProtocol?
    let service: CountryListService
    let persistence: CountryPersistenceProtocol

    init(service: CountryListService, persistence: CountryPersistenceProtocol) {
        self.service = service
        self.persistence = persistence
    }

    func fetchCountryList() async throws {
        do {
            if try persistence.persistedCount() > 0 {
                let rows = try persistence.fetchPersistedCountries()
                let countries = rows.map { Country.from(persisted: $0) }
                presenter?.didFetchCountryList(countries)
                return
            }
        } catch {
            presenter?.didFailWithError(error)
            throw error
        }

        do {
            let countries = try await service.fetchCountryList()
            try persistence.replaceAll(from: countries)
            presenter?.didFetchCountryList(countries)
        } catch {
            presenter?.didFailWithError(error)
            throw error
        }
    }
}

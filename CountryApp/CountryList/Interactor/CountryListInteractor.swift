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
    private let userDefaultsManager = UserDefaultsManager.shared

    init(service: CountryListService) {
        self.service = service
    }

    func fetchCountryList() async throws {
        if let countries = userDefaultsManager.get(forKey: "savedCountries", as: Countries.self) {
            presenter?.didFetchCountryList(countries)
        } else {
            do {
                let countries = try await service.fetchCountryList()
                presenter?.didFetchCountryList(countries)
            } catch {
                presenter?.didFailWithError(error)
                throw error
            }
        }
    }
}


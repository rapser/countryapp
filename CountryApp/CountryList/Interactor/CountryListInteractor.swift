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
    var userDefaultsManager: UserDefaultsManagerProtocol

    init(service: CountryListService, userDefaultsManager: UserDefaultsManagerProtocol = UserDefaultsManager.shared) {
        self.service = service
        self.userDefaultsManager = userDefaultsManager
    }

    func fetchCountryList() async throws {
        if let countries = userDefaultsManager.get(forKey: "savedCountries", as: Countries.self) {
            presenter?.didFetchCountryList(countries)
        } else {
            do {
                let countries = try await service.fetchCountryList()
                userDefaultsManager.save(object: countries, forKey: "savedCountries")
                presenter?.didFetchCountryList(countries)
            } catch {
                presenter?.didFailWithError(error)
                throw error
            }
        }
    }
}

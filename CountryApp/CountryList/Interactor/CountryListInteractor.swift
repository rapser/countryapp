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
        // Intentar obtener la lista de países desde UserDefaults
        if let countries = userDefaultsManager.get(forKey: "savedCountries", as: Countries.self) {
            presenter?.didFetchCountryList(countries)
        } else {
            // Si no hay datos en UserDefaults, hacer la llamada a la API
            do {
                let countries = try await service.fetchCountryList()
                presenter?.didFetchCountryList(countries)
                userDefaultsManager.save(object: countries, forKey: "savedCountries") // Guardar en UserDefaults después de obtenerlo
            } catch {
                presenter?.didFailWithError(error)
                throw error
            }
        }
    }
}


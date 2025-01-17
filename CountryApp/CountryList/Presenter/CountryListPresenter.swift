//
//  CountryListPresenter.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

class CountryListPresenter: CountryListPresenterProtocol {
    weak var view: CountryListViewProtocol?
    var interactor: CountryListInteractorProtocol?
    private var allCountries: Countries = []

    func fetchCountryList() async {
        guard let interactor = interactor else {
            didFailWithError(CountryListError.interactorUnavailable)
            return
        }
        
        view?.showLoadingView()
        do {
            try await interactor.fetchCountryList()
        } catch {
            didFailWithError(error)
        }
    }

    internal func didFetchCountryList(_ countries: Countries) {
        self.allCountries = sortCountries(countries)
        DispatchQueue.main.async {
            self.view?.displayCountryList(self.allCountries)
            self.view?.hideLoadingView()
        }
    }

    func filterCountries(by query: String) {
        let filteredCountries = query.isEmpty ?
            allCountries :
            allCountries.filter { $0.name.common.lowercased().contains(query.lowercased()) }

        DispatchQueue.main.async {
            self.view?.displayFilteredCountries(filteredCountries)
        }
    }

    private func sortCountries(_ countries: Countries) -> Countries {
        return countries.sorted { $0.name.common < $1.name.common }
    }

    internal func didFailWithError(_ error: Error) {
        let errorMessage: String
        if let countryListError = error as? CountryListError {
            errorMessage = {
                switch countryListError {
                case .interactorUnavailable: return "El interactor no está disponible. Por favor, intenta más tarde."
                case .invalidResponse: return "La respuesta del servidor no es válida."
                case .unknownError: return "Ocurrió un error desconocido."
                }
            }()
        } else {
            errorMessage = "Ocurrió un error inesperado: \(error.localizedDescription)"
        }
        
        DispatchQueue.main.async {
            self.view?.displayError(errorMessage)
            self.view?.hideLoadingView()
        }
    }
}

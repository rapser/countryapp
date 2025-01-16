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

    func didFetchCountryList(_ countries: Countries) {
        DispatchQueue.main.async {
            self.allCountries = countries.sorted(by: { $0.name.common < $1.name.common })
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

    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            if let countryListError = error as? CountryListError {
                switch countryListError {
                case .interactorUnavailable:
                    self.view?.displayError("El interactor no está disponible. Por favor, intenta más tarde.")
                case .invalidResponse:
                    self.view?.displayError("La respuesta del servidor no es válida.")
                case .unknownError:
                    self.view?.displayError("Ocurrió un error desconocido.")
                }
            } else {
                self.view?.displayError("Ocurrió un error inesperado: \(error.localizedDescription)")
            }
            self.view?.hideLoadingView()
        }
    }

    func fetchCountryList() async {
        guard let interactor = interactor else {
            didFailWithError(CountryListError.interactorUnavailable)
            return
        }

        do {
            try await interactor.fetchCountryList()
        } catch {
            didFailWithError(error)
        }
    }
}

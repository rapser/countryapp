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

    // Notifica a la vista cuando se obtiene la lista de países
    func didFetchCountryList(_ countries: [Country]) {
        DispatchQueue.main.async {
            self.view?.displayCountryList(countries)
            self.view?.hideLoadingView()
        }
    }

    // Notifica a la vista cuando ocurre un error
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

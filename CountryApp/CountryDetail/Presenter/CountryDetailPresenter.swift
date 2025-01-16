//
//  CountryDetailPresenter.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

class CountryDetailPresenter: CountryDetailPresenterProtocol {
    weak var view: CountryDetailViewProtocol?
    var interactor: CountryDetailInteractorProtocol?
    var router: CountryDetailRouterProtocol?
    var countryName: String?

    func fetchCountryDetail() async {
        guard let countryName = countryName else {
            didFailWithError(CountryDetailError.countryNameUnavailable)
            return
        }

        do {
            try await interactor?.fetchCountryDetail(name: countryName)
        } catch {
            didFailWithError(error)
        }
    }

    func didFetchCountryDetail(_ countryDetail: CountryDetail) {
        DispatchQueue.main.async {
            self.view?.displayCountryDetail(countryDetail)
            self.view?.hideLoadingView()
        }
    }

    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            if let countryDetailError = error as? CountryDetailError {
                switch countryDetailError {
                case .countryNameUnavailable:
                    self.view?.displayError("El nombre del país no está disponible. Por favor, intenta más tarde.")
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
}


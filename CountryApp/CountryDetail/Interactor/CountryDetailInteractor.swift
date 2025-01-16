//
//  CountryDetailInteractor.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

class CountryDetailInteractor: CountryDetailInteractorProtocol {
    var presenter: CountryDetailPresenterProtocol?
    private let service: CountryDetailService

    init(service: CountryDetailService) {
        self.service = service
    }

    func fetchCountryDetail(name: String) async throws {
        guard !name.isEmpty else {
            throw CountryDetailError.countryNameUnavailable
        }

        do {
            let countryDetail = try await service.fetchCountryDetail(by: name)
            presenter?.didFetchCountryDetail(countryDetail)  // Notifica al Presenter con los resultados
        } catch {
            presenter?.didFailWithError(CountryDetailError.unknownError)  // Maneja el error y lo notifica al Presenter
            throw CountryDetailError.unknownError  // Propaga el error
        }
    }
}

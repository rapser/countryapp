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
            let error = CountryDetailError.countryNameUnavailable
            presenter?.didFailWithError(error)
            throw error
        }

        do {
            let countryDetail = try await service.fetchCountryDetail(by: name)
            presenter?.didFetchCountryDetail(countryDetail)
        } catch {
            let error = CountryDetailError.unknownError
            presenter?.didFailWithError(error)
            throw error
        }
    }
}

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
            presenter?.didFetchCountryDetail(countryDetail)
        } catch {
            presenter?.didFailWithError(CountryDetailError.unknownError)
            throw CountryDetailError.unknownError
        }
    }
}

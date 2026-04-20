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
        do {
            guard !name.isEmpty else {
                throw CountryDetailError.countryNameUnavailable
            }

            let allDetails = try await service.fetchAllCountryDetails()
            let normalizedQuery = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let match = allDetails.first { $0.name.common.lowercased() == normalizedQuery }
            guard let match else {
                throw CountryDetailError.invalidResponse
            }
            presenter?.didFetchCountryDetail([match])
        } catch let error as CountryDetailError {
            presenter?.didFailWithError(error)
            throw error
        } catch {
            let error = CountryDetailError.unknownError
            presenter?.didFailWithError(error)
            throw error
        }
    }
}

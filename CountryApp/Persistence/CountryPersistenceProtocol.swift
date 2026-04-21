//
//  CountryPersistenceProtocol.swift
//  CountryApp
//

import Foundation

protocol CountryPersistenceProtocol: AnyObject {
    func fetchPersistedCountries() throws -> [PersistedCountry]
    func replaceAll(from countries: [Country]) throws
    func persistedCount() throws -> Int
}

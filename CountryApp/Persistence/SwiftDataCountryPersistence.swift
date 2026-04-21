//
//  SwiftDataCountryPersistence.swift
//  CountryApp
//

import Foundation
import SwiftData

final class SwiftDataCountryPersistence: CountryPersistenceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchPersistedCountries() throws -> [PersistedCountry] {
        let descriptor = FetchDescriptor<PersistedCountry>(
            sortBy: [SortDescriptor(\.commonName, comparator: .localizedStandard)]
        )
        return try modelContext.fetch(descriptor)
    }

    func replaceAll(from countries: [Country]) throws {
        let existing = try modelContext.fetch(FetchDescriptor<PersistedCountry>())
        existing.forEach { modelContext.delete($0) }
        let now = Date()
        for country in countries {
            let code = country.resolvedFlagAssetCode
            guard !code.isEmpty else { continue }
            let spanish = country.name.nameSpanish?.trimmingCharacters(in: .whitespacesAndNewlines)
            let capitalSpanishFirst = country.capitalSpanish?.first?.trimmingCharacters(in: .whitespacesAndNewlines)
            let capitalFirst = country.capital?.first?.trimmingCharacters(in: .whitespacesAndNewlines)
            let capitalLine: String? = {
                if let c = capitalSpanishFirst, !c.isEmpty { return c }
                if let c = capitalFirst, !c.isEmpty { return c }
                return nil
            }()
            modelContext.insert(
                PersistedCountry(
                    flagAssetCode: code,
                    commonName: country.name.common,
                    officialName: country.name.official,
                    capitalSummary: capitalLine,
                    spanishCommonName: (spanish?.isEmpty == false) ? spanish : nil,
                    syncedAt: now
                )
            )
        }
        try modelContext.save()
    }

    func persistedCount() throws -> Int {
        let descriptor = FetchDescriptor<PersistedCountry>()
        return try modelContext.fetchCount(descriptor)
    }
}

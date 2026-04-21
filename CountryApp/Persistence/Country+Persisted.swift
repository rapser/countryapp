//
//  Country+Persisted.swift
//  CountryApp
//

import Foundation

extension Country {
    static func from(persisted: PersistedCountry) -> Country {
        Country(
            name: Name(common: persisted.commonName, official: persisted.officialName, nameSpanish: persisted.spanishCommonName),
            capital: persisted.capitalSummary.map { [$0] },
            cca2: nil,
            assetFlag: persisted.flagAssetCode
        )
    }
}

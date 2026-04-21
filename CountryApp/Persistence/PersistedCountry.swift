//
//  PersistedCountry.swift
//  CountryApp
//

import Foundation
import SwiftData

@Model
final class PersistedCountry {
    @Attribute(.unique) var flagAssetCode: String
    var commonName: String
    var officialName: String
    /// Nombre común en español para el juego de banderas (`name.nameSpanish` en el API).
    var spanishCommonName: String?
    var capitalSummary: String?
    var syncedAt: Date

    init(
        flagAssetCode: String,
        commonName: String,
        officialName: String,
        capitalSummary: String?,
        spanishCommonName: String? = nil,
        syncedAt: Date
    ) {
        self.flagAssetCode = flagAssetCode
        self.commonName = commonName
        self.officialName = officialName
        self.capitalSummary = capitalSummary
        self.spanishCommonName = spanishCommonName
        self.syncedAt = syncedAt
    }

    /// Nombre mostrado en el juego de banderas: español si viene en el JSON, si no el común (inglés).
    var flagGameDisplayName: String {
        if let s = spanishCommonName?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty {
            return s
        }
        return commonName
    }
}

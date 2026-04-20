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
    var capitalSummary: String?
    var syncedAt: Date

    init(flagAssetCode: String, commonName: String, officialName: String, capitalSummary: String?, syncedAt: Date) {
        self.flagAssetCode = flagAssetCode
        self.commonName = commonName
        self.officialName = officialName
        self.capitalSummary = capitalSummary
        self.syncedAt = syncedAt
    }
}

//
//  CapitalGameModels.swift
//  CountryApp
//

import Foundation

enum CapitalGameError: Error {
    case notEnoughCountries
    case loadFailed
}

struct CapitalQuizQuestion: Equatable {
    let flagAssetCode: String
    let countryName: String
    /// Four capital names in display order; `correctIndex` indexes this array.
    let options: [String]
    let correctIndex: Int
}


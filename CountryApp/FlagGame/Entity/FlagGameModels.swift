//
//  FlagGameModels.swift
//  CountryApp
//

import Foundation

enum FlagGameError: Error {
    case notEnoughCountries
    case loadFailed
}

struct QuizQuestion: Equatable {
    let flagAssetCode: String
    /// Four country names in display order; `correctIndex` indexes this array.
    let options: [String]
    let correctIndex: Int
}

struct GameSummary: Equatable {
    let correctCount: Int
    let wrongCount: Int
    let skippedCount: Int
    let duration: TimeInterval
    /// +10 per correct, −5 per wrong, 0 per skip.
    let score: Int
    /// Nombre del país (respuesta correcta) por cada acierto, en orden.
    let correctCountryNames: [String]
    /// País que debías acertar en cada fallo, en orden.
    let wrongCountryNames: [String]
    /// País que saltaste (debías repasar), en orden.
    let skippedCountryNames: [String]

    /// Países a repasar: fallos y saltadas, sin duplicar, conservando el orden de aparición.
    var countryNamesToReview: [String] {
        Self.orderedUnique(wrongCountryNames + skippedCountryNames)
    }

    private static func orderedUnique(_ names: [String]) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        for name in names {
            let key = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !key.isEmpty else { continue }
            if seen.insert(key).inserted {
                out.append(name)
            }
        }
        return out
    }
}

//
//  FlagGameModels.swift
//  CountryApp
//

import Foundation

enum FlagGameError: Error {
    case notEnoughCountries
    case loadFailed
}

enum FlagGameRound {
    /// Banderas distintas por partida.
    static let questionsPerRound = 20
}

struct QuizQuestion: Equatable {
    let flagAssetCode: String
    /// Four country names in display order; `correctIndex` indexes this array.
    let options: [String]
    let correctIndex: Int
}

/// País + código de asset de bandera para el resumen.
struct SummaryFlagRow: Equatable {
    let countryName: String
    let flagAssetCode: String
}

enum FlagGameTiming {
    /// Si tardas más de este tiempo en confirmar un acierto, se cuenta como «duda».
    static let doubtAnswerThresholdSeconds: TimeInterval = 15
}

struct GameSummary: Equatable {
    let correctCount: Int
    let wrongCount: Int
    let skippedCount: Int
    let duration: TimeInterval
    /// +10 per correct, −5 per wrong, 0 per skip (solo diagnóstico / logs).
    let score: Int
    /// País que debías acertar en cada fallo, en orden.
    let wrongCountryNames: [String]
    /// País que saltaste, en orden.
    let skippedCountryNames: [String]
    /// Fallos y saltos: qué banderas repasar (sin duplicar por nombre).
    let reviewFlagRows: [SummaryFlagRow]
    /// Aciertos con tiempo de respuesta ≤ `FlagGameTiming.doubtAnswerThresholdSeconds`.
    let clearCorrectRows: [SummaryFlagRow]
    /// Aciertos correctos pero con respuesta lenta (duda).
    let doubtCorrectRows: [SummaryFlagRow]

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

    static func orderedUniqueFlagRows(_ rows: [SummaryFlagRow]) -> [SummaryFlagRow] {
        var seen = Set<String>()
        var out: [SummaryFlagRow] = []
        for row in rows {
            let key = row.countryName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !key.isEmpty else { continue }
            if seen.insert(key).inserted {
                out.append(row)
            }
        }
        return out
    }
}

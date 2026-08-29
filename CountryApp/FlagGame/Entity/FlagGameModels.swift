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
    /// Probabilidad de que una pregunta sea de un territorio/colonia en vez de un país independiente.
    static let territoryProbability = 0.02
    /// Cantidad de rondas recientes a excluir para evitar repetir país antes de jugar esa cantidad de partidas.
    static let recentRoundsTracked = 4
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

/// Puntuación con bonus por rapidez. Compartida por FlagGame y CapitalGame.
enum FlagGameScoring {
    /// Puntos fijos por respuesta correcta.
    static let basePointsPerCorrect = 500
    /// Bonus máximo por responder al instante.
    static let maxSpeedBonus = 500
    /// El bonus decae linealmente hasta 0 a lo largo de esta ventana.
    static let speedBonusWindowSeconds: TimeInterval = 10

    /// Puntos otorgados por una pregunta. 0 si se falló; base + bonus (múltiplo de 5) si se acertó.
    static func points(correct: Bool, responseTime: TimeInterval) -> Int {
        guard correct else { return 0 }
        let clamped = max(0, min(responseTime, speedBonusWindowSeconds))
        let bonus = Double(maxSpeedBonus) * (1 - clamped / speedBonusWindowSeconds)
        return basePointsPerCorrect + (Int(bonus.rounded()) / 5) * 5
    }
}

struct GameSummary: Equatable {
    let correctCount: Int
    let wrongCount: Int
    let skippedCount: Int
    let duration: TimeInterval
    /// Puntos totales acumulados en la ronda (base + bonus por rapidez, ver `FlagGameScoring`).
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

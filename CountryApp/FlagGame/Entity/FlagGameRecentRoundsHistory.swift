//
//  FlagGameRecentRoundsHistory.swift
//  CountryApp
//

import Foundation

/// Evita repetir las mismas banderas en la ronda principal durante las **tres** partidas siguientes a la que las usó.
enum FlagGameRecentRoundsHistory {
    private static let defaults = UserDefaults.standard
    private static let storageKey = "CountryApp.FlagGame.lastThreeRoundFlagAssetCodes"
    private static let maxStoredRounds = 3

    /// Códigos de asset de bandera usados en las últimas partidas guardadas (unión de hasta 3 partidas).
    static func excludedFlagAssetCodes() -> Set<String> {
        Set(loadRounds().flatMap { $0 })
    }

    /// Registra los códigos de bandera de una partida ya construida (normalmente las 20 preguntas), antes de empezar la siguiente.
    static func appendCompletedRound(flagAssetCodes: [String]) {
        guard !flagAssetCodes.isEmpty else { return }
        var rounds = loadRounds()
        rounds.append(flagAssetCodes)
        while rounds.count > maxStoredRounds {
            rounds.removeFirst()
        }
        saveRounds(rounds)
    }

    static func resetForTesting() {
        defaults.removeObject(forKey: storageKey)
    }

    private static func loadRounds() -> [[String]] {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([[String]].self, from: data) else {
            return []
        }
        return decoded
    }

    private static func saveRounds(_ rounds: [[String]]) {
        guard let data = try? JSONEncoder().encode(rounds) else { return }
        defaults.set(data, forKey: storageKey)
    }
}

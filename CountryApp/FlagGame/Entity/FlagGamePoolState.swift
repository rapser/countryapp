//
//  FlagGamePoolState.swift
//  CountryApp
//

import Foundation

/// Estado persistido del algoritmo de selección del juego (para evitar repeticiones entre partidas).
///
/// Reglas:
/// - Mientras haya países en `remainingFlagCodes`, las preguntas se eligen solo de ahí (sin repetición global).
/// - Cuando `remainingFlagCodes` se agota, se crea un nuevo ciclo con todos los países **menos** los usados
///   en las últimas `FlagGameRound.recentRoundsTracked` partidas.
/// - `recentRoundsFlagCodes` también amplía la exclusión en el fallback de relleno del interactor.
enum FlagGamePoolState {
    private static let defaults = UserDefaults.standard

    private static let remainingKey       = "CountryApp.FlagGame.pool.remainingFlagCodes"
    private static let recentRoundsKey    = "CountryApp.FlagGame.pool.recentRoundsFlagCodes"
    private static let fingerprintKey     = "CountryApp.FlagGame.pool.datasetFingerprint"

    static func resetForTesting() {
        defaults.removeObject(forKey: remainingKey)
        defaults.removeObject(forKey: recentRoundsKey)
        defaults.removeObject(forKey: fingerprintKey)
    }

    struct State: Equatable {
        var datasetFingerprint: String
        var remainingFlagCodes: Set<String>
        /// Últimas rondas completadas, más antigua primero. Tope: `FlagGameRound.recentRoundsTracked`.
        var recentRoundsFlagCodes: [Set<String>]

        var recentRoundsUnion: Set<String> {
            recentRoundsFlagCodes.reduce(into: Set<String>()) { $0.formUnion($1) }
        }
    }

    static func loadOrInitialize(availableFlagCodes: Set<String>) -> State {
        let fingerprint = fingerprint(for: availableFlagCodes)
        var state = load() ?? State(
            datasetFingerprint: fingerprint,
            remainingFlagCodes: availableFlagCodes,
            recentRoundsFlagCodes: []
        )

        if state.datasetFingerprint != fingerprint {
            state = State(
                datasetFingerprint: fingerprint,
                remainingFlagCodes: availableFlagCodes,
                recentRoundsFlagCodes: []
            )
            save(state)
            return state
        }

        state.remainingFlagCodes = state.remainingFlagCodes.intersection(availableFlagCodes)
        state.recentRoundsFlagCodes = state.recentRoundsFlagCodes.map { $0.intersection(availableFlagCodes) }

        if state.remainingFlagCodes.isEmpty {
            let next = availableFlagCodes.subtracting(state.recentRoundsUnion)
            state.remainingFlagCodes = next.isEmpty ? availableFlagCodes : next
        }

        save(state)
        return state
    }

    static func registerCompletedRound(_ roundFlagCodes: Set<String>, availableFlagCodes: Set<String>) {
        guard !roundFlagCodes.isEmpty else { return }
        var state = loadOrInitialize(availableFlagCodes: availableFlagCodes)
        state.remainingFlagCodes.subtract(roundFlagCodes)
        state.recentRoundsFlagCodes.append(roundFlagCodes)
        while state.recentRoundsFlagCodes.count > FlagGameRound.recentRoundsTracked {
            state.recentRoundsFlagCodes.removeFirst()
        }
        save(state)
    }

    private static func load() -> State? {
        guard
            let fp            = defaults.string(forKey: fingerprintKey),
            let remainingData = defaults.data(forKey: remainingKey),
            let recentData    = defaults.data(forKey: recentRoundsKey),
            let remaining     = try? JSONDecoder().decode([String].self, from: remainingData),
            let recentRounds  = try? JSONDecoder().decode([[String]].self, from: recentData)
        else { return nil }

        return State(
            datasetFingerprint: fp,
            remainingFlagCodes: Set(remaining),
            recentRoundsFlagCodes: recentRounds.map(Set.init)
        )
    }

    private static func save(_ state: State) {
        defaults.set(state.datasetFingerprint, forKey: fingerprintKey)
        if let d = try? JSONEncoder().encode(Array(state.remainingFlagCodes)) { defaults.set(d, forKey: remainingKey) }
        if let d = try? JSONEncoder().encode(state.recentRoundsFlagCodes.map { Array($0) }) {
            defaults.set(d, forKey: recentRoundsKey)
        }
    }

    private static func fingerprint(for codes: Set<String>) -> String {
        codes.sorted().joined(separator: "|")
    }
}

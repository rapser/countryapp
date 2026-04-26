//
//  FlagGamePoolState.swift
//  CountryApp
//

import Foundation

/// Estado persistido del algoritmo de selección del juego (para evitar repeticiones entre partidas).
///
/// Reglas:
/// - Mientras haya países en `remainingFlagCodes`, las preguntas se eligen solo de ahí (sin repetición global).
/// - Cuando `remainingFlagCodes` se agota, se crea un nuevo ciclo con todos los países **menos** los de la última partida.
/// - Si en la última partida del ciclo faltan países para completar 20, los “faltantes” pueden venir de cualquier país,
///   incluyendo la penúltima partida, pero **no** de la última (siempre que sea posible).
enum FlagGamePoolState {
    private static let defaults = UserDefaults.standard

    private static let remainingKey = "CountryApp.FlagGame.pool.remainingFlagCodes"
    private static let lastRoundKey = "CountryApp.FlagGame.pool.lastRoundFlagCodes"
    private static let fingerprintKey = "CountryApp.FlagGame.pool.datasetFingerprint"

    static func resetForTesting() {
        defaults.removeObject(forKey: remainingKey)
        defaults.removeObject(forKey: lastRoundKey)
        defaults.removeObject(forKey: fingerprintKey)
    }

    struct State: Equatable {
        var datasetFingerprint: String
        var remainingFlagCodes: Set<String>
        var lastRoundFlagCodes: Set<String>
    }

    static func loadOrInitialize(availableFlagCodes: Set<String>) -> State {
        let fingerprint = fingerprint(for: availableFlagCodes)
        var state = load() ?? State(datasetFingerprint: fingerprint, remainingFlagCodes: availableFlagCodes, lastRoundFlagCodes: [])

        if state.datasetFingerprint != fingerprint {
            state = State(datasetFingerprint: fingerprint, remainingFlagCodes: availableFlagCodes, lastRoundFlagCodes: [])
            save(state)
            return state
        }

        // Normaliza: si el set de disponibles cambió (sin cambiar fingerprint por cualquier razón),
        // intersectamos para no mantener códigos inexistentes.
        state.remainingFlagCodes = state.remainingFlagCodes.intersection(availableFlagCodes)
        state.lastRoundFlagCodes = state.lastRoundFlagCodes.intersection(availableFlagCodes)

        if state.remainingFlagCodes.isEmpty {
            // Reinicio de ciclo: excluye la última partida del nuevo pool.
            let next = availableFlagCodes.subtracting(state.lastRoundFlagCodes)
            state.remainingFlagCodes = next.isEmpty ? availableFlagCodes : next
        }

        save(state)
        return state
    }

    static func registerCompletedRound(_ roundFlagCodes: Set<String>, availableFlagCodes: Set<String>) {
        guard !roundFlagCodes.isEmpty else { return }
        var state = loadOrInitialize(availableFlagCodes: availableFlagCodes)
        // Elimina de remaining lo que haya sido usado.
        state.remainingFlagCodes.subtract(roundFlagCodes)
        // Guarda última partida.
        state.lastRoundFlagCodes = roundFlagCodes
        save(state)
    }

    private static func load() -> State? {
        guard
            let fp = defaults.string(forKey: fingerprintKey),
            let remainingData = defaults.data(forKey: remainingKey),
            let lastData = defaults.data(forKey: lastRoundKey),
            let remaining = try? JSONDecoder().decode([String].self, from: remainingData),
            let last = try? JSONDecoder().decode([String].self, from: lastData)
        else {
            return nil
        }
        return State(datasetFingerprint: fp, remainingFlagCodes: Set(remaining), lastRoundFlagCodes: Set(last))
    }

    private static func save(_ state: State) {
        defaults.set(state.datasetFingerprint, forKey: fingerprintKey)
        if let remainingData = try? JSONEncoder().encode(Array(state.remainingFlagCodes)) {
            defaults.set(remainingData, forKey: remainingKey)
        }
        if let lastData = try? JSONEncoder().encode(Array(state.lastRoundFlagCodes)) {
            defaults.set(lastData, forKey: lastRoundKey)
        }
    }

    private static func fingerprint(for codes: Set<String>) -> String {
        // Estable y simple: lista ordenada unida.
        // Si en el futuro quieres más robustez, esto puede cambiarse a un hash.
        codes.sorted().joined(separator: "|")
    }
}


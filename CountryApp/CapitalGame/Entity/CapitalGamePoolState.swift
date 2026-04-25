//
//  CapitalGamePoolState.swift
//  CountryApp
//

import Foundation

/// Pool persistido para el juego de capitales (misma regla que banderas, pero namespace distinto).
enum CapitalGamePoolState {
    private static let defaults = UserDefaults.standard

    private static let remainingKey = "CountryApp.CapitalGame.pool.remainingFlagCodes"
    private static let lastRoundKey = "CountryApp.CapitalGame.pool.lastRoundFlagCodes"
    private static let fingerprintKey = "CountryApp.CapitalGame.pool.datasetFingerprint"

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

        state.remainingFlagCodes = state.remainingFlagCodes.intersection(availableFlagCodes)
        state.lastRoundFlagCodes = state.lastRoundFlagCodes.intersection(availableFlagCodes)

        if state.remainingFlagCodes.isEmpty {
            let next = availableFlagCodes.subtracting(state.lastRoundFlagCodes)
            state.remainingFlagCodes = next.isEmpty ? availableFlagCodes : next
        }

        save(state)
        return state
    }

    static func registerCompletedRound(_ roundFlagCodes: Set<String>, availableFlagCodes: Set<String>) {
        guard !roundFlagCodes.isEmpty else { return }
        var state = loadOrInitialize(availableFlagCodes: availableFlagCodes)
        state.remainingFlagCodes.subtract(roundFlagCodes)
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
        else { return nil }

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
        codes.sorted().joined(separator: "|")
    }
}


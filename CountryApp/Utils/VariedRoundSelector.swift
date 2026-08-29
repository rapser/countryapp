//
//  VariedRoundSelector.swift
//  CountryApp
//

import Foundation

/// Requisitos mínimos para que un tipo pueda pasar por `VariedRoundSelector`.
protocol FlagCodeIdentifiable {
    var flagAssetCode: String { get }
    /// Clave usada para el muestreo alfabético por buckets (`variedSample`).
    var alphabeticBucketKey: String { get }
}

/// Motor de selección de rondas compartido por FlagGame y CapitalGame.
///
/// Garantiza:
///   1. Ningún país comparte bandera visual con otro ya elegido en la misma ronda (dedup por `FlagSynonymGroups`).
///   2. Si el pool primario no alcanza, completa desde el fallback evitando las rondas recientes.
///   3. Del total de la ronda, solo una fracción pequeña (`territoryProbability`) proviene de territorios/colonias
///      (ver `TerritoryCountryCodes`); el resto son países independientes.
enum VariedRoundSelector {
    static func pickWeightedRound<T: FlagCodeIdentifiable>(
        primaryPool: [T],
        fallbackPool: [T],
        lastRoundExcluded: Set<String>,
        count: Int,
        territoryProbability: Double = FlagGameRound.territoryProbability,
        isIndependent: (String) -> Bool = TerritoryCountryCodes.isIndependent
    ) -> [T] {
        guard count > 0 else { return [] }

        let independentPrimary  = primaryPool.filter  { isIndependent($0.flagAssetCode) }
        let territoryPrimary    = primaryPool.filter  { !isIndependent($0.flagAssetCode) }
        let independentFallback = fallbackPool.filter { isIndependent($0.flagAssetCode) }
        let territoryFallback   = fallbackPool.filter { !isIndependent($0.flagAssetCode) }

        let territoryPoolSize = deduplicateSameFlag(territoryFallback).count
        let territoryQuota = rollTerritoryQuota(count: count, poolSize: territoryPoolSize, probability: territoryProbability)
        let independentQuota = count - territoryQuota

        let independentPicked = pickVariedRound(
            primaryPool: independentPrimary,
            fallbackPool: independentFallback,
            lastRoundExcluded: lastRoundExcluded,
            count: independentQuota
        )

        var picked = independentPicked
        if territoryQuota > 0 {
            // Evita mostrar la misma bandera visual dos veces (ej. Francia + Mayotte) cuando el
            // representante independiente de un grupo de sinónimos ya fue elegido.
            let independentSynonyms = independentPicked.reduce(into: Set<String>()) {
                $0.formUnion(FlagSynonymGroups.synonyms(for: $1.flagAssetCode))
            }
            let filteredTerritoryPrimary = territoryPrimary.filter { !independentSynonyms.contains($0.flagAssetCode) }
            let filteredTerritoryFallback = territoryFallback.filter { !independentSynonyms.contains($0.flagAssetCode) }

            let territoryPicked = pickVariedRound(
                primaryPool: filteredTerritoryPrimary,
                fallbackPool: filteredTerritoryFallback,
                lastRoundExcluded: lastRoundExcluded,
                count: territoryQuota
            )
            picked.append(contentsOf: territoryPicked)
        }

        if picked.count < count {
            picked.append(contentsOf: topUp(needed: count - picked.count, alreadyPicked: picked, fallbackPool: fallbackPool))
        }

        return Array(picked.shuffled().prefix(count))
    }

    private static func rollTerritoryQuota(count: Int, poolSize: Int, probability: Double) -> Int {
        guard poolSize > 0, probability > 0 else { return 0 }
        let hits = (0..<count).reduce(0) { acc, _ in acc + (Double.random(in: 0..<1) < probability ? 1 : 0) }
        return min(hits, poolSize)
    }

    /// Último recurso: rellena ignorando el split independiente/territorio, evitando sinónimos visuales ya elegidos.
    private static func topUp<T: FlagCodeIdentifiable>(needed: Int, alreadyPicked: [T], fallbackPool: [T]) -> [T] {
        let occupiedSynonyms = alreadyPicked.reduce(into: Set<String>()) {
            $0.formUnion(FlagSynonymGroups.synonyms(for: $1.flagAssetCode))
        }
        let alreadyCodes = Set(alreadyPicked.map(\.flagAssetCode))
        let eligible = deduplicateSameFlag(fallbackPool).filter {
            !occupiedSynonyms.contains($0.flagAssetCode) && !alreadyCodes.contains($0.flagAssetCode)
        }
        return variedSample(from: eligible, count: min(needed, eligible.count))
    }

    // MARK: - Pool selection (genérico, movido desde FlagGameInteractor)

    /// Elige `count` elementos garantizando:
    ///   1. Ningún elemento comparte bandera visual con otro ya elegido (deduplica grupos de sinónimos).
    ///   2. Si el pool primario no alcanza, completa desde el fallback evitando las rondas recientes.
    static func pickVariedRound<T: FlagCodeIdentifiable>(
        primaryPool: [T],
        fallbackPool: [T],
        lastRoundExcluded: Set<String>,
        count: Int
    ) -> [T] {
        guard count > 0 else { return [] }

        let dedupedPrimary  = deduplicateSameFlag(primaryPool)
        let dedupedFallback = deduplicateSameFlag(fallbackPool)

        let primaryPicked = variedSample(from: dedupedPrimary, count: min(count, dedupedPrimary.count))
        if primaryPicked.count >= count {
            return Array(primaryPicked.prefix(count))
        }

        var picked = primaryPicked
        let pickedCodes = Set(picked.map(\.flagAssetCode))
        let pickedSynonyms = pickedCodes.reduce(into: Set<String>()) { acc, code in
            acc.formUnion(FlagSynonymGroups.synonyms(for: code))
        }

        let eligibleFill = dedupedFallback.filter {
            !pickedSynonyms.contains($0.flagAssetCode) && !lastRoundExcluded.contains($0.flagAssetCode)
        }
        let fillNeeded = count - picked.count
        let fill = variedSample(from: eligibleFill, count: min(fillNeeded, eligibleFill.count))
        picked.append(contentsOf: fill)

        if picked.count >= count {
            return Array(picked.prefix(count))
        }

        // Último fallback: si el dataset es pequeño, admite cualquiera no elegido.
        let pickedSynonyms2 = Set(picked.map(\.flagAssetCode)).reduce(into: Set<String>()) { acc, code in
            acc.formUnion(FlagSynonymGroups.synonyms(for: code))
        }
        let eligibleAny = dedupedFallback.filter { !pickedSynonyms2.contains($0.flagAssetCode) }
        let fill2Needed = count - picked.count
        picked.append(contentsOf: variedSample(from: eligibleAny, count: min(fill2Needed, eligibleAny.count)))
        return Array(picked.prefix(count))
    }

    /// Filtra el pool para que haya como máximo un representante por grupo de banderas idénticas.
    /// El representante se elige al azar (shuffle previo), por lo que varía en cada partida.
    static func deduplicateSameFlag<T: FlagCodeIdentifiable>(_ pool: [T]) -> [T] {
        var seenGroupIndices = Set<Int>()
        var result: [T] = []
        for snapshot in pool.shuffled() {
            if let groupIdx = FlagSynonymGroups.groups.firstIndex(where: { $0.contains(snapshot.flagAssetCode) }) {
                if seenGroupIndices.insert(groupIdx).inserted {
                    result.append(snapshot)
                }
                // else: ya hay un representante de este grupo, descarta.
            } else {
                result.append(snapshot)
            }
        }
        return result
    }

    /// Muestreo round-robin por buckets de primera letra para maximizar diversidad alfabética.
    static func variedSample<T: FlagCodeIdentifiable>(from pool: [T], count: Int) -> [T] {
        guard count > 0, !pool.isEmpty else { return [] }
        var buckets: [String: [T]] = [:]
        for s in pool {
            let key = String(s.alphabeticBucketKey.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().prefix(1))
            buckets[key, default: []].append(s)
        }
        var keys = buckets.keys.sorted()
        keys.shuffle()
        keys.forEach { buckets[$0]?.shuffle() }

        var out: [T] = []
        var idx = 0
        while out.count < count, !keys.isEmpty {
            let k = keys[idx % keys.count]
            if var arr = buckets[k], !arr.isEmpty {
                out.append(arr.removeLast())
                buckets[k] = arr
            }
            keys = keys.filter { buckets[$0]?.isEmpty == false }
            idx += 1
        }
        if out.count < count {
            let leftover = pool.shuffled().filter { cand in
                !out.contains(where: { $0.flagAssetCode == cand.flagAssetCode })
            }
            out.append(contentsOf: leftover.prefix(count - out.count))
        }
        return out
    }
}

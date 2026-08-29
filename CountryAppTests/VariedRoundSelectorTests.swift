//
//  VariedRoundSelectorTests.swift
//  CountryAppTests
//

import XCTest
@testable import CountryApp

private struct TestFlagItem: FlagCodeIdentifiable, Equatable {
    let flagAssetCode: String
    var alphabeticBucketKey: String { flagAssetCode }
}

final class VariedRoundSelectorTests: XCTestCase {

    // MARK: - Territory ratio

    func testPickWeightedRound_territoryRatioStaysLowAcrossManyRounds() {
        let independents = (0..<40).map { TestFlagItem(flagAssetCode: "ind\($0)") }
        let territories = (0..<10).map { TestFlagItem(flagAssetCode: "ter\($0)") }
        let pool = independents + territories
        let isIndependent: (String) -> Bool = { !$0.hasPrefix("ter") }

        var territoryPicks = 0
        var totalPicks = 0
        let trials = 600
        for _ in 0..<trials {
            let round = VariedRoundSelector.pickWeightedRound(
                primaryPool: pool,
                fallbackPool: pool,
                lastRoundExcluded: [],
                count: 20,
                territoryProbability: 0.02,
                isIndependent: isIndependent
            )
            totalPicks += round.count
            territoryPicks += round.filter { !isIndependent($0.flagAssetCode) }.count
        }

        let ratio = Double(territoryPicks) / Double(totalPicks)
        XCTAssertGreaterThan(territoryPicks, 0, "En \(trials) rondas simuladas debería aparecer al menos un territorio")
        XCTAssertLessThan(ratio, 0.08, "La proporción de territorios debería mantenerse baja (objetivo ~2%)")
    }

    // MARK: - Cross-pool synonym guard

    func testPickWeightedRound_neverCombinesIndependentAndTerritorySynonyms() {
        // Grupo real de Francia: "fr" independiente + "gf"/"gp"/"mq"/"re" territorio (mismo dibujo de bandera).
        let franceGroup = ["fr", "gf", "gp", "mq", "re"]
        let filler = (0..<30).map { TestFlagItem(flagAssetCode: "filler\($0)") }
        let pool = franceGroup.map { TestFlagItem(flagAssetCode: $0) } + filler
        let isIndependent: (String) -> Bool = { $0 == "fr" || $0.hasPrefix("filler") }

        for _ in 0..<300 {
            let round = VariedRoundSelector.pickWeightedRound(
                primaryPool: pool,
                fallbackPool: pool,
                lastRoundExcluded: [],
                count: 10,
                territoryProbability: 0.5, // alta, para forzar que el pool de territorio se consuma seguido
                isIndependent: isIndependent
            )
            let codes = Set(round.map(\.flagAssetCode))
            if codes.contains("fr") {
                XCTAssertTrue(
                    codes.isDisjoint(with: ["gf", "gp", "mq", "re"]),
                    "No debería coexistir 'fr' con sus sinónimos visuales en la misma ronda"
                )
            }
        }
    }

    // MARK: - Emergency top-up

    func testPickWeightedRound_fillsExactCountEvenWhenSplitCannotBeSatisfied() {
        // Dataset chico: el split 98/2 por sí solo no garantiza territoryQuota, pero igual debe
        // devolver `count` elementos sin duplicados de bandera ni de grupo de sinónimos.
        let pool = (0..<22).map { TestFlagItem(flagAssetCode: "c\($0)") }

        let round = VariedRoundSelector.pickWeightedRound(
            primaryPool: pool,
            fallbackPool: pool,
            lastRoundExcluded: [],
            count: 20
        )

        XCTAssertEqual(round.count, 20)
        let codes = round.map(\.flagAssetCode)
        XCTAssertEqual(Set(codes).count, codes.count, "No debería haber banderas duplicadas")
    }
}

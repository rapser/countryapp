//
//  CapitalGameInteractorTests.swift
//  CountryAppTests
//

import SwiftData
import XCTest
@testable import CountryApp

final class CapitalGameInteractorTests: XCTestCase {

    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!

    override func setUp() {
        super.setUp()
        CapitalGamePoolState.resetForTesting()
        let schema = Schema([PersistedCountry.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() {
        CapitalGamePoolState.resetForTesting()
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    func testStartNewRound_producesConfiguredQuestionCountWithFourOptions() async throws {
        let countries = (0..<40).map { i -> Country in
            Country(
                name: Name(common: "Country\(i)", official: "Official\(i)"),
                capital: ["Capital\(i)"],
                cca2: String(format: "%02d", i % 99),
                assetFlag: "c\(i)"
            )
        }
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        try persistence.replaceAll(from: countries)

        let interactor = CapitalGameInteractor(persistence: persistence)
        try await interactor.startNewRound()

        var seenFlags = Set<String>()
        for _ in 0..<FlagGameRound.questionsPerRound {
            guard let q = interactor.currentQuestion() else {
                XCTFail("Expected a question")
                return
            }
            XCTAssertEqual(q.options.count, 4)
            XCTAssertTrue(q.options.contains(where: { $0 == q.options[q.correctIndex] }))
            XCTAssertFalse(seenFlags.contains(q.flagAssetCode))
            seenFlags.insert(q.flagAssetCode)
            _ = interactor.submitAnswer(optionIndex: q.correctIndex, responseTime: 0)
        }
        XCTAssertFalse(interactor.hasMoreQuestions)
    }

    func testSubmitWrongIncrementsWrongAndSkipIncrementsSkipped() async throws {
        let countries = (0..<35).map { i -> Country in
            Country(
                name: Name(common: "Land\(i)", official: "Rep\(i)"),
                capital: ["Cap\(i)"],
                cca2: nil,
                assetFlag: "x\(i)"
            )
        }
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        try persistence.replaceAll(from: countries)
        let interactor = CapitalGameInteractor(persistence: persistence)
        try await interactor.startNewRound()

        guard let q = interactor.currentQuestion() else {
            XCTFail("missing question")
            return
        }
        let wrongIndex = (0..<4).first { $0 != q.correctIndex } ?? 0
        XCTAssertFalse(interactor.submitAnswer(optionIndex: wrongIndex, responseTime: 0))

        guard interactor.currentQuestion() != nil else {
            XCTFail("expected second question after wrong answer")
            return
        }
        interactor.skipQuestion()

        let summary = interactor.buildSummary()
        XCTAssertEqual(summary.wrongCount, 1)
        XCTAssertEqual(summary.skippedCount, 1)
        XCTAssertEqual(summary.correctCount, 0)
    }

    func testStartNewRound_excludesFlagsFromLastFourRounds() async throws {
        // Dataset amplio para poder jugar 5 rondas de 20 sin agotar el mazo antes de tiempo.
        let countries = (0..<120).map { i -> Country in
            Country(
                name: Name(common: "C\(i)", official: "O\(i)"),
                capital: ["Cap\(i)"],
                cca2: nil,
                assetFlag: "z\(i)"
            )
        }
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        try persistence.replaceAll(from: countries)
        let interactor = CapitalGameInteractor(persistence: persistence)

        var rounds: [Set<String>] = []
        for _ in 0..<5 {
            try await interactor.startNewRound()
            var round = Set<String>()
            for _ in 0..<FlagGameRound.questionsPerRound {
                guard let q = interactor.currentQuestion() else {
                    XCTFail("expected question")
                    return
                }
                round.insert(q.flagAssetCode)
                _ = interactor.submitAnswer(optionIndex: q.correctIndex, responseTime: 0)
            }
            _ = interactor.buildSummary()
            rounds.append(round)
        }

        let firstFourUnion = rounds[0].union(rounds[1]).union(rounds[2]).union(rounds[3])
        XCTAssertTrue(
            rounds[4].isDisjoint(with: firstFourUnion),
            "Un país no debe repetirse hasta después de jugar 4 partidas"
        )
    }
}

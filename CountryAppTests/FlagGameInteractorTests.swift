//
//  FlagGameInteractorTests.swift
//  CountryAppTests
//

import SwiftData
import XCTest
@testable import CountryApp

final class FlagGameInteractorTests: XCTestCase {

    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!

    override func setUp() {
        super.setUp()
        FlagGameRecentRoundsHistory.resetForTesting()
        let schema = Schema([PersistedCountry.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() {
        FlagGameRecentRoundsHistory.resetForTesting()
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    func testStartNewRound_producesConfiguredQuestionCountWithFourOptions() async throws {
        let countries = (0..<40).map { i -> Country in
            Country(
                name: Name(common: "Country\(i)", official: "Official\(i)"),
                capital: ["C\(i)"],
                cca2: String(format: "%02d", i % 99),
                assetFlag: "c\(i)"
            )
        }
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        try persistence.replaceAll(from: countries)

        let interactor = FlagGameInteractor(persistence: persistence)
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
                capital: nil,
                cca2: nil,
                assetFlag: "x\(i)"
            )
        }
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        try persistence.replaceAll(from: countries)
        let interactor = FlagGameInteractor(persistence: persistence)
        try await interactor.startNewRound()

        guard let q = interactor.currentQuestion() else {
            XCTFail("missing question")
            return
        }
        let wrongIndex = (0..<4).first { $0 != q.correctIndex } ?? 0
        XCTAssertFalse(interactor.submitAnswer(optionIndex: wrongIndex, responseTime: 0))
        let expectedWrong = q.options[q.correctIndex]

        guard let q2 = interactor.currentQuestion() else {
            XCTFail("expected second question after wrong answer")
            return
        }
        interactor.skipQuestion()
        let expectedSkipped = q2.options[q2.correctIndex]

        let summary = interactor.buildSummary()
        XCTAssertEqual(summary.wrongCount, 1)
        XCTAssertEqual(summary.skippedCount, 1)
        XCTAssertEqual(summary.correctCount, 0)
        XCTAssertEqual(summary.wrongCountryNames, [expectedWrong])
        XCTAssertEqual(summary.skippedCountryNames, [expectedSkipped])
        XCTAssertEqual(summary.countryNamesToReview, [expectedWrong, expectedSkipped])
        XCTAssertEqual(summary.reviewFlagRows.map(\.countryName), [expectedWrong, expectedSkipped])
    }

    func testSubmitCorrect_fastGoesToClear_slowGoesToDoubt() async throws {
        let countries = (0..<10).map { i -> Country in
            Country(
                name: Name(common: "Land\(i)", official: "Rep\(i)"),
                capital: nil,
                cca2: nil,
                assetFlag: "x\(i)"
            )
        }
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        try persistence.replaceAll(from: countries)
        let interactor = FlagGameInteractor(persistence: persistence)
        try await interactor.startNewRound()

        guard let q1 = interactor.currentQuestion() else {
            XCTFail("missing question")
            return
        }
        XCTAssertTrue(interactor.submitAnswer(optionIndex: q1.correctIndex, responseTime: 2))
        guard let q2 = interactor.currentQuestion() else {
            XCTFail("expected second question")
            return
        }
        XCTAssertTrue(interactor.submitAnswer(optionIndex: q2.correctIndex, responseTime: 16))

        let summary = interactor.buildSummary()
        XCTAssertEqual(summary.correctCount, 2)
        XCTAssertEqual(summary.clearCorrectRows.count, 1)
        XCTAssertEqual(summary.doubtCorrectRows.count, 1)
        XCTAssertEqual(summary.clearCorrectRows.first?.countryName, q1.options[q1.correctIndex])
        XCTAssertEqual(summary.doubtCorrectRows.first?.countryName, q2.options[q2.correctIndex])
    }

    func testSubmitCorrect_exactlyFifteenSecondsCountsAsClear() async throws {
        let countries = (0..<5).map { i -> Country in
            Country(
                name: Name(common: "Only\(i)", official: "O\(i)"),
                capital: nil,
                cca2: nil,
                assetFlag: "o\(i)"
            )
        }
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        try persistence.replaceAll(from: countries)
        let interactor = FlagGameInteractor(persistence: persistence)
        try await interactor.startNewRound()
        guard let q = interactor.currentQuestion() else {
            XCTFail("missing question")
            return
        }
        XCTAssertTrue(interactor.submitAnswer(optionIndex: q.correctIndex, responseTime: 15))
        let summary = interactor.buildSummary()
        XCTAssertEqual(summary.doubtCorrectRows.count, 0)
        XCTAssertEqual(summary.clearCorrectRows.count, 1)
    }

    func testPersistence_savesSpanishNameAndFlagGameUsesIt() throws {
        let countries = [
            Country(name: Name(common: "Spain", official: "Kingdom of Spain", nameSpanish: "España"), capital: nil, cca2: "es", assetFlag: "es"),
            Country(name: Name(common: "France", official: "Fr", nameSpanish: "Francia"), capital: nil, cca2: "fr", assetFlag: "fr"),
            Country(name: Name(common: "Italy", official: "It", nameSpanish: "Italia"), capital: nil, cca2: "it", assetFlag: "it"),
            Country(name: Name(common: "Germany", official: "De", nameSpanish: "Alemania"), capital: nil, cca2: "de", assetFlag: "de"),
        ]
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        try persistence.replaceAll(from: countries)
        let rows = try modelContext.fetch(FetchDescriptor<PersistedCountry>())
        let spain = rows.first { $0.flagAssetCode == "es" }
        XCTAssertEqual(spain?.spanishCommonName, "España")
        XCTAssertEqual(spain?.flagGameDisplayName, "España")
    }

    func testFlagGameDisplayName_fallsBackToCommonWithoutSpanish() throws {
        let countries = [
            Country(name: Name(common: "Alpha", official: "O"), capital: nil, cca2: "aa", assetFlag: "aa"),
            Country(name: Name(common: "Bravo", official: "O"), capital: nil, cca2: "bb", assetFlag: "bb"),
            Country(name: Name(common: "Charlie", official: "O"), capital: nil, cca2: "cc", assetFlag: "cc"),
            Country(name: Name(common: "Delta", official: "O"), capital: nil, cca2: "dd", assetFlag: "dd"),
        ]
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        try persistence.replaceAll(from: countries)
        let rows = try modelContext.fetch(FetchDescriptor<PersistedCountry>())
        XCTAssertEqual(rows.first { $0.flagAssetCode == "aa" }?.flagGameDisplayName, "Alpha")
    }

    func testRecentRoundsHistory_keepsOnlyLastThreeRoundsForExclusion() {
        FlagGameRecentRoundsHistory.resetForTesting()
        FlagGameRecentRoundsHistory.appendCompletedRound(flagAssetCodes: ["a"])
        FlagGameRecentRoundsHistory.appendCompletedRound(flagAssetCodes: ["b"])
        FlagGameRecentRoundsHistory.appendCompletedRound(flagAssetCodes: ["c"])
        XCTAssertEqual(FlagGameRecentRoundsHistory.excludedFlagAssetCodes(), Set(["a", "b", "c"]))
        FlagGameRecentRoundsHistory.appendCompletedRound(flagAssetCodes: ["d"])
        XCTAssertEqual(FlagGameRecentRoundsHistory.excludedFlagAssetCodes(), Set(["b", "c", "d"]))
    }

    func testStartNewRound_excludesFlagsFromImmediatelyPreviousRound() async throws {
        let countries = (0..<50).map { i -> Country in
            Country(
                name: Name(common: "C\(i)", official: "O\(i)"),
                capital: nil,
                cca2: nil,
                assetFlag: "f\(i)"
            )
        }
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        try persistence.replaceAll(from: countries)
        let interactor = FlagGameInteractor(persistence: persistence)
        try await interactor.startNewRound()
        var round1 = Set<String>()
        for _ in 0..<FlagGameRound.questionsPerRound {
            guard let q = interactor.currentQuestion() else {
                XCTFail("round1 question")
                return
            }
            round1.insert(q.flagAssetCode)
            _ = interactor.submitAnswer(optionIndex: q.correctIndex, responseTime: 0)
        }
        _ = interactor.buildSummary()
        try await interactor.startNewRound()
        var round2 = Set<String>()
        for _ in 0..<FlagGameRound.questionsPerRound {
            guard let q = interactor.currentQuestion() else {
                XCTFail("round2 question")
                return
            }
            round2.insert(q.flagAssetCode)
            _ = interactor.submitAnswer(optionIndex: q.correctIndex, responseTime: 0)
        }
        XCTAssertTrue(round1.isDisjoint(with: round2), "Las banderas de la partida anterior no deben repetirse en la siguiente")
    }
}

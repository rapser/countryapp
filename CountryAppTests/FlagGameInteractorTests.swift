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
        let schema = Schema([PersistedCountry.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() {
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    func testStartNewRound_producesThirtyQuestionsWithFourOptions() async throws {
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
        for _ in 0..<30 {
            guard let q = interactor.currentQuestion() else {
                XCTFail("Expected a question")
                return
            }
            XCTAssertEqual(q.options.count, 4)
            XCTAssertTrue(q.options.contains(where: { $0 == q.options[q.correctIndex] }))
            XCTAssertFalse(seenFlags.contains(q.flagAssetCode))
            seenFlags.insert(q.flagAssetCode)
            _ = interactor.submitAnswer(optionIndex: q.correctIndex)
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
        XCTAssertFalse(interactor.submitAnswer(optionIndex: wrongIndex))
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
    }
}

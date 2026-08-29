//
//  FlagGameScoringTests.swift
//  CountryAppTests
//

import XCTest
@testable import CountryApp

final class FlagGameScoringTests: XCTestCase {

    func testWrongAnswerScoresZero() {
        XCTAssertEqual(FlagGameScoring.points(correct: false, responseTime: 0), 0)
        XCTAssertEqual(FlagGameScoring.points(correct: false, responseTime: 3), 0)
    }

    func testInstantCorrectGetsFullBonus() {
        let expected = FlagGameScoring.basePointsPerCorrect + FlagGameScoring.maxSpeedBonus
        XCTAssertEqual(FlagGameScoring.points(correct: true, responseTime: 0), expected)
    }

    func testHalfwayThroughWindowGetsHalfBonus() {
        let half = FlagGameScoring.speedBonusWindowSeconds / 2
        let expected = FlagGameScoring.basePointsPerCorrect + (FlagGameScoring.maxSpeedBonus / 2 / 5) * 5
        XCTAssertEqual(FlagGameScoring.points(correct: true, responseTime: half), expected)
    }

    func testAtOrBeyondWindowGetsNoBonus() {
        XCTAssertEqual(
            FlagGameScoring.points(correct: true, responseTime: FlagGameScoring.speedBonusWindowSeconds),
            FlagGameScoring.basePointsPerCorrect
        )
        XCTAssertEqual(
            FlagGameScoring.points(correct: true, responseTime: 999),
            FlagGameScoring.basePointsPerCorrect
        )
    }

    func testBonusIsAlwaysAMultipleOfFive() {
        for tenths in 0...100 {
            let points = FlagGameScoring.points(correct: true, responseTime: Double(tenths) / 10)
            XCTAssertEqual((points - FlagGameScoring.basePointsPerCorrect) % 5, 0)
        }
    }

    func testFasterAnswersNeverScoreLessThanSlowerOnes() {
        var previous = Int.max
        for tenths in 0...100 {
            let points = FlagGameScoring.points(correct: true, responseTime: Double(tenths) / 10)
            XCTAssertLessThanOrEqual(points, previous)
            previous = points
        }
    }
}

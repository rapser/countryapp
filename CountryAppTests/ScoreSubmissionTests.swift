//
//  ScoreSubmissionTests.swift
//  CountryAppTests
//

import XCTest
@testable import CountryApp

@MainActor
final class ScoreSubmissionTests: XCTestCase {
    private var defaults: MockUserDefaultsManager!
    private var scoreService: MockScoreService!
    private var authService: MockAuthService!
    private var queue: PendingScoreQueue!

    override func setUp() {
        super.setUp()
        defaults = MockUserDefaultsManager()
        scoreService = MockScoreService()
        authService = MockAuthService()
        queue = PendingScoreQueue(defaults: defaults, scoreService: scoreService)
    }

    private func makeSession(signedIn: Bool, backend: Bool = true) -> SessionStore {
        authService.currentUserId = signedIn ? UUID() : nil
        return SessionStore(
            authService: authService,
            profileService: MockProfileService(),
            scoreService: scoreService,
            pendingScores: queue,
            isBackendAvailable: backend
        )
    }

    // MARK: - GameSessionDraft

    func testDraftCopiesSummaryCounters() {
        let draft = GameSessionDraft(summary: BackendFixtures.summary(score: 7_250, correct: 9, wrong: 1, skipped: 2), gameType: .capital)
        XCTAssertEqual(draft.score, 7_250)
        XCTAssertEqual(draft.correctCount, 9)
        XCTAssertEqual(draft.wrongCount, 1)
        XCTAssertEqual(draft.skippedCount, 2)
        XCTAssertEqual(draft.gameType, .capital)
        XCTAssertTrue(draft.isWorthSaving)
    }

    func testDraftWithOnlySkippedQuestionsIsNotWorthSaving() {
        let draft = GameSessionDraft(summary: BackendFixtures.summary(score: 0, correct: 0, wrong: 0, skipped: 5), gameType: .flag)
        XCTAssertFalse(draft.isWorthSaving)
    }

    func testInsertEncodesSnakeCaseColumns() throws {
        let draft = GameSessionDraft(summary: BackendFixtures.summary(), gameType: .flag)
        let data = try JSONEncoder().encode(GameSessionInsert(draft: draft, userId: UUID()))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        for key in ["user_id", "client_id", "game_type", "score", "correct_count", "wrong_count", "skipped_count", "duration_seconds", "created_at"] {
            XCTAssertNotNil(json[key], "falta \(key)")
        }
        XCTAssertEqual(json["game_type"] as? String, "flag")
    }

    // MARK: - PendingScoreQueue

    func testQueueKeepsOnlyMostRecentDrafts() {
        for score in 0..<(PendingScoreQueue.maxPending + 3) {
            queue.enqueue(GameSessionDraft(summary: BackendFixtures.summary(score: score), gameType: .flag))
        }
        XCTAssertEqual(queue.pending.count, PendingScoreQueue.maxPending)
        XCTAssertEqual(queue.pending.last?.score, PendingScoreQueue.maxPending + 2)
    }

    func testFlushSendsAndClearsPending() async {
        let draft = GameSessionDraft(summary: BackendFixtures.summary(), gameType: .flag)
        queue.enqueue(draft)
        let sent = await queue.flush(userId: UUID())
        XCTAssertEqual(sent, [draft.clientId])
        XCTAssertEqual(scoreService.submitted, [draft])
        XCTAssertTrue(queue.pending.isEmpty)
    }

    func testFlushKeepsDraftsWhenOffline() async {
        scoreService.submitError = URLError(.notConnectedToInternet)
        queue.enqueue(GameSessionDraft(summary: BackendFixtures.summary(), gameType: .flag))
        let sent = await queue.flush(userId: UUID())
        XCTAssertTrue(sent.isEmpty)
        XCTAssertEqual(queue.pending.count, 1)
    }

    func testConcurrentFlushesSubmitOnce() async {
        queue.enqueue(GameSessionDraft(summary: BackendFixtures.summary(), gameType: .flag))
        let userId = UUID()
        async let first = queue.flush(userId: userId)
        async let second = queue.flush(userId: userId)
        _ = await (first, second)
        XCTAssertEqual(scoreService.submitted.count, 1)
    }

    // MARK: - GameScoreSubmitter

    func testGuestSubmissionAsksForLoginAndKeepsDraft() async {
        let submitter = GameScoreSubmitter(session: makeSession(signedIn: false))
        let status = await submitter.submit(GameSessionDraft(summary: BackendFixtures.summary(score: 4_200), gameType: .flag))
        XCTAssertEqual(status, .requiresLogin(points: 4_200))
        XCTAssertEqual(queue.pending.count, 1)
        XCTAssertTrue(scoreService.submitted.isEmpty)
    }

    func testSignedInSubmissionSavesAndReportsRank() async {
        scoreService.myRank = MyRank(totalScore: 9_000, gamesPlayed: 2, rank: 7)
        let submitter = GameScoreSubmitter(session: makeSession(signedIn: true))
        let status = await submitter.submit(GameSessionDraft(summary: BackendFixtures.summary(), gameType: .flag))
        XCTAssertEqual(status, .saved(rank: 7))
        XCTAssertEqual(scoreService.submitted.count, 1)
        XCTAssertTrue(queue.pending.isEmpty)
    }

    func testOfflineSubmissionIsQueued() async {
        scoreService.submitError = URLError(.notConnectedToInternet)
        let submitter = GameScoreSubmitter(session: makeSession(signedIn: true))
        let status = await submitter.submit(GameSessionDraft(summary: BackendFixtures.summary(), gameType: .flag))
        XCTAssertEqual(status, .offline)
        XCTAssertEqual(queue.pending.count, 1)
    }

    func testNothingIsSavedWithoutBackend() async {
        let submitter = GameScoreSubmitter(session: makeSession(signedIn: true, backend: false))
        let status = await submitter.submit(GameSessionDraft(summary: BackendFixtures.summary(), gameType: .flag))
        XCTAssertEqual(status, .hidden)
        XCTAssertTrue(queue.pending.isEmpty)
    }
}

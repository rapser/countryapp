//
//  BackendMocks.swift
//  CountryAppTests
//

import Foundation
@testable import CountryApp

final class MockScoreService: ScoreServiceProtocol {
    var submitted: [GameSessionDraft] = []
    var submitError: Error?
    var leaderboard: [LeaderboardEntry] = []
    var leaderboardError: Error?
    var myRank: MyRank?
    var history: [GameSessionEntry] = []
    var requestedLeaderboardTypes: [GameType?] = []

    func submit(_ draft: GameSessionDraft, userId: UUID) async throws {
        if let submitError { throw submitError }
        submitted.append(draft)
    }

    func fetchHistory(userId: UUID, limit: Int, offset: Int) async throws -> [GameSessionEntry] {
        Array(history.dropFirst(offset).prefix(limit))
    }

    func fetchLeaderboard(gameType: GameType?, limit: Int) async throws -> [LeaderboardEntry] {
        requestedLeaderboardTypes.append(gameType)
        if let leaderboardError { throw leaderboardError }
        return leaderboard
    }

    func fetchMyRank(gameType: GameType?) async throws -> MyRank? {
        myRank
    }
}

final class MockAuthService: AuthServiceProtocol {
    var currentUserId: UUID?
    var signInError: Error?
    var signUpResult: SignUpResult = .signedIn
    var signUpRequests: [SignUpRequest] = []

    func signUp(_ request: SignUpRequest) async throws -> SignUpResult {
        signUpRequests.append(request)
        if signUpResult == .signedIn { currentUserId = UUID() }
        return signUpResult
    }

    func signIn(email: String, password: String) async throws {
        if let signInError { throw signInError }
        currentUserId = UUID()
    }

    func signOut() async throws {
        currentUserId = nil
    }

    func userIdChanges() -> AsyncStream<UUID?> {
        AsyncStream { $0.finish() }
    }
}

final class MockProfileService: ProfileServiceProtocol {
    var profile: UserProfile?
    var nicknameAvailable = true
    var uploadedAvatars = 0

    func fetchProfile(id: UUID) async throws -> UserProfile {
        guard let profile else { throw BackendError.notAuthenticated }
        return profile
    }

    func updateProfile(id: UUID, with update: ProfileUpdate) async throws -> UserProfile {
        var current = profile ?? UserProfile(id: id, nickname: "", fullName: nil, countryCode: "pe", avatarURL: nil)
        if let nickname = update.nickname { current.nickname = nickname }
        if let fullName = update.fullName { current.fullName = fullName }
        if let countryCode = update.countryCode { current.countryCode = countryCode }
        if let avatarURL = update.avatarURL { current.avatarURL = avatarURL }
        profile = current
        return current
    }

    func uploadAvatar(userId: UUID, jpegData: Data) async throws -> URL {
        uploadedAvatars += 1
        return URL(string: "https://example.com/\(userId)/avatar.jpg")!
    }

    func isNicknameAvailable(_ nickname: String, excluding userId: UUID?) async throws -> Bool {
        nicknameAvailable
    }
}

enum BackendFixtures {
    static func summary(score: Int = 5_000, correct: Int = 8, wrong: Int = 2, skipped: Int = 0) -> GameSummary {
        GameSummary(
            correctCount: correct,
            wrongCount: wrong,
            skippedCount: skipped,
            duration: 95.4,
            score: score,
            wrongCountryNames: [],
            skippedCountryNames: [],
            reviewFlagRows: [],
            clearCorrectRows: [],
            doubtCorrectRows: [],
            questionResults: []
        )
    }

    static func leaderboardEntry(rank: Int, userId: UUID = UUID(), score: Int = 1_000) -> LeaderboardEntry {
        LeaderboardEntry(
            userId: userId,
            nickname: "player\(rank)",
            fullName: nil,
            countryCode: "pe",
            avatarURL: nil,
            totalScore: score,
            gamesPlayed: 3,
            rank: rank
        )
    }
}

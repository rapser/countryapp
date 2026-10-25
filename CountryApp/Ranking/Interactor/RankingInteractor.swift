//
//  RankingInteractor.swift
//  CountryApp
//

import Foundation

@MainActor
protocol RankingInteractorProtocol: AnyObject {
    var isBackendAvailable: Bool { get }
    var currentUserId: UUID? { get }
    func fetchLeaderboard(filter: RankingFilter) async throws -> [LeaderboardEntry]
    func fetchMyRank(filter: RankingFilter) async -> MyRank?
}

@MainActor
final class RankingInteractor: RankingInteractorProtocol {
    static let limit = 50

    private let session: SessionStore

    init(session: SessionStore? = nil) {
        self.session = session ?? .shared
    }

    var isBackendAvailable: Bool { session.isBackendAvailable }
    var currentUserId: UUID? { session.userId }

    func fetchLeaderboard(filter: RankingFilter) async throws -> [LeaderboardEntry] {
        try await session.scoreService.fetchLeaderboard(gameType: filter.gameType, limit: Self.limit)
    }

    func fetchMyRank(filter: RankingFilter) async -> MyRank? {
        guard session.isSignedIn else { return nil }
        return try? await session.scoreService.fetchMyRank(gameType: filter.gameType)
    }
}

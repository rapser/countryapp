//
//  HistoryInteractor.swift
//  CountryApp
//

import Foundation

@MainActor
protocol HistoryInteractorProtocol: AnyObject {
    var isBackendAvailable: Bool { get }
    var currentUserId: UUID? { get }
    func fetchPage(offset: Int, limit: Int) async throws -> [GameSessionEntry]
    func fetchStats() async -> MyRank?
}

@MainActor
final class HistoryInteractor: HistoryInteractorProtocol {
    private let session: SessionStore

    init(session: SessionStore? = nil) {
        self.session = session ?? .shared
    }

    var isBackendAvailable: Bool { session.isBackendAvailable }
    var currentUserId: UUID? { session.userId }

    func fetchPage(offset: Int, limit: Int) async throws -> [GameSessionEntry] {
        guard let userId = session.userId else { throw BackendError.notAuthenticated }
        return try await session.scoreService.fetchHistory(userId: userId, limit: limit, offset: offset)
    }

    func fetchStats() async -> MyRank? {
        try? await session.scoreService.fetchMyRank(gameType: nil)
    }
}

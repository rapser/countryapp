//
//  ScoreService.swift
//  CountryApp
//

import Foundation

protocol ScoreServiceProtocol: AnyObject {
    /// Inserta la partida. Idempotente por `clientId`: reenviarla no la duplica.
    func submit(_ draft: GameSessionDraft, userId: UUID) async throws
    func fetchHistory(userId: UUID, limit: Int, offset: Int) async throws -> [GameSessionEntry]
    /// `gameType` nil → ranking total de ambos juegos.
    func fetchLeaderboard(gameType: GameType?, limit: Int) async throws -> [LeaderboardEntry]
    /// nil si el usuario aún no jugó ese modo.
    func fetchMyRank(gameType: GameType?) async throws -> MyRank?
}

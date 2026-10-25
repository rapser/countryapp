//
//  SupabaseScoreService.swift
//  CountryApp
//

import Foundation
import Supabase

final class SupabaseScoreService: ScoreServiceProtocol {
    private let client: SupabaseClient?

    init(client: SupabaseClient? = SupabaseProvider.client) {
        self.client = client
    }

    func submit(_ draft: GameSessionDraft, userId: UUID) async throws {
        let client = try requireClient()
        do {
            try await NetworkRetry.run {
                try await client.from("game_sessions")
                    .upsert(
                        GameSessionInsert(draft: draft, userId: userId),
                        onConflict: "client_id",
                        returning: .minimal,
                        ignoreDuplicates: true
                    )
                    .execute()
            }
        } catch {
            throw BackendError.map(error)
        }
    }

    func fetchHistory(userId: UUID, limit: Int, offset: Int) async throws -> [GameSessionEntry] {
        let client = try requireClient()
        do {
            return try await NetworkRetry.run {
                try await client.from("game_sessions")
                    .select("id, game_type, score, correct_count, wrong_count, skipped_count, duration_seconds, created_at")
                    .eq("user_id", value: userId)
                    .order("created_at", ascending: false)
                    .range(from: offset, to: offset + limit - 1)
                    .execute()
                    .value
            }
        } catch {
            throw BackendError.map(error)
        }
    }

    func fetchLeaderboard(gameType: GameType?, limit: Int) async throws -> [LeaderboardEntry] {
        let client = try requireClient()
        struct Params: Encodable {
            let p_game_type: String?
            let p_limit: Int
        }
        do {
            return try await NetworkRetry.run {
                try await client
                    .rpc("get_leaderboard", params: Params(p_game_type: gameType?.rawValue, p_limit: limit))
                    .execute()
                    .value
            }
        } catch {
            throw BackendError.map(error)
        }
    }

    func fetchMyRank(gameType: GameType?) async throws -> MyRank? {
        let client = try requireClient()
        struct Params: Encodable {
            let p_game_type: String?
        }
        do {
            let rows: [MyRank] = try await NetworkRetry.run {
                try await client
                    .rpc("get_my_rank", params: Params(p_game_type: gameType?.rawValue))
                    .execute()
                    .value
            }
            return rows.first
        } catch {
            throw BackendError.map(error)
        }
    }

    private func requireClient() throws -> SupabaseClient {
        guard let client else { throw BackendError.notConfigured }
        return client
    }
}

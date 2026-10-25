//
//  BackendModels.swift
//  CountryApp
//
//  Modelos que viajan a/desde Supabase. Las columnas usan snake_case → `CodingKeys` explícitos.
//

import Foundation

enum GameType: String, Codable, CaseIterable {
    case flag
    case capital

    var displayName: String {
        switch self {
        case .flag: return "Banderas"
        case .capital: return "Capitales"
        }
    }

    var symbolName: String {
        switch self {
        case .flag: return "flag.fill"
        case .capital: return "building.columns.fill"
        }
    }
}

/// Fila de `public.profiles`.
struct UserProfile: Codable, Equatable {
    let id: UUID
    var nickname: String
    var fullName: String?
    var countryCode: String
    var avatarURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case nickname
        case fullName = "full_name"
        case countryCode = "country_code"
        case avatarURL = "avatar_url"
    }

    /// Nombre a mostrar: nombre completo si existe, si no el nickname.
    var displayName: String {
        if let name = fullName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            return name
        }
        return nickname
    }
}

/// Campos editables del perfil (solo se envían los no nil).
struct ProfileUpdate: Encodable {
    var nickname: String?
    var fullName: String?
    var countryCode: String?
    var avatarURL: URL?

    enum CodingKeys: String, CodingKey {
        case nickname
        case fullName = "full_name"
        case countryCode = "country_code"
        case avatarURL = "avatar_url"
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(nickname, forKey: .nickname)
        try c.encodeIfPresent(fullName, forKey: .fullName)
        try c.encodeIfPresent(countryCode, forKey: .countryCode)
        try c.encodeIfPresent(avatarURL, forKey: .avatarURL)
    }
}

/// Datos que pide el registro. Se mandan como metadata del usuario; el trigger crea el perfil.
struct SignUpRequest: Equatable {
    let email: String
    let password: String
    let nickname: String
    let fullName: String?
    let countryCode: String
}

/// Partida terminada pendiente de enviar. Se guarda localmente hasta que el backend la acepta.
struct GameSessionDraft: Codable, Equatable {
    let clientId: UUID
    let gameType: GameType
    let score: Int
    let correctCount: Int
    let wrongCount: Int
    let skippedCount: Int
    let durationSeconds: Double
    let playedAt: Date

    init(summary: GameSummary, gameType: GameType, clientId: UUID = UUID(), playedAt: Date = Date()) {
        self.clientId = clientId
        self.gameType = gameType
        self.score = summary.score
        self.correctCount = summary.correctCount
        self.wrongCount = summary.wrongCount
        self.skippedCount = summary.skippedCount
        self.durationSeconds = max(0, summary.duration)
        self.playedAt = playedAt
    }

    /// Partidas sin ninguna respuesta no se guardan.
    var isWorthSaving: Bool {
        correctCount + wrongCount > 0
    }
}

/// Cuerpo del INSERT en `public.game_sessions`.
struct GameSessionInsert: Encodable {
    let userId: UUID
    let clientId: UUID
    let gameType: GameType
    let score: Int
    let correctCount: Int
    let wrongCount: Int
    let skippedCount: Int
    let durationSeconds: Double
    let createdAt: Date

    init(draft: GameSessionDraft, userId: UUID) {
        self.userId = userId
        self.clientId = draft.clientId
        self.gameType = draft.gameType
        self.score = draft.score
        self.correctCount = draft.correctCount
        self.wrongCount = draft.wrongCount
        self.skippedCount = draft.skippedCount
        self.durationSeconds = draft.durationSeconds
        self.createdAt = draft.playedAt
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case clientId = "client_id"
        case gameType = "game_type"
        case score
        case correctCount = "correct_count"
        case wrongCount = "wrong_count"
        case skippedCount = "skipped_count"
        case durationSeconds = "duration_seconds"
        case createdAt = "created_at"
    }
}

/// Fila de `public.game_sessions` leída para el historial.
struct GameSessionEntry: Decodable, Equatable {
    let id: UUID
    let gameType: GameType
    let score: Int
    let correctCount: Int
    let wrongCount: Int
    let skippedCount: Int
    let durationSeconds: Double
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case gameType = "game_type"
        case score
        case correctCount = "correct_count"
        case wrongCount = "wrong_count"
        case skippedCount = "skipped_count"
        case durationSeconds = "duration_seconds"
        case createdAt = "created_at"
    }
}

/// Fila devuelta por `get_leaderboard`.
struct LeaderboardEntry: Decodable, Equatable {
    let userId: UUID
    let nickname: String
    let fullName: String?
    let countryCode: String
    let avatarURL: URL?
    let totalScore: Int
    let gamesPlayed: Int
    let rank: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nickname
        case fullName = "full_name"
        case countryCode = "country_code"
        case avatarURL = "avatar_url"
        case totalScore = "total_score"
        case gamesPlayed = "games_played"
        case rank
    }
}

/// Fila devuelta por `get_my_rank`.
struct MyRank: Decodable, Equatable {
    let totalScore: Int
    let gamesPlayed: Int
    let rank: Int

    enum CodingKeys: String, CodingKey {
        case totalScore = "total_score"
        case gamesPlayed = "games_played"
        case rank
    }
}

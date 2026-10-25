//
//  RankingModels.swift
//  CountryApp
//

import Foundation

enum RankingFilter: Int, CaseIterable {
    case total
    case flag
    case capital

    var title: String {
        switch self {
        case .total: return "Total"
        case .flag: return GameType.flag.displayName
        case .capital: return GameType.capital.displayName
        }
    }

    var gameType: GameType? {
        switch self {
        case .total: return nil
        case .flag: return .flag
        case .capital: return .capital
        }
    }
}

/// Fila lista para pintar (podio o lista).
struct RankingRowViewModel: Equatable {
    let rank: Int
    let nickname: String
    let subtitle: String
    let points: String
    let avatarURL: URL?
    let countryCode: String
    let isCurrentUser: Bool

    init(entry: LeaderboardEntry, currentUserId: UUID?) {
        rank = entry.rank
        nickname = "@\(entry.nickname)"
        let country = CountryCatalog.name(for: entry.countryCode)
        if let name = entry.fullName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            subtitle = "\(name) · \(country)"
        } else {
            subtitle = country
        }
        points = ScoreFormatter.points(entry.totalScore)
        avatarURL = entry.avatarURL
        countryCode = entry.countryCode
        isCurrentUser = entry.userId == currentUserId
    }
}

/// Barra inferior con la posición propia.
enum MyRankBanner: Equatable {
    case hidden
    case guest
    case notRanked
    case ranked(rank: Int, points: String)
}

//
//  HistoryModels.swift
//  CountryApp
//

import Foundation

struct HistoryRowViewModel: Equatable {
    let symbolName: String
    let title: String
    let date: String
    let points: String
    let detail: String

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es")
        f.dateStyle = .medium
        f.timeStyle = .short
        f.doesRelativeDateFormatting = true
        return f
    }()

    init(entry: GameSessionEntry) {
        symbolName = entry.gameType.symbolName
        title = entry.gameType.displayName
        date = Self.dateFormatter.string(from: entry.createdAt)
        points = "+\(ScoreFormatter.points(entry.score))"
        detail = "✓ \(entry.correctCount)   ✗ \(entry.wrongCount)   ↷ \(entry.skippedCount)   ⏱ \(ScoreFormatter.duration(entry.durationSeconds))"
    }
}

struct HistoryStatsViewModel: Equatable {
    let gamesPlayed: String
    let totalPoints: String
    let rank: String

    init(myRank: MyRank?) {
        gamesPlayed = ScoreFormatter.plain(myRank?.gamesPlayed ?? 0)
        totalPoints = ScoreFormatter.plain(myRank?.totalScore ?? 0)
        rank = myRank.map { "#\($0.rank)" } ?? "—"
    }
}

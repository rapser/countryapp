//
//  CapitalGameInteractor.swift
//  CountryApp
//

import Foundation

protocol CapitalGameInteractorProtocol: AnyObject {
    func ensureCountriesLoaded() async throws
    func startNewRound() async throws
    func recordQuizStarted()
    func currentQuestion() -> CapitalQuizQuestion?
    func currentProgressText() -> String
    func submitAnswer(optionIndex: Int, responseTime: TimeInterval) -> Bool
    func skipQuestion()
    func buildSummary() -> GameSummary
    var hasMoreQuestions: Bool { get }
}

/// Snapshot Sendable (Swift 6): país + capital.
private struct CapitalGameCountrySnapshot: Sendable {
    let flagAssetCode: String
    let countryName: String
    let capitalName: String
}

final class CapitalGameInteractor: CapitalGameInteractorProtocol {
    private let persistence: CountryPersistenceProtocol

    private var questions: [CapitalQuizQuestion] = []
    private var currentIndex: Int = 0
    private var correctCount = 0
    private var wrongCount = 0
    private var skippedCount = 0
    private var wrongCountryNames: [String] = []
    private var skippedCountryNames: [String] = []
    private var wrongFlagRows: [SummaryFlagRow] = []
    private var skippedFlagRows: [SummaryFlagRow] = []
    private var clearCorrectRows: [SummaryFlagRow] = []
    private var doubtCorrectRows: [SummaryFlagRow] = []
    private var sessionStart: Date?

    private var lastAvailableFlagCodes: Set<String> = []
    private var exportedRoundKey: String?

    init(persistence: CountryPersistenceProtocol) {
        self.persistence = persistence
    }

    func ensureCountriesLoaded() async throws {
        let count = try await MainActor.run {
            try persistence.fetchPersistedCountries()
                .filter { !$0.flagAssetCode.isEmpty && (($0.capitalSummary ?? "").isEmpty == false) }
                .count
        }
        if count < 4 { throw CapitalGameError.notEnoughCountries }
    }

    func startNewRound() async throws {
        let snapshots: [CapitalGameCountrySnapshot] = try await MainActor.run {
            try persistence.fetchPersistedCountries()
                .filter { !$0.flagAssetCode.isEmpty }
                .compactMap { row in
                    let cap = row.capitalSummary?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    guard !cap.isEmpty else { return nil }
                    return CapitalGameCountrySnapshot(
                        flagAssetCode: row.flagAssetCode,
                        countryName: row.flagGameDisplayName,
                        capitalName: cap
                    )
                }
        }
        guard snapshots.count >= 4 else { throw CapitalGameError.notEnoughCountries }

        lastAvailableFlagCodes = Set(snapshots.map(\.flagAssetCode))
        let state = CapitalGamePoolState.loadOrInitialize(availableFlagCodes: lastAvailableFlagCodes)
        let remainingSnapshots = snapshots.filter { state.remainingFlagCodes.contains($0.flagAssetCode) }
        let lastRound = state.lastRoundFlagCodes

        let chosen = Self.pickVariedRound(
            primaryPool: remainingSnapshots,
            fallbackPool: snapshots,
            lastRoundExcluded: lastRound,
            count: FlagGameRound.questionsPerRound
        )

        let allCapitals = snapshots.map(\.capitalName)
        questions = try chosen.map { row in
            let distractors = Self.pickDistractorCapitals(answerCapital: row.capitalName, poolCapitals: allCapitals)
            guard distractors.count == 3 else { throw CapitalGameError.loadFailed }
            var options = [row.capitalName] + distractors
            options.shuffle()
            guard let correctIndex = options.firstIndex(of: row.capitalName) else { throw CapitalGameError.loadFailed }
            return CapitalQuizQuestion(flagAssetCode: row.flagAssetCode, countryName: row.countryName, options: options, correctIndex: correctIndex)
        }

        exportedRoundKey = nil
        currentIndex = 0
        correctCount = 0
        wrongCount = 0
        skippedCount = 0
        wrongCountryNames = []
        skippedCountryNames = []
        wrongFlagRows = []
        skippedFlagRows = []
        clearCorrectRows = []
        doubtCorrectRows = []
        sessionStart = nil
    }

    func recordQuizStarted() {
        if sessionStart == nil { sessionStart = Date() }
    }

    func currentQuestion() -> CapitalQuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    func currentProgressText() -> String {
        "\(min(currentIndex + 1, max(questions.count, 1))) / \(questions.count)"
    }

    var hasMoreQuestions: Bool { currentIndex < questions.count }

    func submitAnswer(optionIndex: Int, responseTime: TimeInterval) -> Bool {
        guard let q = currentQuestion(), optionIndex >= 0, optionIndex < q.options.count else { return false }
        let answerCountryName = q.countryName
        let row = SummaryFlagRow(countryName: answerCountryName, flagAssetCode: q.flagAssetCode)
        let correct = optionIndex == q.correctIndex
        if correct {
            correctCount += 1
            if responseTime > FlagGameTiming.doubtAnswerThresholdSeconds {
                doubtCorrectRows.append(row)
            } else {
                clearCorrectRows.append(row)
            }
        } else {
            wrongCount += 1
            wrongCountryNames.append(answerCountryName)
            wrongFlagRows.append(row)
        }
        currentIndex += 1
        return correct
    }

    func skipQuestion() {
        guard let q = currentQuestion() else { return }
        let answerCountryName = q.countryName
        skippedCount += 1
        skippedCountryNames.append(answerCountryName)
        skippedFlagRows.append(SummaryFlagRow(countryName: answerCountryName, flagAssetCode: q.flagAssetCode))
        currentIndex += 1
    }

    func buildSummary() -> GameSummary {
        let roundKey = questions.map(\.flagAssetCode).sorted().joined(separator: "\u{1e}")
        if !questions.isEmpty, exportedRoundKey != roundKey {
            CapitalGamePoolState.registerCompletedRound(Set(questions.map(\.flagAssetCode)), availableFlagCodes: lastAvailableFlagCodes)
            exportedRoundKey = roundKey
        }

        let start = sessionStart ?? Date()
        let duration = Date().timeIntervalSince(start)
        let score = correctCount * 10 - wrongCount * 5
        let reviewRows = GameSummary.orderedUniqueFlagRows(wrongFlagRows + skippedFlagRows)
        return GameSummary(
            correctCount: correctCount,
            wrongCount: wrongCount,
            skippedCount: skippedCount,
            duration: duration,
            score: score,
            wrongCountryNames: wrongCountryNames,
            skippedCountryNames: skippedCountryNames,
            reviewFlagRows: reviewRows,
            clearCorrectRows: clearCorrectRows,
            doubtCorrectRows: doubtCorrectRows
        )
    }

    private static func pickDistractorCapitals(answerCapital: String, poolCapitals: [String]) -> [String] {
        let answer = answerCapital.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidates = poolCapitals.filter { $0.caseInsensitiveCompare(answer) != .orderedSame }
        var picked: [String] = []
        for c in candidates.shuffled() where picked.count < 3 {
            if !picked.contains(where: { $0.caseInsensitiveCompare(c) == .orderedSame }) {
                picked.append(c)
            }
        }
        return Array(picked.prefix(3))
    }

    private static func pickVariedRound(
        primaryPool: [CapitalGameCountrySnapshot],
        fallbackPool: [CapitalGameCountrySnapshot],
        lastRoundExcluded: Set<String>,
        count: Int
    ) -> [CapitalGameCountrySnapshot] {
        let primaryPicked = variedSample(from: primaryPool, count: min(count, primaryPool.count))
        if primaryPicked.count >= count {
            return Array(primaryPicked.prefix(count))
        }

        var picked = primaryPicked
        let pickedCodes = Set(picked.map(\.flagAssetCode))

        let eligibleFill = fallbackPool.filter { !pickedCodes.contains($0.flagAssetCode) && !lastRoundExcluded.contains($0.flagAssetCode) }
        let fillNeeded = count - picked.count
        picked.append(contentsOf: variedSample(from: eligibleFill, count: min(fillNeeded, eligibleFill.count)))

        if picked.count >= count {
            return Array(picked.prefix(count))
        }

        let eligibleAny = fallbackPool.filter { cand in
            !pickedCodes.contains(cand.flagAssetCode) && !picked.contains(where: { $0.flagAssetCode == cand.flagAssetCode })
        }
        let fill2Needed = count - picked.count
        picked.append(contentsOf: variedSample(from: eligibleAny, count: min(fill2Needed, eligibleAny.count)))
        return Array(picked.prefix(count))
    }

    private static func variedSample(from pool: [CapitalGameCountrySnapshot], count: Int) -> [CapitalGameCountrySnapshot] {
        guard count > 0, !pool.isEmpty else { return [] }
        var buckets: [String: [CapitalGameCountrySnapshot]] = [:]
        for s in pool {
            let key = String(s.countryName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().prefix(1))
            buckets[key, default: []].append(s)
        }
        var keys = buckets.keys.sorted()
        keys.shuffle()
        keys.forEach { buckets[$0]?.shuffle() }

        var out: [CapitalGameCountrySnapshot] = []
        var idx = 0
        while out.count < count, !keys.isEmpty {
            let k = keys[idx % keys.count]
            if var arr = buckets[k], !arr.isEmpty {
                out.append(arr.removeLast())
                buckets[k] = arr
            }
            keys = keys.filter { (buckets[$0]?.isEmpty == false) }
            idx += 1
        }
        if out.count < count {
            let leftover = pool.shuffled().filter { cand in
                !out.contains(where: { $0.flagAssetCode == cand.flagAssetCode })
            }
            out.append(contentsOf: leftover.prefix(count - out.count))
        }
        return out
    }
}


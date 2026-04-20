//
//  FlagGameInteractor.swift
//  CountryApp
//

import Foundation

protocol FlagGameInteractorProtocol: AnyObject {
    func ensureCountriesLoaded() async throws
    func startNewRound() async throws
    func recordQuizStarted()
    func currentQuestion() -> QuizQuestion?
    func currentProgressText() -> String
    /// Returns whether the selected option was correct. Advances to next question.
    func submitAnswer(optionIndex: Int) -> Bool
    func skipQuestion()
    /// Ends session with current counters (partial round supported).
    func buildSummary() -> GameSummary
    var hasMoreQuestions: Bool { get }
}

final class FlagGameInteractor: FlagGameInteractorProtocol {
    private let persistence: CountryPersistenceProtocol

    private var questions: [QuizQuestion] = []
    private var currentIndex: Int = 0
    private var correctCount = 0
    private var wrongCount = 0
    private var skippedCount = 0
    private var correctCountryNames: [String] = []
    private var wrongCountryNames: [String] = []
    private var skippedCountryNames: [String] = []
    private var sessionStart: Date?

    init(persistence: CountryPersistenceProtocol) {
        self.persistence = persistence
    }

    func ensureCountriesLoaded() async throws {
        // IMPORTANT: the game must not hit the network. Data should be bootstrapped in Home and stored in SwiftData.
        let rows = try await MainActor.run { try self.persistence.fetchPersistedCountries() }
        if rows.count < 4 {
            throw FlagGameError.notEnoughCountries
        }
    }

    func startNewRound() async throws {
        let rows = try await MainActor.run { try persistence.fetchPersistedCountries() }
        let withFlags = rows.filter { !$0.flagAssetCode.isEmpty }
        guard withFlags.count >= 4 else { throw FlagGameError.notEnoughCountries }

        let pool = withFlags.shuffled()
        let count = min(30, pool.count)
        let chosen = Array(pool.prefix(count))

        let allNames = withFlags.map(\.commonName)
        questions = try chosen.map { row in
            let distractors = Self.pickDistractors(answerName: row.commonName, poolNames: allNames)
            guard distractors.count == 3 else { throw FlagGameError.loadFailed }
            var options = [row.commonName] + distractors
            options.shuffle()
            guard let correctIndex = options.firstIndex(of: row.commonName) else {
                throw FlagGameError.loadFailed
            }
            return QuizQuestion(flagAssetCode: row.flagAssetCode, options: options, correctIndex: correctIndex)
        }

        currentIndex = 0
        correctCount = 0
        wrongCount = 0
        skippedCount = 0
        correctCountryNames = []
        wrongCountryNames = []
        skippedCountryNames = []
        sessionStart = nil
    }

    func recordQuizStarted() {
        if sessionStart == nil {
            sessionStart = Date()
        }
    }

    func currentQuestion() -> QuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    func currentProgressText() -> String {
        "\(min(currentIndex + 1, max(questions.count, 1))) / \(questions.count)"
    }

    var hasMoreQuestions: Bool {
        currentIndex < questions.count
    }

    func submitAnswer(optionIndex: Int) -> Bool {
        guard let q = currentQuestion(), optionsValid(q, optionIndex) else { return false }
        let answerName = q.options[q.correctIndex]
        let correct = optionIndex == q.correctIndex
        if correct {
            correctCount += 1
            correctCountryNames.append(answerName)
        } else {
            wrongCount += 1
            wrongCountryNames.append(answerName)
        }
        currentIndex += 1
        return correct
    }

    func skipQuestion() {
        guard let q = currentQuestion() else { return }
        let answerName = q.options[q.correctIndex]
        skippedCount += 1
        skippedCountryNames.append(answerName)
        currentIndex += 1
    }

    func buildSummary() -> GameSummary {
        let start = sessionStart ?? Date()
        let duration = Date().timeIntervalSince(start)
        let score = correctCount * 10 - wrongCount * 5
        return GameSummary(
            correctCount: correctCount,
            wrongCount: wrongCount,
            skippedCount: skippedCount,
            duration: duration,
            score: score,
            correctCountryNames: correctCountryNames,
            wrongCountryNames: wrongCountryNames,
            skippedCountryNames: skippedCountryNames
        )
    }

    private func optionsValid(_ q: QuizQuestion, _ index: Int) -> Bool {
        index >= 0 && index < q.options.count
    }

    /// Picks 3 names similar to `answerName` from `poolNames` (excluding the answer).
    private static func pickDistractors(answerName: String, poolNames: [String]) -> [String] {
        let answer = answerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidates = poolNames.filter { $0.caseInsensitiveCompare(answer) != .orderedSame }

        let scored = candidates.map { name -> (String, Int) in
            (name, similarityScore(answer: answer, candidate: name))
        }
        let sorted = scored.sorted { $0.1 > $1.1 }
        let topSlice = Array(sorted.prefix(min(15, sorted.count)))
        let shuffledTop = topSlice.shuffled()
        var picked: [String] = []
        for (name, _) in shuffledTop where picked.count < 3 {
            if !picked.contains(where: { $0.caseInsensitiveCompare(name) == .orderedSame }) {
                picked.append(name)
            }
        }
        if picked.count < 3 {
            let filler = candidates.shuffled().filter { c in
                !picked.contains(where: { $0.caseInsensitiveCompare(c) == .orderedSame })
                    && c.caseInsensitiveCompare(answer) != .orderedSame
            }
            for name in filler where picked.count < 3 {
                picked.append(name)
            }
        }
        return Array(picked.prefix(3))
    }

    private static func similarityScore(answer: String, candidate: String) -> Int {
        let a = answer.lowercased()
        let b = candidate.lowercased()
        if a == b { return -10_000 }
        var score = 0
        if let af = a.first, let bf = b.first, af == bf { score += 5 }
        if a.prefix(2) == b.prefix(2) { score += 4 }
        let dist = levenshtein(a, b)
        score += max(0, 14 - min(dist, 14))
        let lenDiff = abs(a.count - b.count)
        if lenDiff <= 2 { score += 3 }
        if a.count >= 3 {
            let pref = String(a.prefix(3))
            if b.contains(pref) { score += 5 }
        }
        return score
    }

    private static func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        var dp = [[Int]](repeating: [Int](repeating: 0, count: bChars.count + 1), count: aChars.count + 1)
        for i in 0...aChars.count { dp[i][0] = i }
        for j in 0...bChars.count { dp[0][j] = j }
        for i in 1...aChars.count {
            for j in 1...bChars.count {
                let cost = aChars[i - 1] == bChars[j - 1] ? 0 : 1
                dp[i][j] = min(
                    dp[i - 1][j] + 1,
                    dp[i][j - 1] + 1,
                    dp[i - 1][j - 1] + cost
                )
            }
        }
        return dp[aChars.count][bChars.count]
    }
}

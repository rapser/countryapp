//
//  FlagGameInteractor.swift
//  CountryApp
//

import Foundation

/// Datos mínimos del listado para el juego (evita cruzar `PersistedCountry` fuera del actor principal en Swift 6).
private struct FlagGameCountrySnapshot: Sendable, FlagCodeIdentifiable {
    let flagAssetCode: String
    let displayName: String

    var alphabeticBucketKey: String { displayName }
}

protocol FlagGameInteractorProtocol: AnyObject {
    func ensureCountriesLoaded() async throws
    func startNewRound() async throws
    func recordQuizStarted()
    func currentQuestion() -> QuizQuestion?
    func currentProgressText() -> String
    func currentProgressFraction() -> Float
    /// Returns whether the selected option was correct. Advances to next question.
    /// `responseTime` es el tiempo desde que se mostró la pregunta hasta confirmar (para «dudas»).
    func submitAnswer(optionIndex: Int, responseTime: TimeInterval) -> Bool
    func skipQuestion()
    /// Ends session with current counters (partial round supported).
    func buildSummary() -> GameSummary
    var hasMoreQuestions: Bool { get }
    /// Puntos acumulados en la ronda.
    var totalScore: Int { get }
    /// Puntos otorgados por la última pregunta confirmada (0 tras un fallo o salto).
    var lastAwardedPoints: Int { get }
}

final class FlagGameInteractor: FlagGameInteractorProtocol {
    private let persistence: CountryPersistenceProtocol

    private var questions: [QuizQuestion] = []
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
    private(set) var totalScore = 0
    private(set) var lastAwardedPoints = 0
    /// Códigos disponibles en el dataset al iniciar la ronda (para persistir estado al generar el resumen).
    private var lastAvailableFlagCodes: Set<String> = []
    /// Evita registrar dos veces la misma ronda al construir el resumen.
    private var exportedRoundKey: String?

    init(persistence: CountryPersistenceProtocol) {
        self.persistence = persistence
    }

    func ensureCountriesLoaded() async throws {
        // IMPORTANT: the game must not hit the network. Data should be bootstrapped in Home and stored in SwiftData.
        let withFlagsCount = try await MainActor.run {
            try persistence.fetchPersistedCountries().filter { !$0.flagAssetCode.isEmpty }.count
        }
        if withFlagsCount < 4 {
            throw FlagGameError.notEnoughCountries
        }
    }

    func startNewRound() async throws {
        let snapshots: [FlagGameCountrySnapshot] = try await MainActor.run {
            try persistence.fetchPersistedCountries()
                .filter { !$0.flagAssetCode.isEmpty }
                .map {
                    FlagGameCountrySnapshot(
                        flagAssetCode: $0.flagAssetCode,
                        displayName: $0.flagGameDisplayName
                    )
                }
        }
        guard snapshots.count >= 4 else { throw FlagGameError.notEnoughCountries }

        lastAvailableFlagCodes = Set(snapshots.map(\.flagAssetCode))
        let state = FlagGamePoolState.loadOrInitialize(availableFlagCodes: lastAvailableFlagCodes)
        let remainingSnapshots = snapshots.filter { state.remainingFlagCodes.contains($0.flagAssetCode) }

        // Excluye las últimas FlagGameRound.recentRoundsTracked partidas en el fallback para maximizar variedad entre rondas.
        let recentExcluded = state.recentRoundsUnion
        let chosenSnapshots = VariedRoundSelector.pickWeightedRound(
            primaryPool: remainingSnapshots,
            fallbackPool: snapshots,
            lastRoundExcluded: recentExcluded,
            count: FlagGameRound.questionsPerRound
        )

        questions = try chosenSnapshots.map { row in
            let answerName = row.displayName
            let distractors = Self.pickDistractors(answer: row, allSnapshots: snapshots)
            guard distractors.count == 3 else { throw FlagGameError.loadFailed }
            var options = [answerName] + distractors
            options.shuffle()
            guard let correctIndex = options.firstIndex(of: answerName) else {
                throw FlagGameError.loadFailed
            }
            return QuizQuestion(flagAssetCode: row.flagAssetCode, options: options, correctIndex: correctIndex)
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
        totalScore = 0
        lastAwardedPoints = 0
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

    func currentProgressFraction() -> Float {
        guard !questions.isEmpty else { return 0 }
        return Float(currentIndex) / Float(questions.count)
    }

    var hasMoreQuestions: Bool {
        currentIndex < questions.count
    }

    func submitAnswer(optionIndex: Int, responseTime: TimeInterval) -> Bool {
        guard let q = currentQuestion(), optionsValid(q, optionIndex) else { return false }
        let answerName = q.options[q.correctIndex]
        let row = SummaryFlagRow(countryName: answerName, flagAssetCode: q.flagAssetCode)
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
            wrongCountryNames.append(answerName)
            wrongFlagRows.append(row)
        }
        lastAwardedPoints = FlagGameScoring.points(correct: correct, responseTime: responseTime)
        totalScore += lastAwardedPoints
        currentIndex += 1
        return correct
    }

    func skipQuestion() {
        guard let q = currentQuestion() else { return }
        let answerName = q.options[q.correctIndex]
        lastAwardedPoints = 0
        skippedCount += 1
        skippedCountryNames.append(answerName)
        skippedFlagRows.append(SummaryFlagRow(countryName: answerName, flagAssetCode: q.flagAssetCode))
        currentIndex += 1
    }

    func buildSummary() -> GameSummary {
        let roundKey = questions.map(\.flagAssetCode).sorted().joined(separator: "\u{1e}")
        if !questions.isEmpty, exportedRoundKey != roundKey {
            FlagGamePoolState.registerCompletedRound(Set(questions.map(\.flagAssetCode)), availableFlagCodes: lastAvailableFlagCodes)
            exportedRoundKey = roundKey
        }

        let start = sessionStart ?? Date()
        let duration = Date().timeIntervalSince(start)
        let score = totalScore
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

    private func optionsValid(_ q: QuizQuestion, _ index: Int) -> Bool {
        index >= 0 && index < q.options.count
    }

    // MARK: - Distractor selection

    /// Elige 3 nombres de países similares al de la respuesta, excluyendo los países cuya bandera
    /// sea visualmente idéntica a la de la respuesta (evita opciones indistinguibles).
    private static func pickDistractors(
        answer: FlagGameCountrySnapshot,
        allSnapshots: [FlagGameCountrySnapshot]
    ) -> [String] {
        let answerName = answer.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let synonymCodes = FlagSynonymGroups.synonyms(for: answer.flagAssetCode)

        let candidates = allSnapshots.filter {
            $0.displayName.caseInsensitiveCompare(answerName) != .orderedSame &&
            !synonymCodes.contains($0.flagAssetCode)
        }

        let candidateNames = candidates.map(\.displayName)
        let scored = candidateNames.map { name -> (String, Int) in
            (name, similarityScore(answer: answerName, candidate: name))
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
            let filler = candidateNames.shuffled().filter { c in
                !picked.contains(where: { $0.caseInsensitiveCompare(c) == .orderedSame })
                    && c.caseInsensitiveCompare(answerName) != .orderedSame
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

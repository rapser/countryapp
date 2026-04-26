//
//  FlagGameInteractor.swift
//  CountryApp
//

import Foundation

/// Datos mínimos del listado para el juego (evita cruzar `PersistedCountry` fuera del actor principal en Swift 6).
private struct FlagGameCountrySnapshot: Sendable {
    let flagAssetCode: String
    let displayName: String
}

protocol FlagGameInteractorProtocol: AnyObject {
    func ensureCountriesLoaded() async throws
    func startNewRound() async throws
    func recordQuizStarted()
    func currentQuestion() -> QuizQuestion?
    func currentProgressText() -> String
    /// Returns whether the selected option was correct. Advances to next question.
    /// `responseTime` es el tiempo desde que se mostró la pregunta hasta confirmar (para «dudas»).
    func submitAnswer(optionIndex: Int, responseTime: TimeInterval) -> Bool
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
    private var wrongCountryNames: [String] = []
    private var skippedCountryNames: [String] = []
    private var wrongFlagRows: [SummaryFlagRow] = []
    private var skippedFlagRows: [SummaryFlagRow] = []
    private var clearCorrectRows: [SummaryFlagRow] = []
    private var doubtCorrectRows: [SummaryFlagRow] = []
    private var sessionStart: Date?
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

        let lastRound = state.lastRoundFlagCodes
        let chosenSnapshots = Self.pickVariedRound(
            primaryPool: remainingSnapshots,
            fallbackPool: snapshots,
            lastRoundExcluded: lastRound,
            count: FlagGameRound.questionsPerRound
        )

        let allNames = snapshots.map(\.displayName)
        questions = try chosenSnapshots.map { row in
            let answerName = row.displayName
            let distractors = Self.pickDistractors(answerName: answerName, poolNames: allNames)
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
        currentIndex += 1
        return correct
    }

    func skipQuestion() {
        guard let q = currentQuestion() else { return }
        let answerName = q.options[q.correctIndex]
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

    private func optionsValid(_ q: QuizQuestion, _ index: Int) -> Bool {
        index >= 0 && index < q.options.count
    }

    /// Selección “variada”:
    /// - Si hay suficientes en el pool primario (`remaining`), elige desde ahí.\n+    /// - Si faltan, completa desde fallback evitando repetir la **última** partida (`lastRoundExcluded`) si es posible.
    private static func pickVariedRound(
        primaryPool: [FlagGameCountrySnapshot],
        fallbackPool: [FlagGameCountrySnapshot],
        lastRoundExcluded: Set<String>,
        count: Int
    ) -> [FlagGameCountrySnapshot] {
        let primaryPicked = variedSample(from: primaryPool, count: min(count, primaryPool.count))
        if primaryPicked.count >= count {
            return Array(primaryPicked.prefix(count))
        }

        var picked = primaryPicked
        let pickedCodes = Set(picked.map(\.flagAssetCode))

        // Completa sin usar la última partida.
        let eligibleFill = fallbackPool.filter { !pickedCodes.contains($0.flagAssetCode) && !lastRoundExcluded.contains($0.flagAssetCode) }
        let fillNeeded = count - picked.count
        let fill = variedSample(from: eligibleFill, count: min(fillNeeded, eligibleFill.count))
        picked.append(contentsOf: fill)

        if picked.count >= count {
            return Array(picked.prefix(count))
        }

        // Último fallback: si no hay suficientes (dataset muy pequeño), completa con cualquiera no elegido.
        let eligibleAny = fallbackPool.filter { cand in
            !pickedCodes.contains(cand.flagAssetCode)
                && !picked.contains(where: { $0.flagAssetCode == cand.flagAssetCode })
        }
        let fill2Needed = count - picked.count
        picked.append(contentsOf: variedSample(from: eligibleAny, count: min(fill2Needed, eligibleAny.count)))
        return Array(picked.prefix(count))
    }

    /// Muestreo round-robin por buckets simples basados en la primera letra del nombre.
    private static func variedSample(from pool: [FlagGameCountrySnapshot], count: Int) -> [FlagGameCountrySnapshot] {
        guard count > 0, !pool.isEmpty else { return [] }
        var buckets: [String: [FlagGameCountrySnapshot]] = [:]
        for s in pool {
            let key = String(s.displayName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().prefix(1))
            buckets[key, default: []].append(s)
        }
        var keys = buckets.keys.sorted()
        keys.shuffle()
        keys.forEach { buckets[$0]?.shuffle() }

        var out: [FlagGameCountrySnapshot] = []
        var idx = 0
        while out.count < count, !keys.isEmpty {
            let k = keys[idx % keys.count]
            if var arr = buckets[k], !arr.isEmpty {
                out.append(arr.removeLast())
                buckets[k] = arr
            }
            // Limpia buckets vacíos y avanza.
            keys = keys.filter { (buckets[$0]?.isEmpty == false) }
            idx += 1
        }
        if out.count < count {
            // Completa con shuffle normal si faltó.
            let leftover = pool.shuffled().filter { cand in
                !out.contains(where: { $0.flagAssetCode == cand.flagAssetCode })
            }
            out.append(contentsOf: leftover.prefix(count - out.count))
        }
        return out
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

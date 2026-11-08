//
//  GameScoreSubmitter.swift
//  CountryApp
//
//  Guarda el resultado de una partida. Compartido por los resúmenes de FlagGame y CapitalGame.
//

import Foundation

enum ScoreSubmissionStatus: Equatable {
    /// Nada que mostrar (backend sin configurar o partida sin respuestas).
    case hidden
    case saving
    /// `rank` es la posición del usuario en el ranking de ese juego, si se pudo obtener.
    case saved(rank: Int?)
    /// Invitado: la partida queda guardada localmente hasta que inicie sesión.
    case requiresLogin(points: Int)
    /// Sin red: se reintentará al volver a la app.
    case offline
}

@MainActor
protocol GameScoreSubmitterProtocol: AnyObject {
    func submit(_ draft: GameSessionDraft) async -> ScoreSubmissionStatus
}

@MainActor
final class GameScoreSubmitter: GameScoreSubmitterProtocol {
    private let session: SessionStore

    init(session: SessionStore? = nil) {
        self.session = session ?? .shared
    }

    func submit(_ draft: GameSessionDraft) async -> ScoreSubmissionStatus {
        guard session.isBackendAvailable, draft.isWorthSaving else { return .hidden }
        session.pendingScores.enqueue(draft)
        guard let userId = session.userId else { return .requiresLogin(points: draft.score) }

        let sent = await session.pendingScores.flush(userId: userId)
        // Si otro envío (p. ej. el del login) ya la mandó, ya no está pendiente.
        let saved = sent.contains(draft.clientId)
            || !session.pendingScores.pending.contains { $0.clientId == draft.clientId }
        guard saved else { return .offline }

        NotificationCenter.default.post(name: .scoresDidSync, object: nil)
        let rank = try? await session.scoreService.fetchMyRank(gameType: draft.gameType)?.rank
        return .saved(rank: rank)
    }
}

/// Vista del resumen que muestra el estado del guardado.
protocol GameScoreStatusViewProtocol: AnyObject {
    func showScoreStatus(_ status: ScoreSubmissionStatus)
}

/// Lógica compartida de los presenters de resumen: envía la partida y, si el invitado
/// inicia sesión desde el resumen, la vuelve a enviar. Todo el trabajo corre en el main actor.
final class GameSummaryScoreReporter {
    private let draft: GameSessionDraft
    private let submitter: GameScoreSubmitterProtocol
    private var onStatus: ((ScoreSubmissionStatus) -> Void)?
    private var status: ScoreSubmissionStatus = .hidden
    private var sessionObserver: NSObjectProtocol?

    init(draft: GameSessionDraft, submitter: GameScoreSubmitterProtocol) {
        self.draft = draft
        self.submitter = submitter
    }

    deinit {
        if let sessionObserver {
            NotificationCenter.default.removeObserver(sessionObserver)
        }
    }

    func start(onStatus: @escaping (ScoreSubmissionStatus) -> Void) {
        self.onStatus = onStatus
        sessionObserver = NotificationCenter.default.addObserver(
            forName: .sessionDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.retryAfterLoginIfNeeded() }
        }
        send()
    }

    @MainActor
    private func retryAfterLoginIfNeeded() {
        guard case .requiresLogin = status, SessionStore.shared.isSignedIn else { return }
        send()
    }

    private func send() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            update(.saving)
            let result = await submitter.submit(draft)
            update(result)
        }
    }

    @MainActor
    private func update(_ newStatus: ScoreSubmissionStatus) {
        status = newStatus
        onStatus?(newStatus)
    }
}

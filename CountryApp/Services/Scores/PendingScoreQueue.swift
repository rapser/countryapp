//
//  PendingScoreQueue.swift
//  CountryApp
//
//  Partidas terminadas que aún no llegaron al backend (sin sesión o sin red).
//  Se guardan en UserDefaults y se envían al iniciar sesión / volver a la app.
//

import Foundation

@MainActor
protocol PendingScoreQueueProtocol: AnyObject {
    var pending: [GameSessionDraft] { get }
    func enqueue(_ draft: GameSessionDraft)
    /// Envía todo lo pendiente. Si ya hay un envío en curso, espera ese mismo envío.
    /// Devuelve los ids que el backend aceptó.
    @discardableResult
    func flush(userId: UUID) async -> Set<UUID>
}

@MainActor
final class PendingScoreQueue: PendingScoreQueueProtocol {
    static let shared = PendingScoreQueue()

    /// Evita que un invitado acumule partidas sin límite.
    static let maxPending = 10
    private static let storageKey = "pendingGameSessions.v1"

    private let defaults: UserDefaultsManagerProtocol
    private let scoreService: ScoreServiceProtocol
    private var flushTask: Task<Set<UUID>, Never>?

    init(
        defaults: UserDefaultsManagerProtocol = UserDefaultsManager.shared,
        scoreService: ScoreServiceProtocol = SupabaseScoreService()
    ) {
        self.defaults = defaults
        self.scoreService = scoreService
    }

    var pending: [GameSessionDraft] {
        defaults.get(forKey: Self.storageKey, as: [GameSessionDraft].self) ?? []
    }

    func enqueue(_ draft: GameSessionDraft) {
        var items = pending.filter { $0.clientId != draft.clientId }
        items.append(draft)
        save(Array(items.suffix(Self.maxPending)))
    }

    @discardableResult
    func flush(userId: UUID) async -> Set<UUID> {
        if let flushTask { return await flushTask.value }
        let task = Task { [weak self] () -> Set<UUID> in
            guard let self else { return [] }
            var sent = Set<UUID>()
            for draft in self.pending {
                do {
                    try await self.scoreService.submit(draft, userId: userId)
                    sent.insert(draft.clientId)
                } catch {
                    AppLog.trace("PendingScoreQueue: envío falló \(error.localizedDescription)")
                    // Sin red no tiene sentido seguir intentando el resto ahora.
                    let mapped = BackendError.map(error)
                    if mapped == .network || mapped == .serverUnreachable { break }
                }
            }
            if !sent.isEmpty {
                self.save(self.pending.filter { !sent.contains($0.clientId) })
            }
            return sent
        }
        flushTask = task
        let result = await task.value
        flushTask = nil
        return result
    }

    private func save(_ items: [GameSessionDraft]) {
        if items.isEmpty {
            defaults.remove(forKey: Self.storageKey)
        } else {
            defaults.save(object: items, forKey: Self.storageKey)
        }
    }
}

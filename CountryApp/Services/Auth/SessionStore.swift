//
//  SessionStore.swift
//  CountryApp
//
//  Estado de sesión compartido por todas las tabs. Publica `.sessionDidChange` cuando
//  cambia el usuario o su perfil.
//

import Foundation

extension Notification.Name {
    static let sessionDidChange = Notification.Name("CountryApp.sessionDidChange")
    /// Se envió al menos una partida pendiente: ranking e historial deberían recargar.
    static let scoresDidSync = Notification.Name("CountryApp.scoresDidSync")
}

@MainActor
final class SessionStore {
    static let shared = SessionStore()

    private(set) var userId: UUID?
    private(set) var profile: UserProfile?

    var isSignedIn: Bool { userId != nil }
    let isBackendAvailable: Bool

    let authService: AuthServiceProtocol
    let profileService: ProfileServiceProtocol
    let scoreService: ScoreServiceProtocol
    let pendingScores: PendingScoreQueueProtocol

    private var listenTask: Task<Void, Never>?

    init(
        authService: AuthServiceProtocol = SupabaseAuthService(),
        profileService: ProfileServiceProtocol = SupabaseProfileService(),
        scoreService: ScoreServiceProtocol = SupabaseScoreService(),
        pendingScores: PendingScoreQueueProtocol? = nil,
        isBackendAvailable: Bool = SupabaseProvider.isConfigured
    ) {
        self.isBackendAvailable = isBackendAvailable
        self.authService = authService
        self.profileService = profileService
        self.scoreService = scoreService
        self.pendingScores = pendingScores ?? PendingScoreQueue.shared
        self.userId = authService.currentUserId
    }

    /// Empieza a escuchar cambios de sesión. Llamar una vez al arrancar la app.
    func start() {
        guard listenTask == nil else { return }
        listenTask = Task { [weak self] in
            guard let stream = self?.authService.userIdChanges() else { return }
            for await id in stream {
                await self?.handleUserChange(id)
            }
        }
    }

    func refreshProfile() async {
        guard let userId else { return }
        do {
            profile = try await profileService.fetchProfile(id: userId)
            notify()
        } catch {
            AppLog.trace("SessionStore: no se pudo cargar el perfil \(error.localizedDescription)")
        }
    }

    func updateLocalProfile(_ profile: UserProfile) {
        guard profile.id == userId else { return }
        self.profile = profile
        notify()
    }

    func signOut() async throws {
        try await authService.signOut()
        await handleUserChange(nil)
    }

    /// Reintenta enviar partidas guardadas localmente (p. ej. al volver a primer plano).
    func syncPendingScores() async {
        guard let userId, !pendingScores.pending.isEmpty else { return }
        let sent = await pendingScores.flush(userId: userId)
        if !sent.isEmpty {
            NotificationCenter.default.post(name: .scoresDidSync, object: nil)
        }
    }

    private func handleUserChange(_ id: UUID?) async {
        let changed = id != userId || (id != nil && profile == nil)
        userId = id
        if id == nil { profile = nil }
        guard changed else { return }
        notify()
        if id != nil {
            await refreshProfile()
            await syncPendingScores()
        }
    }

    private func notify() {
        NotificationCenter.default.post(name: .sessionDidChange, object: nil)
    }
}

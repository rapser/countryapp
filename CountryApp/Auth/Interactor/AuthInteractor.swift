//
//  AuthInteractor.swift
//  CountryApp
//

import Foundation

@MainActor
protocol AuthInteractorProtocol: AnyObject {
    func signIn(email: String, password: String) async throws
    /// Crea la cuenta y, si hay sesión inmediata, sube la foto.
    func signUp(_ request: SignUpRequest, avatarJPEG: Data?) async throws -> SignUpResult
}

@MainActor
final class AuthInteractor: AuthInteractorProtocol {
    private let session: SessionStore

    init(session: SessionStore? = nil) {
        self.session = session ?? .shared
    }

    func signIn(email: String, password: String) async throws {
        try await session.authService.signIn(email: email, password: password)
    }

    func signUp(_ request: SignUpRequest, avatarJPEG: Data?) async throws -> SignUpResult {
        guard try await session.profileService.isNicknameAvailable(request.nickname, excluding: nil) else {
            throw BackendError.nicknameTaken
        }
        let result = try await session.authService.signUp(request)
        guard result == .signedIn, let userId = session.authService.currentUserId else { return result }

        if let avatarJPEG {
            // La cuenta ya existe: si la foto falla no bloqueamos el registro, se puede cambiar en Perfil.
            do {
                let url = try await session.profileService.uploadAvatar(userId: userId, jpegData: avatarJPEG)
                let profile = try await session.profileService.updateProfile(
                    id: userId,
                    with: ProfileUpdate(avatarURL: url)
                )
                session.updateLocalProfile(profile)
            } catch {
                AppLog.trace("AuthInteractor: no se pudo subir el avatar \(error.localizedDescription)")
            }
        }
        await session.refreshProfile()
        return result
    }
}

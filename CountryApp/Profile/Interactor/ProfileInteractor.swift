//
//  ProfileInteractor.swift
//  CountryApp
//

import Foundation

@MainActor
protocol ProfileInteractorProtocol: AnyObject {
    var isBackendAvailable: Bool { get }
    var isSignedIn: Bool { get }
    var profile: UserProfile? { get }
    func refreshProfile() async
    func fetchStats() async -> MyRank?
    func signOut() async throws
    func saveProfile(_ form: EditProfileForm, countryCode: String, avatarJPEG: Data?) async throws -> UserProfile
}

@MainActor
final class ProfileInteractor: ProfileInteractorProtocol {
    private let session: SessionStore

    init(session: SessionStore? = nil) {
        self.session = session ?? .shared
    }

    var isBackendAvailable: Bool { session.isBackendAvailable }
    var isSignedIn: Bool { session.isSignedIn }
    var profile: UserProfile? { session.profile }

    func refreshProfile() async {
        await session.refreshProfile()
    }

    func fetchStats() async -> MyRank? {
        guard session.isSignedIn else { return nil }
        return try? await session.scoreService.fetchMyRank(gameType: nil)
    }

    func signOut() async throws {
        try await session.signOut()
    }

    func saveProfile(_ form: EditProfileForm, countryCode: String, avatarJPEG: Data?) async throws -> UserProfile {
        guard let userId = session.userId, let current = session.profile else { throw BackendError.notAuthenticated }

        if form.nickname.caseInsensitiveCompare(current.nickname) != .orderedSame {
            let available = try await session.profileService.isNicknameAvailable(form.nickname, excluding: userId)
            guard available else { throw BackendError.nicknameTaken }
        }

        var update = ProfileUpdate(
            nickname: form.nickname,
            fullName: form.fullName,
            countryCode: countryCode
        )
        if let avatarJPEG {
            update.avatarURL = try await session.profileService.uploadAvatar(userId: userId, jpegData: avatarJPEG)
        }
        let updated = try await session.profileService.updateProfile(id: userId, with: update)
        session.updateLocalProfile(updated)
        return updated
    }
}

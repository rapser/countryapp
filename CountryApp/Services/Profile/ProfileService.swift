//
//  ProfileService.swift
//  CountryApp
//

import Foundation

protocol ProfileServiceProtocol: AnyObject {
    func fetchProfile(id: UUID) async throws -> UserProfile
    func updateProfile(id: UUID, with update: ProfileUpdate) async throws -> UserProfile
    /// Sube la foto a `avatars/{id}/avatar.jpg` y devuelve la URL pública.
    func uploadAvatar(userId: UUID, jpegData: Data) async throws -> URL
    func isNicknameAvailable(_ nickname: String, excluding userId: UUID?) async throws -> Bool
}

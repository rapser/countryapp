//
//  SupabaseProfileService.swift
//  CountryApp
//

import Foundation
import Supabase

final class SupabaseProfileService: ProfileServiceProtocol {
    private let client: SupabaseClient?

    init(client: SupabaseClient? = SupabaseProvider.client) {
        self.client = client
    }

    func fetchProfile(id: UUID) async throws -> UserProfile {
        let client = try requireClient()
        do {
            return try await NetworkRetry.run {
                try await client.from("profiles")
                    .select()
                    .eq("id", value: id)
                    .single()
                    .execute()
                    .value
            }
        } catch {
            throw BackendError.map(error)
        }
    }

    func updateProfile(id: UUID, with update: ProfileUpdate) async throws -> UserProfile {
        let client = try requireClient()
        do {
            return try await client.from("profiles")
                .update(update)
                .eq("id", value: id)
                .select()
                .single()
                .execute()
                .value
        } catch {
            throw BackendError.map(error)
        }
    }

    func uploadAvatar(userId: UUID, jpegData: Data) async throws -> URL {
        let client = try requireClient()
        let path = "\(userId.uuidString.lowercased())/avatar.jpg"
        do {
            let bucket = client.storage.from(SupabaseProvider.avatarsBucket)
            try await bucket.upload(
                path,
                data: jpegData,
                options: FileOptions(cacheControl: "3600", contentType: "image/jpeg", upsert: true)
            )
            let url = try bucket.getPublicURL(path: path)
            // La ruta no cambia entre subidas: el query evita que cachés muestren la foto anterior.
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "v", value: String(Int(Date().timeIntervalSince1970)))]
            return components?.url ?? url
        } catch {
            throw BackendError.map(error)
        }
    }

    func isNicknameAvailable(_ nickname: String, excluding userId: UUID?) async throws -> Bool {
        let client = try requireClient()
        struct Row: Decodable { let id: UUID }
        do {
            let rows: [Row] = try await NetworkRetry.run {
                try await client.from("profiles")
                    .select("id")
                    .ilike("nickname", pattern: nickname)
                    .limit(1)
                    .execute()
                    .value
            }
            return rows.allSatisfy { $0.id == userId }
        } catch {
            throw BackendError.map(error)
        }
    }

    private func requireClient() throws -> SupabaseClient {
        guard let client else { throw BackendError.notConfigured }
        return client
    }
}

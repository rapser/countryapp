//
//  SupabaseAuthService.swift
//  CountryApp
//

import Foundation
import Supabase

final class SupabaseAuthService: AuthServiceProtocol {
    private let client: SupabaseClient?

    init(client: SupabaseClient? = SupabaseProvider.client) {
        self.client = client
    }

    var currentUserId: UUID? {
        guard let session = client?.auth.currentSession, !session.isExpired else { return nil }
        return session.user.id
    }

    func signUp(_ request: SignUpRequest) async throws -> SignUpResult {
        guard let client else { throw BackendError.notConfigured }
        var metadata: [String: AnyJSON] = [
            "nickname": .string(request.nickname),
            "country_code": .string(request.countryCode)
        ]
        if let fullName = request.fullName {
            metadata["full_name"] = .string(fullName)
        }
        do {
            let response = try await client.auth.signUp(
                email: request.email,
                password: request.password,
                data: metadata
            )
            return response.session == nil ? .confirmationRequired : .signedIn
        } catch {
            throw BackendError.map(error)
        }
    }

    func signIn(email: String, password: String) async throws {
        guard let client else { throw BackendError.notConfigured }
        do {
            _ = try await client.auth.signIn(email: email, password: password)
        } catch {
            throw BackendError.map(error)
        }
    }

    func signOut() async throws {
        guard let client else { return }
        do {
            try await client.auth.signOut(scope: .local)
        } catch {
            throw BackendError.map(error)
        }
    }

    func userIdChanges() -> AsyncStream<UUID?> {
        guard let client else {
            return AsyncStream { $0.yield(nil); $0.finish() }
        }
        return AsyncStream { continuation in
            let task = Task {
                for await (_, session) in client.auth.authStateChanges {
                    if let session, !session.isExpired {
                        continuation.yield(session.user.id)
                    } else {
                        continuation.yield(nil)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

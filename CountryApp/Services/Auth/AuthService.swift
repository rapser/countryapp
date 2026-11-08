//
//  AuthService.swift
//  CountryApp
//

import Foundation

enum SignUpResult: Equatable {
    /// Cuenta creada y sesión iniciada.
    case signedIn
    /// El proyecto exige confirmar el correo antes de iniciar sesión.
    case confirmationRequired
}

protocol AuthServiceProtocol: AnyObject {
    var currentUserId: UUID? { get }
    func signUp(_ request: SignUpRequest) async throws -> SignUpResult
    func signIn(email: String, password: String) async throws
    func signOut() async throws
    /// Emite el id del usuario (o nil) cada vez que cambia la sesión, empezando por la sesión guardada.
    func userIdChanges() -> AsyncStream<UUID?>
}

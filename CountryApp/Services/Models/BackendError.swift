//
//  BackendError.swift
//  CountryApp
//

import Auth
import Foundation
import PostgREST

/// Errores del backend con mensaje listo para mostrar en español.
enum BackendError: LocalizedError, Equatable {
    case notConfigured
    case notAuthenticated
    case invalidCredentials
    case emailNotConfirmed
    case emailAlreadyRegistered
    case weakPassword
    case nicknameTaken
    case network
    case serverUnreachable
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "El servidor no está configurado. Revisa Config/Secrets.xcconfig."
        case .notAuthenticated:
            return "Inicia sesión para continuar."
        case .invalidCredentials:
            return "Correo o contraseña incorrectos."
        case .emailNotConfirmed:
            return "Confirma tu correo antes de iniciar sesión."
        case .emailAlreadyRegistered:
            return "Ya existe una cuenta con ese correo."
        case .weakPassword:
            return "La contraseña es muy débil. Usa al menos 6 caracteres."
        case .nicknameTaken:
            return "Ese nickname ya está en uso."
        case .network:
            return "Sin conexión a internet. Revisa tu red e inténtalo de nuevo."
        case .serverUnreachable:
            return "No pudimos conectar con el servidor. Inténtalo de nuevo en un momento."
        case .unknown(let message):
            return message
        }
    }

    /// Traduce errores de Supabase / URLSession a `BackendError`.
    static func map(_ error: Error) -> BackendError {
        if let backend = error as? BackendError { return backend }
        AppLog.trace("BackendError.map original=\(String(describing: error))")
        if let urlError = error as? URLError {
            return urlError.code == .notConnectedToInternet ? .network : .serverUnreachable
        }
        if let auth = error as? AuthError {
            switch auth.errorCode {
            case .invalidCredentials: return .invalidCredentials
            case .emailNotConfirmed: return .emailNotConfirmed
            case .userAlreadyExists, .emailExists: return .emailAlreadyRegistered
            case .weakPassword: return .weakPassword
            default: break
            }
            // El trigger de alta falla por nickname duplicado → GoTrue devuelve "Database error saving new user".
            if auth.message.localizedCaseInsensitiveContains("database error") {
                return .nicknameTaken
            }
            return .unknown(auth.message)
        }
        if let postgrest = error as? PostgrestError {
            // 23505 = unique_violation (nickname).
            if postgrest.code == "23505" { return .nicknameTaken }
            return .unknown(postgrest.message)
        }
        return .unknown(error.localizedDescription)
    }
}

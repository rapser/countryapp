//
//  ProfileValidator.swift
//  CountryApp
//
//  Validaciones locales de registro y edición de perfil (antes de llamar al backend).
//

import Foundation

enum ProfileValidationError: LocalizedError, Equatable {
    case invalidEmail
    case shortPassword
    case invalidNickname
    case nameTooLong

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Ingresa un correo válido."
        case .shortPassword: return "La contraseña debe tener al menos \(ProfileValidator.minPasswordLength) caracteres."
        case .invalidNickname: return "El nickname debe tener entre 3 y 20 caracteres: letras, números, punto o guion bajo."
        case .nameTooLong: return "El nombre no puede superar los 50 caracteres."
        }
    }
}

enum ProfileValidator {
    static let minPasswordLength = 6

    static func validateEmail(_ email: String) -> ProfileValidationError? {
        let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) == nil ? .invalidEmail : nil
    }

    static func validatePassword(_ password: String) -> ProfileValidationError? {
        password.count < minPasswordLength ? .shortPassword : nil
    }

    static func validateNickname(_ nickname: String) -> ProfileValidationError? {
        let pattern = #"^[A-Za-z0-9_.]{3,20}$"#
        return nickname.range(of: pattern, options: .regularExpression) == nil ? .invalidNickname : nil
    }

    static func validateFullName(_ name: String) -> ProfileValidationError? {
        name.count > 50 ? .nameTooLong : nil
    }
}

//
//  AppColor.swift
//  CountryApp
//
//  Capa única de tokens de color. Hoy son valores solo para tema claro.
//  TODO dark mode: envolver cada token en `UIColor(dynamicProvider:)` cuando se aborde la fase 2.
//

import UIKit

enum AppColor {

    // MARK: - Marca

    /// Morado/índigo principal: botones pill, barra de progreso, iconos, tint de navegación.
    static let primary = UIColor(appHex: 0x5C4DE2)
    /// Estado pulsado del primario.
    static let primaryPressed = UIColor(appHex: 0x4A3DC7)

    // MARK: - Superficies

    /// Fondo de todas las pantallas.
    static let background = UIColor(appHex: 0xF6F6FB)
    /// Fondo de tarjetas.
    static let surface = UIColor.white
    /// Separadores y track de la barra de progreso.
    static let divider = UIColor(appHex: 0xECECF2)

    // MARK: - Texto

    static let textPrimary = UIColor(appHex: 0x29292E)
    static let textSecondary = UIColor(appHex: 0x8A8A99)
    static let textOnPrimary = UIColor.white

    // MARK: - Opciones (identidad fija tipo Kahoot, index 0...3)

    static let optionBlue = UIColor(appHex: 0x4A90E2)
    static let optionRed = UIColor(appHex: 0xE85C5C)
    static let optionOrange = UIColor(appHex: 0xF5A623)
    static let optionGreen = UIColor(appHex: 0x43C59E)

    /// Color de opción por índice (se repite en ciclo si hubiera más de 4).
    static func option(at index: Int) -> UIColor {
        let palette = [optionBlue, optionRed, optionOrange, optionGreen]
        return palette[((index % palette.count) + palette.count) % palette.count]
    }

    // MARK: - Feedback

    /// Cabecera verde "¡Correcto!" y estado de opción correcta.
    static let feedbackCorrect = UIColor(appHex: 0x46C98E)
    /// Cabecera roja "¡Incorrecto!" y estado de opción fallada.
    static let feedbackWrong = UIColor(appHex: 0xE8615D)

    // MARK: - Acentos del resumen

    static let summaryReview = UIColor(appHex: 0xE8615D)
    static let summaryClear = UIColor(appHex: 0x46C98E)
    static let summaryDoubt = UIColor(appHex: 0xF5A623)
}

extension UIColor {
    /// Inicializador desde un entero hexadecimal RGB de 24 bits (`0xRRGGBB`).
    convenience init(appHex hex: UInt32, alpha: CGFloat = 1) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255
        let g = CGFloat((hex & 0x00FF00) >> 8) / 255
        let b = CGFloat(hex & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

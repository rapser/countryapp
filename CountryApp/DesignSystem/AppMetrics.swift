//
//  AppMetrics.swift
//  CountryApp
//
//  Escala de espaciado, radios y sombra compartidos.
//

import UIKit

enum AppMetrics {

    // MARK: - Espaciado

    static let spacing1: CGFloat = 4
    static let spacing2: CGFloat = 8
    static let spacing3: CGFloat = 12
    static let spacing4: CGFloat = 16
    static let spacing5: CGFloat = 20
    static let spacing6: CGFloat = 24
    static let spacing7: CGFloat = 28
    static let spacing8: CGFloat = 32

    // MARK: - Radios

    static let cardRadius: CGFloat = 20
    static let buttonRadius: CGFloat = 16
    static let optionRadius: CGFloat = 16

    // MARK: - Márgenes de pantalla

    static let screenMargin: CGFloat = 20

    // MARK: - Alturas mínimas de control

    static let controlMinHeight: CGFloat = 54
    static let optionMinHeight: CGFloat = 56

    // MARK: - Sombra de tarjeta

    enum Shadow {
        static let color = UIColor.black
        static let opacity: Float = 0.08
        static let radius: CGFloat = 16
        static let offset = CGSize(width: 0, height: 8)
    }
}

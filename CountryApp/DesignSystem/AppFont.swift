//
//  AppFont.swift
//  CountryApp
//
//  Tipografía redondeada del sistema (SF Rounded) con soporte de Dynamic Type.
//  No se bundlean archivos de fuente.
//

import UIKit

enum AppFont {

    /// Fuente redondeada del sistema del tamaño/peso indicados, escalada con Dynamic Type
    /// respecto a `relativeTo`. Si el diseño redondeado no está disponible, cae a la fuente base.
    static func rounded(
        _ size: CGFloat,
        _ weight: UIFont.Weight,
        relativeTo textStyle: UIFont.TextStyle = .body
    ) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        if let descriptor = base.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = base
        }
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }

    // MARK: - Estilos con nombre

    static var largeTitle: UIFont { rounded(34, .bold, relativeTo: .largeTitle) }
    static var title: UIFont { rounded(24, .bold, relativeTo: .title1) }
    static var headline: UIFont { rounded(18, .semibold, relativeTo: .headline) }
    static var body: UIFont { rounded(16, .regular, relativeTo: .body) }
    static var bodyBold: UIFont { rounded(16, .semibold, relativeTo: .body) }
    static var button: UIFont { rounded(17, .bold, relativeTo: .headline) }
    static var caption: UIFont { rounded(13, .medium, relativeTo: .footnote) }
    /// Número grande del badge de puntos ("+945") y de la tarjeta hero del resumen.
    static var score: UIFont { rounded(44, .heavy, relativeTo: .largeTitle) }
    /// Variante reducida del score para el badge del feedback.
    static var scoreBadge: UIFont { rounded(28, .heavy, relativeTo: .title1) }
}

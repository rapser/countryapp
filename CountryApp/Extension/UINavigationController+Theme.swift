//
//  UINavigationController+Theme.swift
//  CountryApp
//
//  Apariencia clara compartida para las pantallas de juego (antes cada VC la copiaba en `viewWillAppear`).
//

import UIKit

extension UINavigationController {

    /// Barra de navegación clara: fondo `AppColor.background`, título oscuro, tint morado.
    static func applyLightAppTheme(to navigationController: UINavigationController?) {
        guard let navBar = navigationController?.navigationBar else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColor.background
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: AppColor.textPrimary,
            .font: AppFont.headline
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: AppColor.textPrimary,
            .font: AppFont.largeTitle
        ]
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.tintColor = AppColor.primary
    }
}

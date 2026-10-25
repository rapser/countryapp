//
//  UITabBarController+Theme.swift
//  CountryApp
//

import UIKit

extension UITabBarController {

    /// Tint morado para el ítem seleccionado; el fondo queda con el material del sistema.
    static func applyAppTheme(to tabBarController: UITabBarController) {
        let tabBar = tabBarController.tabBar
        tabBar.tintColor = AppColor.primary
        tabBar.unselectedItemTintColor = AppColor.textSecondary
    }
}

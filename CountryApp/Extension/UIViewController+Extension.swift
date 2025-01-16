//
//  UIViewController+Extension.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import UIKit

extension UIViewController {
    func showLoadingScreen(message: String = "Cargando...") {
        let loadingView = LoadingView(message: message)
        loadingView.tag = 9999 // Identificador único
        self.view.addSubview(loadingView)
    }
    
    func hideLoadingScreen() {
        if let loadingView = self.view.viewWithTag(9999) {
            loadingView.removeFromSuperview()
        }
    }
}

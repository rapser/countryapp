//
//  LoadingView.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation
import UIKit

class LoadingView: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    
    init(message: String = "Cargando...") {
        super.init(frame: .zero)
        setupView(message: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(message: String) {
        self.frame = UIScreen.main.bounds
        self.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        // Configurar el indicador de actividad
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .yellow
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)
        
        // Configurar el mensaje
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textAlignment = .center
        self.addSubview(messageLabel)
        
        // Configurar las restricciones
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            messageLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            messageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}

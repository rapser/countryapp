//
//  CapitalGameRouterProtocol.swift
//  CountryApp
//

import UIKit

protocol CapitalGameRouterProtocol: AnyObject {
    func pushQuiz(from viewController: UIViewController)
    func pushSummary(from viewController: UIViewController)
    func exitToHome(from viewController: UIViewController)
    /// Login modal desde el resumen (para guardar el puntaje).
    func presentLogin(from viewController: UIViewController)
}


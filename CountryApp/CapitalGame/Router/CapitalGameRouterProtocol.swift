//
//  CapitalGameRouterProtocol.swift
//  CountryApp
//

import UIKit

protocol CapitalGameRouterProtocol: AnyObject {
    func pushQuiz(from viewController: UIViewController)
    func pushSummary(from viewController: UIViewController)
    func exitToHome(from viewController: UIViewController)
}


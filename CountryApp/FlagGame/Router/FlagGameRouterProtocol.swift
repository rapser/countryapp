//
//  FlagGameRouterProtocol.swift
//  CountryApp
//

import UIKit

protocol FlagGameRouterProtocol: AnyObject {
    func pushQuiz(from viewController: UIViewController)
    func pushSummary(from viewController: UIViewController)
    func exitToHome(from viewController: UIViewController)
}

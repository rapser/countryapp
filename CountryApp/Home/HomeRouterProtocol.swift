//
//  HomeRouterProtocol.swift
//  CountryApp
//

import SwiftData
import UIKit

protocol HomeRouterProtocol: AnyObject {
    static func createModule(modelContext: ModelContext) -> UIViewController
    func showCountryList(from viewController: UIViewController)
    func showFlagGame(from viewController: UIViewController)
    func showCapitalGame(from viewController: UIViewController)
}

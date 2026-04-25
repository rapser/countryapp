//
//  HomePresenterProtocol.swift
//  CountryApp
//

import UIKit

protocol HomePresenterProtocol: AnyObject {
    func didTapCountryList(from viewController: UIViewController)
    func didTapFlagGame(from viewController: UIViewController)
    func didTapCapitalGame(from viewController: UIViewController)
}

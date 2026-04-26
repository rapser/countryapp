//
//  HomePresenter.swift
//  CountryApp
//

import UIKit

final class HomePresenter: HomePresenterProtocol {
    weak var view: HomeViewProtocol?
    var router: HomeRouterProtocol?

    func didTapCountryList(from viewController: UIViewController) {
        router?.showCountryList(from: viewController)
    }

    func didTapFlagGame(from viewController: UIViewController) {
        router?.showFlagGame(from: viewController)
    }

    func didTapCapitalGame(from viewController: UIViewController) {
        router?.showCapitalGame(from: viewController)
    }
}

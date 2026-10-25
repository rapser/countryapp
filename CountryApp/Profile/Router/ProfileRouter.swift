//
//  ProfileRouter.swift
//  CountryApp
//

import UIKit

@MainActor
protocol ProfileRouterProtocol: AnyObject {
    func presentLogin(from viewController: UIViewController)
    func presentSignUp(from viewController: UIViewController)
    func pushEditProfile(from viewController: UIViewController)
    func popEditProfile(from viewController: UIViewController)
    func showCountryPicker(from viewController: UIViewController, selectedCode: String?, onSelect: @escaping (CountryOption) -> Void)
}

@MainActor
final class ProfileRouter: ProfileRouterProtocol {
    private let interactor: ProfileInteractorProtocol

    init(interactor: ProfileInteractorProtocol) {
        self.interactor = interactor
    }

    static func createModule() -> UIViewController {
        let interactor = ProfileInteractor()
        let router = ProfileRouter(interactor: interactor)
        let presenter = ProfilePresenter(interactor: interactor, router: router)
        let vc = ProfileViewController(presenter: presenter)
        presenter.view = vc
        return vc
    }

    func presentLogin(from viewController: UIViewController) {
        AuthRouter.presentLogin(from: viewController)
    }

    func presentSignUp(from viewController: UIViewController) {
        AuthRouter.presentSignUp(from: viewController)
    }

    func pushEditProfile(from viewController: UIViewController) {
        let presenter = EditProfilePresenter(interactor: interactor, router: self)
        let vc = EditProfileViewController(presenter: presenter)
        presenter.view = vc
        vc.hidesBottomBarWhenPushed = true
        viewController.navigationController?.pushViewController(vc, animated: true)
    }

    func popEditProfile(from viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }

    func showCountryPicker(from viewController: UIViewController, selectedCode: String?, onSelect: @escaping (CountryOption) -> Void) {
        let picker = CountryPickerViewController(selectedCode: selectedCode, onSelect: onSelect)
        viewController.navigationController?.pushViewController(picker, animated: true)
    }
}

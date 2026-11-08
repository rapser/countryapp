//
//  AuthRouter.swift
//  CountryApp
//
//  Login y registro se presentan como modal desde cualquier tab (perfil, historial, resumen de juego).
//

import UIKit

@MainActor
protocol AuthRouterProtocol: AnyObject {
    func pushSignUp(from viewController: UIViewController)
    func showCountryPicker(from viewController: UIViewController, selectedCode: String?, onSelect: @escaping (CountryOption) -> Void)
    func dismiss(from viewController: UIViewController)
}

@MainActor
final class AuthRouter: AuthRouterProtocol {

    static func presentLogin(from viewController: UIViewController) {
        present(createLoginModule(), from: viewController)
    }

    static func presentSignUp(from viewController: UIViewController) {
        present(createSignUpModule(router: AuthRouter()), from: viewController)
    }

    static func createLoginModule() -> UIViewController {
        let router = AuthRouter()
        let presenter = LoginPresenter(interactor: AuthInteractor(), router: router)
        let vc = LoginViewController(presenter: presenter)
        presenter.view = vc
        return vc
    }

    static func createSignUpModule(router: AuthRouter) -> UIViewController {
        let presenter = SignUpPresenter(interactor: AuthInteractor(), router: router)
        let vc = SignUpViewController(presenter: presenter)
        presenter.view = vc
        return vc
    }

    private static func present(_ root: UIViewController, from viewController: UIViewController) {
        let nav = UINavigationController(rootViewController: root)
        nav.modalPresentationStyle = .pageSheet
        UINavigationController.applyLightAppTheme(to: nav)
        viewController.present(nav, animated: true)
    }

    func pushSignUp(from viewController: UIViewController) {
        viewController.navigationController?.pushViewController(Self.createSignUpModule(router: self), animated: true)
    }

    func showCountryPicker(from viewController: UIViewController, selectedCode: String?, onSelect: @escaping (CountryOption) -> Void) {
        let picker = CountryPickerViewController(selectedCode: selectedCode, onSelect: onSelect)
        viewController.navigationController?.pushViewController(picker, animated: true)
    }

    func dismiss(from viewController: UIViewController) {
        viewController.navigationController?.dismiss(animated: true)
    }
}

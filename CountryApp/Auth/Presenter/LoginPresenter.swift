//
//  LoginPresenter.swift
//  CountryApp
//

import UIKit

@MainActor
protocol LoginViewProtocol: AnyObject {
    func setLoading(_ loading: Bool)
    func showError(_ message: String)
}

@MainActor
protocol LoginPresenterProtocol: AnyObject {
    func didTapSignIn(email: String, password: String, from viewController: UIViewController)
    func didTapCreateAccount(from viewController: UIViewController)
    func didTapClose(from viewController: UIViewController)
}

@MainActor
final class LoginPresenter: LoginPresenterProtocol {
    weak var view: LoginViewProtocol?
    private let interactor: AuthInteractorProtocol
    private let router: AuthRouterProtocol

    init(interactor: AuthInteractorProtocol, router: AuthRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func didTapSignIn(email: String, password: String, from viewController: UIViewController) {
        if let error = ProfileValidator.validateEmail(email) {
            view?.showError(error.localizedDescription)
            return
        }
        guard !password.isEmpty else {
            view?.showError("Ingresa tu contraseña.")
            return
        }
        view?.setLoading(true)
        Task { [weak self, weak viewController] in
            guard let self else { return }
            do {
                try await interactor.signIn(email: email, password: password)
                view?.setLoading(false)
                if let viewController { router.dismiss(from: viewController) }
            } catch {
                view?.setLoading(false)
                view?.showError(BackendError.map(error).localizedDescription)
            }
        }
    }

    func didTapCreateAccount(from viewController: UIViewController) {
        router.pushSignUp(from: viewController)
    }

    func didTapClose(from viewController: UIViewController) {
        router.dismiss(from: viewController)
    }
}

//
//  SignUpPresenter.swift
//  CountryApp
//

import UIKit

struct SignUpForm {
    let fullName: String
    let nickname: String
    let email: String
    let password: String
}

@MainActor
protocol SignUpViewProtocol: AnyObject {
    func setLoading(_ loading: Bool)
    func showError(_ message: String)
    func showCountry(_ country: CountryOption)
    func showPhoto(_ image: UIImage)
    func showConfirmationRequired(email: String)
}

@MainActor
protocol SignUpPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didPickPhoto(_ image: UIImage)
    func didTapCountry(from viewController: UIViewController)
    func didTapSubmit(_ form: SignUpForm, from viewController: UIViewController)
    func didTapClose(from viewController: UIViewController)
}

@MainActor
final class SignUpPresenter: SignUpPresenterProtocol {
    weak var view: SignUpViewProtocol?
    private let interactor: AuthInteractorProtocol
    private let router: AuthRouterProtocol

    private var selectedCountry: CountryOption
    private var avatarJPEG: Data?

    init(interactor: AuthInteractorProtocol, router: AuthRouterProtocol) {
        self.interactor = interactor
        self.router = router
        let code = CountryCatalog.defaultCode
        self.selectedCountry = CountryOption(code: code, name: CountryCatalog.name(for: code))
    }

    func viewDidLoad() {
        view?.showCountry(selectedCountry)
    }

    func didPickPhoto(_ image: UIImage) {
        avatarJPEG = image.avatarJPEGData()
        view?.showPhoto(image)
    }

    func didTapCountry(from viewController: UIViewController) {
        router.showCountryPicker(from: viewController, selectedCode: selectedCountry.code) { [weak self] country in
            self?.selectedCountry = country
            self?.view?.showCountry(country)
        }
    }

    func didTapSubmit(_ form: SignUpForm, from viewController: UIViewController) {
        let validationError = ProfileValidator.validateNickname(form.nickname)
            ?? ProfileValidator.validateFullName(form.fullName)
            ?? ProfileValidator.validateEmail(form.email)
            ?? ProfileValidator.validatePassword(form.password)
        if let validationError {
            view?.showError(validationError.localizedDescription)
            return
        }

        let request = SignUpRequest(
            email: form.email,
            password: form.password,
            nickname: form.nickname,
            fullName: form.fullName.isEmpty ? nil : form.fullName,
            countryCode: selectedCountry.code
        )
        view?.setLoading(true)
        Task { [weak self, weak viewController] in
            guard let self else { return }
            do {
                let result = try await interactor.signUp(request, avatarJPEG: avatarJPEG)
                view?.setLoading(false)
                switch result {
                case .signedIn:
                    if let viewController { router.dismiss(from: viewController) }
                case .confirmationRequired:
                    view?.showConfirmationRequired(email: form.email)
                }
            } catch {
                view?.setLoading(false)
                view?.showError(BackendError.map(error).localizedDescription)
            }
        }
    }

    func didTapClose(from viewController: UIViewController) {
        router.dismiss(from: viewController)
    }
}

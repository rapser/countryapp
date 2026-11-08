//
//  EditProfilePresenter.swift
//  CountryApp
//

import UIKit

@MainActor
protocol EditProfileViewProtocol: AnyObject {
    func showProfile(_ header: ProfileHeaderViewModel, fullName: String, nickname: String)
    func showCountry(_ country: CountryOption)
    func showPhoto(_ image: UIImage)
    func setSaving(_ saving: Bool)
    func showError(_ message: String)
}

@MainActor
protocol EditProfilePresenterProtocol: AnyObject {
    func viewDidLoad()
    func didPickPhoto(_ image: UIImage)
    func didTapCountry(from viewController: UIViewController)
    func didTapSave(_ form: EditProfileForm, from viewController: UIViewController)
}

@MainActor
final class EditProfilePresenter: EditProfilePresenterProtocol {
    weak var view: EditProfileViewProtocol?
    private let interactor: ProfileInteractorProtocol
    private let router: ProfileRouterProtocol

    private var countryCode = CountryCatalog.defaultCode
    private var avatarJPEG: Data?

    init(interactor: ProfileInteractorProtocol, router: ProfileRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        guard let profile = interactor.profile else { return }
        countryCode = profile.countryCode
        view?.showProfile(ProfileHeaderViewModel(profile: profile), fullName: profile.fullName ?? "", nickname: profile.nickname)
        view?.showCountry(CountryOption(code: countryCode, name: CountryCatalog.name(for: countryCode)))
    }

    func didPickPhoto(_ image: UIImage) {
        avatarJPEG = image.avatarJPEGData()
        view?.showPhoto(image)
    }

    func didTapCountry(from viewController: UIViewController) {
        router.showCountryPicker(from: viewController, selectedCode: countryCode) { [weak self] country in
            self?.countryCode = country.code
            self?.view?.showCountry(country)
        }
    }

    func didTapSave(_ form: EditProfileForm, from viewController: UIViewController) {
        let validationError = ProfileValidator.validateNickname(form.nickname)
            ?? ProfileValidator.validateFullName(form.fullName)
        if let validationError {
            view?.showError(validationError.localizedDescription)
            return
        }
        view?.setSaving(true)
        Task { [weak self, weak viewController] in
            guard let self else { return }
            do {
                _ = try await interactor.saveProfile(form, countryCode: countryCode, avatarJPEG: avatarJPEG)
                view?.setSaving(false)
                if let viewController { router.popEditProfile(from: viewController) }
            } catch {
                view?.setSaving(false)
                view?.showError(BackendError.map(error).localizedDescription)
            }
        }
    }
}

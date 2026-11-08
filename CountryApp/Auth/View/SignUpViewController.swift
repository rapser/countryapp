//
//  SignUpViewController.swift
//  CountryApp
//

import PhotosUI
import UIKit

final class SignUpViewController: FormViewController {
    private let presenter: SignUpPresenterProtocol

    private let avatarView = AvatarView(size: .large)
    private let photoButton = UIButton(type: .system)
    private let fullNameField = FormTextField(title: "Nombre (opcional)", placeholder: "Ana Torres", kind: .name)
    private let nicknameField = FormTextField(title: "Nickname", placeholder: "ana_viajera", kind: .nickname)
    private let countrySelector = CountrySelectorControl()
    private let emailField = FormTextField(title: "Correo", placeholder: "tu@correo.com", kind: .email)
    private let passwordField = FormTextField(title: "Contraseña", placeholder: "Mínimo 6 caracteres", kind: .newPassword)
    private let submitButton = PillButton(title: "Crear cuenta", style: .primary)

    init(presenter: SignUpPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Crear cuenta"
        if navigationController?.viewControllers.first === self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                systemItem: .close,
                primaryAction: UIAction { [weak self] _ in
                    guard let self else { return }
                    self.presenter.didTapClose(from: self)
                }
            )
        }

        var photoConfig = UIButton.Configuration.plain()
        photoConfig.title = "Elegir foto"
        photoConfig.image = UIImage(systemName: "camera.fill")
        photoConfig.imagePadding = AppMetrics.spacing2
        photoConfig.baseForegroundColor = AppColor.primary
        photoButton.configuration = photoConfig
        photoButton.addTarget(self, action: #selector(photoTapped), for: .touchUpInside)

        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(photoTapped))
        avatarView.addGestureRecognizer(avatarTap)
        avatarView.isUserInteractionEnabled = true

        let avatarColumn = UIStackView(arrangedSubviews: [avatarView, photoButton])
        avatarColumn.axis = .vertical
        avatarColumn.alignment = .center
        avatarColumn.spacing = AppMetrics.spacing2

        contentStack.addArrangedSubview(avatarColumn)
        contentStack.addArrangedSubview(fullNameField)
        contentStack.addArrangedSubview(nicknameField)
        contentStack.addArrangedSubview(countrySelector)
        contentStack.addArrangedSubview(emailField)
        contentStack.addArrangedSubview(passwordField)
        contentStack.setCustomSpacing(AppMetrics.spacing6, after: passwordField)
        contentStack.addArrangedSubview(submitButton)

        countrySelector.addTarget(self, action: #selector(countryTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        nicknameField.textField.addTarget(self, action: #selector(nicknameChanged), for: .editingChanged)
        fullNameField.textField.addTarget(self, action: #selector(nicknameChanged), for: .editingChanged)

        updateAvatarPreview()
        presenter.viewDidLoad()
    }

    private var selectedCountryCode: String?

    private func updateAvatarPreview() {
        let name = fullNameField.text.isEmpty ? nicknameField.text : fullNameField.text
        avatarView.updateIdentity(name: name, countryCode: selectedCountryCode)
    }

    @objc private func nicknameChanged() {
        updateAvatarPreview()
    }

    @objc private func photoTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func countryTapped() {
        view.endEditing(true)
        presenter.didTapCountry(from: self)
    }

    @objc private func submitTapped() {
        view.endEditing(true)
        presenter.didTapSubmit(
            SignUpForm(
                fullName: fullNameField.text,
                nickname: nicknameField.text,
                email: emailField.text,
                password: passwordField.textField.text ?? ""
            ),
            from: self
        )
    }
}

extension SignUpViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.presenter.didPickPhoto(image)
            }
        }
    }
}

extension SignUpViewController: SignUpViewProtocol {
    func setLoading(_ loading: Bool) {
        submitButton.setLoading(loading)
        isModalInPresentation = loading
        navigationItem.hidesBackButton = loading
    }

    func showError(_ message: String) {
        presentError(message)
    }

    func showCountry(_ country: CountryOption) {
        selectedCountryCode = country.code
        countrySelector.show(country)
        updateAvatarPreview()
    }

    func showPhoto(_ image: UIImage) {
        avatarView.setLocalPhoto(image)
        photoButton.configuration?.title = "Cambiar foto"
    }

    func showConfirmationRequired(email: String) {
        let alert = UIAlertController(
            title: "Revisa tu correo",
            message: "Te enviamos un enlace a \(email). Confírmalo y luego inicia sesión.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Entendido", style: .default) { [weak self] _ in
            guard let self else { return }
            self.presenter.didTapClose(from: self)
        })
        present(alert, animated: true)
    }
}

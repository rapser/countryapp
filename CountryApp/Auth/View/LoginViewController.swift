//
//  LoginViewController.swift
//  CountryApp
//

import UIKit

final class LoginViewController: FormViewController {
    private let presenter: LoginPresenterProtocol

    private let emailField = FormTextField(title: "Correo", placeholder: "tu@correo.com", kind: .email)
    private let passwordField = FormTextField(title: "Contraseña", placeholder: "••••••", kind: .password)
    private let signInButton = PillButton(title: "Ingresar", style: .primary)
    private let createAccountButton = PillButton(title: "Crear cuenta", style: .secondary)

    init(presenter: LoginPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Iniciar sesión"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [weak self] _ in
                guard let self else { return }
                self.presenter.didTapClose(from: self)
            }
        )

        let icon = UIImageView(image: UIImage(systemName: "trophy.circle.fill"))
        icon.tintColor = AppColor.primary
        icon.contentMode = .scaleAspectFit
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 64, weight: .semibold)

        contentStack.addArrangedSubview(icon)
        contentStack.addArrangedSubview(makeLabel("¡Hola de nuevo!", font: AppFont.title, alignment: .center))
        contentStack.addArrangedSubview(makeLabel(
            "Inicia sesión para guardar tus puntos, ver tu historial y competir en el ranking.",
            font: AppFont.body, color: AppColor.textSecondary, alignment: .center
        ))
        contentStack.setCustomSpacing(AppMetrics.spacing6, after: contentStack.arrangedSubviews.last!)
        contentStack.addArrangedSubview(emailField)
        contentStack.addArrangedSubview(passwordField)
        contentStack.addArrangedSubview(signInButton)
        contentStack.setCustomSpacing(AppMetrics.spacing6, after: signInButton)
        contentStack.addArrangedSubview(makeLabel("¿Aún no tienes cuenta?", font: AppFont.caption,
                                                  color: AppColor.textSecondary, alignment: .center))
        contentStack.addArrangedSubview(createAccountButton)

        emailField.textField.returnKeyType = .next
        passwordField.textField.returnKeyType = .go
        emailField.textField.delegate = self
        passwordField.textField.delegate = self
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
    }

    @objc private func signInTapped() {
        view.endEditing(true)
        presenter.didTapSignIn(email: emailField.text, password: passwordField.textField.text ?? "", from: self)
    }

    @objc private func createAccountTapped() {
        presenter.didTapCreateAccount(from: self)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailField.textField {
            passwordField.textField.becomeFirstResponder()
        } else {
            signInTapped()
        }
        return true
    }
}

extension LoginViewController: LoginViewProtocol {
    func setLoading(_ loading: Bool) {
        signInButton.setLoading(loading)
        createAccountButton.isEnabled = !loading
        isModalInPresentation = loading
    }

    func showError(_ message: String) {
        presentError(message)
    }
}

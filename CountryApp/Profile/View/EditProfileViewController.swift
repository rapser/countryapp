//
//  EditProfileViewController.swift
//  CountryApp
//

import PhotosUI
import UIKit

final class EditProfileViewController: FormViewController {
    private let presenter: EditProfilePresenterProtocol

    private let avatarView = AvatarView(size: .large)
    private let photoButton = UIButton(type: .system)
    private let fullNameField = FormTextField(title: "Nombre", placeholder: "Ana Torres", kind: .name)
    private let nicknameField = FormTextField(title: "Nickname", placeholder: "ana_viajera", kind: .nickname)
    private let countrySelector = CountrySelectorControl()
    private let saveButton = PillButton(title: "Guardar cambios", style: .primary)
    private var countryCode: String?

    init(presenter: EditProfilePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Editar perfil"

        var photoConfig = UIButton.Configuration.plain()
        photoConfig.title = "Cambiar foto"
        photoConfig.image = UIImage(systemName: "camera.fill")
        photoConfig.imagePadding = AppMetrics.spacing2
        photoConfig.baseForegroundColor = AppColor.primary
        photoButton.configuration = photoConfig
        photoButton.addTarget(self, action: #selector(photoTapped), for: .touchUpInside)
        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(photoTapped)))

        let avatarColumn = UIStackView(arrangedSubviews: [avatarView, photoButton])
        avatarColumn.axis = .vertical
        avatarColumn.alignment = .center
        avatarColumn.spacing = AppMetrics.spacing2

        contentStack.addArrangedSubview(avatarColumn)
        contentStack.addArrangedSubview(fullNameField)
        contentStack.addArrangedSubview(nicknameField)
        contentStack.addArrangedSubview(countrySelector)
        contentStack.setCustomSpacing(AppMetrics.spacing6, after: countrySelector)
        contentStack.addArrangedSubview(saveButton)

        countrySelector.addTarget(self, action: #selector(countryTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        presenter.viewDidLoad()
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

    @objc private func saveTapped() {
        view.endEditing(true)
        presenter.didTapSave(EditProfileForm(fullName: fullNameField.text, nickname: nicknameField.text), from: self)
    }
}

extension EditProfileViewController: PHPickerViewControllerDelegate {
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

extension EditProfileViewController: EditProfileViewProtocol {
    func showProfile(_ header: ProfileHeaderViewModel, fullName: String, nickname: String) {
        fullNameField.text = fullName
        nicknameField.text = nickname
        countryCode = header.countryCode
        avatarView.configure(name: header.displayName, photoURL: header.avatarURL, countryCode: header.countryCode)
    }

    func showCountry(_ country: CountryOption) {
        countryCode = country.code
        countrySelector.show(country)
        let name = fullNameField.text.isEmpty ? nicknameField.text : fullNameField.text
        avatarView.updateIdentity(name: name, countryCode: country.code)
    }

    func showPhoto(_ image: UIImage) {
        avatarView.setLocalPhoto(image)
    }

    func setSaving(_ saving: Bool) {
        saveButton.setLoading(saving)
        navigationItem.hidesBackButton = saving
    }

    func showError(_ message: String) {
        presentError(message)
    }
}

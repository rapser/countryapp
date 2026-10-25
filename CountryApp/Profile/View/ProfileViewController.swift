//
//  ProfileViewController.swift
//  CountryApp
//

import UIKit

final class ProfileViewController: FormViewController {
    private let presenter: ProfilePresenterProtocol

    private let avatarView = AvatarView(size: .large)
    private let nameLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let countryLabel = UILabel()
    private let statsView = StatTilesView()
    private let editButton = PillButton(title: "Editar perfil", style: .primary)
    private let signOutButton = PillButton(title: "Cerrar sesión", style: .secondary)
    private let emptyState = EmptyStateView()
    private let spinner = UIActivityIndicatorView(style: .large)

    init(presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Perfil"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        nameLabel.font = AppFont.title
        nameLabel.textColor = AppColor.textPrimary
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        nicknameLabel.font = AppFont.bodyBold
        nicknameLabel.textColor = AppColor.primary
        nicknameLabel.textAlignment = .center
        countryLabel.font = AppFont.body
        countryLabel.textColor = AppColor.textSecondary
        countryLabel.textAlignment = .center

        let avatarRow = UIStackView(arrangedSubviews: [avatarView])
        avatarRow.axis = .vertical
        avatarRow.alignment = .center

        contentStack.addArrangedSubview(avatarRow)
        contentStack.addArrangedSubview(nameLabel)
        contentStack.addArrangedSubview(nicknameLabel)
        contentStack.addArrangedSubview(countryLabel)
        contentStack.setCustomSpacing(AppMetrics.spacing1, after: nameLabel)
        contentStack.setCustomSpacing(AppMetrics.spacing1, after: nicknameLabel)
        contentStack.addArrangedSubview(statsView)
        contentStack.setCustomSpacing(AppMetrics.spacing6, after: statsView)
        contentStack.addArrangedSubview(editButton)
        contentStack.addArrangedSubview(signOutButton)

        showStats(HistoryStatsViewModel(myRank: nil))
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)

        emptyState.isHidden = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = AppColor.primary
        spinner.hidesWhenStopped = true
        view.addSubview(emptyState)
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            emptyState.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyState.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyState.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    @objc private func editTapped() {
        presenter.didTapEdit(from: self)
    }

    @objc private func signOutTapped() {
        let sheet = UIAlertController(title: "¿Cerrar sesión?", message: "Podrás seguir jugando como invitado.", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cerrar sesión", style: .destructive) { [weak self] _ in
            self?.presenter.didConfirmSignOut()
        })
        sheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        sheet.popoverPresentationController?.sourceView = signOutButton
        present(sheet, animated: true)
    }

    private func showContent(_ visible: Bool) {
        scrollView.isHidden = !visible
        emptyState.isHidden = visible
    }
}

// MARK: - ProfileViewProtocol

extension ProfileViewController: ProfileViewProtocol {
    func showLoading() {
        scrollView.isHidden = true
        emptyState.isHidden = true
        spinner.startAnimating()
    }

    func showUnavailable() {
        spinner.stopAnimating()
        showContent(false)
        emptyState.configure(symbol: "icloud.slash", title: "Perfil no disponible",
                             message: "Configura Supabase para crear tu cuenta.")
    }

    func showSignedOut() {
        spinner.stopAnimating()
        showContent(false)
        emptyState.configure(
            symbol: "person.crop.circle.badge.plus",
            title: "Únete al ranking",
            message: "Crea tu cuenta con foto, nickname y país para competir con jugadores de todo el mundo.",
            actionTitle: "Crear cuenta"
        ) { [weak self] in
            guard let self else { return }
            self.presenter.didTapSignUp(from: self)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Ingresar",
            primaryAction: UIAction { [weak self] _ in
                guard let self else { return }
                self.presenter.didTapLogin(from: self)
            }
        )
    }

    func showProfile(_ header: ProfileHeaderViewModel) {
        spinner.stopAnimating()
        showContent(true)
        navigationItem.rightBarButtonItem = nil
        avatarView.configure(name: header.displayName, photoURL: header.avatarURL, countryCode: header.countryCode)
        nameLabel.text = header.displayName
        nicknameLabel.text = header.nickname
        countryLabel.text = header.countryName
    }

    func showStats(_ stats: HistoryStatsViewModel) {
        statsView.configure([
            .init(value: stats.totalPoints, label: "Puntos"),
            .init(value: stats.gamesPlayed, label: "Partidas"),
            .init(value: stats.rank, label: "Ranking")
        ])
    }

    func setSigningOut(_ loading: Bool) {
        signOutButton.setLoading(loading)
        editButton.isEnabled = !loading
    }

    func showError(_ message: String) {
        presentError(message)
    }
}

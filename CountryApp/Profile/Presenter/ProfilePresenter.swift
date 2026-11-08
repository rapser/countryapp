//
//  ProfilePresenter.swift
//  CountryApp
//

import UIKit

@MainActor
protocol ProfileViewProtocol: AnyObject {
    func showLoading()
    func showUnavailable()
    func showSignedOut()
    func showProfile(_ header: ProfileHeaderViewModel)
    func showStats(_ stats: HistoryStatsViewModel)
    func setSigningOut(_ loading: Bool)
    func showError(_ message: String)
}

@MainActor
protocol ProfilePresenterProtocol: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func didTapLogin(from viewController: UIViewController)
    func didTapSignUp(from viewController: UIViewController)
    func didTapEdit(from viewController: UIViewController)
    func didConfirmSignOut()
}

@MainActor
final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?
    private let interactor: ProfileInteractorProtocol
    private let router: ProfileRouterProtocol
    private var observers: [NSObjectProtocol] = []
    private var statsStale = true

    init(interactor: ProfileInteractorProtocol, router: ProfileRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        observers.append(NotificationCenter.default.addObserver(forName: .sessionDidChange, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.statsStale = true
                self?.render()
            }
        })
        observers.append(NotificationCenter.default.addObserver(forName: .scoresDidSync, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.statsStale = true }
        })
        render()
    }

    func viewWillAppear() {
        if interactor.isSignedIn && interactor.profile == nil {
            Task { await interactor.refreshProfile() }
        }
        loadStatsIfNeeded()
    }

    func didTapLogin(from viewController: UIViewController) {
        router.presentLogin(from: viewController)
    }

    func didTapSignUp(from viewController: UIViewController) {
        router.presentSignUp(from: viewController)
    }

    func didTapEdit(from viewController: UIViewController) {
        guard interactor.profile != nil else { return }
        router.pushEditProfile(from: viewController)
    }

    func didConfirmSignOut() {
        view?.setSigningOut(true)
        Task { [weak self] in
            guard let self else { return }
            do {
                try await interactor.signOut()
            } catch {
                view?.showError(BackendError.map(error).localizedDescription)
            }
            view?.setSigningOut(false)
        }
    }

    private func render() {
        guard interactor.isBackendAvailable else {
            view?.showUnavailable()
            return
        }
        guard interactor.isSignedIn else {
            view?.showSignedOut()
            return
        }
        if let profile = interactor.profile {
            view?.showProfile(ProfileHeaderViewModel(profile: profile))
            loadStatsIfNeeded()
        } else {
            view?.showLoading()
        }
    }

    private func loadStatsIfNeeded() {
        guard statsStale, interactor.isSignedIn, interactor.profile != nil else { return }
        statsStale = false
        Task { [weak self] in
            guard let self else { return }
            let myRank = await interactor.fetchStats()
            view?.showStats(HistoryStatsViewModel(myRank: myRank))
        }
    }
}

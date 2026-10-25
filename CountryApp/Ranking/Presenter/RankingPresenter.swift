//
//  RankingPresenter.swift
//  CountryApp
//

import UIKit

@MainActor
protocol RankingViewProtocol: AnyObject {
    func showLoading()
    func showRanking(podium: [RankingRowViewModel], rows: [RankingRowViewModel])
    func showMyRank(_ banner: MyRankBanner)
    func showEmpty(title: String, message: String)
    func showError(_ message: String)
}

@MainActor
protocol RankingPresenterProtocol: AnyObject {
    var filters: [RankingFilter] { get }
    func viewDidLoad()
    func viewWillAppear()
    func didSelectFilter(at index: Int)
    func didPullToRefresh()
    func didTapLogin(from viewController: UIViewController)
}

@MainActor
final class RankingPresenter: RankingPresenterProtocol {
    weak var view: RankingViewProtocol?
    private let interactor: RankingInteractorProtocol
    private let router: RankingRouterProtocol

    let filters = RankingFilter.allCases
    private var filter: RankingFilter = .total
    private var loadTask: Task<Void, Never>?
    /// Marca que hay que recargar al volver a la tab (cambió la sesión o se guardó una partida).
    private var isStale = true
    private var observers: [NSObjectProtocol] = []

    init(interactor: RankingInteractorProtocol, router: RankingRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        for name in [Notification.Name.sessionDidChange, .scoresDidSync] {
            observers.append(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.isStale = true }
            })
        }
    }

    func viewWillAppear() {
        guard isStale else { return }
        load(showSpinner: true)
    }

    func didSelectFilter(at index: Int) {
        guard filters.indices.contains(index), filters[index] != filter else { return }
        filter = filters[index]
        load(showSpinner: true)
    }

    func didPullToRefresh() {
        load(showSpinner: false)
    }

    func didTapLogin(from viewController: UIViewController) {
        router.presentLogin(from: viewController)
    }

    private func load(showSpinner: Bool) {
        guard interactor.isBackendAvailable else {
            view?.showEmpty(title: "Ranking no disponible", message: "Configura Supabase para ver el ranking global.")
            view?.showMyRank(.hidden)
            return
        }
        isStale = false
        loadTask?.cancel()
        if showSpinner { view?.showLoading() }
        let filter = self.filter
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                async let entriesCall = interactor.fetchLeaderboard(filter: filter)
                async let myRankCall = interactor.fetchMyRank(filter: filter)
                let (entries, myRank) = try await (entriesCall, myRankCall)
                guard !Task.isCancelled else { return }
                present(entries: entries, myRank: myRank)
            } catch {
                guard !Task.isCancelled else { return }
                isStale = true
                view?.showError(BackendError.map(error).localizedDescription)
            }
        }
    }

    private func present(entries: [LeaderboardEntry], myRank: MyRank?) {
        let userId = interactor.currentUserId
        let rows = entries.map { RankingRowViewModel(entry: $0, currentUserId: userId) }
        if rows.isEmpty {
            view?.showEmpty(title: "Aún no hay puntajes", message: "Juega una partida y sé el primero del ranking.")
        } else {
            view?.showRanking(podium: Array(rows.prefix(3)), rows: Array(rows.dropFirst(3)))
        }

        if userId == nil {
            view?.showMyRank(.guest)
        } else if let myRank {
            view?.showMyRank(.ranked(rank: myRank.rank, points: ScoreFormatter.points(myRank.totalScore)))
        } else {
            view?.showMyRank(.notRanked)
        }
    }
}

//
//  HistoryPresenter.swift
//  CountryApp
//

import UIKit

@MainActor
protocol HistoryViewProtocol: AnyObject {
    func showLoading()
    func showSignedOut()
    func showHistory(stats: HistoryStatsViewModel, rows: [HistoryRowViewModel], hasMore: Bool)
    func showEmpty(stats: HistoryStatsViewModel)
    func showUnavailable()
    func showError(_ message: String)
}

@MainActor
protocol HistoryPresenterProtocol: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func didPullToRefresh()
    func willDisplayRow(at index: Int)
    func didTapLogin(from viewController: UIViewController)
    func didTapPlay(from viewController: UIViewController)
}

@MainActor
final class HistoryPresenter: HistoryPresenterProtocol {
    static let pageSize = 20

    weak var view: HistoryViewProtocol?
    private let interactor: HistoryInteractorProtocol
    private let router: HistoryRouterProtocol

    private var entries: [GameSessionEntry] = []
    private var stats = HistoryStatsViewModel(myRank: nil)
    private var hasMore = false
    private var isLoadingPage = false
    private var isStale = true
    private var loadTask: Task<Void, Never>?
    private var observers: [NSObjectProtocol] = []

    init(interactor: HistoryInteractorProtocol, router: HistoryRouterProtocol) {
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
        reload(showSpinner: true)
    }

    func didPullToRefresh() {
        reload(showSpinner: false)
    }

    func willDisplayRow(at index: Int) {
        guard hasMore, !isLoadingPage, index >= entries.count - 4 else { return }
        loadNextPage()
    }

    func didTapLogin(from viewController: UIViewController) {
        router.presentLogin(from: viewController)
    }

    func didTapPlay(from viewController: UIViewController) {
        router.showHomeTab(from: viewController)
    }

    private func reload(showSpinner: Bool) {
        guard interactor.isBackendAvailable else {
            view?.showUnavailable()
            return
        }
        guard interactor.currentUserId != nil else {
            entries = []
            isStale = false
            view?.showSignedOut()
            return
        }
        isStale = false
        loadTask?.cancel()
        if showSpinner { view?.showLoading() }
        isLoadingPage = true
        loadTask = Task { [weak self] in
            guard let self else { return }
            defer { isLoadingPage = false }
            do {
                async let pageCall = interactor.fetchPage(offset: 0, limit: Self.pageSize)
                async let statsCall = interactor.fetchStats()
                let (page, myRank) = try await (pageCall, statsCall)
                guard !Task.isCancelled else { return }
                entries = page
                hasMore = page.count == Self.pageSize
                stats = HistoryStatsViewModel(myRank: myRank)
                render()
            } catch {
                guard !Task.isCancelled else { return }
                isStale = true
                view?.showError(BackendError.map(error).localizedDescription)
            }
        }
    }

    private func loadNextPage() {
        isLoadingPage = true
        let offset = entries.count
        loadTask = Task { [weak self] in
            guard let self else { return }
            defer { isLoadingPage = false }
            do {
                let page = try await interactor.fetchPage(offset: offset, limit: Self.pageSize)
                guard !Task.isCancelled else { return }
                entries.append(contentsOf: page)
                hasMore = page.count == Self.pageSize
                render()
            } catch {
                hasMore = false
            }
        }
    }

    private func render() {
        if entries.isEmpty {
            view?.showEmpty(stats: stats)
        } else {
            view?.showHistory(stats: stats, rows: entries.map(HistoryRowViewModel.init), hasMore: hasMore)
        }
    }
}

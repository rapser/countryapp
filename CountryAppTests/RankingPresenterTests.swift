//
//  RankingPresenterTests.swift
//  CountryAppTests
//

import XCTest
@testable import CountryApp

@MainActor
private final class MockRankingView: RankingViewProtocol {
    var podium: [RankingRowViewModel] = []
    var rows: [RankingRowViewModel] = []
    var banner: MyRankBanner?
    var emptyTitle: String?
    var error: String?
    var onUpdate: (() -> Void)?

    func showLoading() {}
    func showRanking(podium: [RankingRowViewModel], rows: [RankingRowViewModel]) {
        self.podium = podium
        self.rows = rows
    }
    func showMyRank(_ banner: MyRankBanner) {
        self.banner = banner
        onUpdate?()
    }
    func showEmpty(title: String, message: String) {
        emptyTitle = title
    }
    func showError(_ message: String) {
        error = message
        onUpdate?()
    }
}

@MainActor
private final class MockRankingRouter: RankingRouterProtocol {
    var loginPresented = false
    func presentLogin(from viewController: UIViewController) { loginPresented = true }
}

@MainActor
final class RankingPresenterTests: XCTestCase {
    private var scoreService: MockScoreService!
    private var authService: MockAuthService!
    private var view: MockRankingView!

    override func setUp() {
        super.setUp()
        scoreService = MockScoreService()
        authService = MockAuthService()
        view = MockRankingView()
    }

    private func makePresenter(signedInAs userId: UUID?) -> RankingPresenter {
        authService.currentUserId = userId
        let session = SessionStore(
            authService: authService,
            profileService: MockProfileService(),
            scoreService: scoreService,
            pendingScores: PendingScoreQueue(defaults: MockUserDefaultsManager(), scoreService: scoreService),
            isBackendAvailable: true
        )
        let presenter = RankingPresenter(interactor: RankingInteractor(session: session), router: MockRankingRouter())
        presenter.view = view
        return presenter
    }

    private func loadAndWait(_ presenter: RankingPresenter) async {
        let done = expectation(description: "render")
        view.onUpdate = { done.fulfill() }
        presenter.viewDidLoad()
        presenter.viewWillAppear()
        await fulfillment(of: [done], timeout: 2)
    }

    func testTopThreeGoToPodiumAndRestToList() async {
        let me = UUID()
        scoreService.leaderboard = (1...5).map { BackendFixtures.leaderboardEntry(rank: $0, userId: $0 == 4 ? me : UUID()) }
        scoreService.myRank = MyRank(totalScore: 1_000, gamesPlayed: 3, rank: 4)

        await loadAndWait(makePresenter(signedInAs: me))

        XCTAssertEqual(view.podium.map(\.rank), [1, 2, 3])
        XCTAssertEqual(view.rows.map(\.rank), [4, 5])
        XCTAssertTrue(view.rows[0].isCurrentUser)
        XCTAssertEqual(view.banner, .ranked(rank: 4, points: ScoreFormatter.points(1_000)))
    }

    func testGuestSeesLoginBanner() async {
        scoreService.leaderboard = [BackendFixtures.leaderboardEntry(rank: 1)]
        await loadAndWait(makePresenter(signedInAs: nil))
        XCTAssertEqual(view.banner, .guest)
    }

    func testEmptyLeaderboardShowsEmptyState() async {
        await loadAndWait(makePresenter(signedInAs: UUID()))
        XCTAssertEqual(view.emptyTitle, "Aún no hay puntajes")
        XCTAssertEqual(view.banner, .notRanked)
    }

    func testFilterChangeRequestsThatGameType() async {
        let presenter = makePresenter(signedInAs: nil)
        await loadAndWait(presenter)

        let done = expectation(description: "reload")
        view.onUpdate = { done.fulfill() }
        presenter.didSelectFilter(at: RankingFilter.capital.rawValue)
        await fulfillment(of: [done], timeout: 2)

        XCTAssertEqual(scoreService.requestedLeaderboardTypes, [nil, .capital])
    }
}

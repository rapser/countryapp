//
//  RankingViewController.swift
//  CountryApp
//

import UIKit

final class RankingViewController: UIViewController {
    private let presenter: RankingPresenterProtocol

    private enum Section: Int, CaseIterable {
        case podium
        case rows
    }

    private var podium: [RankingRowViewModel] = []
    private var rows: [RankingRowViewModel] = []

    private lazy var filterControl: UISegmentedControl = {
        let control = UISegmentedControl(items: presenter.filters.map(\.title))
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = AppColor.primary
        control.setTitleTextAttributes([.foregroundColor: AppColor.textOnPrimary, .font: AppFont.bodyBold], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: AppColor.textPrimary, .font: AppFont.body], for: .normal)
        control.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        return control
    }()

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = AppColor.background
        t.separatorStyle = .none
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 72
        t.register(RankingCell.self, forCellReuseIdentifier: RankingCell.reuseIdentifier)
        t.register(PodiumCell.self, forCellReuseIdentifier: PodiumCell.reuseIdentifier)
        return t
    }()

    private let refreshControl = UIRefreshControl()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let emptyState = EmptyStateView()
    private let myRankBar = MyRankBarView()

    init(presenter: RankingPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ranking"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = AppColor.background

        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = AppColor.primary
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = AppColor.primary
        spinner.hidesWhenStopped = true
        emptyState.isHidden = true
        myRankBar.isHidden = true
        myRankBar.onLoginTapped = { [weak self] in
            guard let self else { return }
            self.presenter.didTapLogin(from: self)
        }

        view.addSubview(filterControl)
        view.addSubview(tableView)
        view.addSubview(emptyState)
        view.addSubview(spinner)
        view.addSubview(myRankBar)

        NSLayoutConstraint.activate([
            filterControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppMetrics.spacing2),
            filterControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppMetrics.screenMargin),
            filterControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppMetrics.screenMargin),
            filterControl.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),

            tableView.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: AppMetrics.spacing2),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: myRankBar.topAnchor),

            myRankBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppMetrics.screenMargin),
            myRankBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppMetrics.screenMargin),
            myRankBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -AppMetrics.spacing2),

            emptyState.topAnchor.constraint(equalTo: tableView.topAnchor),
            emptyState.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyState.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])

        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationController.applyLightAppTheme(to: navigationController)
        presenter.viewWillAppear()
    }

    @objc private func filterChanged() {
        presenter.didSelectFilter(at: filterControl.selectedSegmentIndex)
    }

    @objc private func refreshPulled() {
        presenter.didPullToRefresh()
    }
}

// MARK: - RankingViewProtocol

extension RankingViewController: RankingViewProtocol {
    func showLoading() {
        emptyState.isHidden = true
        if podium.isEmpty && rows.isEmpty {
            spinner.startAnimating()
        } else {
            tableView.alpha = 0.5
        }
    }

    func showRanking(podium: [RankingRowViewModel], rows: [RankingRowViewModel]) {
        stopLoading()
        emptyState.isHidden = true
        tableView.isHidden = false
        self.podium = podium
        self.rows = rows
        tableView.reloadData()
    }

    func showMyRank(_ banner: MyRankBanner) {
        myRankBar.apply(banner)
    }

    func showEmpty(title: String, message: String) {
        stopLoading()
        podium = []
        rows = []
        tableView.reloadData()
        emptyState.configure(symbol: "trophy", title: title, message: message)
        emptyState.isHidden = false
    }

    func showError(_ message: String) {
        stopLoading()
        if podium.isEmpty && rows.isEmpty {
            emptyState.configure(symbol: "wifi.exclamationmark", title: "No pudimos cargar el ranking", message: message,
                                 actionTitle: "Reintentar") { [weak self] in
                self?.presenter.didPullToRefresh()
            }
            emptyState.isHidden = false
        } else {
            let alert = UIAlertController(title: "Ups", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Entendido", style: .default))
            present(alert, animated: true)
        }
    }

    private func stopLoading() {
        spinner.stopAnimating()
        refreshControl.endRefreshing()
        tableView.alpha = 1
    }
}

// MARK: - UITableViewDataSource

extension RankingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .podium: return podium.isEmpty ? 0 : 1
        case .rows: return rows.count
        case .none: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if Section(rawValue: indexPath.section) == .podium {
            let cell = tableView.dequeueReusableCell(withIdentifier: PodiumCell.reuseIdentifier, for: indexPath) as! PodiumCell
            cell.configure(with: podium)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: RankingCell.reuseIdentifier, for: indexPath) as! RankingCell
        cell.configure(with: rows[indexPath.row])
        return cell
    }
}

// MARK: - MyRankBarView

/// Barra fija con la posición del usuario (o invitación a iniciar sesión).
final class MyRankBarView: UIView {
    var onLoginTapped: (() -> Void)?

    private let card = CardView(fillColor: AppColor.primary)
    private let label = UILabel()
    private let loginButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        label.font = AppFont.bodyBold
        label.textColor = AppColor.textOnPrimary
        label.numberOfLines = 0

        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = AppColor.surface
        config.baseForegroundColor = AppColor.primary
        config.title = "Ingresar"
        loginButton.configuration = config
        loginButton.setContentHuggingPriority(.required, for: .horizontal)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        let row = UIStackView(arrangedSubviews: [label, loginButton])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.spacing = AppMetrics.spacing3
        row.alignment = .center

        addSubview(card)
        card.contentView.addSubview(row)
        card.cornerRadius = AppMetrics.optionRadius
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),
            row.topAnchor.constraint(equalTo: card.contentView.topAnchor, constant: AppMetrics.spacing3),
            row.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor, constant: -AppMetrics.spacing3),
            row.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor, constant: AppMetrics.spacing4),
            row.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor, constant: -AppMetrics.spacing3)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(_ banner: MyRankBanner) {
        loginButton.isHidden = true
        switch banner {
        case .hidden:
            isHidden = true
            return
        case .guest:
            label.text = "Inicia sesión para aparecer en el ranking"
            loginButton.isHidden = false
        case .notRanked:
            label.text = "Aún no tienes puntos en este modo. ¡Juega una partida!"
        case .ranked(let rank, let points):
            label.text = "Tu posición: #\(rank) · \(points)"
        }
        isHidden = false
    }

    @objc private func loginTapped() {
        onLoginTapped?()
    }
}

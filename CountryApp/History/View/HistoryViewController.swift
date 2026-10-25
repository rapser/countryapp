//
//  HistoryViewController.swift
//  CountryApp
//

import UIKit

final class HistoryViewController: UIViewController {
    private let presenter: HistoryPresenterProtocol

    private var stats: HistoryStatsViewModel?
    private var rows: [HistoryRowViewModel] = []
    private var hasMore = false

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = AppColor.background
        t.separatorStyle = .none
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 80
        t.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseIdentifier)
        t.register(HistoryStatsCell.self, forCellReuseIdentifier: HistoryStatsCell.reuseIdentifier)
        return t
    }()

    private let refreshControl = UIRefreshControl()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let emptyState = EmptyStateView()
    private let footerSpinner = UIActivityIndicatorView(style: .medium)

    init(presenter: HistoryPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Historial"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = AppColor.background

        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = AppColor.primary
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        footerSpinner.frame = CGRect(x: 0, y: 0, width: 0, height: 44)
        footerSpinner.color = AppColor.primary

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = AppColor.primary
        spinner.hidesWhenStopped = true
        emptyState.isHidden = true

        view.addSubview(tableView)
        view.addSubview(emptyState)
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
        UINavigationController.applyLightAppTheme(to: navigationController)
        presenter.viewWillAppear()
    }

    @objc private func refreshPulled() {
        presenter.didPullToRefresh()
    }

    private func stopLoading() {
        spinner.stopAnimating()
        refreshControl.endRefreshing()
    }

    private func showEmptyState(_ configure: (EmptyStateView) -> Void) {
        stopLoading()
        stats = nil
        rows = []
        tableView.reloadData()
        tableView.isHidden = true
        configure(emptyState)
        emptyState.isHidden = false
    }
}

// MARK: - HistoryViewProtocol

extension HistoryViewController: HistoryViewProtocol {
    func showLoading() {
        emptyState.isHidden = true
        if rows.isEmpty { spinner.startAnimating() }
    }

    func showSignedOut() {
        showEmptyState { state in
            state.configure(
                symbol: "clock.badge.questionmark",
                title: "Tu historial te espera",
                message: "Inicia sesión para guardar cada partida y ver cómo mejoras.",
                actionTitle: "Iniciar sesión"
            ) { [weak self] in
                guard let self else { return }
                self.presenter.didTapLogin(from: self)
            }
        }
    }

    func showHistory(stats: HistoryStatsViewModel, rows: [HistoryRowViewModel], hasMore: Bool) {
        stopLoading()
        emptyState.isHidden = true
        tableView.isHidden = false
        self.stats = stats
        self.rows = rows
        self.hasMore = hasMore
        tableView.tableFooterView = hasMore ? footerSpinner : nil
        if hasMore { footerSpinner.startAnimating() } else { footerSpinner.stopAnimating() }
        tableView.reloadData()
    }

    func showEmpty(stats: HistoryStatsViewModel) {
        showEmptyState { state in
            state.configure(
                symbol: "gamecontroller",
                title: "Aún no hay partidas",
                message: "Juega Banderas o Capitales y aquí verás tus resultados.",
                actionTitle: "Jugar ahora"
            ) { [weak self] in
                guard let self else { return }
                self.presenter.didTapPlay(from: self)
            }
        }
    }

    func showUnavailable() {
        showEmptyState { state in
            state.configure(symbol: "icloud.slash", title: "Historial no disponible",
                            message: "Configura Supabase para guardar tus partidas.")
        }
    }

    func showError(_ message: String) {
        if rows.isEmpty {
            showEmptyState { state in
                state.configure(symbol: "wifi.exclamationmark", title: "No pudimos cargar tu historial",
                                message: message, actionTitle: "Reintentar") { [weak self] in
                    self?.presenter.didPullToRefresh()
                }
            }
        } else {
            stopLoading()
            let alert = UIAlertController(title: "Ups", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Entendido", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource / Delegate

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? (stats == nil ? 0 : 1) : rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, let stats {
            let cell = tableView.dequeueReusableCell(withIdentifier: HistoryStatsCell.reuseIdentifier, for: indexPath) as! HistoryStatsCell
            cell.configure(with: stats)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.reuseIdentifier, for: indexPath) as! HistoryCell
        cell.configure(with: rows[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        presenter.willDisplayRow(at: indexPath.row)
    }
}

// MARK: - Cells

final class HistoryStatsCell: UITableViewCell {
    static let reuseIdentifier = "HistoryStatsCell"
    private let tiles = StatTilesView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(tiles)
        NSLayoutConstraint.activate([
            tiles.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppMetrics.spacing2),
            tiles.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppMetrics.spacing3),
            tiles.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppMetrics.screenMargin),
            tiles.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppMetrics.screenMargin)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with stats: HistoryStatsViewModel) {
        tiles.configure([
            .init(value: stats.gamesPlayed, label: "Partidas"),
            .init(value: stats.totalPoints, label: "Puntos"),
            .init(value: stats.rank, label: "Ranking")
        ])
    }
}

final class HistoryCell: UITableViewCell {
    static let reuseIdentifier = "HistoryCell"

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let detailLabel = UILabel()
    private let pointsLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = AppColor.surface
        card.layer.cornerRadius = AppMetrics.optionRadius
        card.layer.cornerCurve = .continuous
        contentView.addSubview(card)

        let iconBackground = UIView()
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconBackground.backgroundColor = AppColor.currentUserHighlight
        iconBackground.layer.cornerRadius = 22
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = AppColor.primary
        iconView.contentMode = .scaleAspectFit
        iconBackground.addSubview(iconView)

        titleLabel.font = AppFont.bodyBold
        titleLabel.textColor = AppColor.textPrimary
        dateLabel.font = AppFont.caption
        dateLabel.textColor = AppColor.textSecondary
        detailLabel.font = AppFont.caption
        detailLabel.textColor = AppColor.textSecondary
        detailLabel.numberOfLines = 0
        pointsLabel.font = AppFont.rounded(16, .heavy, relativeTo: .body)
        pointsLabel.textColor = AppColor.feedbackCorrect
        pointsLabel.setContentHuggingPriority(.required, for: .horizontal)
        pointsLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, pointsLabel])
        titleRow.spacing = AppMetrics.spacing2
        let labels = UIStackView(arrangedSubviews: [titleRow, dateLabel, detailLabel])
        labels.axis = .vertical
        labels.spacing = 2

        let row = UIStackView(arrangedSubviews: [iconBackground, labels])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.spacing = AppMetrics.spacing3
        row.alignment = .center
        card.addSubview(row)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppMetrics.spacing1),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppMetrics.spacing1),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppMetrics.screenMargin),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppMetrics.screenMargin),
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: AppMetrics.spacing3),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -AppMetrics.spacing3),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AppMetrics.spacing3),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AppMetrics.spacing4),
            iconBackground.widthAnchor.constraint(equalToConstant: 44),
            iconBackground.heightAnchor.constraint(equalToConstant: 44),
            iconView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with row: HistoryRowViewModel) {
        iconView.image = UIImage(systemName: row.symbolName)
        titleLabel.text = row.title
        dateLabel.text = row.date
        detailLabel.text = row.detail
        pointsLabel.text = row.points
        isAccessibilityElement = true
        accessibilityLabel = "\(row.title), \(row.date), \(row.points)"
    }
}

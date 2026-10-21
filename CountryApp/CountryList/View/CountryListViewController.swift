//
//  CountryListViewController.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import UIKit

class CountryListViewController: UIViewController, CountryListViewProtocol {
    private let presenter: CountryListPresenterProtocol
    private let tableView = UITableView()
    private var countries: Countries = []
    private var loadingView: LoadingView?
    /// Retrasa la aparición del overlay de carga para evitar un flash en fetches rápidos/cacheados.
    private var pendingLoadingWorkItem: DispatchWorkItem?
    private let searchBar = UISearchBar()

    init(presenter: CountryListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showLoadingView()
        Task {
            await presenter.fetchCountryList()
        }
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Countries"

        searchBar.delegate = self
        searchBar.placeholder = "Buscar país"
        view.addSubview(searchBar)

        view.addSubview(tableView)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }

    func displayCountryList(_ countries: [Country]) {
        self.countries = countries.sorted(by: { $0.name.common < $1.name.common })
        tableView.reloadData()
    }

    func displayFilteredCountries(_ countries: [Country]) {
        self.countries = countries
        tableView.reloadData()
    }

    func displayError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func showLoadingView() {
        guard loadingView == nil, pendingLoadingWorkItem == nil else { return }
        let workItem = DispatchWorkItem { [weak self] in
            guard let self, self.loadingView == nil else { return }
            self.pendingLoadingWorkItem = nil
            let loadingView = LoadingView(message: "Cargando países...")
            self.loadingView = loadingView
            self.view.addSubview(loadingView)
        }
        pendingLoadingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + LoadingView.showDelay, execute: workItem)
    }

    func hideLoadingView() {
        pendingLoadingWorkItem?.cancel()
        pendingLoadingWorkItem = nil
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
}

extension CountryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = countries[indexPath.row].name.common
        cell.detailTextLabel?.text = countries[indexPath.row].capital?.first ?? "Sin capital"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCountry = countries[indexPath.row]
        presenter.didSelectCountry(selectedCountry)
    }
}

extension CountryListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.filterCountries(by: searchText)
    }
}


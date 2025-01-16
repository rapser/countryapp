//
//  CountryDetailViewController.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation
import UIKit

class CountryDetailViewController: UIViewController, CountryDetailViewProtocol {
    private let presenter: CountryDetailPresenterProtocol
    private let tableView = UITableView()
    private let flagImageView = UIImageView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var countryDetail: CountryDetail?
    private var loadingView: LoadingView?

    init(presenter: CountryDetailPresenterProtocol) {
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
            await presenter.fetchCountryDetail()
        }
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Configurar imagen de la bandera
        flagImageView.contentMode = .scaleAspectFit
        flagImageView.translatesAutoresizingMaskIntoConstraints = false

        // Configurar la tabla
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
        tableView.tableHeaderView = flagImageView

        // Configurar el indicador de carga
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        // Agregar botón de cerrar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Cerrar",
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )

        // Agregar subviews
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)

        // Configurar constraints
        NSLayoutConstraint.activate([
            flagImageView.heightAnchor.constraint(equalToConstant: 200),
            flagImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    func displayCountryDetail(_ countryDetail: CountryDetail) {
        self.countryDetail = countryDetail
        guard let detail = countryDetail.first else { return }
        title = detail.name.common // Configurar el título con el nombre del país
        if let flagURL = URL(string: detail.flags.png) {
            loadFlagImage(from: flagURL)
        }
        tableView.reloadData()
    }

    func displayError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func loadFlagImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.flagImageView.image = image
                }
            }
        }
    }
    
    func showLoadingView() {
        if loadingView == nil {
            loadingView = LoadingView(message: "Cargando detalle...")
            view.addSubview(loadingView!)
        }
    }

    func hideLoadingView() {
        if let loadingView = loadingView {
            loadingView.removeFromSuperview()
            self.loadingView = nil
        }
    }
}

// MARK: - UITableViewDataSource
extension CountryDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let detail = countryDetail?.first else { return 0 }
        
        switch section {
        case 0: return 1 // Capital
        case 1: return 1 // Región
        case 2:
            // Verificar si hay fronteras (borders) y retornar el conteo si es válido
            return (detail.borders?.isEmpty ?? true) ? 1 : (detail.borders?.count ?? 0)
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        guard let detail = countryDetail?.first else { return cell }
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = detail.capital.first
        case 1:
            cell.textLabel?.text = detail.region
        case 2:
            if let borders = detail.borders, borders.count > 0 {
                cell.textLabel?.text = borders[indexPath.row]
            } else {
                cell.textLabel?.text = "No hay fronteras"
            }
        default:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Capital"
        case 1: return "Región"
        case 2: return "Límites"
        default: return nil
        }
    }

}




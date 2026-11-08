//
//  CountryPickerViewController.swift
//  CountryApp
//
//  Lista con buscador para elegir el país del perfil.
//

import UIKit

final class CountryPickerViewController: UITableViewController {
    private let selectedCode: String?
    private let onSelect: (CountryOption) -> Void
    private let searchController = UISearchController(searchResultsController: nil)
    private var filtered = CountryCatalog.all

    init(selectedCode: String?, onSelect: @escaping (CountryOption) -> Void) {
        self.selectedCode = selectedCode
        self.onSelect = onSelect
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Elige tu país"
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = AppColor.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "country")

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar país"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedCode, let row = filtered.firstIndex(where: { $0.code == selectedCode }) {
            tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtered.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "country", for: indexPath)
        let country = filtered[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = country.name
        content.textProperties.font = AppFont.body
        content.textProperties.color = AppColor.textPrimary
        content.image = UIImage(named: country.code)
        content.imageProperties.maximumSize = CGSize(width: 36, height: 24)
        content.imageProperties.cornerRadius = 4
        cell.contentConfiguration = content
        cell.accessoryType = country.code == selectedCode ? .checkmark : .none
        cell.tintColor = AppColor.primary
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect(filtered[indexPath.row])
        if searchController.isActive {
            searchController.dismiss(animated: false)
        }
        navigationController?.popViewController(animated: true)
    }
}

extension CountryPickerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
        filtered = query.isEmpty
            ? CountryCatalog.all
            : CountryCatalog.all.filter {
                $0.name.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
        tableView.reloadData()
    }
}

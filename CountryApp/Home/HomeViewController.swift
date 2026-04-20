//
//  HomeViewController.swift
//  CountryApp
//

import UIKit

final class HomeViewController: UIViewController, HomeViewProtocol {
    private let presenter: HomePresenterProtocol
    var interactor: HomeInteractorProtocol?

    private let titleLabel = UILabel()
    private let listButton = UIButton(type: .system)
    private let gameButton = UIButton(type: .system)
    private let stack = UIStackView()

    init(presenter: HomePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "CountryApp"

        Task { [weak self] in
            await self?.interactor?.bootstrapCountriesIfNeeded()
        }

        titleLabel.text = "¿Qué quieres hacer?"
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        listButton.setTitle("Ver listado de países", for: .normal)
        listButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        listButton.addTarget(self, action: #selector(tapList), for: .touchUpInside)

        gameButton.setTitle("Adivinar países (banderas)", for: .normal)
        gameButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        gameButton.addTarget(self, action: #selector(tapGame), for: .touchUpInside)

        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(listButton)
        stack.addArrangedSubview(gameButton)

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func tapList() {
        presenter.didTapCountryList(from: self)
    }

    @objc private func tapGame() {
        presenter.didTapFlagGame(from: self)
    }
}

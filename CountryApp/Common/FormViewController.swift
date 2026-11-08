//
//  FormViewController.swift
//  CountryApp
//
//  Base de las pantallas de formulario (login, registro, editar perfil):
//  scroll que se ajusta al teclado, stack vertical con márgenes y alertas de error.
//

import UIKit

class FormViewController: UIViewController {

    let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.alwaysBounceVertical = true
        s.keyboardDismissMode = .interactive
        return s
    }()

    let contentStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = AppMetrics.spacing4
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = UIEdgeInsets(top: AppMetrics.spacing4, left: AppMetrics.screenMargin,
                                       bottom: AppMetrics.spacing6, right: AppMetrics.screenMargin)
        return s
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingTapped))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationController.applyLightAppTheme(to: navigationController)
    }

    func presentError(_ message: String) {
        let alert = UIAlertController(title: "Ups", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Entendido", style: .default))
        present(alert, animated: true)
    }

    func makeLabel(_ text: String, font: UIFont, color: UIColor = AppColor.textPrimary, alignment: NSTextAlignment = .natural) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    @objc private func endEditingTapped() {
        view.endEditing(true)
    }
}

/// Fila tocable "País: 🇵🇪 Perú ›" usada en registro y edición de perfil.
final class CountrySelectorControl: UIControl {
    private let titleLabel = UILabel()
    private let flagView = UIImageView()
    private let nameLabel = UILabel()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "País"
        titleLabel.font = AppFont.caption
        titleLabel.textColor = AppColor.textSecondary

        let box = UIView()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.isUserInteractionEnabled = false
        box.backgroundColor = AppColor.surface
        box.layer.cornerRadius = AppMetrics.buttonRadius
        box.layer.cornerCurve = .continuous
        box.layer.borderWidth = 1
        box.layer.borderColor = AppColor.divider.cgColor

        flagView.translatesAutoresizingMaskIntoConstraints = false
        flagView.contentMode = .scaleAspectFill
        flagView.clipsToBounds = true
        flagView.layer.cornerRadius = 4

        nameLabel.font = AppFont.body
        nameLabel.textColor = AppColor.textPrimary

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = AppColor.textSecondary
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [flagView, nameLabel, chevron])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.spacing = AppMetrics.spacing3
        row.alignment = .center
        box.addSubview(row)

        let stack = UIStackView(arrangedSubviews: [titleLabel, box])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = AppMetrics.spacing1
        stack.isUserInteractionEnabled = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            box.heightAnchor.constraint(greaterThanOrEqualToConstant: AppMetrics.controlMinHeight),
            row.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: AppMetrics.spacing4),
            row.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -AppMetrics.spacing3),
            row.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            flagView.widthAnchor.constraint(equalToConstant: 32),
            flagView.heightAnchor.constraint(equalToConstant: 22)
        ])
        accessibilityTraits = .button
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(_ country: CountryOption) {
        flagView.image = UIImage(named: country.code)
        nameLabel.text = country.name
        accessibilityLabel = "País: \(country.name)"
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.7 : 1 }
    }
}

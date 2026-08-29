//
//  CapitalGameSummaryViewController.swift
//  CountryApp
//

import UIKit

final class CapitalGameSummaryViewController: UIViewController {
    private let presenter: CapitalGameSummaryPresenterProtocol
    private let summary: GameSummary

    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.alwaysBounceVertical = true
        s.showsVerticalScrollIndicator = true
        return s
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = AppMetrics.spacing4
        s.alignment = .fill
        return s
    }()

    private let exitButton = PillButton(title: "Volver al principio", style: .primary)

    private let rootStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = AppMetrics.spacing3
        s.alignment = .fill
        s.distribution = .fill
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = UIEdgeInsets(top: AppMetrics.spacing2, left: AppMetrics.screenMargin,
                                       bottom: AppMetrics.spacing3, right: AppMetrics.screenMargin)
        return s
    }()

    init(presenter: CapitalGameSummaryPresenterProtocol, summary: GameSummary) {
        self.presenter = presenter
        self.summary = summary
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Resumen"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = AppColor.background

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareTapped)
        )

        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)

        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        contentStack.addArrangedSubview(SummaryCardFactory.heroScoreCard(summary: summary))
        contentStack.addArrangedSubview(
            SummaryCardFactory.sectionCard(
                title: "Repasa estas banderas",
                subtitle: "Fallaste o saltaste la pregunta: conviene revisar el país correcto.",
                accentColor: AppColor.summaryReview,
                rows: summary.reviewFlagRows
            )
        )
        contentStack.addArrangedSubview(
            SummaryCardFactory.sectionCard(
                title: "Las acertaste con claridad",
                subtitle: "Respuesta correcta en \(Int(FlagGameTiming.doubtAnswerThresholdSeconds)) segundos o menos.",
                accentColor: AppColor.summaryClear,
                rows: summary.clearCorrectRows
            )
        )
        contentStack.addArrangedSubview(
            SummaryCardFactory.sectionCard(
                title: "Dudas",
                subtitle: "Aciertos en los que tardaste más de \(Int(FlagGameTiming.doubtAnswerThresholdSeconds)) segundos en confirmar.",
                accentColor: AppColor.summaryDoubt,
                rows: summary.doubtCorrectRows
            )
        )

        rootStack.addArrangedSubview(scrollView)
        rootStack.addArrangedSubview(exitButton)
        view.addSubview(rootStack)

        scrollView.setContentHuggingPriority(.defaultLow, for: .vertical)
        scrollView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        exitButton.setContentHuggingPriority(.required, for: .vertical)
        exitButton.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UINavigationController.applyLightAppTheme(to: navigationController)
    }

    @objc private func exitTapped() {
        presenter.didTapExit(from: self)
    }

    @objc private func shareTapped() {
        let card = GameShareCardRenderer(summary: summary, gameModeName: "Adivina la capital").render()
        let text = "🌍 Acerté \(summary.correctCount) de \(summary.correctCount + summary.wrongCount + summary.skippedCount) capitales. ¿Puedes superarme? #CountryApp"
        let ac = UIActivityViewController(activityItems: [card, text], applicationActivities: nil)
        if let pop = ac.popoverPresentationController {
            pop.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(ac, animated: true)
    }
}

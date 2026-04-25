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
        s.spacing = 18
        s.alignment = .fill
        return s
    }()

    private let exitButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let rootStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 14
        s.alignment = .fill
        s.distribution = .fill
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 12, right: 16)
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
        view.backgroundColor = .systemGroupedBackground

        exitButton.configuration = Self.exitButtonConfiguration()
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)

        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        contentStack.addArrangedSubview(Self.makeIntroLabel())
        contentStack.addArrangedSubview(
            Self.makeSectionCard(
                title: "Repasa estas banderas",
                subtitle: "Fallaste o saltaste la pregunta: conviene revisar el país correcto.",
                accentColor: .systemRed,
                rows: summary.reviewFlagRows
            )
        )
        contentStack.addArrangedSubview(
            Self.makeSectionCard(
                title: "Las acertaste con claridad",
                subtitle: "Respuesta correcta en \(Int(FlagGameTiming.doubtAnswerThresholdSeconds)) segundos o menos.",
                accentColor: .systemGreen,
                rows: summary.clearCorrectRows
            )
        )
        contentStack.addArrangedSubview(
            Self.makeSectionCard(
                title: "Dudas",
                subtitle: "Aciertos en los que tardaste más de \(Int(FlagGameTiming.doubtAnswerThresholdSeconds)) segundos en confirmar.",
                accentColor: .systemOrange,
                rows: summary.doubtCorrectRows
            )
        )
        contentStack.addArrangedSubview(Self.makeFooterDuration(summary.duration))

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
            rootStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc private func exitTapped() {
        presenter.didTapExit(from: self)
    }

    private static func exitButtonConfiguration() -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = "Volver al principio"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .systemBlue
        config.background.cornerRadius = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .boldSystemFont(ofSize: 18)
            return outgoing
        }
        return config
    }

    private static func makeIntroLabel() -> UILabel {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = .preferredFont(forTextStyle: .title3)
        l.textColor = .secondaryLabel
        l.text = "Lo esencial es saber qué repasar y qué ya dominas."
        return l
    }

    private static func makeFooterDuration(_ duration: TimeInterval) -> UILabel {
        let l = UILabel()
        l.numberOfLines = 1
        l.textAlignment = .center
        l.font = .preferredFont(forTextStyle: .footnote)
        l.textColor = .tertiaryLabel
        l.text = "Tiempo en esta sesión: \(formatDuration(duration))"
        return l
    }

    private static func formatDuration(_ t: TimeInterval) -> String {
        let total = max(0, Int(t.rounded()))
        let m = total / 60
        let s = total % 60
        if m == 0 { return "\(s) s" }
        return String(format: "%d min %02d s", m, s)
    }

    private static func makeSectionCard(title: String, subtitle: String?, accentColor: UIColor, rows: [SummaryFlagRow]) -> UIView {
        let outer = UIStackView()
        outer.axis = .vertical
        outer.spacing = 10
        outer.alignment = .fill
        outer.isLayoutMarginsRelativeArrangement = true
        outer.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        outer.backgroundColor = .secondarySystemGroupedBackground
        outer.layer.cornerRadius = 14
        outer.layer.cornerCurve = .continuous

        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = accentColor
        bar.layer.cornerRadius = 2

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        let headerRow = UIStackView(arrangedSubviews: [bar, titleLabel])
        headerRow.axis = .horizontal
        headerRow.spacing = 10
        headerRow.alignment = .center
        NSLayoutConstraint.activate([
            bar.widthAnchor.constraint(equalToConstant: 4),
            bar.heightAnchor.constraint(equalToConstant: 22),
        ])
        outer.addArrangedSubview(headerRow)

        if let subtitle {
            let sub = UILabel()
            sub.text = subtitle
            sub.font = .preferredFont(forTextStyle: .subheadline)
            sub.textColor = .secondaryLabel
            sub.numberOfLines = 0
            outer.addArrangedSubview(sub)
        }

        if rows.isEmpty {
            let empty = UILabel()
            empty.text = "Ninguno en esta partida."
            empty.textColor = .tertiaryLabel
            let base = UIFont.preferredFont(forTextStyle: .callout)
            if let italicDesc = base.fontDescriptor.withSymbolicTraits(.traitItalic) {
                empty.font = UIFont(descriptor: italicDesc, size: 0)
            } else {
                empty.font = base
            }
            outer.addArrangedSubview(empty)
        } else {
            let rowsStack = UIStackView()
            rowsStack.axis = .vertical
            rowsStack.spacing = 10
            for row in rows {
                rowsStack.addArrangedSubview(makeFlagRow(row))
            }
            outer.addArrangedSubview(rowsStack)
        }

        return outer
    }

    private static func makeFlagRow(_ row: SummaryFlagRow) -> UIStackView {
        let flag = UIImageView(image: UIImage(named: row.flagAssetCode))
        flag.contentMode = .scaleAspectFit
        flag.clipsToBounds = true
        flag.layer.cornerRadius = 6
        flag.layer.borderWidth = 1
        flag.layer.borderColor = UIColor.separator.cgColor
        flag.backgroundColor = .tertiarySystemFill
        flag.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            flag.widthAnchor.constraint(equalToConstant: 80),
            flag.heightAnchor.constraint(equalToConstant: 52),
        ])

        let name = UILabel()
        name.text = row.countryName
        name.font = .preferredFont(forTextStyle: .body)
        name.textColor = .label
        name.numberOfLines = 0

        let h = UIStackView(arrangedSubviews: [flag, name])
        h.axis = .horizontal
        h.spacing = 12
        h.alignment = .center
        return h
    }
}


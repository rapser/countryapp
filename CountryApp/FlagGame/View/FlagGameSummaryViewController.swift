//
//  FlagGameSummaryViewController.swift
//  CountryApp
//

import UIKit

final class FlagGameSummaryViewController: UIViewController {
    private let presenter: FlagGameSummaryPresenterProtocol
    private let summary: GameSummary

    private let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isSelectable = true
        tv.isScrollEnabled = true
        tv.alwaysBounceVertical = true
        tv.showsVerticalScrollIndicator = true
        tv.backgroundColor = .secondarySystemGroupedBackground
        tv.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        tv.textContainer.lineFragmentPadding = 0
        tv.adjustsFontForContentSizeCategory = true
        return tv
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

    init(presenter: FlagGameSummaryPresenterProtocol, summary: GameSummary) {
        self.presenter = presenter
        self.summary = summary
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AppLog.trace("FlagGameSummary viewDidLoad")
        title = "Resumen"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground

        exitButton.configuration = Self.exitButtonConfiguration()
        exitButton.addTarget(self, action: #selector(exitTapped), for: .touchUpInside)

        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        exitButton.setContentHuggingPriority(.required, for: .vertical)
        exitButton.setContentCompressionResistancePriority(.required, for: .vertical)

        rootStack.addArrangedSubview(textView)
        rootStack.addArrangedSubview(exitButton)
        view.addSubview(rootStack)

        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let attributed = Self.buildAttributedSummary(summary)
        textView.attributedText = attributed
        AppLog.trace("FlagGameSummary texto length=\(attributed.length) aciertos=\(summary.correctCount)")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppLog.trace("FlagGameSummary viewDidAppear nav=\(navigationController != nil) bounds=\(view.bounds.integral)")
    }

    @objc private func exitTapped() {
        AppLog.trace("FlagGameSummary Volver al principio")
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

    private static func buildAttributedSummary(_ summary: GameSummary) -> NSAttributedString {
        let labelFont = UIFont.preferredFont(forTextStyle: .title2)
        let numberFont = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .systemFont(ofSize: 44, weight: .bold))
        let color = UIColor.label

        let para = NSMutableParagraphStyle()
        para.paragraphSpacing = 20

        let line1Label: [NSAttributedString.Key: Any] = [
            .font: labelFont,
            .foregroundColor: color,
            .paragraphStyle: para
        ]
        let line1Value: [NSAttributedString.Key: Any] = [
            .font: numberFont,
            .foregroundColor: color,
            .paragraphStyle: para
        ]

        let out = NSMutableAttributedString()
        out.append(NSAttributedString(string: "Aciertos\n", attributes: line1Label))
        out.append(NSAttributedString(string: "\(summary.correctCount)\n\n", attributes: line1Value))
        out.append(NSAttributedString(string: "Fallos\n", attributes: line1Label))
        out.append(NSAttributedString(string: "\(summary.wrongCount)", attributes: line1Value))
        return out
    }
}

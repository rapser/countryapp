//
//  RankingCells.swift
//  CountryApp
//

import UIKit

/// Fila del ranking del puesto 4 en adelante: posición, avatar con bandera, nickname y puntos.
final class RankingCell: UITableViewCell {
    static let reuseIdentifier = "RankingCell"

    private let rankLabel = UILabel()
    private let avatarView = AvatarView(size: .small)
    private let nicknameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let pointsLabel = UILabel()
    private let card = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = AppColor.surface
        card.layer.cornerRadius = AppMetrics.optionRadius
        card.layer.cornerCurve = .continuous
        contentView.addSubview(card)

        rankLabel.font = AppFont.rounded(17, .heavy, relativeTo: .headline)
        rankLabel.textColor = AppColor.textSecondary
        rankLabel.textAlignment = .center
        rankLabel.setContentHuggingPriority(.required, for: .horizontal)

        nicknameLabel.font = AppFont.bodyBold
        nicknameLabel.textColor = AppColor.textPrimary
        subtitleLabel.font = AppFont.caption
        subtitleLabel.textColor = AppColor.textSecondary

        pointsLabel.font = AppFont.rounded(16, .heavy, relativeTo: .body)
        pointsLabel.textColor = AppColor.primary
        pointsLabel.setContentHuggingPriority(.required, for: .horizontal)
        pointsLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let labels = UIStackView(arrangedSubviews: [nicknameLabel, subtitleLabel])
        labels.axis = .vertical
        labels.spacing = 2

        let row = UIStackView(arrangedSubviews: [rankLabel, avatarView, labels, pointsLabel])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.spacing = AppMetrics.spacing3
        row.alignment = .center
        row.setCustomSpacing(AppMetrics.spacing4, after: avatarView)
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
            rankLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 32)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with row: RankingRowViewModel) {
        rankLabel.text = "\(row.rank)"
        nicknameLabel.text = row.isCurrentUser ? "\(row.nickname) (tú)" : row.nickname
        subtitleLabel.text = row.subtitle
        pointsLabel.text = row.points
        avatarView.configure(name: row.nickname.replacingOccurrences(of: "@", with: ""), photoURL: row.avatarURL, countryCode: row.countryCode)
        card.backgroundColor = row.isCurrentUser ? AppColor.currentUserHighlight : AppColor.surface
        accessibilityLabel = "Puesto \(row.rank), \(row.nickname), \(row.subtitle), \(row.points)"
        isAccessibilityElement = true
    }
}

/// Celda con el podio de los tres primeros.
final class PodiumCell: UITableViewCell {
    static let reuseIdentifier = "PodiumCell"

    private let columns = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        columns.translatesAutoresizingMaskIntoConstraints = false
        columns.axis = .horizontal
        columns.alignment = .bottom
        columns.distribution = .fillEqually
        columns.spacing = AppMetrics.spacing2
        contentView.addSubview(columns)
        NSLayoutConstraint.activate([
            columns.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AppMetrics.spacing4),
            columns.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AppMetrics.spacing3),
            columns.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppMetrics.screenMargin),
            columns.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppMetrics.screenMargin)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// `podium` viene ordenado 1°, 2°, 3°; se muestra 2° · 1° · 3°.
    func configure(with podium: [RankingRowViewModel]) {
        columns.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let order = [1, 0, 2]
        for index in order {
            if podium.indices.contains(index) {
                columns.addArrangedSubview(Self.makeColumn(for: podium[index], place: index + 1))
            } else {
                columns.addArrangedSubview(UIView())
            }
        }
    }

    private static func makeColumn(for row: RankingRowViewModel, place: Int) -> UIView {
        let medal = AppColor.medal(forRank: place) ?? AppColor.primary
        let isFirst = place == 1

        let crown = UIImageView(image: UIImage(systemName: isFirst ? "crown.fill" : "medal.fill"))
        crown.tintColor = medal
        crown.contentMode = .scaleAspectFit
        crown.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: isFirst ? 26 : 18, weight: .bold)

        let avatar = AvatarView(size: isFirst ? .custom(88) : .medium)
        avatar.ringColor = medal
        avatar.configure(name: row.nickname.replacingOccurrences(of: "@", with: ""), photoURL: row.avatarURL, countryCode: row.countryCode)

        let nickname = UILabel()
        nickname.text = row.nickname
        nickname.font = AppFont.bodyBold
        nickname.textColor = AppColor.textPrimary
        nickname.textAlignment = .center
        nickname.adjustsFontSizeToFitWidth = true
        nickname.minimumScaleFactor = 0.7

        let points = UILabel()
        points.text = row.points
        points.font = AppFont.caption
        points.textColor = AppColor.primary
        points.textAlignment = .center

        let pedestal = UIView()
        pedestal.translatesAutoresizingMaskIntoConstraints = false
        pedestal.backgroundColor = medal.withAlphaComponent(0.22)
        pedestal.layer.cornerRadius = AppMetrics.spacing3
        pedestal.layer.cornerCurve = .continuous
        pedestal.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let placeLabel = UILabel()
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        placeLabel.text = "\(place)"
        placeLabel.font = AppFont.rounded(isFirst ? 30 : 24, .heavy, relativeTo: .title1)
        placeLabel.textColor = medal
        pedestal.addSubview(placeLabel)
        let pedestalHeight: CGFloat = place == 1 ? 72 : (place == 2 ? 52 : 40)
        NSLayoutConstraint.activate([
            pedestal.heightAnchor.constraint(equalToConstant: pedestalHeight),
            placeLabel.centerXAnchor.constraint(equalTo: pedestal.centerXAnchor),
            placeLabel.centerYAnchor.constraint(equalTo: pedestal.centerYAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [crown, avatar, nickname, points, pedestal])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = AppMetrics.spacing1
        stack.setCustomSpacing(AppMetrics.spacing2, after: avatar)
        stack.setCustomSpacing(AppMetrics.spacing2, after: points)
        pedestal.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        nickname.widthAnchor.constraint(lessThanOrEqualTo: stack.widthAnchor).isActive = true

        stack.isAccessibilityElement = true
        stack.accessibilityLabel = "Puesto \(place), \(row.nickname), \(row.subtitle), \(row.points)"
        return stack
    }
}

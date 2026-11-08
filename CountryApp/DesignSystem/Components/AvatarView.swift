//
//  AvatarView.swift
//  CountryApp
//
//  Foto circular del usuario con la bandera de su país como insignia abajo a la derecha.
//  Sin foto muestra las iniciales sobre el color primario.
//

import UIKit

final class AvatarView: UIView {

    enum Size {
        case small
        case medium
        case large
        case custom(CGFloat)

        var diameter: CGFloat {
            switch self {
            case .small: return 44
            case .medium: return 72
            case .large: return 112
            case .custom(let value): return value
            }
        }

        var initialsFont: UIFont {
            AppFont.rounded(diameter * 0.38, .bold, relativeTo: .headline)
        }
    }

    private let size: Size
    private let photoView = UIImageView()
    private let initialsLabel = UILabel()
    private let flagView = UIImageView()
    private var loadTask: Task<Void, Never>?
    private var currentURL: URL?

    /// Color del anillo alrededor de la foto (p. ej. oro/plata/bronce en el podio).
    var ringColor: UIColor? {
        didSet {
            photoView.layer.borderColor = ringColor?.cgColor
            photoView.layer.borderWidth = ringColor == nil ? 0 : max(2, size.diameter * 0.04)
        }
    }

    init(size: Size) {
        self.size = size
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: size.diameter, height: size.diameter)
    }

    /// Configura foto, iniciales y bandera. Seguro para reutilizar en celdas.
    func configure(name: String, photoURL: URL?, countryCode: String?) {
        updateIdentity(name: name, countryCode: countryCode)

        guard photoURL != currentURL || photoView.image == nil else { return }
        loadTask?.cancel()
        currentURL = photoURL
        showPhoto(nil)

        guard let url = photoURL else { return }
        if let cached = ImageLoader.shared.cachedImage(for: url) {
            showPhoto(cached)
            return
        }
        loadTask = Task { [weak self] in
            let image = await ImageLoader.shared.image(for: url)
            guard !Task.isCancelled, let self, self.currentURL == url else { return }
            self.showPhoto(image)
        }
    }

    /// Actualiza iniciales y bandera sin tocar la foto.
    func updateIdentity(name: String, countryCode: String?) {
        initialsLabel.text = Self.initials(from: name)
        if let code = countryCode, let flag = UIImage(named: code.lowercased()) {
            flagView.image = flag
            flagView.isHidden = false
        } else {
            flagView.isHidden = true
        }
        accessibilityLabel = name
    }

    /// Muestra una imagen local (p. ej. la elegida en el picker antes de subirla).
    func setLocalPhoto(_ image: UIImage?) {
        loadTask?.cancel()
        currentURL = nil
        showPhoto(image)
    }

    private func showPhoto(_ image: UIImage?) {
        photoView.image = image
        initialsLabel.isHidden = image != nil
    }

    static func initials(from name: String) -> String {
        let parts = name
            .split(whereSeparator: { $0 == " " || $0 == "_" || $0 == "." })
            .prefix(2)
        let letters = parts.compactMap { $0.first.map(String.init) }.joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }

    private func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        let diameter = size.diameter
        let flagWidth = diameter * 0.42
        let flagHeight = flagWidth * 0.7

        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        photoView.backgroundColor = AppColor.primary
        photoView.layer.cornerRadius = diameter / 2

        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.font = size.initialsFont
        initialsLabel.textColor = AppColor.textOnPrimary
        initialsLabel.textAlignment = .center
        initialsLabel.adjustsFontSizeToFitWidth = true

        flagView.translatesAutoresizingMaskIntoConstraints = false
        flagView.contentMode = .scaleAspectFill
        flagView.clipsToBounds = true
        flagView.layer.cornerRadius = max(3, flagHeight * 0.22)
        flagView.layer.cornerCurve = .continuous
        flagView.layer.borderColor = AppColor.surface.cgColor
        flagView.layer.borderWidth = max(1.5, diameter * 0.03)
        flagView.backgroundColor = AppColor.divider

        addSubview(photoView)
        photoView.addSubview(initialsLabel)
        addSubview(flagView)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: diameter),
            heightAnchor.constraint(equalToConstant: diameter),
            photoView.topAnchor.constraint(equalTo: topAnchor),
            photoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoView.bottomAnchor.constraint(equalTo: bottomAnchor),
            initialsLabel.centerXAnchor.constraint(equalTo: photoView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: photoView.centerYAnchor),
            initialsLabel.widthAnchor.constraint(lessThanOrEqualTo: photoView.widthAnchor, multiplier: 0.8),
            flagView.widthAnchor.constraint(equalToConstant: flagWidth),
            flagView.heightAnchor.constraint(equalToConstant: flagHeight),
            flagView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: diameter * 0.04),
            flagView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: diameter * 0.02)
        ])
    }
}

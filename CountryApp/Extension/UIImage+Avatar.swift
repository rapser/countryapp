//
//  UIImage+Avatar.swift
//  CountryApp
//

import UIKit

extension UIImage {
    /// Recorte cuadrado centrado, reducido a `maxSide` y comprimido en JPEG para subir como avatar.
    func avatarJPEGData(maxSide: CGFloat = 512, quality: CGFloat = 0.8) -> Data? {
        let side = min(size.width, size.height)
        let target = min(side, maxSide)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: target, height: target), format: format)
        let scaled = renderer.image { _ in
            let scale = target / side
            let drawSize = CGSize(width: size.width * scale, height: size.height * scale)
            let origin = CGPoint(x: (target - drawSize.width) / 2, y: (target - drawSize.height) / 2)
            draw(in: CGRect(origin: origin, size: drawSize))
        }
        return scaled.jpegData(compressionQuality: quality)
    }
}

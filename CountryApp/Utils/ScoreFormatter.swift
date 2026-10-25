//
//  ScoreFormatter.swift
//  CountryApp
//

import Foundation

enum ScoreFormatter {
    private static let number: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "es_PE")
        f.maximumFractionDigits = 0
        return f
    }()

    /// "12,345 pts"
    static func points(_ value: Int) -> String {
        "\(number.string(from: NSNumber(value: value)) ?? "\(value)") pts"
    }

    static func plain(_ value: Int) -> String {
        number.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// "2:05"
    static func duration(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

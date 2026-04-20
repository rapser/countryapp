//
//  Country.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

struct Country: Codable, Equatable {
    let name: Name
    let capital: [String]?
    /// ISO 3166-1 alpha-2 (may come from API as `cca2`).
    let cca2: String?
    /// Name of the asset in `Assets.xcassets/countries` (e.g. `gb-nir`).
    let assetFlag: String?

    enum CodingKeys: String, CodingKey {
        case name, capital, cca2, assetFlag
    }

    init(name: Name, capital: [String]?, cca2: String? = nil, assetFlag: String? = nil) {
        self.name = name
        self.capital = capital
        self.cca2 = cca2
        self.assetFlag = assetFlag
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(Name.self, forKey: .name)
        capital = try c.decodeIfPresent([String].self, forKey: .capital)
        cca2 = try c.decodeIfPresent(String.self, forKey: .cca2)
        assetFlag = try c.decodeIfPresent(String.self, forKey: .assetFlag)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encodeIfPresent(capital, forKey: .capital)
        try c.encodeIfPresent(cca2, forKey: .cca2)
        try c.encodeIfPresent(assetFlag, forKey: .assetFlag)
    }

    /// Lowercased asset name for `UIImage(named:)`.
    var resolvedFlagAssetCode: String {
        if let asset = assetFlag?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !asset.isEmpty {
            return asset
        }
        if let code = cca2?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !code.isEmpty {
            return code
        }
        return ""
    }

    static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.name == rhs.name
            && lhs.capital == rhs.capital
            && lhs.cca2 == rhs.cca2
            && lhs.assetFlag == rhs.assetFlag
    }
}

// MARK: - Flags
struct Flags: Codable {
    let png: String
    let svg: String
    let alt: String?
}

// MARK: - Name
struct Name: Codable, Equatable {
    let common: String
    let official: String
}

typealias Countries = [Country]

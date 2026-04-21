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
    /// Capital en español (misma forma que `capital`); opcional en el JSON.
    let capitalSpanish: [String]?
    /// ISO 3166-1 alpha-2 (may come from API as `cca2`).
    let cca2: String?
    /// Name of the asset in `Assets.xcassets/countries` (e.g. `gb-nir`).
    let assetFlag: String?

    enum CodingKeys: String, CodingKey {
        case name, capital, capitalSpanish, cca2, assetFlag
    }

    init(name: Name, capital: [String]?, capitalSpanish: [String]? = nil, cca2: String? = nil, assetFlag: String? = nil) {
        self.name = name
        self.capital = capital
        self.capitalSpanish = capitalSpanish
        self.cca2 = cca2
        self.assetFlag = assetFlag
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(Name.self, forKey: .name)
        capital = try c.decodeIfPresent([String].self, forKey: .capital)
        capitalSpanish = try c.decodeIfPresent([String].self, forKey: .capitalSpanish)
        cca2 = try c.decodeIfPresent(String.self, forKey: .cca2)
        assetFlag = try c.decodeIfPresent(String.self, forKey: .assetFlag)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encodeIfPresent(capital, forKey: .capital)
        try c.encodeIfPresent(capitalSpanish, forKey: .capitalSpanish)
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
            && lhs.capitalSpanish == rhs.capitalSpanish
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
    /// Nombre en español (`name.nameSpanish` en el API). Opcional por compatibilidad.
    let nameSpanish: String?

    enum CodingKeys: String, CodingKey {
        case common, official, nameSpanish
    }

    init(common: String, official: String, nameSpanish: String? = nil) {
        self.common = common
        self.official = official
        self.nameSpanish = nameSpanish
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        common = try c.decode(String.self, forKey: .common)
        official = try c.decode(String.self, forKey: .official)
        nameSpanish = try c.decodeIfPresent(String.self, forKey: .nameSpanish)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(common, forKey: .common)
        try c.encode(official, forKey: .official)
        try c.encodeIfPresent(nameSpanish, forKey: .nameSpanish)
    }
}

typealias Countries = [Country]

//
//  CountryDetail.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

struct CountryDetailElement: Decodable {
    let name: Name
    let capital: [String]
    /// Si el mock incluye `capitalSpanish`, la UI de detalle la usa para la fila Capital.
    let capitalSpanish: [String]?
    let region: String
    let borders: [String]?
    let flags: Flags
    let latlng: [Double]

    enum CodingKeys: String, CodingKey {
        case name, capital, capitalSpanish, region, borders, flags, latlng
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(Name.self, forKey: .name)
        capital = try c.decodeIfPresent([String].self, forKey: .capital) ?? []
        capitalSpanish = try c.decodeIfPresent([String].self, forKey: .capitalSpanish)
        region = try c.decode(String.self, forKey: .region)
        borders = try c.decodeIfPresent([String].self, forKey: .borders)
        flags = try c.decode(Flags.self, forKey: .flags)
        latlng = try c.decode([Double].self, forKey: .latlng)
    }

    init(name: Name, capital: [String], capitalSpanish: [String]? = nil, region: String, borders: [String]?, flags: Flags, latlng: [Double]) {
        self.name = name
        self.capital = capital
        self.capitalSpanish = capitalSpanish
        self.region = region
        self.borders = borders
        self.flags = flags
        self.latlng = latlng
    }
}

typealias CountryDetail = [CountryDetailElement]

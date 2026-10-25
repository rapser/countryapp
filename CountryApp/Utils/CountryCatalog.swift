//
//  CountryCatalog.swift
//  CountryApp
//
//  Países elegibles para el perfil: regiones ISO con bandera en el catálogo de assets,
//  con nombre en español. No depende de que el listado remoto ya esté en SwiftData.
//

import UIKit

struct CountryOption: Equatable {
    /// Código del asset de bandera (ISO 3166-1 alpha-2 en minúsculas).
    let code: String
    let name: String
}

enum CountryCatalog {
    private static let spanish = Locale(identifier: "es")

    static let all: [CountryOption] = {
        Locale.Region.isoRegions
            .map { $0.identifier }
            .filter { $0.count == 2 && $0.allSatisfy(\.isLetter) }
            .map { $0.lowercased() }
            .filter { UIImage(named: $0) != nil }
            .map { CountryOption(code: $0, name: name(for: $0)) }
            .sorted { $0.name.compare($1.name, locale: spanish) == .orderedAscending }
    }()

    static func name(for code: String) -> String {
        spanish.localizedString(forRegionCode: code.uppercased()) ?? code.uppercased()
    }

    /// País del dispositivo si tiene bandera; si no, Perú.
    static var defaultCode: String {
        let region = Locale.current.region?.identifier.lowercased() ?? "pe"
        return UIImage(named: region) != nil ? region : "pe"
    }
}

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
    
    static func ==(lhs: Country, rhs: Country) -> Bool {
        return lhs.name == rhs.name && lhs.capital == rhs.capital
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

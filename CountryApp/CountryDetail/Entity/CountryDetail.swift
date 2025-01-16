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
    let region: String
    let borders: [String]?
    let flags: Flags
}

typealias CountryDetail = [CountryDetailElement]

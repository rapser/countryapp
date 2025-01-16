//
//  CountryListError.swift
//  CountryApp
//
//  Created by miguel tomairo on 16/01/25.
//

import Foundation

enum CountryListError: Error {
    case interactorUnavailable
    case invalidResponse
    case unknownError
}

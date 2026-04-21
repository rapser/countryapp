//
//  HomeInteractorProtocol.swift
//  CountryApp
//

import Foundation

protocol HomeInteractorProtocol: AnyObject {
    /// Descarga y guarda países solo si SwiftData está vacío.
    func bootstrapCountriesIfNeeded() async
}

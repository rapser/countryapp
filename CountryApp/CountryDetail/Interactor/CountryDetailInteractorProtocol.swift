//
//  CountryDetailInteractorProtocol.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

protocol CountryDetailInteractorProtocol: AnyObject {
    var presenter: CountryDetailPresenterProtocol? { get set }
    func fetchCountryDetail(name: String) async throws
}

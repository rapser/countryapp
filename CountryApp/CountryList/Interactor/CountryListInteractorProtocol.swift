//
//  CountryListInteractorProtocol.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

protocol CountryListInteractorProtocol: AnyObject {
    var presenter: CountryListPresenterProtocol? { get set }
    func fetchCountryList() async throws
}

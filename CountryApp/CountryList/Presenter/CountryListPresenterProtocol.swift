//
//  CountryListPresenterProtocol.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

protocol CountryListPresenterProtocol: AnyObject {
    var view: CountryListViewProtocol? { get set }
    var interactor: CountryListInteractorProtocol? { get set }
    
    func didFetchCountryList(_ countries: Countries)
    func didFailWithError(_ error: Error)
    
    func fetchCountryList() async
    func filterCountries(by searchText: String)
}


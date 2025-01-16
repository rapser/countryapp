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

    func didFetchCountryList(_ countries: [Country])  // Notifica a la vista sobre los datos
    func didFailWithError(_ error: Error)            // Notifica a la vista sobre errores
    
    func fetchCountryList() async                    // Inicia la obtención de datos, sin lanzar errores
}


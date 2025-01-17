//
//  CountryListInteractorTests.swift
//  CountryAppTests
//
//  Created by miguel tomairo on 17/01/25.
//

import XCTest
@testable import CountryApp

final class CountryListInteractorTests: XCTestCase {

    private var interactor: CountryListInteractor!
    private var mockService: MockCountryListService!
    private var mockUserDefaultsManager: MockUserDefaultsManager!
    private var mockPresenter: MockCountryListPresenter!

    override func setUp() {
        super.setUp()
        mockService = MockCountryListService()
        mockUserDefaultsManager = MockUserDefaultsManager()
        interactor = CountryListInteractor(service: mockService, userDefaultsManager: mockUserDefaultsManager)
        mockPresenter = MockCountryListPresenter()
        interactor.presenter = mockPresenter
    }

    override func tearDown() {
        interactor = nil
        mockService = nil
        mockUserDefaultsManager = nil
        mockPresenter = nil
        super.tearDown()
    }

    func testFetchCountryList_usesCachedData() async throws {
        // Arrange
        let cachedCountries: Countries = [
            Country(name: Name(common: "Argentina", official: "Argentine Republic"), capital: ["Buenos Aires"])
        ]
        let testKey = "savedCountries"
        let mockUserDefaultsManager = MockUserDefaultsManager()
        let mockPresenter = MockCountryListPresenter()

        // Configurar el interactor
        interactor.userDefaultsManager = mockUserDefaultsManager
        interactor.presenter = mockPresenter

        // Guardar los datos de prueba en el mock de UserDefaultsManager
        mockUserDefaultsManager.save(object: cachedCountries, forKey: testKey)

        // Act
        try await interactor.fetchCountryList()

        // Assert
        XCTAssertTrue(mockPresenter.didFetchCountryListCalled, "El método didFetchCountryList debería haber sido llamado.")
        XCTAssertEqual(mockPresenter.fetchedCountries, cachedCountries, "Los países recuperados deberían coincidir con los datos en caché.")
    }

    func testFetchCountryList_usesServiceWhenNoCache() async throws {
        let serviceCountries: Countries = [
            Country(name: Name(common: "CachedCountry", official: "Argentine Republic"), capital: ["Buenos Aires"])
        ]
        mockService.mockedCountries = serviceCountries

        try await interactor.fetchCountryList()

        XCTAssertTrue(mockService.fetchCountryListCalled)
        XCTAssertTrue(mockUserDefaultsManager.saveCalled)
        XCTAssertTrue(mockPresenter.didFetchCountryListCalled)
        XCTAssertEqual(mockPresenter.fetchedCountries, serviceCountries)
    }

    func testFetchCountryList_handlesServiceError() async {
        mockService.shouldThrowError = true

        do {
            try await interactor.fetchCountryList()
            XCTFail("Expected error but got none.")
        } catch {
            XCTAssertTrue(mockPresenter.didFailWithErrorCalled)
        }
    }
}

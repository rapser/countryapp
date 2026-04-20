//
//  CountryListInteractorTests.swift
//  CountryAppTests
//

import SwiftData
import XCTest
@testable import CountryApp

final class CountryListInteractorTests: XCTestCase {

    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    private var interactor: CountryListInteractor!
    private var mockService: MockCountryListService!
    private var mockPresenter: MockCountryListPresenter!

    override func setUp() {
        super.setUp()
        mockService = MockCountryListService()
        mockPresenter = MockCountryListPresenter()
        let schema = Schema([PersistedCountry.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        interactor = CountryListInteractor(service: mockService, persistence: persistence)
        interactor.presenter = mockPresenter
    }

    override func tearDown() {
        interactor = nil
        mockService = nil
        mockPresenter = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    func testFetchCountryList_whenPersistenceHasData_doesNotCallService() async throws {
        let rows = [
            Country(name: Name(common: "Argentina", official: "Argentine Republic"), capital: ["Buenos Aires"], cca2: "AR", assetFlag: nil)
        ]
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        try persistence.replaceAll(from: rows)

        try await interactor.fetchCountryList()

        XCTAssertFalse(mockService.fetchCountryListCalled)
        XCTAssertTrue(mockPresenter.didFetchCountryListCalled)
        XCTAssertEqual(mockPresenter.fetchedCountries.first?.name.common, "Argentina")
    }

    func testFetchCountryList_whenPersistenceEmpty_fetchesAndPersists() async throws {
        mockService.mockedCountries = [
            Country(name: Name(common: "Peru", official: "Republic of Peru"), capital: ["Lima"], cca2: "PE", assetFlag: nil)
        ]

        try await interactor.fetchCountryList()

        XCTAssertTrue(mockService.fetchCountryListCalled)
        XCTAssertTrue(mockPresenter.didFetchCountryListCalled)
        XCTAssertEqual(mockPresenter.fetchedCountries.first?.name.common, "Peru")

        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        XCTAssertEqual(try persistence.persistedCount(), 1)
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

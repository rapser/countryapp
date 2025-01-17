//
//  CountryDetailInteractorTests.swift
//  CountryAppTests
//
//  Created by miguel tomairo on 16/01/25.
//

import XCTest
@testable import CountryApp

final class CountryDetailInteractorTests: XCTestCase {
    
    var interactor: CountryDetailInteractor!
    var mockPresenter: MockCountryDetailPresenter!
    var mockService: MockCountryDetailService!
    
    override func setUp() {
        super.setUp()
        mockPresenter = MockCountryDetailPresenter()
        mockService = MockCountryDetailService()
        
        interactor = CountryDetailInteractor(service: mockService)
        interactor.presenter = mockPresenter
    }
    
    func testFetchCountryDetail_whenServiceReturnsData_callsPresenter() async {
        
        let mockCountryDetail = CountryDetailElement(
            name: Name(common: "Peru", official: "Republic of Peru"),
            capital: ["Lima"],
            region: "America",
            borders: nil,
            flags: Flags(png: "someFlagUrl", svg: "someSvg", alt: "someAlt"),
            latlng: [-12.0,-77.0]
        )
        
        mockService.countryDetailToReturn = [mockCountryDetail]
        
        do {
            try await interactor.fetchCountryDetail(name: "Peru")
        } catch {
            XCTFail("Expected successful fetch, but got an error: \(error)")
        }
        
        XCTAssertTrue(mockService.fetchCountryDetailCalled)
        XCTAssertTrue(mockPresenter.didFetchCountryDetailCalled)
        XCTAssertEqual(mockPresenter.receivedCountryDetail?.first?.name.common, "Peru")
    }
    
    func testFetchCountryDetail_whenServiceThrowsError_callsPresenterWithError() async {
        mockService.errorToThrow = CountryDetailError.unknownError
        
        do {
            try await interactor.fetchCountryDetail(name: "Peru")
        } catch {
            // Expected to throw an error
        }
        
        XCTAssertTrue(mockService.fetchCountryDetailCalled)
        XCTAssertTrue(mockPresenter.didFailWithErrorCalled)
        XCTAssertEqual(mockPresenter.receivedError as? CountryDetailError, CountryDetailError.unknownError)
    }
    
    func testFetchCountryDetail_whenNameIsEmpty_throwsCountryNameUnavailableError() async {
        do {
            try await interactor.fetchCountryDetail(name: "")
        } catch let error as CountryDetailError {
            XCTAssertEqual(error, CountryDetailError.countryNameUnavailable)
        } catch {
            XCTFail("Expected CountryDetailError.countryNameUnavailable, but got: \(error)")
        }
    }
}

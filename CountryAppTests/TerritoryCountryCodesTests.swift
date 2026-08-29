//
//  TerritoryCountryCodesTests.swift
//  CountryAppTests
//

import XCTest
@testable import CountryApp

final class TerritoryCountryCodesTests: XCTestCase {

    func testIsIndependent_falseForKnownTerritories() {
        XCTAssertFalse(TerritoryCountryCodes.isIndependent("gb-eng"))
        XCTAssertFalse(TerritoryCountryCodes.isIndependent("ck"))
        XCTAssertFalse(TerritoryCountryCodes.isIndependent("nu"))
        XCTAssertFalse(TerritoryCountryCodes.isIndependent("eh"))
        XCTAssertFalse(TerritoryCountryCodes.isIndependent("pr"))
        XCTAssertFalse(TerritoryCountryCodes.isIndependent("hk"))
    }

    func testIsIndependent_trueForDisputedButSelfGovernedCases() {
        XCTAssertTrue(TerritoryCountryCodes.isIndependent("tw"))
        XCTAssertTrue(TerritoryCountryCodes.isIndependent("xk"))
        XCTAssertTrue(TerritoryCountryCodes.isIndependent("ps"))
    }

    func testIsIndependent_defaultsTrueForUnknownCode() {
        XCTAssertTrue(TerritoryCountryCodes.isIndependent("zz-not-a-real-code"))
    }
}

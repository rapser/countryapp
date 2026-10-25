//
//  ProfileValidatorTests.swift
//  CountryAppTests
//

import XCTest
@testable import CountryApp

final class ProfileValidatorTests: XCTestCase {

    func testEmailValidation() {
        XCTAssertNil(ProfileValidator.validateEmail("ana@correo.com"))
        XCTAssertEqual(ProfileValidator.validateEmail("ana@correo"), .invalidEmail)
        XCTAssertEqual(ProfileValidator.validateEmail("ana correo.com"), .invalidEmail)
        XCTAssertEqual(ProfileValidator.validateEmail(""), .invalidEmail)
    }

    func testPasswordNeedsMinimumLength() {
        XCTAssertEqual(ProfileValidator.validatePassword("12345"), .shortPassword)
        XCTAssertNil(ProfileValidator.validatePassword("123456"))
    }

    func testNicknameRules() {
        XCTAssertNil(ProfileValidator.validateNickname("ana_viajera"))
        XCTAssertNil(ProfileValidator.validateNickname("a.b"))
        XCTAssertEqual(ProfileValidator.validateNickname("ab"), .invalidNickname)
        XCTAssertEqual(ProfileValidator.validateNickname("con espacio"), .invalidNickname)
        XCTAssertEqual(ProfileValidator.validateNickname("ñandú"), .invalidNickname)
        XCTAssertEqual(ProfileValidator.validateNickname(String(repeating: "a", count: 21)), .invalidNickname)
    }

    func testAvatarInitials() {
        XCTAssertEqual(AvatarView.initials(from: "Ana Torres"), "AT")
        XCTAssertEqual(AvatarView.initials(from: "ana_viajera"), "AV")
        XCTAssertEqual(AvatarView.initials(from: "miguel"), "M")
        XCTAssertEqual(AvatarView.initials(from: ""), "?")
    }

    func testCountryCatalogOnlyListsCountriesWithFlags() {
        XCTAssertFalse(CountryCatalog.all.isEmpty)
        XCTAssertTrue(CountryCatalog.all.contains { $0.code == "pe" && $0.name == "Perú" })
        XCTAssertTrue(CountryCatalog.all.allSatisfy { UIImage(named: $0.code) != nil })
    }
}

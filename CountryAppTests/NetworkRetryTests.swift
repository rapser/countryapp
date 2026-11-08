//
//  NetworkRetryTests.swift
//  CountryAppTests
//

import XCTest
@testable import CountryApp

final class NetworkRetryTests: XCTestCase {

    func testRetriesTransientErrorThenSucceeds() async throws {
        var calls = 0
        let value = try await NetworkRetry.run(delay: 0) { () -> Int in
            calls += 1
            if calls < 3 { throw URLError(.networkConnectionLost) }
            return 42
        }
        XCTAssertEqual(value, 42)
        XCTAssertEqual(calls, 3)
    }

    func testGivesUpAfterMaxAttempts() async {
        var calls = 0
        do {
            _ = try await NetworkRetry.run(attempts: 2, delay: 0) { () -> Int in
                calls += 1
                throw URLError(.timedOut)
            }
            XCTFail("debería fallar")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .timedOut)
        }
        XCTAssertEqual(calls, 2)
    }

    func testDoesNotRetryNonTransientErrors() async {
        var calls = 0
        do {
            _ = try await NetworkRetry.run(delay: 0) { () -> Int in
                calls += 1
                throw BackendError.notAuthenticated
            }
        } catch {}
        XCTAssertEqual(calls, 1)
    }

    func testOfflineAndServerErrorsHaveDifferentMessages() {
        XCTAssertEqual(BackendError.map(URLError(.notConnectedToInternet)), .network)
        XCTAssertEqual(BackendError.map(URLError(.networkConnectionLost)), .serverUnreachable)
    }
}

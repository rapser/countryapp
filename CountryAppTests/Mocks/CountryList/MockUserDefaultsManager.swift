//
//  MockUserDefaultsManager.swift
//  CountryAppTests
//
//  Created by miguel tomairo on 17/01/25.
//

import Foundation
@testable import CountryApp

final class MockUserDefaultsManager: UserDefaultsManagerProtocol {
    var storedData: [String: Any] = [:] // Simula almacenamiento en memoria
    var saveCalled = false
    var accessedKeys: [String] = []
    var removedKeys: [String] = []

    func get<T>(forKey key: String, as type: T.Type) -> T? where T: Decodable {
        accessedKeys.append(key)
        guard let data = storedData[key] as? Data else { return nil }
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            print("Error decoding data in mock: \(error.localizedDescription)")
            return nil
        }
    }

    func save<T>(object: T, forKey key: String) where T: Encodable {
        do {
            let data = try JSONEncoder().encode(object)
            storedData[key] = data
            saveCalled = true
        } catch {
            print("Error encoding data in mock: \(error.localizedDescription)")
        }
    }

    func remove(forKey key: String) {
        storedData.removeValue(forKey: key)
        removedKeys.append(key)
    }
}



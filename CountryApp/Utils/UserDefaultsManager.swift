//
//  UserDefaultsManager.swift
//  CountryApp
//
//  Created by miguel tomairo on 16/01/25.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard

    private init() {}

    func save<T: Codable>(object: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            defaults.set(data, forKey: key)
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }
    }

    func get<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            return object
        } catch {
            print("Error decoding data: \(error.localizedDescription)")
            return nil
        }
    }

    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}

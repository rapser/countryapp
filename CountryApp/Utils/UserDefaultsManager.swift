//
//  UserDefaultsManager.swift
//  CountryApp
//
//  Created by miguel tomairo on 16/01/25.
//

import Foundation

protocol UserDefaultsManagerProtocol {
    func get<T: Decodable>(forKey key: String, as type: T.Type) -> T?
    func save<T: Codable>(object: T, forKey key: String)
    func remove(forKey key: String)
}

class UserDefaultsManager: UserDefaultsManagerProtocol {
    static var shared: UserDefaultsManagerProtocol = UserDefaultsManager()

    private let defaults: UserDefaults

    // Inicializador público para permitir la inyección de dependencias en los tests
    init(defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
    }

    func save<T: Codable>(object: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            defaults.set(data, forKey: key)
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
        }
    }

    func get<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
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

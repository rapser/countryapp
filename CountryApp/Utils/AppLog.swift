//
//  AppLog.swift
//  CountryApp
//
//  NSLog aparece en la consola de Xcode aunque el filtro oculte stdout;
//  print() a veces no se ve según esquema / dispositivo.
//

import Foundation

enum AppLog {
    private static let prefix = "CountryApp"

    static func trace(_ message: String) {
        NSLog("[%@] %@", prefix, message)
        print("[\(prefix)] \(message)")
    }
}

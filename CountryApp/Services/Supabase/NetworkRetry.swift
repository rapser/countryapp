//
//  NetworkRetry.swift
//  CountryApp
//
//  Reintento de lecturas ante fallos de red pasajeros. El más común en simulador/dispositivo es
//  `networkConnectionLost` (-1005): URLSession reutiliza una conexión HTTP/2 que el servidor ya cerró.
//

import Foundation

enum NetworkRetry {
    static let transientCodes: Set<URLError.Code> = [
        .networkConnectionLost,
        .timedOut,
        .cannotConnectToHost,
        .cannotFindHost,
        .dnsLookupFailed,
        .notConnectedToInternet
    ]

    /// Ejecuta `operation` y la repite hasta `attempts` veces si falla por un error de red pasajero.
    /// Solo para operaciones idempotentes (lecturas o escrituras con clave única).
    static func run<T>(
        attempts: Int = 3,
        delay: TimeInterval = 0.4,
        _ operation: () async throws -> T
    ) async throws -> T {
        var attempt = 1
        while true {
            do {
                return try await operation()
            } catch let error as URLError where transientCodes.contains(error.code) && attempt < attempts {
                AppLog.trace("NetworkRetry intento \(attempt) falló (\(error.code.rawValue)), reintentando")
                try await Task.sleep(nanoseconds: UInt64(delay * Double(attempt) * 1_000_000_000))
                attempt += 1
            }
        }
    }
}

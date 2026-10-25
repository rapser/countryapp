//
//  SupabaseProvider.swift
//  CountryApp
//
//  Cliente compartido. Las claves vienen de `Config/Secrets.xcconfig` → Info.plist.
//  Si faltan, `client` es nil y la app sigue funcionando en modo invitado.
//

import Foundation
import Supabase

enum SupabaseProvider {
    static let avatarsBucket = "avatars"

    static let client: SupabaseClient? = {
        guard
            let urlString = Bundle.main.object(forInfoDictionaryKey: "SupabaseURL") as? String,
            let key = Bundle.main.object(forInfoDictionaryKey: "SupabaseAnonKey") as? String,
            !key.isEmpty,
            !key.hasPrefix("YOUR-"),
            let url = URL(string: urlString),
            url.host != nil
        else {
            AppLog.trace("SupabaseProvider: sin configuración, modo invitado")
            return nil
        }
        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: key,
            options: SupabaseClientOptions(auth: .init(emitLocalSessionAsInitialSession: true))
        )
    }()

    static var isConfigured: Bool { client != nil }

    static func requireClient() throws -> SupabaseClient {
        guard let client else { throw BackendError.notConfigured }
        return client
    }
}

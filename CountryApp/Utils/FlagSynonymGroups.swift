//
//  FlagSynonymGroups.swift
//  CountryApp
//

import Foundation

/// Grupos de países cuya bandera visual es idéntica o prácticamente indistinguible.
/// Usados para evitar que el juego muestre la misma bandera dos veces en la misma ronda
/// (como pregunta o como distractor) y para que los distractores nunca compartan bandera con la respuesta.
enum FlagSynonymGroups {
    /// Cada Set contiene los `flagAssetCode` de países que comparten la misma imagen de bandera.
    static let groups: [Set<String>] = [
        // Tricolor francesa – Francia y todos sus territorios que usan el mismo pabellón
        ["fr", "gf", "gp", "mq", "re", "yt", "pm", "mf", "tf"],
        // Pabellón noruego – Noruega y sus territorios deshabitados
        ["no", "bv", "sj"],
        // Bandera australiana – Australia y territorios sin gobierno propio
        ["au", "hm"],
        // Diseño neozelandés – Nueva Zelanda y territorios asociados con motivo muy similar
        ["nz", "ck", "nu"],
    ]

    /// Todos los códigos del grupo al que pertenece `code`, incluido él mismo.
    /// Devuelve Set vacío si `code` no forma parte de ningún grupo.
    static func synonyms(for code: String) -> Set<String> {
        groups.first { $0.contains(code) } ?? []
    }

    /// Códigos del mismo grupo excepto el propio `code`.
    static func siblings(for code: String) -> Set<String> {
        let group = synonyms(for: code)
        return group.subtracting([code])
    }
}

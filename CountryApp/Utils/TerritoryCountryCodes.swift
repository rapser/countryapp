//
//  TerritoryCountryCodes.swift
//  CountryApp
//

import Foundation

/// Territorios, colonias y dependencias que NO son países soberanos independientes.
/// Cualquier `flagAssetCode` ausente de este Set se asume país independiente
/// (la lista solo enumera la minoría, ~57 de ~249 códigos totales del catálogo de banderas).
///
/// Criterio: ¿está administrado por otro país soberano? Casos disputados (Taiwán `tw`,
/// Kosovo `xk`, Palestina `ps`) se consideran independientes por ser autogobernados y no
/// administrados por otro estado. Sahara Occidental (`eh`) se incluye como territorio por
/// figurar en la lista oficial de la ONU de Territorios No Autónomos. Islas Cook (`ck`) y
/// Niue (`nu`) se incluyen como territorio por ser estados de libre asociación con Nueva
/// Zelanda (ya agrupados visualmente con `nz` en FlagSynonymGroups).
enum TerritoryCountryCodes {
    static let territoryFlagAssetCodes: Set<String> = [
        "ai", "aq", "as", "aw", "ax", "bl", "bm", "bq", "bv", "cc", "ck", "cw", "cx",
        "eh", "fk", "fo", "gb-eng", "gb-nir", "gb-sct", "gb-wls", "gf", "gg", "gi",
        "gl", "gp", "gs", "gu", "hk", "hm", "im", "io", "je", "ky", "mf", "mo", "mp",
        "mq", "ms", "nc", "nf", "nu", "pf", "pm", "pn", "pr", "re", "sh", "sj", "sx",
        "tc", "tf", "tk", "um", "vg", "vi", "wf", "yt"
    ]

    static func isIndependent(_ flagAssetCode: String) -> Bool {
        !territoryFlagAssetCodes.contains(flagAssetCode)
    }
}

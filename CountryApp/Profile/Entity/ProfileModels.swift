//
//  ProfileModels.swift
//  CountryApp
//

import Foundation

struct ProfileHeaderViewModel: Equatable {
    let displayName: String
    let nickname: String
    let countryCode: String
    let countryName: String
    let avatarURL: URL?

    init(profile: UserProfile) {
        displayName = profile.displayName
        nickname = "@\(profile.nickname)"
        countryCode = profile.countryCode
        countryName = CountryCatalog.name(for: profile.countryCode)
        avatarURL = profile.avatarURL
    }
}

struct EditProfileForm: Equatable {
    let fullName: String
    let nickname: String
}

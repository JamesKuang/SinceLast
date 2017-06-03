//
//  TokenStorage.swift
//  SinceLast
//
//  Created by James Kuang on 5/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation
import KeychainAccess

final class TokenStorage {
    let serviceName: String

    private let keychain: Keychain

    private static let accessTokenKey = "accessToken"
    private static let refreshTokenKey = "refreshToken"
    private static let expirationKey = "expiration"

    var token: OAuthAccessToken? {
        guard
            let token = keychain[TokenStorage.accessTokenKey],
            let refreshToken = keychain[TokenStorage.refreshTokenKey],
            let expirationData = keychain[data: TokenStorage.expirationKey]
            else { return nil }

        return OAuthAccessToken(token: token, refreshToken: refreshToken, expiration: expirationData.dateRepresentationSince1970)
    }

    var hasToken: Bool {
        return token != nil
    }

    init(service: GitService) {
        self.serviceName = service.name.lowercased()
        let name = "com.sincelast.token." + serviceName
        self.keychain = Keychain(service: name)
    }

    func store(token: OAuthAccessToken) {
        keychain[TokenStorage.accessTokenKey] = token.token
        keychain[TokenStorage.refreshTokenKey] = token.refreshToken
        keychain[data: TokenStorage.expirationKey] = token.expiration.dataRepresentationSince1970
    }

    func clearToken() {
        keychain[TokenStorage.accessTokenKey] = nil
        keychain[TokenStorage.refreshTokenKey] = nil
        keychain[data: TokenStorage.expirationKey] = nil
    }
}

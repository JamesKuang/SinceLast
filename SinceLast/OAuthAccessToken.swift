//
//  OAuthAccessToken.swift
//  SinceLast
//
//  Created by James Kuang on 5/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct OAuthAccessToken {
    let token: String
    let refreshToken: String
    let expiration: Date

    var isExpired: Bool {
        return Date().compare(expiration) == .orderedDescending
    }
}

extension OAuthAccessToken: JSONInitializable {
    init(json: JSON) throws {
        guard
            let token = json["access_token"] as? String,
            let refreshToken = json["refresh_token"] as? String,
            let expiresIn = json["expires_in"] as? Int
            else { throw JSONParsingError() }

        self.token = token
        self.refreshToken = refreshToken
        self.expiration = Date(timeIntervalSinceNow: TimeInterval(expiresIn))
    }
}

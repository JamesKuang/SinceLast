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
    let refreshToken: String?
}

extension OAuthAccessToken: JSONInitializable {
    init(json: JSON) throws {
        guard let token = json["access_token"] as? String
            else { throw JSONParsingError() }

        self.token = token
        self.refreshToken = json["refresh_token"] as? String
    }
}

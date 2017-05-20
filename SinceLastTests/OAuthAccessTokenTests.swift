//
//  OAuthAccessTokenTests.swift
//  SinceLast
//
//  Created by James Kuang on 5/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import XCTest
@testable import SinceLast

class OAuthAccessTokenTests: XCTestCase {
    func testExample() {
        let access = UUID().uuidString
        let refresh = UUID().uuidString
        let expirationInSeconds = 3600
        let json: JSON = [
            "scopes": "repository",
            "refresh_token": refresh,
            "token_type": "bearer",
            "access_token": access,
            "expires_in": expirationInSeconds,
            ]

        let token = OAuthAccessToken(json: json)
        XCTAssertNotNil(token)
        XCTAssertEqual(token!.token, access)
        XCTAssertEqual(token!.refreshToken, refresh)

        let expectedExpiration = Date(timeIntervalSinceNow: TimeInterval(expirationInSeconds))
        let result = Calendar.current.compare(token!.expiration, to: expectedExpiration, toGranularity: .second)
        XCTAssertEqual(result, .orderedSame)
    }
}

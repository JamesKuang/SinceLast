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
    func testInitializingFromJSON() {
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

        let token = try! OAuthAccessToken(json: json)
        XCTAssertEqual(token.token, access)
        XCTAssertEqual(token.refreshToken, refresh)

        let expectedExpiration = Date(timeIntervalSinceNow: TimeInterval(expirationInSeconds))
        let result = Calendar.current.compare(token.expiration, to: expectedExpiration, toGranularity: .second)
        XCTAssertEqual(result, .orderedSame)
    }

    func testIsExpired() {
        let token = OAuthAccessToken(token: "", refreshToken: "", expiration: Date().addingTimeInterval(1.0))
        XCTAssertFalse(token.isExpired)
        sleep(2)
        XCTAssertTrue(token.isExpired)
    }
}

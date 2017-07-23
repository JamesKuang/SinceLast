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
        let json: JSON = [
            "refresh_token": refresh,
            "access_token": access,
            ]

        let token = try! OAuthAccessToken(json: json)
        XCTAssertEqual(token.token, access)
        XCTAssertEqual(token.refreshToken, refresh)
    }

    func testInitializingWithoutRefreshToken() {
        let access = UUID().uuidString
        let json: JSON = [
            "access_token": access,
            ]

        let token = try! OAuthAccessToken(json: json)
        XCTAssertEqual(token.token, access)
        XCTAssertNil(token.refreshToken)
    }
}

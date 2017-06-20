//
//  GithubRequests.swift
//  SinceLast
//
//  Created by James Kuang on 6/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct GithubUserRequest: TypedRequest {
    typealias ResultType = User

    let method: RequestMethod = .POST
    let path = ""

    let additionalHeaders: [String : String] = [
        "Content-Type": "application/json",
    ]

    var queryParameters: [String : String] {
        return [
            "query": "query { viewer { login }}",
        ]
    }
}

//
//  GithubRequests.swift
//  SinceLast
//
//  Created by James Kuang on 6/19/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct GithubUserRequest: TypedRequest {
    typealias ResultType = GithubUser

    let method: RequestMethod = .POST
    let contentType: ContentType = .json
    let path = ""

    var queryParameters: [String : String] {
        return [:]
    }

    var bodyParameters: [String : Any] {
        return [
            "query": "query { viewer { login id }}",
        ]
    }
}

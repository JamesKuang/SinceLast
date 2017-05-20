//
//  BitbucketRequests.swift
//  SinceLast
//
//  Created by James Kuang on 5/20/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct BitbucketUserRequest: Request {
    let path = "/2.0/user"
    let queryParameters: [String : String] = [:]
}

struct BitbucketRepositoriesRequest: Request {
    let userName: String

    var path: String {
        return "/2.0/teams/\(userName)/repositories"
    }

    let queryParameters: [String : String] = [:]
}

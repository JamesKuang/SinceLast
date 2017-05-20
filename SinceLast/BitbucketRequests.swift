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
    let path = "/2.0/repositories"
    let queryParameters: [String : String] = [:]
}

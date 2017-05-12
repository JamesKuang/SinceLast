//
//  GitService.swift
//  SinceLast
//
//  Created by James Kuang on 5/11/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol GitService {
    var name: String { get }
    var oAuthCredentials: OAuthCredentials { get }
}

struct BitbucketService: GitService {
    let name = "Bitbucket"
    let oAuthCredentials: OAuthCredentials = BitbucketOAuth()
}

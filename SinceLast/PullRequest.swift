//
//  PullRequest.swift
//  SinceLast
//
//  Created by James Kuang on 5/28/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct PullRequest {
    let title: String
    let author: User
}

extension PullRequest: JSONInitializable {
    init(json: JSON) throws {
        guard
            let title = json["title"] as? String,
            let author = json["author"] as? JSON
            else { throw JSONParsingError() }
        
        self.title = title
        self.author = try BitbucketUser(json: author)   // FIXME:
    }
}

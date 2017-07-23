//
//  PullRequest.swift
//  SinceLast
//
//  Created by James Kuang on 5/28/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol PullRequest {

}

// MARK: - BitbucketPullRequest

struct BitbucketPullRequest: PullRequest {
    let title: String
    let author: User
}

extension BitbucketPullRequest: JSONInitializable {
    init(json: JSON) throws {
        guard
            let title = json["title"] as? String,
            let author = json["author"] as? JSON
            else { throw JSONParsingError() }
        
        self.title = title
        self.author = try BitbucketUser(json: author)   // FIXME:
    }
}

// MARK: - GithubPullRequest

struct GithubPullRequest: PullRequest {
    let viewerDidAuthor: Bool
}

extension GithubPullRequest: JSONInitializable {
    init(json: JSON) throws {
        guard let node = json["node"] as? JSON,
            let viewerDidAuthor = node["viewerDidAuthor"] as? Bool
            else { throw JSONParsingError() }
        self.viewerDidAuthor = viewerDidAuthor
    }
}

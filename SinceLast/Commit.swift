//
//  Commit.swift
//  SinceLast
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct Commit {
    let sha: String
    let message: String

    let author: User
    let committer: User

    init(sha: String, message: String, author: User, committer: User? = nil) {
        precondition(sha.characters.count == 40, "SHA must be 40 characters")
        self.sha = sha
        self.message = message
        self.author = author
        self.committer = committer ?? author
    }
}

extension Commit {
    var shortSHA: String {
        let index = sha.index(sha.startIndex, offsetBy: 7)
        return sha.substring(to: index)
    }
}

extension Commit: Equatable {
    static func == (lhs: Commit, rhs: Commit) -> Bool {
        return lhs.sha == rhs.sha
    }
}

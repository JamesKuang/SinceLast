//
//  Commit.swift
//  SinceLast
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol Commit: UUIDEquatable {
    var hash: String { get }
    var message: String { get }
    var date: Date { get }
}

extension Commit {
    var uuid: String {
        return hash
    }
}

extension Commit {
    var shortSHA: String {
        let index = hash.index(hash.startIndex, offsetBy: 7)
        return hash.substring(to: index)
    }
}

enum DateFormatters {
    static let ISO8601: ISO8601DateFormatter = {
        return ISO8601DateFormatter()
    }()
}

// MARK: - BitbucketCommit

struct BitbucketCommit: Commit {
    let hash: String
    let message: String
    let date: Date

    let author: User
    let committer: User

    init(hash: String, message: String, date: Date, author: User, committer: User? = nil) {
        precondition(hash.characters.count == 40, "Hash must be 40 characters")
        self.hash = hash
        self.message = message.trimmingCharacters(in: .newlines)
        self.date = date
        self.author = author
        self.committer = committer ?? author
    }
}

extension BitbucketCommit: JSONInitializable {
    init(json: JSON) throws {
        guard
            let hash = json["hash"] as? String,
            let message = json["message"] as? String,
            let dateString = json["date"] as? String,
            let date = DateFormatters.ISO8601.date(from: dateString),
            let author = json["author"] as? JSON
            else { throw JSONParsingError() }

        let user: User
        if let authorUser = author["user"] as? JSON {
            user = try BitbucketUser(json: authorUser)  // FIXME:
        } else {
            let name = author["raw"] as? String ?? "Unknown"
            user = BitbucketUser(uuid: "", name: name, kind: .user) // FIXME:
        }

        self.init(hash: hash, message: message, date: date, author: user)
    }
}

extension BitbucketCommit: Equatable {
    static func == (lhs: BitbucketCommit, rhs: BitbucketCommit) -> Bool {
        return lhs.hash == rhs.hash
    }
}

// MARK: - GithubCommit

struct GithubCommit: Commit {
    let hash: String
    let message: String
    let date: Date

    init(hash: String, message: String, date: Date) {
        precondition(hash.characters.count == 40, "Hash must be 40 characters")
        self.hash = hash
        self.message = message
        self.date = date
    }
}

extension GithubCommit: JSONInitializable {
    init(json: JSON) throws {
        guard
            let node = json["node"] as? JSON,
            let hash = node["oid"] as? String,
            let message = node["message"] as? String,
            let dateString = node["committedDate"] as? String,
            let date = DateFormatters.ISO8601.date(from: dateString)
            else { throw JSONParsingError() }

        self.init(hash: hash, message: message, date: date)
    }
}

extension GithubCommit: Equatable {
    static func == (lhs: GithubCommit, rhs: GithubCommit) -> Bool {
        return lhs.hash == rhs.hash
    }
}

extension GithubCommit: Hashable {
    var hashValue: Int {
        return hash.hashValue
    }
}

extension GithubCommit: Comparable {
    static func <(lhs: GithubCommit, rhs: GithubCommit) -> Bool {
        return lhs.date > rhs.date
    }
}

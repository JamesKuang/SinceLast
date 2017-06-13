//
//  Commit.swift
//  SinceLast
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct Commit {
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

extension Commit: JSONInitializable {
    init(json: JSON) throws {
        guard
            let hash = json["hash"] as? String,
            let message = json["message"] as? String,
            let dateString = json["date"] as? String,
            let date = DateFormatters.commitJSONFormatter.date(from: dateString),
            let author = json["author"] as? JSON
            else { throw JSONParsingError() }

        let user: User
        if let authorUser = author["user"] as? JSON {
            user = try User(json: authorUser)
        } else {
            let name = author["raw"] as? String ?? "Unknown"
            user = User(uuid: "", name: name, kind: .user)
        }

        self.init(hash: hash, message: message, date: date, author: user)
    }
}

enum DateFormatters {
    static let commitJSONFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }()

    static let commitDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
}

extension Commit {
    var shortSHA: String {
        let index = hash.index(hash.startIndex, offsetBy: 7)
        return hash.substring(to: index)
    }
}

extension Commit: Equatable {
    static func == (lhs: Commit, rhs: Commit) -> Bool {
        return lhs.hash == rhs.hash
    }
}

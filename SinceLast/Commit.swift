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
    let date: Date

    let author: User
    let committer: User

    init(sha: String, message: String, date: Date, author: User, committer: User? = nil) {
        precondition(sha.characters.count == 40, "SHA must be 40 characters")
        self.sha = sha
        self.message = message.trimmingCharacters(in: .newlines)
        self.date = date
        self.author = author
        self.committer = committer ?? author
    }
}

extension Commit: JSONInitializable {
    init(json: JSON) throws {
        guard
            let sha = json["hash"] as? String,
            let message = json["message"] as? String,
            let dateString = json["date"] as? String,
            let date = DateFormatters.commitJSONFormatter.date(from: dateString),
            let author = json["author"] as? JSON,
            let authorUser = author["user"] as? JSON
            else { throw JSONParsingError() }

        self.init(sha: sha, message: message, date: date, author: try User(json: authorUser))
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
        let index = sha.index(sha.startIndex, offsetBy: 7)
        return sha.substring(to: index)
    }
}

extension Commit: Equatable {
    static func == (lhs: Commit, rhs: Commit) -> Bool {
        return lhs.sha == rhs.sha
    }
}

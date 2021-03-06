//
//  GithubResults.swift
//  SinceLast
//
//  Created by James Kuang on 6/26/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct GithubArrayResult<T: JSONInitializable, U>: JSONInitializable where U: GithubGraphTraversing, U: GithubGraphPaginating {
    let objects: [T]
    let pagination: Pagination

    init(json: JSON) throws {
        func findJSON<X>(traversals: [String], in json: JSON) throws -> X {
            var dictionary = json
            for traversal in traversals {
                let value = dictionary[traversal]
                if let next = value as? JSON {
                    dictionary = next
                } else if let values = value as? X {
                    return values
                } else {
                    break
                }
            }

            if let values = dictionary as? X {
                return values
            }
            throw JSONParsingError()
        }

        let pageInfo: JSON = try findJSON(traversals: U.pageInfo, in: json)
        guard let hasNextPage = pageInfo["hasNextPage"] as? Bool,
            let endCursor = pageInfo["endCursor"]
            else { throw JSONParsingError() }

        if hasNextPage, let cursor = endCursor as? String {
            self.pagination = .cursor(cursor)
        } else {
            self.pagination = .none
        }

        let edges: [JSON] = try findJSON(traversals: U.connections, in: json)

        self.objects = try edges.flatMap { edge in
            do {
                return try T(json: edge)
            } catch _ as GithubDiscardRefError {
                return nil
            } catch let error {
                throw error
            }
        }
    }
}

struct GithubResult<T: JSONInitializable, U>: JSONInitializable where U: GithubGraphTraversing {
    let object: T

    init(json: JSON) throws {
        func findJSON<X>(traversals: [String], in json: JSON) throws -> X {
            var dictionary = json
            for traversal in traversals {
                let value = dictionary[traversal]
                if let next = value as? JSON {
                    dictionary = next
                } else if let values = value as? X {
                    return values
                } else {
                    break
                }
            }

            if let values = dictionary as? X {
                return values
            }
            throw JSONParsingError()
        }

        let edge: JSON = try findJSON(traversals: U.connections, in: json)
        self.object = try T(json: edge)
    }
}

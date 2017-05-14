//
//  JSONParsing.swift
//  SinceLast
//
//  Created by James Kuang on 5/10/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

protocol JSONInitializable {
    init?(json: JSON)
}

protocol RequestParser {
    func parse(data: Data) -> [String: Any]?
}

struct JSONParser: RequestParser {
    func parse(data: Data) -> JSON? {
        do {
            guard let untyped = try JSONSerialization.jsonObject(with: data, options: []) as? JSON else {
                throw NilError()
            }
            return untyped
        } catch {
            print("JSON parsing error")
        }
        return nil
    }
}

//
//  Request.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

enum RequestMethod: String {
    case GET
    case POST
}

enum ContentType: String {
    case ascii = "application/x-www-form-urlencoded"
    case json = "application/json"

    var httpHeaderField: String {
        return "Content-Type"
    }
}

protocol Request {
    var method: RequestMethod { get }
    var contentType: ContentType { get }
    var path: String { get }
    var queryParameters: [String: String] { get }
    var bodyParameters: [String: Any] { get }
    var additionalHeaders: [String: String] { get }
    var parser: RequestParser { get }
}

extension Request {
    var method: RequestMethod {
        return .GET
    }

    var contentType: ContentType {
        return .ascii
    }

    var additionalHeaders: [String: String] {
        return [:]
    }

    var parser: RequestParser {
        return JSONParser()
    }

    var bodyParameters: [String: Any] { return [:] }
}

protocol TypedRequest: Request {
    associatedtype ResultType: JSONInitializable
}

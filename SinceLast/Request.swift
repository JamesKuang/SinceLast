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

protocol Request {
    var method: RequestMethod { get }
    var path: String { get }
    var queryParameters: [String: String] { get }
    var additionalHeaders: [String: String] { get }
    var parser: RequestParser { get }
}

extension Request {
    var additionalHeaders: [String: String] {
        return [:]
    }

    var parser: RequestParser {
        return JSONParser()
    }
}

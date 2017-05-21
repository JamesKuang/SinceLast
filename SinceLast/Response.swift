//
//  Response.swift
//  SinceLast
//
//  Created by James Kuang on 5/21/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct Response<OutputType: JSONInitializable> {
    let result: OutputType
    let httpResponse: HTTPURLResponse
    var statusCode: Int {
        return httpResponse.statusCode
    }

    init(data: Data, parser: RequestParser, httpResponse: HTTPURLResponse) throws {
        guard let json = parser.parse(data: data) else { throw JSONParsingError() }
        self.result = try OutputType(json: json)
        self.httpResponse = httpResponse
    }
}

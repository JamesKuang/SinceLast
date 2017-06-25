//
//  AnyJSONRequest.swift
//  SinceLast
//
//  Created by James Kuang on 6/25/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct AnyJSONRequest<ConcreteResult: JSONInitializable>: TypedRequest {
    typealias ResultType = ConcreteResult

    let method: RequestMethod
    let contentType: ContentType
    let path: String
    let queryParameters: [String: String]
    let bodyParameters: [String: Any]
    let additionalHeaders: [String: String]
    let parser: RequestParser
}

extension AnyJSONRequest where ConcreteResult == User {
    init<R>(_ request: R) where R: TypedRequest, R.ResultType == ConcreteResult {
        self.method = request.method
        self.contentType = request.contentType
        self.path = request.path
        self.queryParameters = request.queryParameters
        self.bodyParameters = request.bodyParameters
        self.additionalHeaders = request.additionalHeaders
        self.parser = request.parser
    }
}

//extension AnyJSONRequest where Concrete == BitbucketArrayResult<Repository> {
//    init<R>(_ request: R) where R: TypedRequest, R.ResultType == ConcreteResult {
//        self.path = request.path
//        self.queryParameters = request.queryParameters
//    }
//}

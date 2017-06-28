//
//  AnyJSONRequest.swift
//  SinceLast
//
//  Created by James Kuang on 6/25/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct AnyJSONRequest<Result: JSONInitializable>: TypedRequest {
    typealias ResultType = Result

    let method: RequestMethod
    let contentType: ContentType
    let path: String
    let queryParameters: [String: String]
    let bodyParameters: [String: Any]
    let additionalHeaders: [String: String]
    let parser: RequestParser
}

extension AnyJSONRequest {
    init<R: TypedRequest>(_ request: R) where R.ResultType == BitbucketUser {
        self.method = request.method
        self.contentType = request.contentType
        self.path = request.path
        self.queryParameters = request.queryParameters
        self.bodyParameters = request.bodyParameters
        self.additionalHeaders = request.additionalHeaders
        self.parser = request.parser
    }
}

extension AnyJSONRequest {
    init<R: TypedRequest>(_ request: R) where R.ResultType == GithubUser {
        self.method = request.method
        self.contentType = request.contentType
        self.path = request.path
        self.queryParameters = request.queryParameters
        self.bodyParameters = request.bodyParameters
        self.additionalHeaders = request.additionalHeaders
        self.parser = request.parser
    }
}

extension AnyJSONRequest {
    init<R: TypedRequest>(_ request: R) where R.ResultType: JSONInitializable {
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
//    init<R>(_ request: R) where R: TypedRequest, R.ResultType == Result {
//        self.path = request.path
//        self.queryParameters = request.queryParameters
//    }
//}

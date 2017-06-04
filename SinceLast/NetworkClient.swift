//
//  NetworkClient.swift
//  SinceLast
//
//  Created by James Kuang on 5/10/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation
import PromiseKit

final class NetworkClient {
    let baseURL: String
    private(set) var session: URLSession

    init(baseURL: String, configuration: URLSessionConfiguration) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: configuration)
    }

    func send<RequestType, OutputType>(request: RequestType) -> Promise<OutputType> where RequestType: TypedRequest, RequestType.ResultType == OutputType {
        let builder = URLRequestBuilder(request: request, baseURL: baseURL)
        guard let urlRequest = builder.urlRequest else { fatalError("Request couldn't be built") }

        let taskPromise = session.dataTaskPromise(with: urlRequest)
        return taskPromise
            .then { (data, response) -> Response<OutputType> in
                return try Response<OutputType>(data: data, parser: request.parser, httpResponse: response)
            }.then {
                return $0.result
        }
    }

    func renewSession(with configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
}

extension URLSession {
    public func dataTaskPromise(with request: URLRequest) -> Promise<(Data, HTTPURLResponse)> {
        return Promise<(Data, HTTPURLResponse)>(resolvers: { fulfill, reject in
            self.dataTask(with: request, completionHandler: { data, response, error in
                if let error = error {
                    reject(error)
                } else if let data = data, let response = response as? HTTPURLResponse {
                    fulfill((data, response))
                } else {
                    fatalError("Unexpected HTTP response.")
                }
            }).resume()
        })
    }
}

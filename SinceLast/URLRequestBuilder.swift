//
//  URLRequestBuilder.swift
//  SinceLast
//
//  Created by James Kuang on 5/14/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

struct URLRequestBuilder {
    let request: Request
    let baseURL: String

    init(request: Request, baseURL: String) {
        self.request = request
        self.baseURL = baseURL
    }

    var url: URL? {
        guard var urlComponents = URLComponents(string: baseURL) else { return nil }
        urlComponents.path = request.path
        if request.method == .GET {
            urlComponents.queryItems = queryItems
        }
        return urlComponents.url
    }

    var queryItems: [URLQueryItem]? {
        guard !request.queryParameters.isEmpty else { return nil }
        return request.queryParameters.map { (key, value) in
            return URLQueryItem(name: key, value: value)
        }
    }

    var body: Data? {
        var urlComponents = URLComponents()
        urlComponents.queryItems = queryItems
        return urlComponents.query?.data(using: .ascii)
    }

    var urlRequest: URLRequest? {
        guard let url = self.url else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        if request.method == .POST {
            urlRequest.httpBody = body
        }

        request.additionalHeaders.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        return urlRequest
    }
}

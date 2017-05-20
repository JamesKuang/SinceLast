//
//  NetworkClient.swift
//  SinceLast
//
//  Created by James Kuang on 5/10/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}

enum SharedNetworkClient {
    static let bitbucket: NetworkClient = {
        let client = NetworkClient(baseURL: "https://api.bitbucket.org")    // FIXME: split this up
        return client
    }()

    static let oAuth: NetworkClient = {
        let client = NetworkClient(baseURL: "https://bitbucket.org")
        return client
    }()
}

final class NetworkClient {
    let baseURL: String
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    func send(request: Request, completion: @escaping (Result<[String : Any]>) -> ()) {
        let builder = URLRequestBuilder(request: request, baseURL: baseURL)
        guard let urlRequest = builder.urlRequest else { fatalError("Request couldn't be built") }
        session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            guard let data = data else {
                completion(.failure(NilError()))
                return
            }
            if let stuff = request.parser.parse(data: data) {
                completion(.success(stuff))
            } else {
                completion(.failure(NilError()))
            }
        }).resume()
    }
}

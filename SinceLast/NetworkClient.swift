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

final class NetworkClient {
    let baseURL: String
    let session: URLSession

    init(baseURL: String, configuration: URLSessionConfiguration = .default) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: configuration)
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

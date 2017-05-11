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

struct NetworkResource<T> {
    let url: URL
    let parser: JSONParser<T>
}

final class NetworkClient {
    let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func load<T>(resource: NetworkResource<T>, completion: @escaping (Result<T>) -> ()) {
        let request = URLRequest(url: resource.url)
        session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data else {
                completion(.failure(NilError()))
                return
            }
            if let stuff = resource.parser.parse(data: data) {
                completion(.success(stuff))
            } else {
                completion(.failure(NilError()))
            }
        }).resume()
    }
}

//
//  NetworkClient.swift
//  SinceLast
//
//  Created by James Kuang on 5/10/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

typealias JSON = [String: Any]

protocol JSONInitializable {
    init?(json: JSON)
}

struct NetworkResource<A: JSONInitializable> {
    let url: URL
    let parse: (Data) -> A?
}

final class NetworkClient {
    let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func load<A>(resource: NetworkResource<A>, completion: @escaping (A?) -> ()) {
        let request = URLRequest(url: resource.url)
        session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(resource.parse(data))
        }).resume()
    }
}

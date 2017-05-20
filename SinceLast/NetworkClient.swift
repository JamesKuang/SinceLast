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
}

final class NetworkClient: NSObject {
    let baseURL: String
    lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
    }()

    init(baseURL: String) {
        self.baseURL = baseURL
        super.init()
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

extension NetworkClient: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        switch (challenge.protectionSpace.authenticationMethod, challenge.protectionSpace.host) {
        case (NSURLAuthenticationMethodServerTrust, "bitbucket.org"):
            basicAuthTrip(didReceive: challenge, completionHandler: completionHandler)
        default:
            completionHandler(.performDefaultHandling, nil)
        }
    }

    func basicAuthTrip(didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.previousFailureCount < 3 else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let provider = OAuthKeySecretProvider()
        let credential = URLCredential(user: provider.key, password: provider.secret, persistence: .none)
        completionHandler(.useCredential, credential)
    }
}

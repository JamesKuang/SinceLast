//
//  GitClient.swift
//  SinceLast
//
//  Created by James Kuang on 5/20/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol GitClient {
    var service: GitService { get }
    func send(request: Request, completion: @escaping (Result<[String : Any]>) -> ())
    func authorize(code: String, success: (() -> Void)?)
}

protocol GitClientRequiring {
    var gitClient: GitClient { get }
}

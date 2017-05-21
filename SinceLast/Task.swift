//
//  Task.swift
//  SinceLast
//
//  Created by James Kuang on 5/21/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation
import PromiseKit

protocol Task {
    func perform() -> Promise<Void>
}

//struct OAuthAccessTokenTask: Task {
//    let code: String
//    
//    func perform() -> Promise<Void> {
//        let request = OAuthAccessTokenRequest(code: code)
//
//    }
//}

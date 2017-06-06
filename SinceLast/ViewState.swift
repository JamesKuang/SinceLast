//
//  ViewState.swift
//  SinceLast
//
//  Created by James Kuang on 6/5/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

enum ViewState<T> {
    case initial
    case loading
    case loaded(T)
    case error(Error)
}

//
//  ConfigurableCell.swift
//  SinceLast
//
//  Created by James Kuang on 5/23/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import Foundation

protocol ConfigurableCell {
    associatedtype T
    func configure(with object: T)
}

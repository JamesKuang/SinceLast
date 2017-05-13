//
//  ApplicationURLOpening.swift
//  SinceLast
//
//  Created by James Kuang on 5/13/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

protocol ApplicationURLOpening {
    func canOpenURL(_ url: URL) -> Bool
}

extension UIApplication: ApplicationURLOpening {}

//
//  DateToDataConversionTests.swift
//  SinceLastTests
//
//  Created by James Kuang on 5/8/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import XCTest
@testable import SinceLast

class DateToDataConversionTests: XCTestCase {
    func testDateToData() {
        let original = Date(timeIntervalSince1970: 1495248453)  // May 19, 2017, 10:47 PM
        let data = original.dataRepresentationSince1970
        let converted = data.dateRepresentationSince1970
        XCTAssertEqual(original, converted)
    }
}

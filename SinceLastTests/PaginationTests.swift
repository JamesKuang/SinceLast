//
//  PaginationTests.swift
//  SinceLast
//
//  Created by James Kuang on 7/4/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import XCTest
@testable import SinceLast

class PaginationTests: XCTestCase {
    func testHasNextPage() {
        XCTAssertTrue(Pagination.initial.hasNextPage)
        XCTAssertTrue(Pagination.integer(1).hasNextPage)
        XCTAssertTrue(Pagination.cursor("abc").hasNextPage)
        XCTAssertFalse(Pagination.none.hasNextPage)
    }

    func testIntegerPage() {
        XCTAssertEqual(Pagination.initial.integerPage, 1)
        XCTAssertEqual(Pagination.integer(1).integerPage, 1)
        XCTAssertNil(Pagination.cursor("abc").integerPage)
        XCTAssertNil(Pagination.none.integerPage)
    }

    func testCursorPage() {
        XCTAssertEqual(Pagination.cursor("abc").cursorPage, "abc")
        XCTAssertNil(Pagination.initial.cursorPage)
        XCTAssertNil(Pagination.integer(1).cursorPage)
        XCTAssertNil(Pagination.none.cursorPage)
    }
}

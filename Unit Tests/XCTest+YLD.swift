//
//  XCTest+YLD.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 28.10.19.
//

import XCTest

func XCTAssertThrowsError<T> (_ expression: Optional<() throws -> T>,
                              file: StaticString = #file,
                              line: UInt = #line,
                              handler: (Error) -> Void = { _ in })
{
    XCTAssertNotNil(expression, file: file, line: line)
    
    if let expr = expression {
        XCTAssertThrowsError(try expr(), file: file, line: line) { error in
            handler(error)
        }
    }
}

extension XCTestCase {
    
    func await (file: StaticString = #file,
                line: UInt = #line,
                function: StaticString = #function,
                block: (@escaping () -> Void) -> Void)
    {
        dispatchPrecondition(condition: .onQueue(.main))
        
        var called = 0
        let expectation = self.expectation(description: function.description)
        var waiting: Optional = expectation
        
        block {
            DispatchQueue.main.async {
                waiting?.fulfill()
                waiting = nil
                called += 1
                XCTAssertEqual(called, 1, "Must be called only once.", file: file, line: line)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
}

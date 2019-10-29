//
//  HTTPClientTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 16.10.19.
//

import XCTest
@testable import Yieldprobe

class HTTPClientTests: XCTestCase {
    
    func testGetWithTimeout () {
        // Arrange:
        var caught: Result<URLReply,Error>?
        let sut = HTTPMock()
        let url = URL.example
        
        // Act:
        await { done in
            sut.get(url: url, timeout: 0.000_000_001) { result in
                XCTAssertNil(caught)
                caught = result
                done()
            }
            
            await { done in
                DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(1)) {
                    sut.calls.first?.process { url in
                        URLReply(data: Data(),
                                 response: HTTPURLResponse(url: url,
                                                           statusCode: 200,
                                                           httpVersion: nil,
                                                           headerFields: nil)!)
                    }
                    done()
                }
            }
        }
        
        // Assert:
        XCTAssertEqual(sut.calls.count, 1)
        XCTAssertNotNil(caught)
        XCTAssertThrowsError(caught?.get) { error in
            XCTAssertEqual(error as? URLError, URLError(.timedOut))
        }
    }
    
    func testGetWithoutTimeout () {
        // Arrange:
        let error = URLError(.notConnectedToInternet)
        var expectation: Optional = self.expectation(description: "async call")
        var caught = [Result<URLReply,Error>]()
        let sut = HTTPMock()
        
        // Act:
        sut.get(url: .example, timeout: 0.1) { result in
            caught.append(result)
            
            expectation?.fulfill()
            expectation = nil
        }
        DispatchQueue.main.async {
            sut.calls.first?.process { url in
                throw error
            }
        }
        
        // Assert:
        wait(for: [expectation!], timeout: 0.1)
        expectation = nil
        XCTAssertEqual(caught.count, 1)
        XCTAssertThrowsError(caught.first?.get) { thrown in
            XCTAssertEqual(thrown as? URLError, error)
        }
    }
    
    func testZeroTimeoutMeansIndefinitely () {
        // Arrange:
        var caught = [Result<URLReply,Error>]()
        let error = URLError(.notConnectedToInternet)
        let sut = HTTPMock()
        
        // Act:
        await { done in
            sut.get(url: .example, timeout: 0) { result in
                caught.append(result)
                
                done()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(1)) {
                sut.calls.first?.process { url in
                    throw error
                }
            }
        }
        
        // Assert:
        XCTAssertEqual(caught.count, 1)
        XCTAssertThrowsError(caught.first?.get) { thrown in
            XCTAssertEqual(thrown as? URLError, error)
        }
    }
    
}

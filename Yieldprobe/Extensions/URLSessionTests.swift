//
//  URLSessionTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 04.10.19.
//

import XCTest
@testable import Yieldprobe

class SpyURLSession: URLSessionProtocol {
    
    class Task: DataTaskProtocol {
        
        enum State {
            case initialized
            case resumed
            case completed
        }
        
        let completionHandler: (Data?, URLResponse?, Error?) -> Void
        
        let url: URL
        
        private(set) var state = State.initialized
        
        init (url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
            self.completionHandler = completionHandler
            self.url = url
        }
        
        func complete (data: Data, response: URLResponse) {
            precondition(state == .resumed)
            state = .completed
            completionHandler(data, response, nil)
        }
        
        func fail (with error: Error) {
            precondition(state == .resumed)
            state = .completed
            completionHandler(nil, nil, error)
        }
        
        func resume () {
            state = .resumed
        }
        
    }
    
    var calls = [Task]()
    
    func dataTask(with url: URL,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> Task
    {
        let result = Task(url: url, completionHandler: completionHandler)
        calls.append(result)
        return result
    }
    
}

class URLSessionTests: XCTestCase {
    
    func testGetRequest () {
        // Arrange:
        let url = URL.example
        let sut = SpyURLSession()
        
        // Act:
        _ = sut.get(url: url) { result in
            XCTFail("not reached")
        }
        
        // Assert:
        XCTAssertEqual(sut.calls.count, 1)
        XCTAssertEqual(sut.calls.first?.url, url)
        XCTAssertEqual(sut.calls.first?.state, .resumed)
    }
    
    func testGetSuccess () throws {
        // Arrange:
        let data = Data()
        let response = URLResponse()
        let sut = SpyURLSession()
        var result: Result<URLReply,Error>? = nil
        
        // Act:
        _ = sut.get(url: .example) { _result in
            XCTAssertNil(result)
            result = _result
        }
        sut.calls.first?.complete(data: data, response: response)
        
        // Assert:
        XCTAssertNotNil(result)
        let reply = try result?.get()
        XCTAssertEqual(reply?.data, data)
        XCTAssertEqual(reply?.response, response)
    }
    
    func testGetFailure () {
        // Arrange:
        let error = URLError(.notConnectedToInternet)
        let sut = SpyURLSession()
        var result: Result<URLReply, Error>? = nil
        
        // Act:
        _ = sut.get(url: .example) { _result in
            XCTAssertNil(result)
            result = _result
        }
        sut.calls.first?.fail(with: error)
        
        // Arrange:
        XCTAssertNotNil(result)
        do {
            _ = try result?.get()
            XCTFail("Should not be executed.")
        } catch URLError.notConnectedToInternet {
            XCTAssert(true, "passed")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
}

//
//  NetworkTestTests.swift
//  NetworkTestTests
//
//  Created by Jerel Rocktaschel rMBP on 2/11/21.
//  Copyright © 2021 HighScoreApps. All rights reserved.
//

import XCTest
@testable import NetworkTest

//MARK: MOCKURLSESSION CONFORMING TO URLSESSIONPROTOCOL

class MockURLSession: URLSessionProtocol {
    var dataTaskRequest: [URLRequest] = []
    var dataTaskCompletionHandler: [(Data?, URLResponse?, Error?) -> Void] = []
    
    func dataTask(
            with request: URLRequest,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        dataTaskRequest.append(request)
        dataTaskCompletionHandler.append(completionHandler)
        return FakeURLSessionDataTask()
    }
}

//MARK: FAKEURLSESSIONDATATASK FOR COMPILER

private class FakeURLSessionDataTask: URLSessionDataTask {
    override func resume() {}
}

//MARK: NETWORKMANAGER UNIT TESTS

class NetworkTestTests: XCTestCase {
    
    var networkManager: NetworkManager!
    var mockURLSession: MockURLSession!

    override func setUp() {
        networkManager = NetworkManager()
        mockURLSession = MockURLSession()
    }
    
    override func tearDown() {
        networkManager = nil
        mockURLSession = nil
    }
    
    func test_getTodoNetworkCall_withSuccessfulToDoResponseAndModelDecoding() {
        networkManager.session = mockURLSession
        var toDoResponse: ToDo?
        
        let expectation = XCTestExpectation(description: "ToDo Response")
        
        networkManager.getToDo{ toDo, error  in
            toDoResponse = toDo!
            expectation.fulfill()
        }

        mockURLSession.dataTaskCompletionHandler.first?(
            jsonData(), response(statusCode: 200), nil
        )
             
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(toDoResponse?.userId, 1)
        XCTAssertEqual(toDoResponse?.id, 1)
        XCTAssertEqual(toDoResponse?.title, "delectus aut autem")
        XCTAssertEqual(toDoResponse?.completed, false)
    }
    
    func test_getTodoNetworkCall_withUnsuccessfulHTTPURLResponse() {
        networkManager.session = mockURLSession
        var errorDescription = String()
        
        let expectation = XCTestExpectation(description: "HTTPURLResponse Error")
        
        networkManager.getToDo{ toDo, error  in
            errorDescription = error!.localizedDescription
            expectation.fulfill()
        }

        mockURLSession.dataTaskCompletionHandler.first?(
            jsonData(), response(statusCode: 400), nil
        )
             
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(errorDescription, "The URL Response was unsuccessful.")
    }
    
    func test_getTodoNetworkCall_withNoDataErrorResponse() {
        networkManager.session = mockURLSession
        var errorDescription = String()
        
        let expectation = XCTestExpectation(description: "No Data Error")
        
        networkManager.getToDo{ toDo, error  in
            errorDescription = error!.localizedDescription
            expectation.fulfill()
        }

        mockURLSession.dataTaskCompletionHandler.first?(
            nil, response(statusCode: 200), nil
        )
             
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(errorDescription, "No data was returned.")
    }
    
    func test_getTodoNetworkCall_withUnableToDecodeJSONErrorResponse() {
        networkManager.session = mockURLSession
        var errorDescription = String()
        
        let expectation = XCTestExpectation(description: "Decode Error")
        
        networkManager.getToDo{ toDo, error  in
            errorDescription = error!.localizedDescription
            expectation.fulfill()
        }

        mockURLSession.dataTaskCompletionHandler.first?(
            badJsonData(), response(statusCode: 200), nil
        )
             
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(errorDescription, "Unable to decode the JSON response.")
    }
    
    //MARK: HELPERS

    //bad JSON data
    private func badJsonData() -> Data {
        """
        {{
        """.data(using: .utf8)!
    }
    
    //same JSON as JSON placeholder
    private func jsonData() -> Data {
        """
        {
          "userId": 1,
          "id": 1,
          "title": "delectus aut autem",
          "completed": false
        }
        """.data(using: .utf8)!
    }
    
    //will return an HTTPURLRESPONSE of the status code passed in
    private func response(statusCode: Int) -> HTTPURLResponse? {
        HTTPURLResponse(url: URL(string: "http://DUMMY")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil)
    }
}

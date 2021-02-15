//
//  NetworkManager.swift
//  NetworkTest
//
//  Created by Jerel Rocktaschel rMBP on 2/11/21.
//  Copyright © 2021 HighScoreApps. All rights reserved.
//

import Foundation

//MARK: URLSESSIONPROTOCOL FOR MOCKING URLSESSION

protocol URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}

//MARK: URLSESSION CONFORMING TO URLSESSIONPROTOCOL

extension URLSession: URLSessionProtocol {}

//MARK: NETWORK ERRORS

enum NetworkManagerError: Error {
    case noDataError
    case unableToDecodeError
    case failedRequestError
}

extension NetworkManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noDataError:
            return NSLocalizedString(
                "No data was returned.",
                comment: ""
            )
        case .unableToDecodeError:
            return NSLocalizedString(
                "Unable to decode the JSON response.",
                comment: ""
            )
        case .failedRequestError:
            return NSLocalizedString(
                "The URL Response was unsuccessful.",
                comment: ""
            )
        }
    }
}

//MARK: RESULT

enum Result<T> {
    case success(T?)
    case failure(Error)
}

//MARK: MODEL

struct ToDo: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

//MARK: NETWORK MANAGER

class NetworkManager {
    let toDoURLRequest = URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)
    
    //make a session variable for mocking
    //need to adopt to URLSessionProtocol
    var session: URLSessionProtocol = URLSession.shared
    
    func getToDo (completion: @escaping (_ toDo: ToDo?, _ error: Error?)->()){
        //use the session variable to call data task.
        //this is where the mockURLSession object will be used
        let dataTask = session.dataTask(with: toDoURLRequest, completionHandler: { data, response, error in
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse  (response)
                switch result {
                case .success:
                    guard let data = data else {
                        //No data error
                        completion(nil, NetworkManagerError.noDataError)
                        return
                    }
            
                    do {
                        let toDo = try JSONDecoder().decode(ToDo.self, from: data)
                        completion(toDo, nil)
                    } catch {
                        //JSON failure
                        completion(nil, NetworkManagerError.unableToDecodeError)
                    }
                case .failure(let networkFailureError):
                    //HTTPURLResponse error
                    completion(nil, networkFailureError)
                }
            }
        })
       dataTask.resume()
    }
    
    public func handleNetworkResponse  (_ response: HTTPURLResponse) -> Result<Error>{
        switch response.statusCode {
        case 200...299: return .success(nil)
        default: return .failure(NetworkManagerError.failedRequestError)
        }
    }
}

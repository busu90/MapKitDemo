//
//  ApiClient.swift
//  Demo
//
//  Created by Andrei Busuioc on 2/1/19.
//  Copyright © 2019 Busu. All rights reserved.
//

import Foundation

protocol URLRequestConvertible {
    func asURLRequest() -> URLRequest
}

enum ApiError: Error, LocalizedError{
    case parse(error: Error, response: HTTPURLResponse, data: Data?)
    case core(message: String)
    case api(response: HTTPURLResponse, data: Data?)
    case network(error: Error?)
    
    public var errorDescription: String? {
        switch self {
        case .parse(let error, _, _):
            return NSLocalizedString(error.localizedDescription, comment: "Networking parse error")
        case .core(let message):
            return NSLocalizedString(message, comment: "Core networking error")
        case .api(_, let data):
            var text = "The api returned an error message!"
            if data != nil{
                if let rez = String.init(data: data!, encoding: .utf8){
                    text = rez
                }
            }
            return NSLocalizedString(text, comment: "Api error")
        case .network(let error):
            return NSLocalizedString(error != nil ? error!.localizedDescription : "Network request error - no other information", comment: "Api request error")
        }
    }
    
    func getData() -> Data? {
        switch self {
        case .parse(_, _, let data):
            return data
        case .api(_, let data):
            return data
        default:
            return nil
        }
    }
    
    func getResponse() -> HTTPURLResponse? {
        switch self {
        case .parse(_, let response, _):
            return response
        case .api(let response, _):
            return response
        default:
            return nil
        }
    }
}

enum Result<T> {
    case success(T)
    case failure(Error)
    
    public func dematerialize() throws -> T {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
}

struct VoidResponse: Codable {}

struct ApiResponse<T: Codable> {
    let entity: T
    let httpUrlResponse: HTTPURLResponse
    let data: Data?
    
    init(data: Data?, httpUrlResponse: HTTPURLResponse) throws {
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(formatter)
            if T.self != VoidResponse.self{
                self.entity = try decoder.decode(T.self, from: data!)
            }else{
                self.entity = VoidResponse() as! T
            }
            self.httpUrlResponse = httpUrlResponse
            self.data = data
        } catch {
            throw ApiError.parse(error: error, response: httpUrlResponse, data: data)
        }
    }
}

protocol ApiClient {
    func execute<T>(request: URLRequestConvertible, completionHandler: @escaping (_ result: Result<ApiResponse<T>>) -> Void)
}

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol { }

class ApiClientImpl: ApiClient {
    
    let urlSession: URLSessionProtocol
    
    init(urlSessionConfiguration: URLSessionConfiguration, completionHandlerQueue: OperationQueue) {
        urlSession = URLSession(configuration: urlSessionConfiguration, delegate: nil, delegateQueue: completionHandlerQueue)
    }
    
    // User for testing
    init(urlSession: URLSessionProtocol) {
        self.urlSession = urlSession
    }
    
    init() {
        urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
    }
    func execute<T>(request: URLRequestConvertible, completionHandler: @escaping (Result<ApiResponse<T>>) -> Void) {
        let dataTask = urlSession.dataTask(with: request.asURLRequest()) { (data, response, error) in
            guard let httpUrlResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(ApiError.network(error: error)))
                return
            }
            
            let successRange = 200...299
            if successRange.contains(httpUrlResponse.statusCode) {
                do {
                    let response = try ApiResponse<T>(data: data, httpUrlResponse: httpUrlResponse)
                    completionHandler(.success(response))
                } catch {
                    completionHandler(.failure(error))
                }
            } else {
                completionHandler(.failure(ApiError.api(response: httpUrlResponse, data: data)))
            }
        }
        dataTask.resume()
    }
}

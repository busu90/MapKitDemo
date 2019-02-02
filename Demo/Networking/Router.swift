//
//  Router.swift
//  Demo
//
//  Created by Andrei Busuioc on 2/1/19.
//  Copyright © 2019 Busu. All rights reserved.
//

import Foundation

enum Router: URLRequestConvertible {
    case getWeather(long: Double, lat: Double)
    
    //since we use a third party api there is no need to externalize this
    //if it changes so could the routes
    static let baseURLString = "https://api.openweathermap.org/data/2.5/"
    static let apiKey = "e4fd3b5393c445f4273f32f2b1529224"
    
    var method: String {
        switch self {
        case .getWeather:
            return "GET"
        }
    }
    
    var path: String {
        switch self {
        case .getWeather(let long, let lat):
            return "weather?lat=\(lat)&lon=\(long)&appid=\(Router.apiKey)&units=imperial"
        }
    }
    
    func asURLRequest() -> URLRequest {
        let baseUrl = URL(string: Router.baseURLString)!
        let url = URL(string: path, relativeTo: baseUrl)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        
        switch self {
        case .getWeather:
            urlRequest.httpBody = nil
        }
        
        return urlRequest
    }
}

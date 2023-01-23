//
//  APIService.swift
//  JGithubSearch
//
//  Created by 권회경 on 2022/11/29.
//

import Foundation
import Combine

enum APIError: LocalizedError {
    case notReady
    case failedRequest
    case failedJsonDesrialized
}

struct APIService {
    private let baseURL = "https://api.github.com"
    
    func searchReposeCombine<T: Codable>(with keyword: String,
                                         page: Int = 1,
                                         type: T.Type) -> AnyPublisher<T, APIError> {
        
        let url = baseURL + "/search/repositories"
        let headers = ["application/vnd.github.v3+json": "accept"]
        let params = [
            "q": keyword,
            "page": String(page)
        ]
        
        guard let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error: encoded URL")
            
            return Fail(error: APIError.notReady).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: encodedURL) else {
            print("Error: cannot create URL")
            
            return Fail(error: APIError.notReady).eraseToAnyPublisher()
        }
        
        lazy var queryItems: [URLQueryItem] = params.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        // Request
        var request: URLRequest = {
            var r = URLRequest(url: url)
            r.httpMethod = "GET"
            r.url?.append(queryItems: queryItems)
            
            return r
        }()
        
        // TODO: URLRequset 클로저에서 만들수는 없을까? by jeanclad
        _ = headers.map {
            request.setValue($0.key, forHTTPHeaderField: $0.value)
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap() { data, response in
                guard let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                    print("Error: HTTP request failed")
                    throw APIError.failedRequest
                }
                
                return data
            }
            .decode(type: type, decoder: JSONDecoder())
            .mapError { error in
                if let error = error as? APIError {
                    return error
                } else {
                    return APIError.failedRequest
                }
            }
            .eraseToAnyPublisher()
    }
    
    func searchRepos(with keyword: String,
                     page: Int = 1,
                     completionHandler: @escaping (Result<Data, Error>) -> Void) {
        
        let url = baseURL + "/search/repositories"
        let headers = ["application/vnd.github.v3+json": "accept"]
        let params = [
            "q": keyword,
            "page": String(page)
        ]
        
        guard let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error: encoded URL")
            
            return completionHandler(.failure(APIError.notReady))
        }
        
        guard let url = URL(string: encodedURL) else {
            print("Error: cannot create URL")
            
            return completionHandler(.failure(APIError.notReady))
        }
        
        lazy var queryItems: [URLQueryItem] = params.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        // Request
        var request: URLRequest = {
            var r = URLRequest(url: url)
            r.httpMethod = "GET"
            r.url?.append(queryItems: queryItems)
            
            return r
        }()
        
        // TODO: URLRequset 클로저에서 만들수는 없을까? by jeanclad
        _ = headers.map {
            request.setValue($0.key, forHTTPHeaderField: $0.value)
        }
        
        // Task
        URLSession(configuration: .default)
            .dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                
                guard error == nil else {
                    print("Error : response error - \(String(describing: error))")
                    return completionHandler(.failure(error!))
                }
                
                guard let d = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                    print("Error: HTTP request failed")
                    return completionHandler(.failure(APIError.failedRequest))
                }
                
                return completionHandler(.success(d))
            }
            .resume()
    }
}

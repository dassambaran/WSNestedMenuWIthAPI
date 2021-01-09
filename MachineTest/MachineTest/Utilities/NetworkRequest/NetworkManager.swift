//
//  NetworkManager.swift
//  NetworkRequests
//
//  Created by SD on 12/10/20.
//

import Foundation
//import UIKit

/// Http methods
public enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
}

/// Networkmanager with generic response model
final class NetworkManager {
    private init() {}
    static let shared = NetworkManager()
    private var observation: NSKeyValueObservation?
    deinit {
        observation?.invalidate()
    }
    
    
    /// Print API details
    /// - Parameters:
    ///   - url: URL
    ///   - header: Header
    ///   - body: Body as input parameters
    fileprivate func printAPI(with url: URL?,header: NetworkHeaders? = nil, body: Encodable? = nil) {
        debugPrint("URL->",url ?? "No url found")
        debugPrint("Header->",header?.header ?? "No header provided")
        print("params->",body ?? "No params provided")
    }
    
    /// Network call using Get method
    /// - Parameters:
    ///   - urlString: url in string Format
    ///   - urlPath: Append a path after the base URL
    ///   - query: only the path using query string
    ///   - headers: header in NetworkHeaders Format
    ///   - requestType: request model, must conform to protocol Loopable
    ///   - responseType: response model
    ///   - completionHandler: response,error
    final func getRequest<T: RequestModelType>(_
                                                urlString: String,
                                               urlPath: String = "",
                                               query: String = "",
                                               headers: NetworkHeaders?,
                                               requestType: T?,
                                               completionHandler: @escaping(DataTaskResult)-> Void) {
        var url: URL?
        
        if let urlComps = requestType?.convertToURLComponents(with: urlString,query: query) {
            url = urlComps.url
        } else {
            guard let urlWithoutQueryStr = URL(string: urlString) else {
                completionHandler(Result.failure(HTTPError.UnknownCustomError(.invalidURL)))
                return
            }
            url = urlWithoutQueryStr
        }
        !urlPath.isEmpty ? url?.appendPathComponent(urlPath) : ()
        NetworkManager.shared.printAPI(with: url,header: headers)
        
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        urlRequest.httpBody = nil
        urlRequest.allHTTPHeaderFields = headers?.header
        ///For Low Data Mode enabled
        //        if #available(iOS 13.0, *) {
        //            urlRequest.allowsConstrainedNetworkAccess = false
        //        }
        
        let configuration = URLSessionConfiguration.default
        ///it will wait for internet connection upto 7 days by default else custom timeout can be set with  "timeoutIntervalForResource"
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForResource = 60
        configuration.timeoutIntervalForRequest = 60
        let session = URLSession(configuration: configuration)
        session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completionHandler(Result.failure(HTTPError.transportError(error)))
                return
            }
            let response = response as! HTTPURLResponse
            let status = response.statusCode
            guard (200...299).contains(status) else {
                completionHandler(Result.failure(HTTPError.serverSideError(status)))
                return
            }
            completionHandler(Result.success((response, data!)))
        }.resume()
    }
    
}

enum HTTPError: Error {
    case transportError(Error)
    case serverSideError(Int)
    case UnknownCustomError(UnknownError)
}
typealias DataTaskResult = Result<(HTTPURLResponse, Data), Error>

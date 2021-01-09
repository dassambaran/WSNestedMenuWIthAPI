//
//  NetworkRequestManager.swift
//
//  Created by Sambaran on 23/09/20.
//  Copyright © 2020. All rights reserved.
//

import Foundation
import UIKit

let deployEnvironmnet: Environmenttypes = .dev

/// URL Endpoints
 struct Endpoints {
    static let resource = "unknown"
}

enum Environmenttypes {
    case dev
    case staging
    case live
}
enum Baseurltypes {
    case general(_ environment: Environmenttypes)
    case image(_ environment: Environmenttypes)
    
    ///Change Base url below accoring to your deploy environment  and baseurl type(Like for genral or image Server)
    public var rawValue: String {
        switch self {
        case .general(.dev):
            return "http://planningpro.dedicateddevelopers.us/api/role/planning/0"
        case .general(type: .staging):
            return "http://planningpro.dedicateddevelopers.us/api/role/planning/0"
        case .general(type: .live):
            return "http://planningpro.dedicateddevelopers.us/api/role/planning/0"
        case .image(type: .dev):
            return "http://planningpro.dedicateddevelopers.us/api/role/planning/0"
        case .image(type: .staging):
            return "http://planningpro.dedicateddevelopers.us/api/role/planning/0"
        case .image(type: .live):
            return "http://planningpro.dedicateddevelopers.us/api/role/planning/0"
        }
    }
}
    
/// Http headers; If need to provide extra header option other than default header then use as:
///     - USAGE: NetworkHeaders(["example1": "test1", "example2": "test2"])
struct NetworkHeaders  {
    var header: [String: String] = [:]
    init(_ param: [String: String] = [:]) {
        
        header["Accept"] = "application/json"
        header["Content-Type"] = "application/json"
        header["Authorization"] = "Bearer 739|c0DxqQa9nURCa2OSMMgxAdyEMdLre0JCscuXpTYz"
    }
}

final class NetworkRequestManager {
    private init(){}
    static let shared = NetworkRequestManager()
    fileprivate let currentBaseUrl = Baseurltypes.general(deployEnvironmnet)
    
    
    /// Network request with GET Http method
    /// - Parameters:
    ///   - endPoint: endpoint of URL
    ///   - urlPath: Append a path after the base URL
    ///   - query: only the path using query string
    ///   - request: request model , it must conform to protocol Loopable
    ///   - header: heaeder
    ///   - response: response model
    ///   - completion: response model, Message
    func requestWithGet<U: Decodable,T: RequestModelType> (
        endPoint: String,
        urlPath: String = "",
        query: String = "",
        request: T ,
        header: NetworkHeaders,
        response: U.Type,
        completion:@escaping (U?,String,Bool) -> Void) {
        
        let urlString = "\(currentBaseUrl.rawValue)\(endPoint)"
        NetworkManager.shared.getRequest(urlString,urlPath: urlPath,query: query,headers: header, requestType: request, completionHandler: { (result) in
            result.getResponse(responseType: U.self) { (response, message,token,isTokenExpired)  in
                completion(response, message, isTokenExpired)
            }
        })
    }
}




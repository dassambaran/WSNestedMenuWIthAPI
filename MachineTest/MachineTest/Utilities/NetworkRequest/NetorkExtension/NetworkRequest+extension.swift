//
//  extension.swift
//
//  Created by Sambaran on 12/08/20.
//  Copyright © 2020 UIPL. All rights reserved.
//

import Foundation

extension Encodable {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}
typealias RequestModelType = Loopable & Encodable
protocol Loopable {
    var allProperties: [String: Any] { get }
}
extension Loopable {
   
    var allProperties: [String: Any] {
        var result = [String: Any]()
        Mirror(reflecting: self).children.forEach { child in
            if let property = child.label {
                result[property] = child.value
            }
        }
        return result
    }
    
    /// FOR HTTP GET request converted to querystring with URL
    /// - Parameter url: Expecting string type as URL
    /// - Returns: Http url components for GET request
    func convertToURLComponents(with url: String,query: String) -> URLComponents? {
        var queryItems: [URLQueryItem] = []
        for (key,val) in self.allProperties {
            queryItems.append(URLQueryItem(name: key, value: "\(val)"))
        }
        var urlComps = URLComponents(string: url)
        urlComps?.queryItems = queryItems
        if !query.isEmpty {
            urlComps?.query = query
        }
        return urlComps
    }
    func getNestedValues(_ data: Loopable) -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = []
        for (key,val) in data.allProperties {
            if let value = val as? Loopable {
                queryItems.append(contentsOf: self.getNestedValues(value))
            } else {
                queryItems.append(URLQueryItem(name: key, value: "\(val)"))
            }
        }
        return queryItems
    }
}

extension NSMutableData {
    func appendStrng(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
extension Bundle {
    static func name() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return ""
        }
        if let name : String = dictionary["CFBundleName"] as? String {
            return name
        } else {
            return ""
        }
    }
}

///handling https response ; success and errors
extension DataTaskResult {
    func getResponse<U: Decodable>(
        responseType: U.Type,
        completionHandler: (U?,_ message: String,_ newToken: String,_ isTokenExpired: Bool) -> Void) {
        
        switch self {
        case .success((let response,let data)):
            do {
                let status = response.statusCode
                switch status {
                case 204:
                    debugPrint("No response!")
                    let response = EmptyResponse()
                    completionHandler(response as? U,"No response!" , "", false)
                default:
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Reponse Json=>",json)
                        
                    }
                    
                    let result = try JSONDecoder().decode(U.self, from: data)
                    completionHandler(result,"Success!", "", false)
                }
            } catch (let error) {
//                let outputStr  = String(data: data, encoding: String.Encoding.utf8) as String?
//                print("response:",outputStr)
                debugPrint("Error Converting data:",error)
                completionHandler(nil,error.localizedDescription, "", false)
            }
            break // Handle response
        case .failure(let error):
            if let error = error as? HTTPError {
                switch error {
                case .transportError(let error):
                    switch error._code {
                    case -1009:
                        debugPrint(">>>>The Internet connection appears to be offline.")
                    default:
                        debugPrint("Transport layer error->",error)
                    }
                    completionHandler(nil,error.localizedDescription, "", false)
                    break
                case .serverSideError(let status):
                    switch status {
                    case 400:
                        debugPrint("Missing parameter")
                        completionHandler(nil,error.localizedDescription, "", false)
                        break
                    case 401:
                        debugPrint(error.localizedDescription)
                        completionHandler(nil,ErrorMessage.unAuthorised, "", false)
                        break
                    case 404:
                        debugPrint(error.localizedDescription)
                        completionHandler(nil,ErrorMessage.noResponse, "", false)
                        break
                    default:
                        debugPrint(error.localizedDescription)
                        completionHandler(nil,ErrorMessage.unknownServerErr, "", false)
                        break
                    }
                    break
                case .UnknownCustomError(let error):
                    switch error {
                    case .invalidURL:
                        debugPrint(error.errorDescription ?? error.localizedDescription)
                        completionHandler(nil,error.errorDescription ?? error.localizedDescription, "", false)
                    }
                }
            } else {
                debugPrint(error.localizedDescription)
                completionHandler(nil,error.localizedDescription, "", false)
            }
            break // Handle error
        }
    }
}


/// Custom error , can add error accoring to your need
public enum UnknownError: Error {
    case invalidURL
}

extension UnknownError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Error: Cannot create URL", comment: "Sorry, invalid error encounterred!")
        }
    }
}

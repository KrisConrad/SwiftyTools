//
//  RestHandler.swift
//
//
//  Created by Kris Conrad on 7/20/16.
//
//

import UIKit
import SwiftyJSON

private func stripFileExtension(_ filename: String ) -> String {
    var components = filename.components(separatedBy: ".")
    guard components.count > 1 else { return filename }
    components.removeLast()
    return components.joined(separator: ".")
}

private var appName: String {
    let bundle = Bundle.main
    if let name =  bundle.object(forInfoDictionaryKey: "CFBundleDisplayName")
        ?? bundle.object(forInfoDictionaryKey: kCFBundleNameKey as String),
        let stringName = name as? String
        { return stringName }

    let bundleURL = bundle.bundleURL
    let filename = bundleURL.lastPathComponent
    return stripFileExtension(filename)
}

/// A class for handling RESTful communications
class RESTHandler: NSObject {
    
    enum Method: String {
        case delete = "DELETE"
        case get = "GET"
        case patch = "PATCH"
        case post = "POST"
        case put = "PUT"
    }

    static let shared = RESTHandler()

    ///The URLSession to use when building a URLRequest.
    private var session: URLSession {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }
    
    var httpHeaders: [String: String] = [:]

    /**
     Make a request to a restful API Endpoint

     - parameter address:    The address of the endpoint to make a request to
     - parameter httpMethod: the HTTP Method to use for the reuest
     - parameter bodyObject: a Valid JSON Object to use for the HTTP Body
     */
    public func request(_ address: String, method: Method, bodyObject: Any?) async throws -> JSON {
        guard let url = URL(string: address) else {
            let details = [NSLocalizedDescriptionKey: "Bad URL Format"]
            let error = NSError(domain: "URL", code: 0, userInfo: details)
            throw(error)
        }
        
        var bodyData: Data?
        if let bodyObject = bodyObject {
            bodyData = try JSONSerialization.data(withJSONObject: bodyObject, options: [])
        }
        
        var request = self.configuredRequest(for: url)
        request.httpMethod = method.rawValue
        request.httpBody = bodyData
        
        return try await self.request(withRequest: request)
    }
 
    public func request(_ address: String, httpMethod: String, bodyObject: Any?, complete: ((JSON?, Error?) -> Void)?) {
        guard let url = URL(string: address) else {
            let details = [NSLocalizedDescriptionKey: "Bad URL Format"]
            let error = NSError(domain: "URL", code: 0, userInfo: details)
            complete?(nil, error)
            return
        }
        DispatchQueue.global().async {
            var bodyData: Data?
            if let bodyObject = bodyObject {
                do {
                    bodyData = try JSONSerialization.data(withJSONObject: bodyObject, options: [])
                } catch {
                    complete?(nil, error)
                    return
                }
            }

            var request = self.configuredRequest(for: url)
            request.httpMethod = httpMethod
            request.httpBody = bodyData

            self.request(withRequest: request, complete: { (json, error) in
                complete?(json, error)
            })
        }
    }
    
    private func configuredRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)

        var device = UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
        #if targetEnvironment(macCatalyst)
        device = "Mac"
        #endif

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(appName)/\(appVersion)(\(appBuildNumber)) iOS \(device)", forHTTPHeaderField: "User-Agent")
        
        httpHeaders.forEach({ request.addValue($0, forHTTPHeaderField: $1) })

        request.timeoutInterval = 120
        
        return request
    }

    /**
     Make a request to a restful API Endpoint

     - parameter request:  a NSURLRequest object for request
     */
    private func request(withRequest request: URLRequest) async throws -> JSON {
        print("\(request.httpMethod!): \(request.url!.absoluteString)")
                
        if #available(iOS 15.0, *) {
            let (data, _) = try await session.data(for: request, delegate: nil)
            return try JSON(data: data)
        } else {
            return try await withCheckedThrowingContinuation({ continuation in
                self.request(withRequest: request) { result in
                    continuation.resume(with: result)
                }
            })
        }
    }

    // iOS <15.0 fallback
    private func request(withRequest request: URLRequest, complete: @escaping (Result<JSON, Error>) -> Void) {
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            let result = self.result(from: data, response: response, error: error)
            
            if let json = result.json {
                complete(.success(json))
            } else {
                let details = [NSLocalizedDescriptionKey: "Missing data in response from \(String(describing: request.url?.absoluteString))"]
                let error = result.error ?? NSError(domain: "Unknown", code: 0, userInfo: details)
                complete(.failure(error))
            }
        })
        task.resume()
    }
    
    /**
     Make a request to a restful API Endpoint

     - parameter request:  a NSURLRequest object for request
     - parameter complete:  A closure that is called when after the request has finished/failed.
                            Takes an optional JSON object containing the data of the response and an optional
                            NSError object that provides information about any errors that happend during the request.
     */
    private func request(withRequest request: URLRequest, complete: ((JSON?, Error?) -> Void)?) {
        print("\(request.httpMethod!): \(request.url!.absoluteString)")

        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            let result = self.result(from: data, response: response, error: error)
            complete?(result.json, result.error)
            
        })
        task.resume()
    }
    
    private func result(from data: Data?, response: URLResponse?, error: Error?) -> (json: JSON?, error: Error?) {
        var returnError = error
        var json: JSON?

        if let jsonData = data {
            do {
                json = try JSON(data: jsonData)
            } catch {
                if let str = String(data: jsonData, encoding: .utf8) {
                    json = JSON(parseJSON: "{\"response\": \"\(str)\"}")
                }
            }
        }

        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            if statusCode < 200 || statusCode >= 300 {
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                var details: [String: Any] = [NSLocalizedDescriptionKey: errorMessage]
                print("Status Code: \(statusCode) - \(errorMessage)")
                if let json = json {
                    details.merge(json.dictionaryObject ?? [:], uniquingKeysWith: {(first, _) in first })
                    print("\nResponse Body:\n`\(details)`")
                }
                if returnError == nil {
                    returnError = NSError(domain: "HTTPURLResponse", code: httpResponse.statusCode, userInfo: details)
                }
            }
        }
        
        return (json: json, error: returnError)
    }
}

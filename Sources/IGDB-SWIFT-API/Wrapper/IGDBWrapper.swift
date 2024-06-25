//
//  IGDBWrapper.swift
//  IGDB-API-SWIFT
//
//  Created by Filip Husnjak on 2019-01-04.
//  Copyright © 2019 Filip Husnjak. All rights reserved.
//

import Foundation

private let APIURL = "https://api.igdb.com/v4"

public class IGDBWrapper {
    private var requestHeaders = ["x-user-agent": "igdb-api-swift"]
    private var requestURL = APIURL

    public init(clientID: String, accessToken: String) {
        requestHeaders = ["x-user-agent": "igdb-api-swift", "client-id": clientID, "authorization": "Bearer \(accessToken)"]
    }

    public init(proxyURL: String, proxyHeaders: [String: String]) {
        requestURL = proxyURL
        requestHeaders = proxyHeaders
        requestHeaders["x-user-agent"] = "igdb-api-swift"
    }

    public func apiProtoRequest(endpoint: Endpoint, apicalypseQuery: String, dataResponse: @escaping (Data) -> (Void), errorResponse: @escaping (RequestException) -> (Void)) {
        let requestURL = "\(APIURL)\(endpoint.url()).pb"
        var urlComp = URLComponents(string: requestURL)!

        var req = URLRequest(url: urlComp.url!)
        req.httpBody = apicalypseQuery.data(using: .utf8, allowLossyConversion: false)
        req.httpMethod = "POST"
        for header in requestHeaders {
            req.setValue(header.value, forHTTPHeaderField: header.key)
        }

        let task = URLSession(configuration: .ephemeral).dataTask(with: req) { [weak self] data, response, error in
            if let error = error {
                print(error.localizedDescription)
                errorResponse(RequestException(statusCode: 400, url: requestURL, msg: error.localizedDescription))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                DispatchQueue.main.async {
                    dataResponse(data)
                }
            } else {
                errorResponse(RequestException(statusCode: 404, url: requestURL, msg: ""))
            }
        }
        task.resume()
    }

    public func apiJsonRequest(endpoint: Endpoint, apicalypseQuery: String, dataResponse: @escaping (String) -> (Void), errorResponse: @escaping (RequestException) -> (Void)) {
        let requestURL = "\(requestURL)\(endpoint.url())"
        var urlComp = URLComponents(string: requestURL)!

        var req = URLRequest(url: urlComp.url!)
        req.httpBody = apicalypseQuery.data(using: .utf8, allowLossyConversion: false)
        req.httpMethod = "POST"
        for header in requestHeaders {
            req.setValue(header.value, forHTTPHeaderField: header.key)
        }

        let task = URLSession(configuration: .ephemeral).dataTask(with: req) { [weak self] data, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                DispatchQueue.main.async {
                    dataResponse(String(data: data, encoding: .utf8) ?? "")
                }
            }
        }
        task.resume()
    }

//    Adding count functions
    public func apiProtoCountRequest(endpoint: Endpoint, apicalypseQuery: String, dataResponse: @escaping (Data) -> (Void), errorResponse: @escaping (RequestException) -> (Void)) {
        let requestURL = "\(requestURL)\(endpoint.url())/count.pb"
        Just.post(requestURL, headers: requestHeaders, requestBody: apicalypseQuery.data(using: .utf8, allowLossyConversion: false), asyncCompletionHandler:  { response in
            if response.statusCode != 200 {
                errorResponse(RequestException(statusCode: response.statusCode ?? -1, url: requestURL, msg: response.text ?? ""))
            }
            dataResponse(response.content!)
        })
    }

    public func apiJsonCountRequest(endpoint: Endpoint, apicalypseQuery: String, dataResponse: @escaping (String) -> (Void), errorResponse: @escaping (RequestException) -> (Void)) {
        let requestURL = "\(requestURL)\(endpoint.url())/count"
        Just.post(requestURL, headers: requestHeaders, requestBody: apicalypseQuery.data(using: .utf8, allowLossyConversion: false), asyncCompletionHandler:  { response in
            if response.statusCode != 200 {
                errorResponse(RequestException(statusCode: response.statusCode ?? -1, url: requestURL, msg: response.text ?? ""))
            }
        }
    }
}

public extension Endpoint {
    func url() -> String {
        return "/\(self.rawValue.lowercased())"
    }
}

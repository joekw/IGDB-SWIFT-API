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

    public func apiProtoRequest(endpoint: Endpoint, apicalypseQuery: String, completion: @escaping (Result<Data, Error>) -> Void) {
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
                completion(.failure(error))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(.success(data))
                }
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
}

public extension Endpoint {
    func url() -> String {
        return "/\(self.rawValue.lowercased())"
    }
}

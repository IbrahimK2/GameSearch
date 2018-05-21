//
//  GameSearchClient.swift
//  GameSearch
//
//  Created by Ibrahim Kurabi on 2018-05-21.
//  Copyright © 2018 Ibrahim Kurabi. All rights reserved.
//

import Foundation

// The result of an asynchronous GiantBombClient.request call. It can either succeed with data or fail with an error.
enum GBRequestResult {
    case response (GiantBombResponse)
    case error (Error)
}

// Callback for asynchronous request call of GiantBombClient
typealias GBRequestCompletionHandler = (GBRequestResult) -> Void

// Model for response object
struct GiantBombResponse: Decodable {
    let error: String?
    let limit: Int?
    let offset: Int?
    let numberOfPageResults: Int?
    let numberOfTotalResults: Int?
    let statusCode: Int?
    let results: [VideoGame]?
    let version: String?
}

// Model for result from response
struct VideoGame: Decodable {
    let name: String?
    let deck: String?
    let image: [String: String?]?
    let resourceType: String?
}

/* Consumes data from GiantBomb API.
 *  Reference: https://www.giantbomb.com/api/
 *  Reference: https://www.giantbomb.com/forums/api-developers-3017/quick-start-guide-to-using-the-api-1427959/#19
 */

class GiantBombClient {
    
    let domain = "www.giantbomb.com/api"
    let token = "00435f0d8481427b652ded4913e8068646b12f6a"
    
    func request(resource: String, withParameters: [String: String], _ completionHandler: @escaping GBRequestCompletionHandler) {
        // Combine Params
        let combinedParams = [ "api_key": token, "format": "json", "resources": "game"].merging(withParameters) { (_, new) in new }
        
        // Get the URL
        let queryParams = GiantBombClient.paramsToQueryString(combinedParams)
        let path = resource.hasPrefix("/") ? resource : ("/" + resource)
        let url = "https://\(self.domain)\(path)?\(queryParams)"
        let urlToSend = URL(string: url)
        
        // Build the request
        let request = NSMutableURLRequest(url: urlToSend!)
        
        // Send it
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, reqError in
            
            // We sync the callback with the main thread to make UI programming easier
            let syncCompletion = { res in OperationQueue.main.addOperation { completionHandler (res) } }
            
            // Check for net error
            if let error = reqError {
                syncCompletion(.error (error))
                return
            }
            
            // Make sure data exists
            guard let data = data else {
                syncCompletion(.error (NSError(domain: "GiantBombClient", code: 0, userInfo: ["Error": "No data from request"])))
                return
            }
            
            // Decode data to model objects
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedResponse = try decoder.decode(GiantBombResponse.self, from: data)
                syncCompletion(.response (decodedResponse))
            } catch let jsonError {
                syncCompletion(.error (jsonError))
                return
            }
            
        }
        task.resume()
    }

    // Converts an Dictionary into a query string.
    class func paramsToQueryString (_ params: [String: String]) -> String {
        var parts: [String] = []
        for (key, value) in params {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }

}



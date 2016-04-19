//
//  WebClient.swift
//  onthemap_3.0
//
//  Created by gongzhen on 4/16/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

public class WebClient {

    let JsonContentType = "application/json"
    let HttpHeaderAccept = "Accept"
    let HttpHeaderContentType = "Content-Type"
    let HttpPost = "POST"
    let HttpGet = "GET"
    
    // createHttpGetRequestForUrlString
    // Creates fully configured NSURLRequest for making HTTP GET requests.
    // urlString: properly formatted URL string
    // includeHeaders: field-name / value pairs for request headers. It might be nil.You don't have to pass parameter.
    public func createHttpGetRequestForUrlString(urlString: String,
        includeHeaders requestHeaders: [String:String]? = nil) -> NSURLRequest {
        // TODO: this should do something smarter if the urlString is malformed
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = WebClientConstant.HttpGet
        if let requestHeaders = requestHeaders {
            request = addRequestHeaders(requestHeaders, toRequest: request)
        }
        return request
    }
    
    // createHttpPostRequestForUrlString
    // Creates fully configured NSURLRequest for making HTTP POST requests.
    // urlString: properly formatted URL string
    // withBody: body of the post request, not necessarily JSON or any particular format.
    // includeHeaders: field-name / value pairs for request headers.
    public func createHttpPostRequestForUrlString(urlString: String, withBody body: NSData,
        includeHeaders requestHeaders: [String:String]?) -> NSURLRequest {
        
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = WebClientConstant.HttpPost
        if let requestHeaders = requestHeaders {
            request = addRequestHeaders(requestHeaders, toRequest: request)
        }
        request.HTTPBody = body
        return request
    }
    
    // return Set: (jsonData, error)
    func parseJsonFromData(data: NSData) -> (jsonData: AnyObject?, error: NSError?) {
        var parsingError: NSError? = nil
        let jsonData: AnyObject?
        do{
            jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let JSONError as NSError {
            parsingError = JSONError
            jsonData = nil
        }
        return (jsonData, parsingError)
    }
    
    func createErrorWithCode(code: Int, message: String, domain: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : message]
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
    
    // executeRequest
    // Execute the request in a background thread, and call completionHandler when done.
    // Performs the work of checking for general errors and then
    // turning raw data into JSON data to feed to completionHandler.
    public func executeRequest(request: NSURLRequest,
        completionHandler: (jsonData: AnyObject?, error: NSError?) -> Void) {
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
            // this is a general communication error
            if let error = error {
                Logger.debug(error.description)
                completionHandler(jsonData: nil, error: error)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                return
            }
            
            let (jsonData, parsingError) = self.parseJsonFromData(data)
            
            // parsingError not nil, return
            if let parsingError = parsingError {
                Logger.debug(parsingError.description)
                completionHandler(jsonData: nil, error: parsingError)
                return
            }
            
            completionHandler(jsonData: jsonData, error: nil)
        }
        task.resume()
    }
    
    // MARK: Private Helpers
    
    // helper function adds request headers to request
    private func addRequestHeaders(requestHeaders: [String:String], toRequest request: NSMutableURLRequest) -> NSMutableURLRequest {
        let request = request
        for (field, value) in requestHeaders {
            request.addValue(value, forHTTPHeaderField: field)
        }
        return request
    }
}

// MARK: - Constants

extension WebClient {
    struct WebClientConstant {
        static let JsonContentType = "application/json"
        static let HttpHeaderAccept = "Accept"
        static let HttpHeaderContentType = "Content-Type"
        static let HttpPost = "POST"
        static let HttpGet = "GET"
    }
}


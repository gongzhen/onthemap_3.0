//
//  WebClient.swift
//  onthemap_3.0
//
//  Created by gongzhen on 4/16/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

// MARK: - Class WebClient

// WebClient
// Base Class for general interactions with any Web Service API that produces JSON data.
public class WebClient {

    // optional data maniupation function
    // if set will modify the data before handing it off to the parser.
    // Common Use Case: some web services include extraneous content
    // before or after the desired JSON content in response data.
    // Parsing the parameter NSData and pre-process it and return new NSData.
    public var prepareData: ((NSData) -> NSData?)?
    
    // createHttpGetRequestForUrlString
    // Creates fully configured NSURLRequest for making HTTP GET requests.
    // urlString: properly formatted URL string
    // includeHeaders: field-name / value pairs for request headers. It might be nil.You don't have to pass parameter.
    public func createHttpGetRequestForUrlString(var urlString: String,
        includeHeaders requestHeaders: [String:String]? = nil,
        includeParameters requestParameters: [String:AnyObject]? = nil ) -> NSURLRequest {
        
            // TODO: this should do something smarter if the urlString is malformed
            // Construct parameters
            if let requestParameters = requestParameters {
                urlString = "\(urlString)?\(encodeParameters(requestParameters))"
            }
            // TODO: this should do something smarter if the urlString is malformed
            
            var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            request.HTTPMethod = WebClient.HttpGet
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
    public func createHttpPostRequestForUrlString(var urlString: String, withBody body: NSData,
        includeHeaders requestHeaders: [String:String]? = nil,
        includeParameters requestParameters:[String:AnyObject]? = nil ) -> NSURLRequest {
            
            if let requestParameters = requestParameters {
                // encodeParameters:
                // passing paramter as [String: AnyObject] and create the urlString.
                urlString = "\(urlString)?\(encodeParameters(requestParameters))"
            }
            
            var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            request.HTTPMethod = WebClient.HttpPost
            if let requestHeaders = requestHeaders {
                request = addRequestHeaders(requestHeaders, toRequest: request)
            }
            request.HTTPBody = body
            return request
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
    
    // encodeParameters
    // convert dictionary to parameterized String appropriate for use in an HTTP URL
    private func encodeParameters(params:[String: AnyObject]) ->String {
        var queryItems = [NSURLQueryItem]()
        
        for (key, value) in params {
            queryItems.append(NSURLQueryItem(name:key, value: "\(value)"))
        }
        let components = NSURLComponents()
        components.queryItems = queryItems
        return components.percentEncodedFragment ?? ""
    }
    
    // Produces usable JSON object from the raw data.
    // return Set: (jsonData, error)
    func parseJsonFromData(data: NSData) -> (jsonData: AnyObject?, error: NSError?) {
        var mutableData = data
        var parsingError: NSError? = nil
        // Very smart here
        // if prepareData is set in the initiator then prepareData(data)
        // prepareData accepts data as parameter and return data
        if let prepareData = prepareData, modifiedData = prepareData(data) {
            mutableData = modifiedData
        }
        
        let jsonData: AnyObject?
        do{
            jsonData = try NSJSONSerialization.JSONObjectWithData(mutableData, options: NSJSONReadingOptions.AllowFragments)
        } catch let JSONError as NSError {
            parsingError = JSONError
            jsonData = nil
        }
        return (jsonData, parsingError)
    }
}

// MARK: - Constants

// Constants: Web Client constants.
extension WebClient {
    static let JsonContentType = "application/json"
    static let HttpHeaderAccept = "Accept"
    static let HttpHeaderContentType = "Content-Type"
    static let HttpPost = "POST"
    static let HttpGet = "GET"
}


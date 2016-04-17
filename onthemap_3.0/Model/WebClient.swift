//
//  WebClient.swift
//  onthemap_3.0
//
//  Created by gongzhen on 4/16/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

class WebClient {

    let JsonContentType = "application/json"
    let HttpHeaderAccept = "Accept"
    let HttpHeaderContentType = "Content-Type"
    let HttpPost = "POST"
    let HttpGet = "GET"
    
    func createHttpGetRequestForUrlString(urlString: String) -> NSURLRequest {
        return NSURLRequest(URL: NSURL(string: urlString)!)
    }
    
    func createHttpPostRequestForUrlString(urlString: String, withBody body: NSData) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = HttpPost
        request.addValue(JsonContentType, forHTTPHeaderField: HttpHeaderAccept)
        request.addValue(JsonContentType, forHTTPHeaderField: HttpHeaderContentType)
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
    
    // passing request,
    // dataValidator: checking if the jsonData length < 5
    func executeRequest(request: NSURLRequest,
        dataValidator: ((jsonData: NSData!) -> NSError?)?,
        completionHandler: (jsonData: AnyObject?, error: NSError?) -> Void) {
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                // this is a general communication error
                if error != nil {
                    completionHandler(jsonData: nil, error: error)
                    return
                }
                
                // dataValidator: checking if the jsonData length < 5
                // call back function: Smart!
                if let dataValidator = dataValidator,
                    dataError = dataValidator(jsonData: data) {
                        completionHandler(jsonData: nil, error: dataError)
                        return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    return
                }
                
                let (jsonData, parsingError) = self.parseJsonFromData(data.subdataWithRange(NSMakeRange(5, data.length-5)))
                // parsingError not nil, return
                if let parsingError = parsingError {
                    completionHandler(jsonData: nil, error: parsingError)
                    return
                }
                
                completionHandler(jsonData: jsonData, error: nil)
            }
            task.resume()
    }
}

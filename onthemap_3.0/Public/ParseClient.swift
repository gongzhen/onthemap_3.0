//
//  ParseClient.swift
//  onthemap_3.0
//
//  Created by gongzhen on 4/18/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

public class ParseClient {
    
    private var applicationId: String!
    private var restApiKey: String!
    private var webClient: WebClient!
    
    private var StandardHeaders: [String:String] {
        return [
            "X-Parse-Application-Id":applicationId,
            "X-Parse-REST-API-Key":restApiKey
        ]
    }

    public init(client: WebClient, applicationId: String, restApiKey: String) {
        self.webClient = client
        self.applicationId = applicationId
        self.restApiKey = restApiKey
    }
    
    // passing parameters: ClassName, Limit, Skip.
    // return resultArrays with closure.
    public func fetchResultsForClassName(className: String, limit: Int = 50, skip: Int = 0,
        completionHandler: (resultsArray: [[String:AnyObject]]?, error: NSError?) -> Void) {
            // passing:https://api.parse.com/1/classes/StudentLocations
            let request = webClient.createHttpGetRequestForUrlString("\(ParseClient.ObjectUrl)/\(className)",
                includeHeaders: StandardHeaders,
                includeParameters: [ParseParameter.Limit:limit, ParseParameter.Skip: skip])
            
            // webClient executeRequest by request
            // return jsonData from closure.
            webClient.executeRequest(request) {
                jsonData, error in
                if let resultsArray = jsonData?.valueForKey(ParseJsonKey.Results) as? [[String:AnyObject]] {
                    Logger.info("Found resultArray of size: \(resultsArray.count)")
                    completionHandler(resultsArray: resultsArray, error: nil)
                } else {
                    completionHandler(resultsArray: nil, error: ParseClient.errorForCode(.ResponseContainedNoResultObject))
                }
            }
    }
}

// MARK: - Constants

extension ParseClient {
    // Provide Parse web service information.
    static let BaseUrl = "https://api.parse.com/1/"
    static let ObjectUrl = BaseUrl + "classes/"
    
    struct ParseParameter {
        static let Limit = "limit"
        static let Skip = "skip"
    }
    
    struct ParseJsonKey {
        static let Results = "results"
        static let Count = "count"
    }
    
}

// MARK: - Errors {

extension ParseClient {
    
    private static let ErrorDomain = "ParseClient"
    
    private enum ErrorCode: Int, CustomStringConvertible {
        case ResponseContainedNoResultObject = 1
        
        var description: String {
            switch self {
            case ResponseContainedNoResultObject:
                return "Response data did not provide a results object."
            }
        }
    }
    
    // createErrorWithCode
    // helper function to simplify creation of error object
    // return NSError
    private static func errorForCode(code: ErrorCode) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : code.description]
        return NSError(domain: ParseClient.ErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}

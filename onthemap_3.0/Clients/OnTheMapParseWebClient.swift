//
//  OnTheMapParseWebClient.swift
//  onthemap_3.0
//
//  Created by gongzhen on 4/17/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

class OnTheMapParseService {
    
    private var parseClient: ParseClient!

    init() {
        parseClient = ParseClient(
            client: WebClient(),
            applicationId: AppDelegate.ParseApplicationId,
            restApiKey: AppDelegate.ParseRestApiKey
        )
    }
    
    func fetchStudentLocations(limit: Int = 50, skip: Int = 0,
        completionHandler: (studentLocations: [StudentLocation]?, error: NSError?) -> Void) {
            // ParseClient: fetchResultsForClassName
            // passing:StudentLocation String as ClassName, limit, skip,
            // return resultsArray from closure.
            self.parseClient.fetchResultsForClassName(OnTheMapParseService.StudentLocationClassName, limit: limit, skip: skip) {
                resultsArray, error in
                completionHandler(studentLocations: self.parseResults(resultsArray), error: error)
            }
    }
    
    // MARK: - Data Parsers

    private func parseResults(resultsArray: [[String:AnyObject]]?) -> [StudentLocation]? {
        if let resultsArray = resultsArray {
            let optionalStudentLocations = resultsArray.map(){StudentLocation(data: $0)}
            var studentLocations = [StudentLocation]()
            for item in optionalStudentLocations {
                if let location = item {
                    studentLocations.append(location)
                }
            }
            return studentLocations
        } else {
            return nil
        }
    }
    
}

// MARK: - Constants

// OnTheMapService: className:
extension OnTheMapParseService {
    // OnTheMapParseServce provides StudentLocation services constant.
    static let StudentLocationClassName = "StudentLocation"
}

// MARK: - Errors {

extension OnTheMapParseService {
    
    private static let ErrorDomain = "OnTheMapParseWebClient"
    
    private enum ErrorCode: Int, CustomStringConvertible {
        case ResponseContainedNoResultObject = 1, ParseClientApiFailure
        
        var description: String {
            switch self {
            case ResponseContainedNoResultObject: return "Response data did not provide a results object."
            case ParseClientApiFailure: return "Parse Client failed to find data but also failed to provide a valid error object."
            }
        }
    }
    
    // createErrorWithCode
    // helper function to simplify creation of error object
    private static func errorForCode(code: ErrorCode) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : code.description]
        return NSError(domain: OnTheMapParseService.ErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}

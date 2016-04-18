//
//  OnTheMapParseWebClient.swift
//  onthemap_3.0
//
//  Created by gongzhen on 4/17/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

class OnTheMapParseWebClient: WebClient {
    
    func fetchStudentLocations(completionHandler: (data: NSData?, error: NSError?) -> Void) {
        
        // WebClient: createHttpGetRequestForUrlString
        // passing the location url, headers
        let request = createHttpGetRequestForUrlString(OnTheMapParseWebService.StudentLocationUrl, includeHeaders: OnTheMapParseWebService.StandardHeaders)
        
        // WebClient: executeRequest
        // passing the request
        executeRequest(request)
        { jsonData, error in
            if let error = error {
                print("Uh oh, error...\(error.description)")
            } else {
                print(jsonData)
            }
        }
    }
}

extension OnTheMapParseWebClient {
    
    struct OnTheMapParseError {
        static let Domain = "OnTheMapParseWebClient"
        static let SomeResponseDataCode = 1
        static let SomeResponseDataMessage = "some message"
    }
    
    struct OnTheMapParseWebService {
        
        static let BaseUrl = "https://api.parse.com/1/classes"
        static let StudentLocationApi = "/StudentLocation"
        static var StudentLocationUrl: String {
            return BaseUrl + StudentLocationApi
        }
        static var StandardHeaders: [String:String] {
            return [
                "X-Parse-Application-Id":"QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                "X-Parse-REST-API-Key":"QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
            ]
        }
    }
    
    struct UdacityJsonKey {
        static let Account = "account"
        static let User = "user"
        static let Key = "key"
        static let Nickname = "nickname"
        static let Firstname = "first_name"
        static let Lastname = "last_name"
    }
}
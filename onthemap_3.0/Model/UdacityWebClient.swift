//
//  UdacityWebClient.swift
//  onthemap_3.0
//
//  Created by gongzhen on 4/16/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

class UdacityWebClient: WebClient {

    struct UdacityError {
        static let Domain = "UdacityWebClient"
        static let UnexpectedResponseDataCode = 1
        static let UnexpectedResponseDataMessage = "Unexpected Response Data"
        static let InsufficientDataLengthCode = 2
        static let InsufficientDataLengthMessage = "Insufficient Data Length In Response"
    }
    
    struct UdacityWebService {
        static let BaseUrl = "https://www.udacity.com/api"
        static let SessionApi = "/session"
        static let UsersApi = "/users"
        static var SessionMethod: String {
            return BaseUrl + SessionApi
        }
        static var UsersMethod: String {
            return BaseUrl + UsersApi
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
    
    // UdacitySessionBody: return NSData from username and password.
    private func UdacitySessionBody(username: String, password: String) -> NSData {
        return "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    private func produceErrorFromResponseData(jsonData: AnyObject?) -> NSError {
        var errorObject: NSError!
        // Retrieve error message from jsonData by key "error" and errorCode from key "status"
        if let errorMessage = jsonData?.valueForKey("error") as? String,
            errorCode = jsonData?.valueForKey("status") as? Int {
                
                // createErrorWithCode: return NSError, errorCode: jsonData "status"
                errorObject = createErrorWithCode(errorCode, message: errorMessage, domain: UdacityError.Domain)
        } else {
            // very nice code here.
            errorObject = createErrorWithCode(UdacityError.UnexpectedResponseDataCode,
                message: UdacityError.UnexpectedResponseDataMessage, domain: UdacityError.Domain)
        }
        return errorObject
    }
    
    private func validateUdacityLengthRequirement(jsonData: NSData!) -> NSError? {
        if jsonData.length <= 5 {
            // struct: UdacityError. InsufficientDataLengthCode: 2. domain: UdacityWebClient
            let dataError = self.createErrorWithCode(UdacityError.InsufficientDataLengthCode,
                message: UdacityError.InsufficientDataLengthMessage, domain: UdacityError.Domain)
            return dataError
        } else {
            return nil
        }
    }
    
    func authenticateByUsername(username: String?, withPassword password: String?,
        completionHandler: (userIdentity: UserIdentity?, error: NSError?) -> Void) {
            
            // WebClient: createHttpPostRequestForUrlString return request
            // passing session method
            // body: UdacitySessionBody return NSData from username and password.
            let request = createHttpPostRequestForUrlString(UdacityWebService.SessionMethod, withBody: UdacitySessionBody(username!, password: password!))
            // WebClient:executeRequest return void
            // dataValidator: ((jsonData: NSData!) -> NSError?)?
            // completionHandler: (jsonData: AnyObject?, error: NSError?) -> Void)
            executeRequest(request, dataValidator: validateUdacityLengthRequirement) { jsonData, error in
                // jsonData not nil, then retrive "account" value from jsonData AND
                // retrieve "key" value from jsonData.
                if let account = jsonData?.valueForKey(UdacityJsonKey.Account) as? NSDictionary,
                    key = account[UdacityJsonKey.Key] as? String {
                        // Convert key to String and error is nil
                        completionHandler(userIdentity: UserIdentity(key), error: nil)
                } else {
                    // called private method: produceErrorFromResponseData to generate error.
                    completionHandler(userIdentity: nil, error: self.produceErrorFromResponseData(jsonData))
                }
        }
    }
    
    func fetchUserDataForUserIdentity(userIdentity: UserIdentity,
        completionHandler: (userData: UserData?, error: NSError?) -> Void) {
            
            // WebClient:createHttpGetRequestForUrlString return get request
            let request = createHttpGetRequestForUrlString("\(UdacityWebService.UsersMethod)/\(userIdentity)")
            
            // Check if the data length is less than 5, if True, then return error.
            executeRequest(request, dataValidator: validateUdacityLengthRequirement)
                { jsonData, error in
                    // retrive "user" key from returned jsonData
                    if let userObject = jsonData?.valueForKey(UdacityJsonKey.User) as? NSDictionary {
                        // parsing the userObject based on the jsonKey.
                        let _ = userObject.valueForKey(UdacityJsonKey.Key) as? String
                        let nickname = userObject.valueForKey(UdacityJsonKey.Nickname) as? String
                        let firstname = userObject.valueForKey(UdacityJsonKey.Firstname) as? String
                        let lastname = userObject.valueForKey(UdacityJsonKey.Lastname) as? String
                        
                        // Create UserData object and initialized its properties by jsonData.
                        let userData = UserData(userIdentity: userIdentity, nickname: nickname,
                            firstname: firstname, lastname: lastname, imageUrl: nil)
                        // call back closure from here and returned userData and error is nil.
                        completionHandler(userData: userData, error: nil)
                    } else {
                        completionHandler(userData: nil, error: self.produceErrorFromResponseData(jsonData))
                    }
            }
    }
}

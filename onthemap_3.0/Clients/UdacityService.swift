//
//  UdacityWebClient.swift
//  onthemap_3.0
//
//  Created by gongzhen on 4/16/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

// MARK: Class UdacityWebClient

// UdacityWebClient
// Provids a simple interface for interacting with the Udacity web service.
class UdacityWebClient: WebClient {
    
    // authenticate with Udacity using a username and password.
    // the user's basic identity (userid) is returned as a UserIdentity in the completionHandler.
    func authenticateByUsername(username: String?, withPassword password: String?,
        completionHandler: (userIdentity: UserIdentity?, error: NSError?) -> Void) {
            
            // WebClient: createHttpPostRequestForUrlString return request
            // passing session url string.
            // body: UdacitySessionBody return NSData from username and password.
            let request = createHttpPostRequestForUrlString(UdacityWebService.SessionUrlString,
                withBody: buildUdacitySessionBody(username!, password: password!),
                includeHeaders: UdacityWebService.StandardHeaders)

            // WebClient:executeRequest return void
            // completionHandler: (jsonData: AnyObject?, error: NSError?) -> Void)
            self.executeRequest(request) {
                jsonData, error in
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
    
    // fetch available data for the user identified by userIdentity.
    // For the logged in user, the service returns most of the available data on the user.
    // For any non-logged in user, this will return just the public data for the specified user.
    func fetchUserDataForUserIdentity(userIdentity: UserIdentity,
        completionHandler: (userData: UserData?, error: NSError?) -> Void) {
            
            // WebClient:createHttpGetRequestForUrlString return get request
            // includeHeaders: requestHeaders: [String:String]? = nil
            let request = createHttpGetRequestForUrlString("\(UdacityWebService.UsersUrlString)/\(userIdentity)")
            
            // Check if the data length is less than 5, if True, then return error.
            executeRequest(request)
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
    
    // MARK: Overrides
    
    // parseJsonFromData
    // Override in order to verify response length and to trim extraneous characters in the response,
    // specific to the UdacityWebService since it is inherited from WebClient
    override func parseJsonFromData(data: NSData) -> (jsonData: AnyObject?, error: NSError?) {
        if let lengthError = validateUdacityLengthRequirement(data) {
            return (nil, lengthError)
        }
        // WebClient: parseJsonFromData
        // passing the data with specific range.
        return super.parseJsonFromData(data.subdataWithRange(NSMakeRange(5, data.length - 5)))
    }
    
    // MARK: Private Helpers
    
    // buildUdacitySessionBody: return NSData from username and password.
    private func buildUdacitySessionBody(username: String, password: String) -> NSData {
        return "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    // used when the json body is suspected to contain an error descrptor,
    // pulls out the error message based on the Udacity error format.
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
    
    // verify response data is sufficiently long enough to sub set the extraneous characters safely,
    // otherwise return an explanatory error message for why the request will appear to have failed.
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
    

}

// MARK: - Constants

extension UdacityWebClient {
    // UdacityError: handle error
    struct UdacityError {
        static let Domain = "UdacityWebClient"
        static let UnexpectedResponseDataCode = 1
        static let UnexpectedResponseDataMessage = "Unexpected Response Data"
        static let InsufficientDataLengthCode = 2
        static let InsufficientDataLengthMessage = "Insufficient Data Length In Response"
    }
    // UdacityWebService
    // Provided web url, session api
    struct UdacityWebService {
        static let BaseUrl = "https://www.udacity.com/api"
        static let SessionApi = "/session"
        static let UsersApi = "/users"
        static let UdacityResponsePadding = 5
        static var SessionUrlString: String {
            return BaseUrl + SessionApi
        }
        static var UsersUrlString: String {
            return BaseUrl + UsersApi
        }
        static var StandardHeaders: [String:String] {
            return [
                WebClientConstant.HttpHeaderAccept:WebClientConstant.JsonContentType,
                WebClientConstant.HttpHeaderContentType:WebClientConstant.JsonContentType
            ]
        }
    }
    
    // UdacityJsonKey
    // key: value pair.
    struct UdacityJsonKey {
        static let Account = "account"
        static let User = "user"
        static let Key = "key"
        static let Nickname = "nickname"
        static let Firstname = "first_name"
        static let Lastname = "last_name"
    }
    
}

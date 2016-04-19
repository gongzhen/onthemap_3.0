//
//  UdacityService.swift
//  onthemap_3.0
//
//  Created by gongzhen on 4/16/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

// MARK: Class UdacityWebClient

// UdacityWebClient
// Provids a simple interface for interacting with the Udacity web service.
class UdacityService {
    
    private var webClient: WebClient!
    
    init() {
        webClient = WebClient()
        // UdacityService:prepareDataForParsing(data: NSData) -> NSData?
        // webClient.prepareData: closure.
        webClient.prepareData = prepareDataForParsing
    }
    
    // authenticate with Udacity using a username and password.
    // the user's basic identity (userid) is returned as a UserIdentity in the completionHandler.
    func authenticateByUsername(username: String?, withPassword password: String?,
        completionHandler: (userIdentity: UserIdentity?, error: NSError?) -> Void) {
            
            // WebClient: createHttpPostRequestForUrlString return request
            // passing session url string, body: UdacitySessionBody,  
            // return NSData from username and password.
            let request = webClient.createHttpPostRequestForUrlString(
                UdacityService.SessionUrlString,
                withBody: buildUdacitySessionBody(username!, password: password!),
                // StandardHeaders:[String: String]
                includeHeaders: UdacityService.StandardHeaders
            )

            // WebClient:executeRequest return void
            // completionHandler: (jsonData: AnyObject?, error: NSError?) -> Void)
            webClient.executeRequest(request) {
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
            let request = webClient.createHttpGetRequestForUrlString("\(UdacityService.UsersUrlString)/\(userIdentity)")
            
            // Check if the data length is less than 5, if True, then return error.
            webClient.executeRequest(request)
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
    
    // MARK: Private Helpers
    
    private func prepareDataForParsing(data: NSData) -> NSData? {
        if let lengthError = validateUdacityLengthRequirement(data) {
            Logger.error(lengthError.description)
            return nil
        }
        return data.subdataWithRange(NSMakeRange(5, data.length - 5))
    }
    
    // buildUdacitySessionBody: return NSData from username and password.
    private func buildUdacitySessionBody(username: String, password: String) -> NSData {
        return "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    // used when the json body is suspected to contain an error descrptor,
    // pulls out the error message based on the Udacity error format.
    private func produceErrorFromResponseData(jsonData: AnyObject?) -> NSError {
        // Retrieve error message from jsonData by key "error" and errorCode from key "status"
        if let errorMessage = jsonData?.valueForKey("error") as? String,
            errorCode = jsonData?.valueForKey("status") as? Int {
            // createErrorWithCode: return NSError, errorCode: jsonData "status"
            return UdacityService.errorWithMessage(errorMessage, code: errorCode)
        } else {
            // very nice code here.
            return UdacityService.errorForCode(.UnexpectedResponseData)
        }
    }
    
    // verify response data is sufficiently long enough to sub set the extraneous characters safely,
    // otherwise return an explanatory error message for why the request will appear to have failed.
    private func validateUdacityLengthRequirement(jsonData: NSData!) -> NSError? {
        if jsonData.length <=  UdacityService.UdacityResponsePadding {
            // struct: UdacityError. InsufficientDataLengthCode: 2. domain: UdacityWebClient
            return UdacityService.errorForCode(.InsufficientDataLength)
        } else {
            return nil
        }
    }
}

// MARK: - Constants

extension UdacityService {
    
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
            WebClient.HttpHeaderAccept:WebClient.JsonContentType,
            WebClient.HttpHeaderContentType:WebClient.JsonContentType
        ]
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

// MARK: - Errors {

extension UdacityService {
    
    private static let ErrorDomain = "UdacityWebClient"
    
    // enum:ErrorCode
    // codes: Unexpected Response Data error
    // Insufficient Data Length error
    private enum ErrorCode: Int, CustomStringConvertible {
        case UnexpectedResponseData, InsufficientDataLength
        
        //description: return the text message accordingly to different codes.
        var description: String {
            switch self {
            case UnexpectedResponseData:
                return "Unexpected Response Data"
            case InsufficientDataLength:
                return "Insufficient Data Length In Response"
            }
        }
    }
    
    // createErrorWithCode
    // helper function to simplify creation of error object
    // Passing the parameter: UdacityService.ErrorCode
    private static func errorForCode(code: ErrorCode) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : code.description]
        return NSError(domain: UdacityService.ErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
    
    // passing the parameters: message, errorcode:Int
    private static func errorWithMessage(message: String, code: Int) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : message]
        return NSError(domain: UdacityService.ErrorDomain, code: code, userInfo: userInfo)
    }
}


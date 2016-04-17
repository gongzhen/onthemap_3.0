//
//  UserIdentity.swift
//  onthemap_3.0
//
//  Created by gongzhen on 4/16/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

// alias: UserIdentity
typealias UserIdentity = String

struct UserData: CustomStringConvertible {
    
    // name or id identifying this user to the remote system
    var userIdentity: UserIdentity
    
    // nickname
    var nickname: String?
    
    // user first name
    var firstname: String?
    
    // user last name
    var lastname: String?
    
    // produce either gravatar or robohash
    var imageUrl: NSURL?
    
    // description: member of CustomStringConvertible that has to be implemented.
    var description: String {
        let nicknameVal = nickname ?? "null"
        let firstnameVal = firstname ?? "null"
        let lastnameVal = lastname ?? "null"
        let imageUrlVal = imageUrl?.description ?? "null"
        return "{ userIdentity: \"\(userIdentity)\", nickname: \"\(nicknameVal)\", firstname: \"\(firstnameVal)\", lastname: \"\(lastnameVal)\", imageUrl: \"\(imageUrlVal)\" }"
    }
    
}

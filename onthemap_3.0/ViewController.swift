//
//  ViewController.swift
//  onthemap_3.0
//
//  Created by gongzhen on 4/16/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    var udacityClient: UdacityWebClient!
    var onTheMapClient: OnTheMapParseWebClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        udacityClient = UdacityWebClient()
        onTheMapClient = OnTheMapParseWebClient()
    }

    @IBAction func performLogin(sender: AnyObject) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        print("login tapped")
        // UdacityWebClient: authenticateByUsername
        // passing parameters: username!: String, password!: String
        self.udacityClient.authenticateByUsername(username, withPassword: password) {
            userIdentity, error in
            
            //userIdentity is not nil then process it.
            if let userIdentity = userIdentity {
                //UdacityWebClient: fetchUserDataForUserIdentity
                // return userIdntity:String
                self.udacityClient.fetchUserDataForUserIdentity(userIdentity) {
                    userData, error in
                    print("UserData: \(userData)")
                }
            } else {
                print("Login failed with code \(error?.code) \((error?.description)!)")
            }
        }
        print("login request sent")
    }
    
    @IBAction func requestStudentLocations(sender: UIButton) {
        print("student locations tapped")
        // OnTheMapParseWebClient: fetchStudentLocations
        onTheMapClient.fetchStudentLocations() {
            data, error in
            print("nothing, probably not called yet")
        }
        print("student locations request sent")
    }

}


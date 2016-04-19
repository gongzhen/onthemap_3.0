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
    
    var udacityClient: UdacityService!
    var onTheMapClient: OnTheMapParseService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UdacityService: initialize
        // WebClient and prepareData that trim the jasonData.
        udacityClient = UdacityService()
        // OnTheMapParseService: initialize
        // parseClient with WebClient, applicationId, restApiKey
        onTheMapClient = OnTheMapParseService()
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
        // parameters: limit = 50, skip = 50
        // return the studentLocations: [StudentLocation]
        self.onTheMapClient.fetchStudentLocations(50, skip: 50) {
            studentLocations, error -> Void in
            if let studentLocations = studentLocations {
                print("found \(studentLocations.count) locations")
                print("First item name is \(studentLocations[0].firstname)")
            }
        }
        print("student locations request sent")
    }
}


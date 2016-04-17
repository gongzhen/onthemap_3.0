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
    
    var webClient: UdacityWebClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webClient = UdacityWebClient()
    }

    @IBAction func performLogin(sender: AnyObject) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        print("login tapped")
        // UdacityWebClient: authenticateByUsername
        // passing parameters: username!: String, password!: String
        webClient.authenticateByUsername(username, withPassword: password) {
            userIdentity, error in
            
            //userIdentity is not nil then process it.
            if let userIdentity = userIdentity {
                //UdacityWebClient: fetchUserDataForUserIdentity
                // return userIdntity:String
                self.webClient.fetchUserDataForUserIdentity(userIdentity) {
                    userData, error in
                    print("UserData: \(userData)")
                }
            } else {
                print("Login failed with code \(error?.code) \(error?.description)")
            }
        }
        print("login request sent")
        
    }

}


//
//  ViewController.swift
//  PicQurate
//
//  Created by SongXujie on 17/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.fbLoginButton.delegate = self;
        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        NSLog(result.description);
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        NSLog("Facebook user logged out");
    }

}


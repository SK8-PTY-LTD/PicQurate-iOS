//
//  SignUpViewController.swift
//  PicQurate
//
//  Created by SongXujie on 24/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func loginButtonClicked(sender: UIButton) {
        //Check if it's already signing up
        if activityIndicator.isAnimating() {
            return
        }
        //Check if sign up criteria is good enough
        var email : String = self.emailTextField.text;
        if (!StringIsValidEmail(email)) {
            return
        }
        var passWord = self.passwordTextField.text;
        
        activityIndicator.startAnimating()
        
        //If it's logging in/Signing up, and criteria is good
        PQUser.logInWithUsernameInBackground(email, password: passWord) { (user, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
                var user = user as! PQUser;
                PQ.currentUser = user;
                NSLog("Email user log in successful");
                if let method = PQ.delegate?.onUserRefreshed {
                    method();
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.activityIndicator.stopAnimating();
        }
    }
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem!) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    func StringIsValidEmail(email : String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        var emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(email)
        if result {
            return result
        } else {
            var alert = UIAlertView()
            alert.message = "Please enter a valid email!"
            alert.addButtonWithTitle("OK!")
            alert.show()
            return result
        }
    }
    
}
//
//  SignUpViewController.swift
//  PicQurate
//
//  Created by SongXujie on 23/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation


class SignupViewController: UIViewController, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderSegmentControl: UISegmentedControl!;
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func signupButtonClicked(sender: UIButton) {
        //Check if it's already signing up
        if (activityIndicator.isAnimating()) {
            return
        }
        //Check if sign up criteria is good enough
        var email : String = self.emailTextField.text;
        if (!StringIsValidEmail(email)) {
            return
        }
        
        var passWord = self.passwordTextField.text;
        if (count(passWord) < 8) {
            var alert = UIAlertView()
            alert.message = "Please choose a longer password, minimum 8 character"
            alert.addButtonWithTitle("OK!")
            alert.show()
            return
        }
        
        var username = self.usernameTextField.text;
        
        //If it's logging in/Signing up, and criteria is good
        activityIndicator.startAnimating()
        
        //Saving profile image
        var user = PQUser(email: email, password: passWord, profileName: username);
        if (self.genderSegmentControl.selectedSegmentIndex == 0) {
            user.setObject("male", forKey: "gender");
        } else if (self.genderSegmentControl.selectedSegmentIndex == 1) {
            user.setObject("female", forKey: "gender");
        }
        //        user.setProfileImage(slider.slider.currentBackgroundImage!);
        user.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
                var user = PQUser.currentUser();
                user.refresh();
                if let image = self.profileImageButton.imageForState(.Normal) {
                    if image != UIImage(named: "default_profile") {
                        user.setProfileImage(image);
                    }
                }
                PQ.currentUser = user;
                NSLog("Email user sign up successful");
                if let method = PQ.delegate?.onUserRefreshed {
                    method();
                }
                self.dismissViewControllerAnimated(true, completion: nil);
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
    
    @IBAction func profileImageViewClicked(sender: UIButton) {
        //Check if sign up criteria is good enough
        var alert = UIActionSheet();
        alert.title = "Pick your profile image from: "
        alert.delegate = self
        alert.addButtonWithTitle("Camera")
        alert.addButtonWithTitle("Photo Albums")
        alert.addButtonWithTitle("Cancel")
        alert.showInView(self.view.superview);
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            var picker = UIImagePickerController();
            picker.delegate = self;
            picker.allowsEditing = true;
            picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera)!;
            picker.sourceType = UIImagePickerControllerSourceType.Camera;
            self.presentViewController(picker, animated: true, completion: nil);
        } else if (buttonIndex == 1) {
            var picker = UIImagePickerController();
            picker.delegate = self;
            picker.allowsEditing = true;
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            self.presentViewController(picker, animated: true, completion: nil);
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.profileImageButton.setImage(image, forState: .Normal);
        picker.dismissViewControllerAnimated(true, completion: nil);
    }

    

}
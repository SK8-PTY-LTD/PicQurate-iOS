//
//  EditProfileViewController.swift
//  PicQurate
//
//  Created by SongXujie on 2/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import CoreLocation

class EditProfileViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var realNameTextField: UITextField!
    @IBOutlet weak var profileNameTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        //Display user info
        if let file = PQ.currentUser.profileImage {
            self.profileImageButton.setBackgroundImage(UIImage(data: file.getData()), forState: .Normal);
        }
        
    }
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //Do nothing
        });
    }
    
    @IBAction func saveButtonClicked(sender: UIBarButtonItem) {
        //Save user info
        PQ.currentUser.setProfileUIImage(self.profileImageButton.backgroundImageForState(.Normal)!);
        PQ.currentUser.realName = self.realNameTextField.text;
        PQ.currentUser.profileName = self.profileNameTextField.text;
        if let urlString = self.urlTextField.text {
            if urlString.hasPrefix("http://") {
                PQ.currentUser.url = urlString;
            } else if urlString.hasPrefix("https://") {
                PQ.currentUser.url = urlString;
            } else {
                PQ.currentUser.url = "http://" + urlString;
            }
        }
        PQ.currentUser.bio = self.bioTextView.text;
        PQ.currentUser.email = self.emailTextField.text;
        PQ.currentUser.username = self.emailTextField.text;
//        if (PQ.currentUser.gender) {
//            self.genderTextField.text = "Male";
//        } else {
//            self.genderTextField.text = "Female";
//        }
        PQ.currentUser.saveInBackground();
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //Do nothing
        });
    }
    
    @IBAction func locationButtonClicked() {
        getLocation();
    }
    
    func getLocation() {
        self.locationManager.requestWhenInUseAuthorization();
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.startUpdatingLocation();
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        //Authorization status changed, get location
        //        if (CLAuthorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse || CLAuthorizationStatus == CLAuthorizationStatus.AuthorizedAlways) {
        //            getLocation();
        //        }
        getLocation();
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        PQ.showError(error);
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var newLocation = locations.last as! CLLocation;
        NSLog("Got location: \(newLocation.coordinate.latitude) \(newLocation.coordinate.longitude)");
        manager.stopUpdatingLocation();
        //Get place mark
        var geoCoder = CLGeocoder();
        geoCoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) -> Void in
            if let e = error {
                NSLog(e.localizedDescription);
            } else {
                for (var i = 0; i < placemarks.count; i++) {
                    var placemark = placemarks[i] as! CLPlacemark;
                    var geoPoint = AVGeoPoint(latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude);
                    PQ.currentUser.location = geoPoint;
                    PQ.currentUser.locationString = "\(placemark.administrativeArea), \(placemark.country)";
                    PQ.currentUser.saveEventually();
                    self.locationButton.setTitle(PQ.currentUser.locationString, forState: .Normal);
                }
            }
        })
    }
    
    @IBAction func logoutButtonClicked(sender: UIButton) {
        AVUser.logOut();
        var fbLoginManager = FBSDKLoginManager();
        fbLoginManager.logOut();
        PQ.currentUser = nil;
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //Do nothing
        });
    }
    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder();
//        return true;
//    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 1) {
            return 64.0;
        } else {
            return 32.0;
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4;
        case 1:
            return 1;
        case 2:
            return 2;
        default:
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("EditProfileTableViewTextFieldCell") as! EditProfileTableViewCell;
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                self.realNameTextField = cell.textfield;
                self.realNameTextField.text = PQ.currentUser.realName;
                cell.textfield.placeholder = "Full Name";
            case 1:
                self.profileNameTextField = cell.textfield;
                self.profileNameTextField.text = PQ.currentUser.profileName;
                cell.textfield.placeholder = "Username";
            case 2:
                self.urlTextField = cell.textfield;
                self.urlTextField.text = PQ.currentUser.url;
                cell.textfield.placeholder = "Website";
            case 3:
                cell = tableView.dequeueReusableCellWithIdentifier("EditProfileTableViewButtonCell") as! EditProfileTableViewCell;
                self.locationButton = cell.button;
                self.locationButton.setTitle(PQ.currentUser.locationString, forState: .Normal);
            default:
                break;
            }
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("EditProfileTableViewTextViewCell") as! EditProfileTableViewCell;
            self.bioTextView = cell.textView;
            self.bioTextView.text = PQ.currentUser.bio;
        case 2:
            switch indexPath.row {
            case 0:
                self.emailTextField = cell.textfield;
                self.emailTextField.text = PQ.currentUser.email;
                cell.textfield.placeholder = "Email";
            case 1:
                self.genderTextField = cell.textfield;
                if (PQ.currentUser.gender) {
                    self.genderTextField.text = "Male";
                } else {
                    self.genderTextField.text = "Female";
                }
                self.genderTextField.placeholder = "Gender";
            default:
                break;
            }
        default:
            break;
        }
        return cell;
    }
    
}
//
//  EditProfileViewController.swift
//  PicQurate
//
//  Created by SongXujie on 2/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import CoreLocation

class EditProfileViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var realNameTextField: UITextField!
    @IBOutlet weak var profileNameTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    
    var locationButton: UIButton!
    var genderButton: UIButton!
    var genderImageView: UIImageView!
    
    let locationManager = CLLocationManager();
    let imagePickerController = UIImagePickerController();
    var isFullScreen = false;
    
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
        PQ.currentUser.saveInBackground();
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //Do nothing
        });
    }
    
    func getLocation() {
        if (self.locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization"))) {
            self.locationManager.requestWhenInUseAuthorization();
        }
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.startUpdatingLocation();
    }
    
    func chagneGender() {
        if (PQ.currentUser.gender as Bool) {
            PQ.currentUser.gender = false as Bool;
            self.genderButton.setTitle("Female", forState: .Normal);
            self.genderImageView.image = UIImage(named: "profile_female_icon");
        } else {
            PQ.currentUser.gender = true as Bool;
            self.genderButton.setTitle("Male", forState: .Normal);
            self.genderImageView.image = UIImage(named: "profile_male_icon");
        }
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
        PQ.currentUser = PQUser();
        var fbLoginManager = FBSDKLoginManager();
        fbLoginManager.logOut();
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            AVAnonymousUtils.logInWithBlock { (anonymousUser, error) -> Void in
                PQ.currentUser = PQUser.currentUser();
            }
        });
    }
    
    
    @IBAction func profileImageButtonClicked(sender: UIButton) {
        self.imagePickerController.delegate = self;
        self.imagePickerController.allowsEditing = true;
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet);
            var popover = alertController.popoverPresentationController;
            if (popover != nil){
                popover?.sourceView = sender;
                popover?.sourceRect = sender.bounds;
                popover?.permittedArrowDirections = UIPopoverArrowDirection.Any;
            }
            
            let cameraAction: UIAlertAction = UIAlertAction(title: "take a photo", style: .Default) { (action: UIAlertAction!) -> Void in
                self.imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera;
                self.presentViewController(self.imagePickerController, animated: true, completion: nil);
            }
            alertController.addAction(cameraAction);
            
            let photoLibraryAction: UIAlertAction = UIAlertAction(title: "choose from gallery", style: .Default) { (action: UIAlertAction!) -> Void in
                self.imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                self.imagePickerController.navigationBar.barTintColor = UIColor(red: 171/255, green: 202/255, blue: 41/255, alpha: 1.0);
                self.imagePickerController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()];
                self.imagePickerController.navigationBar.tintColor = UIColor.whiteColor();
                self.presentViewController(self.imagePickerController, animated: true, completion: nil);
            }
            alertController.addAction(photoLibraryAction);
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
            alertController.addAction(cancelAction);
            
            presentViewController(alertController, animated: true, completion: nil);
            
        }else{
            let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet);
            var popover = alertController.popoverPresentationController
            if (popover != nil){
                popover?.sourceView = sender;
                popover?.sourceRect = sender.bounds;
                popover?.permittedArrowDirections = UIPopoverArrowDirection.Any;
            }
            
            let photoLibraryAction: UIAlertAction = UIAlertAction(title: "choose from gallery", style: .Default) { (action: UIAlertAction!) -> Void in
                self.imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                self.imagePickerController.navigationBar.barTintColor = UIColor(red: 171/255, green: 202/255, blue: 41/255, alpha: 1.0);
                self.imagePickerController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()];
                self.imagePickerController.navigationBar.tintColor = UIColor.whiteColor();
                self.presentViewController(self.imagePickerController, animated: true, completion: nil);
            }
            alertController.addAction(photoLibraryAction);
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: .Cancel, handler: nil);
            alertController.addAction(cancelAction);
            
            presentViewController(alertController, animated: true, completion: nil);
        }

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil);
        var image:UIImage!
        if(picker.allowsEditing){
            image = info[UIImagePickerControllerEditedImage] as! UIImage
        } else {
            image = info[UIImagePickerControllerEditedImage] as! UIImage
        }
        self.saveImage(image, newSize: CGSize(width: 640, height: 640), percent: 0.5, imageName: "currentImage.png")
        let fullPath: String = NSHomeDirectory().stringByAppendingPathComponent("Documents").stringByAppendingPathComponent("currentImage.png")
        println("fullPath=\(fullPath)")
        let savedImage: UIImage = UIImage(contentsOfFile: fullPath)!
        self.isFullScreen = false
        //save image to server
        PQ.currentUser.setProfileUIImage(image);
        self.profileImageButton.setBackgroundImage(image, forState: .Normal);
    }
    
    func saveImage(currentImage: UIImage, newSize: CGSize, percent: CGFloat, imageName: String){
        UIGraphicsBeginImageContext(newSize)
        currentImage.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageData: NSData = UIImageJPEGRepresentation(newImage, percent)
        let fullPath: String = NSHomeDirectory().stringByAppendingPathComponent("Documents").stringByAppendingPathComponent(imageName)
        imageData.writeToFile(fullPath, atomically: false)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 1) {
            return 64.0;
        } else {
            return 40.0;
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
                cell.imageView?.image = UIImage(named: "profile_fullname_icon");
            case 1:
                self.profileNameTextField = cell.textfield;
                self.profileNameTextField.text = PQ.currentUser.profileName;
                cell.textfield.placeholder = "Username";
                cell.imageView?.image = UIImage(named: "profile_username_icon");
            case 2:
                self.urlTextField = cell.textfield;
                self.urlTextField.text = PQ.currentUser.url;
                cell.textfield.placeholder = "Website";
                cell.imageView?.image = UIImage(named: "profile_website_icon");
            case 3:
                cell = tableView.dequeueReusableCellWithIdentifier("EditProfileTableViewButtonCell") as! EditProfileTableViewCell;
                self.locationButton = cell.button;
                self.locationButton.setTitle(PQ.currentUser.locationString, forState: .Normal);
                self.locationButton.addTarget(self, action: "getLocation", forControlEvents: UIControlEvents.TouchUpInside);
                cell.imageView?.image = UIImage(named: "profile_location_icon");
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
                cell.imageView?.image = UIImage(named: "profile_email_icon");
            case 1:
                cell = tableView.dequeueReusableCellWithIdentifier("EditProfileTableViewButtonCell") as! EditProfileTableViewCell;
                self.genderButton = cell.button;
                self.genderButton.addTarget(self, action: "chagneGender", forControlEvents: UIControlEvents.TouchUpInside);
                self.genderImageView = cell.imageView;
                if (PQ.currentUser.gender as Bool) {
                    self.genderButton.setTitle("Male", forState: .Normal);
                    self.genderImageView.image = UIImage(named: "profile_male_icon");
                } else {
                    self.genderButton.setTitle("Female", forState: .Normal);
                    self.genderImageView.image = UIImage(named: "profile_female_icon");
                }
            default:
                break;
            }
        default:
            break;
        }
        return cell;
    }
    
}
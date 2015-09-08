//
//  ProfileViewController.swift
//  PicQurate
//
//  Created by SongXujie on 1/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import CoreLocation

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ProfileCollectionViewSegmentCellDelegate, ProfileHeaderCollectionReusableViewDelegate, CLLocationManagerDelegate, PhotoToProfileProtocol, PQProtocol {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var flowLayout: CSStickyHeaderFlowLayout!
    var headerView: ProfileHeaderCollectionReusableView!
    
    var user: PQUser?;
    var imageArray: [PQPhoto] = [PQPhoto]();
    var column: Int = 1;
    
    var locationArray: [AVGeoPoint] = [];
    var locationNameArray: [String]  = [];
    
    let locationManager = CLLocationManager()
    
    var index = 0;
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        self.collectionView.reloadData();
        //Anonymous user does not have an email
        if (PQ.currentUser.email == nil) {
            return;
        }
        
        self.refreshLocation();
        
        
        //Reload user information
        if let user = self.user {
            if (user.isUser(PQ.currentUser)) {
                
            } else {
                //Display other user information
                self.navigationItem.rightBarButtonItem = nil;
            }
        } else {
            self.user = PQ.currentUser;
        }
        
        self.flowLayout = self.collectionView.collectionViewLayout as! CSStickyHeaderFlowLayout;
        self.flowLayout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.width, 280);
        
        var headerNib = UINib(nibName: "ProfileHeaderCollectionReusableView", bundle: nil);
        self.collectionView.registerNib(headerNib, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "header");
    }
    
    @IBAction func loginButtonClicked(sender: UIButton) {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.performSegueWithIdentifier("segueToLogin", sender: nil);
    }
    
    override func viewDidAppear(animated: Bool) {
        
        PQ.delegate = self;
        
        //Reload user information
        if let user = self.user {
            if (PQ.currentUser.email == nil) {
                self.collectionView.hidden = true;
            } else {
                if (user.isUser(PQ.currentUser)) {
                } else {
                    //Display other user information
                    self.navigationItem.rightBarButtonItem = nil;
                }
                self.collectionView.hidden = false;
            }
        } else {
            self.collectionView.hidden = true;
        }
        
        if let user = self.user {
            switch self.index{
            case 0:
                self.queryPhotoByHistory();
                self.index = 0;
            case 1:
                self.queryPhotoByChain();
                self.index = 1;

            case 2:
                self.queryPhotoByLike();
                self.index = 2;
            default:
                break;
            }
            self.headerView?.initWithUser(user);
        }
    }
    
    func segmentSelected(index: Int) {
        switch index {
        case 0:
            queryPhotoByHistory();
            self.index = 0;
        case 1:
            queryPhotoByChain();
            self.index = 1;
        case 2:
            queryPhotoByLike();
            self.index = 2;
        default:
            break;
        }
    }
    
    func queryPhotoByHistory() {
        var query = PQPhoto.query();
        query.whereKey("user", equalTo: user);
        query.includeKey("user.profileImage");
        query.orderByDescending("createdAt");
        query.findObjectsInBackgroundWithBlock({ (array, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
                if let a = array as? [PQPhoto] {
                    self.imageArray = a;
                    self.setColumns(2);
                } else {
                    PQLog.e("Error downcasting [AnyObject!] to [PQPhoto]");
                }
            }
        });
    }
    
    func queryPhotoByChain() {
        var query = PQPhoto.query();
        query.whereKey("user", equalTo: user);
        query.orderByDescending("chain");

        query.findObjectsInBackgroundWithBlock({ (array, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
                if let a = array as? [PQPhoto] {
                    self.imageArray = a;
                    self.setColumns(1);
                } else {
                    PQLog.e("Error downcasting [AnyObject!] to [PQPhoto]");
                }
            }
        });
    }
    
    func queryPhotoByLike() {
        var query = PQPhoto.query();
        query.whereKey("user", equalTo: user);
        query.orderByDescending("chain");
        query.findObjectsInBackgroundWithBlock({ (array, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
                if let a = array as? [PQPhoto] {
                    self.imageArray = a;
                    self.setColumns(1);
                } else {
                    PQLog.e("Error downcasting [AnyObject!] to [PQPhoto]");
                }
            }
        });
    }
    
    func setColumns(numberOfColumns: Int) {
        self.column = numberOfColumns;
        var itemWidth = self.view.frame.size.width / CGFloat(self.column);
        if let layout = self.flowLayout {
            if (self.column != 1) {
                layout.itemSize = CGSizeMake(itemWidth-1, itemWidth-1);
            } else {
                layout.itemSize = CGSizeMake(itemWidth, itemWidth + 120);
            }
        }
        self.collectionView.reloadData();
        self.collectionView.layoutIfNeeded();
    }
    
    @IBAction func editButtonClicked(sender: UIBarButtonItem) {
        if (PQ.currentUser != nil && PQ.currentUser.email != nil) {
            self.performSegueWithIdentifier("editProfileSegue", sender: nil);
        } else {
            var VC = self.parentViewController?.parentViewController as! TabViewController;
            VC.performSegueWithIdentifier("segueToLogin", sender: nil);
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if (kind == CSStickyHeaderParallaxHeader) {
            // Config Collection View header
            if let cell = self.headerView {
                return cell;
            } else {
                self.headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! ProfileHeaderCollectionReusableView;
                if let user = self.user {
                    self.headerView.initWithUser(user);
                    self.headerView.delegate = self;
                    return self.headerView;
                } else {
                    return UICollectionReusableView();
                }

            }
        } else if (kind == UICollectionElementKindSectionHeader) {
            // Config Collection View section header
            var cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "sectionHeader", forIndexPath: indexPath) as! ProfileCollectionViewSegmentCell;
            cell.delegate = self;
            return cell;
        } else {
            // other custom supplementary views
            return UICollectionReusableView();
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (self.column == 1) {
            var cell = collectionView.dequeueReusableCellWithReuseIdentifier("profileViewCell", forIndexPath: indexPath) as! PQPhotoCollectionViewCell;
            var photo = self.imageArray[indexPath.row];
            cell.initializeWithPhoto(photo);
            cell.delegate = self
            return cell;
        } else {
            var cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageViewCell", forIndexPath: indexPath) as! PQPhotoCollectionViewCell;
            var photo = self.imageArray[indexPath.row];
            cell.initializeWithPhoto(photo);
            return cell;
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var photo = self.imageArray[indexPath.row];
        self.performSegueWithIdentifier("segueToPhoto", sender: photo);
    }
    
    func refreshLocation() {
        if (self.locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization"))) {
            self.locationManager.requestWhenInUseAuthorization();
        }
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.startUpdatingLocation();
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        refreshLocation();
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
//        PQ.showError(error);
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
                    if (PQ.currentUser.email != nil) {
                        PQ.currentUser.location = geoPoint;
                        PQ.currentUser.locationString = "\(placemark.administrativeArea), \(placemark.country)";
                        PQ.currentUser.saveEventually();
                    }
                }
            }
        })
    }
    
    func followerButtonClicked() {
        var query = AVUser.followerQuery(self.user?.objectId);
        self.performSegueWithIdentifier("segueToUserTableView", sender: [query, "Follower"]);
    }
    
    func followeeButtonClicked() {
        var query = AVUser.followeeQuery(self.user?.objectId);
        self.performSegueWithIdentifier("segueToUserTableView", sender: [query, "Following"]);
    }
    
    func showLocation(locationArray: [AVGeoPoint], locationNameArray: [String]) {
        self.locationArray = locationArray;
        self.locationNameArray = locationNameArray;
        self.performSegueWithIdentifier("segueToMap", sender: self);
    }
    func showLike(query: AnyObject) {
        self.performSegueWithIdentifier("segueToLike", sender: query);
    }
    func showProfile(user: PQUser) {
        self.performSegueWithIdentifier("segueToProfile", sender: user);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToUserTableView") {
            var VC = segue.destinationViewController as! UserTableViewController;
            VC.query = (sender as! [AnyObject])[0] as! AVQuery;
            VC.title = (sender as! [AnyObject])[1] as? String;
        } else if (segue.identifier == "segueToPhoto"){
            var VC = segue.destinationViewController as! PhotoViewController;
            VC.photo = sender as! PQPhoto;
        } else if (segue.identifier == "segueToMap") {
            var VC = segue.destinationViewController as! MapViewController;
            VC.locationArray = self.locationArray;
            VC.locationNameArray = self.locationNameArray;
        } else if(segue.identifier == "segueToLike"){
            var VC = segue.destinationViewController as! UserTableViewController;
            VC.title = "Like"
            VC.query = sender as! AVQuery;
        } else if(segue.identifier == "segueToProfile"){
            var VC = segue.destinationViewController as! ProfileViewController;
            VC.user = sender as! PQUser;
        }
    }
    
    func onUserRefreshed() {
        self.user = PQ.currentUser;
    }
    
}
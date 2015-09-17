//
//  NewsViewController.swift
//  PicQurate
//
//  Created by SongXujie on 10/08/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class NewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ActivityToProfileProtocol, PhotoToProfileProtocol, PQProtocol {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var likedButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    
    var flowLayout: CSStickyHeaderFlowLayout!
    var column: Int = 1;
    
    var photoList = [PQPhoto]();
    var pushList = [PQPush]();
    var profileUser: PQUser?;
    var locationArray: [AVGeoPoint] = [];
    var locationNameArray: [String]  = [];
    
    var selectedTab = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.flowLayout = self.collectionView.collectionViewLayout as! CSStickyHeaderFlowLayout;
        
        //Anonymous user does not have an email
        if (PQ.currentUser.email == nil) {
            return;
        }
        
        
        self.refreshFolloweeSection();
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        PQ.delegate = self;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedTab {
        case 0:
            return photoList.count;
        case 1:
            return photoList.count;
        case 2:
            return pushList.count;
        default:
            return 0;
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch selectedTab {
        case 0:
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("profileViewCell", forIndexPath: indexPath) as! PQPhotoCollectionViewCell;
            cell.initializeWithPhoto(photoList[indexPath.row]);
            cell.delegate = self
            return cell;
        case 1:
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("imageViewCell", forIndexPath: indexPath) as! PQPhotoCollectionViewCell;
            cell.initializeWithPhoto(photoList[indexPath.row]);
            return cell;
        case 2:
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("activityViewCell", forIndexPath: indexPath) as! PQActivityCollectionViewCell;
            if pushList.count != 0 {
                cell.initializeWithActivity(pushList[indexPath.row]);
                cell.delegate = self
            }
            return cell;
        default:
            return UICollectionViewCell();
        }
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        
//        switch selectedTab{
//            
//        }
//        return CGSizeMake(270, 300)
//    }
    
    func refreshFolloweeSection() {
        // Find all followee
        selectedTab = 0;
        NSLog("following Button Pressed");
        let followeeQuery = AVQuery(className: "_Followee");
        followeeQuery.whereKey("user", equalTo: PQ.currentUser);
        
        // Find all posts by followee
        let photoQuery = PQPhoto.query();
        photoQuery.orderByDescending("createdAt");
        photoQuery.whereKey("user.id", matchesKey: "followee.id", inQuery: followeeQuery);
        photoQuery.includeKey("user");
        photoQuery.findObjectsInBackgroundWithBlock { (list, error) -> Void in
            if let e = error {
                NSLog(e.localizedDescription);
            } else {
                if let l = list as? [PQPhoto] {
                    NSLog("Follow Photo downloaded \(l.count)");
                    self.photoList = l;
                    self.setColumns(1);
                } else {
                    NSLog("Error downcasting list to photoList");
                }
            }
        }
    }
    
    func refreshLikedSection() {
        NSLog("like Button Pressed");
        selectedTab = 1;
        // Find all liked photos
        let likedPhotoQuery = PQ.currentUser.relationforKey("photoLiked").query();
        likedPhotoQuery.orderByDescending("createdAt");
        likedPhotoQuery.includeKey("user");
        likedPhotoQuery.findObjectsInBackgroundWithBlock { (list, error) -> Void in
            if let e = error {
                NSLog(e.localizedDescription);
            } else {
                if let l = list as? [PQPhoto] {
                    NSLog("Like Photo downloaded \(l.count)");
                    self.photoList = l;
                    self.setColumns(2);
                } else {
                    NSLog("Error downcasting list to photoList");
                }
            }
        }
    }
    
    func refreshActivitySection() {
        NSLog("activity Button Pressed");
        selectedTab = 2;
        let query = PQPush.query();
        query.whereKey("user", equalTo: PQ.currentUser);
        query.orderByDescending("createdAt");
        query.includeKey("user");
        query.includeKey("sender");
        query.includeKey("photo");
        query.includeKey("photo.file");
        query.findObjectsInBackgroundWithBlock { (list, error) -> Void in
            if let e = error {
                NSLog(e.localizedDescription);
            } else {
                if let l = list as? [PQPush] {
                    NSLog("Push downloaded \(l.count)");
                    self.pushList = l;
                    self.setColumns(1);
                } else {
                    NSLog("Error downcasting list to photoList");
                }
            }
        }
    }
    
    @IBAction func sectionSelected(sender: UIButton) {
        switch sender {
        case followingButton:
            refreshFolloweeSection();
            followingButton.setTitleColor(UIColor(hex: "#BE0004"), forState: .Normal);
            likedButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal);
            activityButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal);
            break;
        case likedButton:
            refreshLikedSection();
            followingButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal);
            likedButton.setTitleColor(UIColor(hex: "#BE0004"), forState: .Normal);
            activityButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal);
        case activityButton:
            refreshActivitySection();
            followingButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal);
            likedButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal);
            activityButton.setTitleColor(UIColor(hex: "#BE0004"), forState: .Normal);
        default:
            break;
        }
    }
    
    func setColumns(numberOfColumns: Int) {
        self.column = numberOfColumns;
        let itemWidth = self.view.frame.size.width / CGFloat(self.column);
        if let layout = self.flowLayout {
            if (self.column != 1 ) {
                layout.itemSize = CGSizeMake(itemWidth, itemWidth);
            } else  if (selectedTab == 0 ){
                layout.itemSize = CGSizeMake(itemWidth, itemWidth + 120);
            } else {
                layout.itemSize = CGSizeMake(itemWidth, 80);
            }
        }
        self.collectionView.reloadData();
        self.collectionView.layoutIfNeeded();
    }
    
    func showProfile(user: PQUser){
        self.performSegueWithIdentifier("segueToProfile", sender: user)
        profileUser = user;
        NSLog("user: \(user)");
    }
    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("activityViewCell", forIndexPath: indexPath) as! PQActivityCollectionViewCell
//        cell.profileNameButton.addTarget(self, action: "profileNameButtonToProfile:", forControlEvents: UIControlEvents.TouchUpInside);
//        
//    }
//    
//    func profileNameButtonToProfile(sender: UIButton){
////        let profileName = sender.activity.sender;
//        let point = sender.convertPoint(CGPointZero, toView: self.collectionView);
//        let indexPath = self.collectionView.indexPathForItemAtPoint(point)
//        let user = pushList[indexPath!.row].sender;
//        self.performSegueWithIdentifier("segueToProfile", sender: user);
//    }
    
    func showLocation(locationArray: [AVGeoPoint], locationNameArray: [String]) {
        self.locationArray = locationArray;
        self.locationNameArray = locationNameArray;
        self.performSegueWithIdentifier("segueToMap", sender: self);
    }
    func showLike(query: AnyObject) {
        self.performSegueWithIdentifier("segueToLike", sender: query);
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "segueToProfile"){
            let VC = segue.destinationViewController as! ProfileViewController;
            VC.user = sender as? PQUser;
            NSLog("profileUser: \(profileUser)");
//            VC.user = profileUser
        } else if (segue.identifier == "segueToMap") {
            let VC = segue.destinationViewController as! MapViewController;
            VC.locationArray = self.locationArray;
            VC.locationNameArray = self.locationNameArray;
        } else if(segue.identifier == "segueToLike"){
            let VC = segue.destinationViewController as! UserTableViewController;
            VC.title = "Like"
            VC.query = sender as! AVQuery;
        }
    }
    
    func onUserRefreshed() {
        //When user login
        self.viewDidLoad();
    }
}
//
//  NewsViewController.swift
//  PicQurate
//
//  Created by SongXujie on 10/08/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class NewsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var likedButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    
    var flowLayout: CSStickyHeaderFlowLayout!
    var column: Int = 1;
    
    var photoList = [PQPhoto]();
    var pushList = [PQPush]();
    
    var selectedTab = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.flowLayout = self.collectionView.collectionViewLayout as! CSStickyHeaderFlowLayout;
        
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
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch selectedTab {
        case 0:
            var cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("imageViewCell", forIndexPath: indexPath) as! PQPhotoCollectionViewCell;
            cell.initializeWithPhoto(photoList[indexPath.row]);
            return cell;
        case 1:
            var cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("profileViewCell", forIndexPath: indexPath) as! PQPhotoCollectionViewCell;
            cell.initializeWithPhoto(photoList[indexPath.row]);
            return cell;
//        case 2:
//            var cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("imageViewCell", forIndexPath: indexPath) as! PQPhotoCollectionViewCell;
//            cell.initializeWithPhoto(photoList[indexPath.row]);
//            return cell;
        default:
            return UICollectionViewCell();
        }
    }
    
    func refreshFolloweeSection() {
        // Find all followee
        var followeeQuery = AVQuery(className: "_Followee");
        followeeQuery.whereKey("user", equalTo: PQ.currentUser);
        
        // Find all posts by followee
        var photoQuery = PQPhoto.query();
        photoQuery.whereKey("user.id", matchesKey: "followee.id", inQuery: followeeQuery);
        photoQuery.findObjectsInBackgroundWithBlock { (list, error) -> Void in
            if let e = error {
                NSLog(e.localizedDescription);
            } else {
                if let l = list as? [PQPhoto] {
                    self.photoList = l;
                    self.setColumns(1);
                } else {
                    NSLog("Error downcasting list to photoList");
                }
            }
        }
    }
    
    func refreshLikedSection() {
        // Find all liked photos
        var likedPhotoQuery = PQ.currentUser.relationforKey("photoLiked").query();
        likedPhotoQuery.findObjectsInBackgroundWithBlock { (list, error) -> Void in
            if let e = error {
                NSLog(e.localizedDescription);
            } else {
                if let l = list as? [PQPhoto] {
                    self.photoList = l;
                    self.setColumns(1);
                } else {
                    NSLog("Error downcasting list to photoList");
                }
            }
        }
    }
    
    func refreshActivitySection() {
        var query = PQPush.query();
        query.whereKey("user", equalTo: PQ.currentUser);
        query.findObjectsInBackgroundWithBlock { (list, error) -> Void in
            if let e = error {
                NSLog(e.localizedDescription);
            } else {
                if let l = list as? [PQPush] {
                    self.pushList = l;
                    self.setColumns(2);
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
            followingButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal);
            likedButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal);
            activityButton.setTitleColor(UIColor(hex: "#BE0004"), forState: .Normal);
        default:
            break;
        }
    }
    
    func setColumns(numberOfColumns: Int) {
        self.column = numberOfColumns;
        var itemWidth = self.view.frame.size.width / CGFloat(self.column);
        if let layout = self.flowLayout {
            if (self.column != 1) {
                layout.itemSize = CGSizeMake(itemWidth, itemWidth);
            } else {
                layout.itemSize = CGSizeMake(itemWidth, itemWidth + 120);
            }
        }
        self.collectionView.reloadData();
        self.collectionView.layoutIfNeeded();
    }
    
    
    
}
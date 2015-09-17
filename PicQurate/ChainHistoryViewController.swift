//
//  ChainHistoryViewController.swift
//  PicQurate
//
//  Created by SongXujie on 6/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class ChainHistoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var popularButton: UIButton!
    var flowLayout: CSStickyHeaderFlowLayout!
    var column = 2;
    
    var photoArray: [PQPhoto] = [PQPhoto]();
    
    override func viewDidLoad() {
        
        //Set up collection view
        self.flowLayout = self.collectionView.collectionViewLayout as! CSStickyHeaderFlowLayout;
        
        let itemWidth = self.view.frame.size.width / CGFloat(self.column);
        if (self.column != 1) {
            self.flowLayout.itemSize = CGSizeMake(itemWidth-1, itemWidth-1);
        } else {
            self.flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth + 120);
        }
        self.collectionView.reloadData();
        self.collectionView.layoutIfNeeded();
        
        self.navigationItem.title = "Chained Photos";
        
        self.queryPhotoByDate();
    }
    
    func queryPhotoByDate() {
        let query = PQPhoto.query();
        query.orderByDescending("createdAt");
        query.whereKey("user", equalTo: PQ.currentUser);
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
                if let a = array as! [PQPhoto]! {
                    self.photoArray = a;
                    self.collectionView.reloadData();
                } else {
                    NSLog("Error downcasting [AnyObject] to [PQPhoto]");
                }
            }
        }
    }
    
    func queryPhotoByPopularity() {
        let query = PQPhoto.query();
        query.orderByDescending("chain");
        query.whereKey("user", equalTo: PQ.currentUser);
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
                if let a = array as! [PQPhoto]! {
                    self.photoArray = a;
                    self.collectionView.reloadData();
                } else {
                    NSLog("Error downcasting [AnyObject] to [PQPhoto]");
                }
            }
        }
    }
    
//    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
////        if (kind == CSStickyHeaderParallaxHeader) {
////            // Config Collection View header
////            if let cell = self.headerView {
////                return cell;
////            } else {
////                self.headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! ProfileHeaderCollectionReusableView;
////                if let user = self.user {
////                    self.headerView.initWithUser(user);
////                    return self.headerView;
////                } else {
////                    return UICollectionReusableView();
////                }
////                
////            }
////        } else
//        if (kind == UICollectionElementKindSectionHeader) {
//            // Config Collection View section header
//            var cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "sectionHeader", forIndexPath: indexPath) as! ProfileCollectionViewSegmentCell;
//            cell.delegate = self;
//            return cell;
//        } else {
//            // other custom supplementary views
//            return UICollectionReusableView();
//        }
//    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoArray.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageViewCell", forIndexPath: indexPath) as! PQPhotoCollectionViewCell;
        cell.initializeWithPhoto(self.photoArray[indexPath.row]);
        return cell;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = self.photoArray[indexPath.row];
        self.performSegueWithIdentifier("segueToPhoto", sender: photo);
    }
    
    func segmentSelected(index: Int) {
        switch index {
        case 0:
            NSLog("0");
            self.queryPhotoByDate();
        case 1:
            NSLog("1");
            self.queryPhotoByPopularity();
        default:
            break;
        }
    }
    @IBAction func dateButtonClicked(sender: UIButton) {
        dateButton.setTitleColor(UIColor(hex: "#BE0004"), forState: .Normal);
        popularButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal);
        segmentSelected(0);
        NSLog("datebbutton clicked");
    }
    @IBAction func popularButtonClicked(sender: UIButton) {
        dateButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal);
        popularButton.setTitleColor(UIColor(hex: "#BE0004"), forState: .Normal);
        segmentSelected(1);
        NSLog("popularbutton clicked");
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToPhoto"){
            let VC = segue.destinationViewController as! PhotoViewController;
            VC.photo = sender as! PQPhoto;
            VC.title = (sender as! PQPhoto).user?.profileName;
        }
    }

}
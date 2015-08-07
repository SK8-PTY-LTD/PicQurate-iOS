//
//  ChainHistoryViewController.swift
//  PicQurate
//
//  Created by SongXujie on 6/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class ChainHistoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ProfileCollectionViewSegmentCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var flowLayout: CSStickyHeaderFlowLayout!
    var column = 2;
    
    var photoArray: [PQPhoto] = [PQPhoto]();
    
    override func viewDidLoad() {
        
        //Set up collection view
        self.flowLayout = self.collectionView.collectionViewLayout as! CSStickyHeaderFlowLayout;
        
        var itemWidth = self.view.frame.size.width / CGFloat(self.column);
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
        var query = PQPhoto.query();
        query.orderByDescending("createdAt");
//        query.whereKey("user", notEqualTo: PQ.currentUser);
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
        var query = PQPhoto.query();
        query.orderByDescending("chain");
//        query.whereKey("user", notEqualTo: PQ.currentUser);
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
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//        if (kind == CSStickyHeaderParallaxHeader) {
//            // Config Collection View header
//            if let cell = self.headerView {
//                return cell;
//            } else {
//                self.headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! ProfileHeaderCollectionReusableView;
//                if let user = self.user {
//                    self.headerView.initWithUser(user);
//                    return self.headerView;
//                } else {
//                    return UICollectionReusableView();
//                }
//                
//            }
//        } else
        if (kind == UICollectionElementKindSectionHeader) {
            // Config Collection View section header
            var cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "sectionHeader", forIndexPath: indexPath) as! ProfileCollectionViewSegmentCell;
            cell.delegate = self;
            return cell;
        } else {
            // other custom supplementary views
            return UICollectionReusableView();
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoArray.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageViewCell", forIndexPath: indexPath) as! PQPhotoCollectionViewCell;
        cell.initializeWithPhoto(self.photoArray[indexPath.row]);
        return cell;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var photo = self.photoArray[indexPath.row];
        self.performSegueWithIdentifier("segueToPhoto", sender: photo);
    }
    
    func segmentSelected(index: Int) {
        switch index {
        case 0:
            self.queryPhotoByDate();
        case 1:
            self.queryPhotoByPopularity();
        default:
            break;
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToPhoto"){
            var VC = segue.destinationViewController as! PhotoViewController;
            VC.photo = sender as! PQPhoto;
            VC.title = (sender as! PQPhoto).user?.profileName;
        }
    }

}
//
//  HomeViewController.swift
//  PicQurate
//
//  Created by SongXujie on 24/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var genderButton: UIBarButtonItem!
    @IBOutlet weak var dailyButton: UIButton!
    @IBOutlet weak var localButton: UIButton!
    
    var flowLayout: CSStickyHeaderFlowLayout!
    var headerView: HomeHeaderCollectionReusableView!
    
    var chainArray0: [PQChain] = [PQChain]();
    var chainArray1: [PQChain] = [PQChain]();
    var chainArray2: [PQChain] = [PQChain]();
    var column: Int = 2;
    var displayMode: Int = 0;
    var gender: Bool = false;
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        var headerNib = UINib(nibName: "HomeHeaderCollectionReusableView", bundle: nil);
        self.collectionView.registerNib(headerNib, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "header");
        
        self.flowLayout = self.collectionView.collectionViewLayout as! CSStickyHeaderFlowLayout;
        self.flowLayout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.width, 280);
        self.setColumns(2);
        
    }
    
    @IBAction func dailyButtonClicked(sender: UIButton) {
        self.displayMode = 0;
        self.dailyButton.setTitleColor(UIColor(hex: "#BE0004"), forState: .Normal);
        self.localButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal);
        displayPhotoByDay();
    }
    
    @IBAction func localButtonClicked(sender: UIButton) {
        self.displayMode = 1;
        self.dailyButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal);
        self.localButton.setTitleColor(UIColor(hex: "#BE0004"), forState: .Normal);
        displayPhotoByLocation();
    }
    
    
    @IBAction func genderButtonClicked(sender: UIBarItem) {
        self.gender = !self.gender;
        self.reloadPhoto();
        if (self.genderButton.image == UIImage(named: "icon-male")) {
            self.genderButton.image = UIImage(named: "icon-female");
        } else {
            self.genderButton.image = UIImage(named: "icon-male");
        }
    }
    

    func reloadPhoto() {
        //Display photo
        switch displayMode {
//        case 0:
//            self.displayPhotoByWorld();
        case 0:
            self.displayPhotoByDay();
        case 1:
            self.displayPhotoByLocation();
        default:
            break;
        }
    }
    
    func displayPhotoByWorld() {
        var query = PQChain.query();
        query.orderByDescending("createdAt");
        query.includeKey("photo");
        query.includeKey("photo.user");
        if (self.gender) {
            query.whereKey("gender", equalTo: 1);
        } else {
            query.whereKey("gender", equalTo: 0);
        }
        query.limit = 10;
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
                if let a = array as? [PQChain] {
                    self.chainArray0 = a;
                    self.collectionView.reloadData();
                    if (self.chainArray0.count > 0) {
                        self.headerView.imageView.file = self.chainArray0[0].photo?.file;
                        self.headerView.imageView.loadInBackground();
                    } else {
                        self.headerView.imageView.image = nil;
                    }
                } else {
                    PQLog.e("Error downcasint [AnyObject] to [PQChain]");
                }
            }
        }
    }
    
    func displayPhotoByDay() {
        var query = PQChain.query();
        query.orderByAscending("createdAt");
        var yesterday = NSDate().dateByAddingTimeInterval(-2 * 24 * 60 * 60);
        NSLog("\(NSDate())");
        NSLog("\(yesterday)");
        
        query.whereKey("createdAt", greaterThan: yesterday);
        query.limit = 10;
        query.includeKey("photo");
        query.includeKey("photo.user");
        if (self.gender) {
            query.whereKey("gender", equalTo: 1);
        } else {
            query.whereKey("gender", equalTo: 0);
        }
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
                if let a = array as? [PQChain] {
                    self.chainArray1 = a;
                    self.collectionView.reloadData();
                    NSLog("Photo by daily count return \(a.count)");
                    if (self.chainArray1.count > 0) {
                        self.headerView.imageView.file = self.chainArray1[0].photo?.file;
                        self.headerView.imageView.loadInBackground();
                    } else {
                        self.headerView.imageView.image = nil;
                    }
                } else {
                    PQLog.e("Error downcasint [AnyObject] to [PQChain]");
                }
            }
        }
    }
    
    func displayPhotoByLocation() {
        var query = PQChain.query();
//        query.whereKey("photo.user.gender", equalTo: self.gender);
        query.orderByDescending("createdAt");
        NSLog("\(PQ.currentUser.location)");
//        query.whereKey("location", nearGeoPoint: PQ.currentUser.location, withinKilometers: 10.0);
        query.limit = 10;
        query.includeKey("photo");
        query.includeKey("photo.user");
        if (self.gender) {
            query.whereKey("gender", equalTo: 1);
        } else {
            query.whereKey("gender", equalTo: 0);
        }
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            NSLog("array: \(array.count)");
            if let e = error {
                PQ.showError(e);
            } else {
                if let a = array as? [PQChain] {
                    self.chainArray2 = a;
                    self.collectionView.reloadData();
                    NSLog("chainArray2: \(a.count)");
                    if (self.chainArray2.count > 0) {
                        self.headerView.imageView.file = self.chainArray2[0].photo?.file;
                        self.headerView.imageView.loadInBackground();
                    } else {
                        self.headerView.imageView.image = nil;
                    }
                } else {
                    PQLog.e("Error downcasint [AnyObject] to [PQChain]");
                }
            }
        }
    }
    
    func setColumns(numberOfColumns: Int) {
        self.column = numberOfColumns;
        var itemWidth = self.view.frame.size.width / CGFloat(self.column);
        self.flowLayout.itemSize = CGSizeMake(itemWidth-1, itemWidth-1);
        NSLog("itemWidth: \(itemWidth)");
        NSLog("collectionView: \(self.collectionView.frame.size)");
        self.collectionView.reloadData();
        self.collectionView.layoutIfNeeded();
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if (kind == CSStickyHeaderParallaxHeader) {
            // Config Collection View header
            if let cell = self.headerView {
                return cell;
            } else {
                self.headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! HomeHeaderCollectionReusableView;
                switch self.displayMode {
//                case 0:
//                    if (self.chainArray0.count > 0) {
//                        self.headerView.imageView.file = self.chainArray0[0].photo?.file;
//                        self.headerView.imageView.loadInBackground();
//                    }
                case 0:
                    if (self.chainArray1.count > 0) {
                        self.headerView.imageView.file = self.chainArray1[0].photo?.file;
                        self.headerView.imageView.loadInBackground();
                    }
                case 1:
                    if (self.chainArray2.count > 0) {
                        self.headerView.imageView.file = self.chainArray2[0].photo?.file;
                        self.headerView.imageView.loadInBackground();
                    }
                default:
                    break;
                }
                return self.headerView;
            }
        } else if (kind == UICollectionElementKindSectionHeader) {
            // Config Collection View section headers
            return UICollectionReusableView();
        } else {
            // other custom supplementary views
            return UICollectionReusableView();
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.displayMode {
//        case 0:
//            if (self.chainArray0.count > 0) {
//                return self.chainArray0.count - 1;
//            }
        case 0:
            if (self.chainArray1.count > 0) {
                return self.chainArray1.count - 1;
            }
        case 1:
            if (self.chainArray2.count > 0) {
                return self.chainArray2.count - 1;
            }
        default:
            break;
        }
        return 0;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageViewCell", forIndexPath: indexPath) as! PQPhotoCollectionViewCell;
        switch self.displayMode {
//        case 0:
//            cell.initializeWithPhoto(self.chainArray0[indexPath.row + 1].photo!);
        case 0:
            cell.initializeWithPhoto(self.chainArray1[indexPath.row + 1].photo!);
        case 1:
            cell.initializeWithPhoto(self.chainArray2[indexPath.row + 1].photo!);
        default:
            break;
        }
        return cell;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo: PQPhoto!;
        switch self.displayMode {
//        case 0:
//            photo = self.chainArray0[indexPath.row + 1].photo!;
        case 0:
            photo = self.chainArray1[indexPath.row + 1].photo!;
            NSLog("\(photo.file)");
            self.performSegueWithIdentifier("segueToPhoto", sender: photo);
        case 1:
            photo = self.chainArray2[indexPath.row + 1].photo!;
            NSLog("\(photo.file)");
            self.performSegueWithIdentifier("segueToPhoto", sender: photo);
        default:
            break;
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToPhoto") {
            let VC = segue.destinationViewController as! PhotoViewController;
            VC.photo = sender as! PQPhoto;
            
//            VC.initializeWithPhoto(sender as! PQPhoto);
        }
    }
    
}

class HomeHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var imageView: AVImageView!;
    
}
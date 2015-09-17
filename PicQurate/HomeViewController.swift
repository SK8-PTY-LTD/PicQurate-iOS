//
//  HomeViewController.swift
//  PicQurate
//
//  Created by SongXujie on 24/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, HomeHeaderCollectionReusableViewProtocol {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
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
    var gender: NSNumber = false;
    
     var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
//        self.activityIndicatorView.startAnimating();
        
        let headerNib = UINib(nibName: "HomeHeaderCollectionReusableView", bundle: nil);
        self.collectionView.registerNib(headerNib, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: "header");
        self.flowLayout = self.collectionView.collectionViewLayout as! CSStickyHeaderFlowLayout;
        self.flowLayout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.width, 280);
        self.setColumns(2);
        self.reloadPhoto();
        self.refreshControl = UIRefreshControl();
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh");
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged);
        self.collectionView.addSubview(refreshControl);
    }
    
    func refresh(sender:AnyObject)
    {
        self.reloadPhoto();
        self.refreshControl.endRefreshing()
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
        if (self.gender == true) {
            self.gender = false;
            self.genderButton.image = UIImage(named: "icon-female");
        } else {
            self.gender = true;
            self.genderButton.image = UIImage(named: "icon-male");
        }
        self.reloadPhoto();
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
        let query = PQChain.query();
        query.orderByDescending("createdAt");
        query.includeKey("photo");
        query.includeKey("photo.user");
        query.whereKey("gender", equalTo: self.gender);
        query.limit = 11;
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
                if let a = array as? [PQChain] {
                    self.chainArray0 = a;
                    self.collectionView.reloadData();
                    NSLog("Photo by local count return \(a.count)");
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
        self.activityIndicatorView.startAnimating();
        let yesterday = NSDate().dateByAddingTimeInterval(-2 * 24 * 60 * 60);
        
        let query = PQChain.query();
        query.orderByDescending("createdAt");
        query.whereKey("createdAt", greaterThan: yesterday);
        query.limit = 11;
        query.includeKey("photo");
        query.includeKey("photo.user");
        query.whereKey("gender", equalTo: self.gender);
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
                        self.headerView.delegate = self;
                    } else {
                        self.headerView.imageView.image = nil;
                    }
                self.activityIndicatorView.stopAnimating();
                } else {
                    PQLog.e("Error downcasint [AnyObject] to [PQChain]");
                }
            }
        }
    }
    
    func displayPhotoByLocation() {
        self.activityIndicatorView.startAnimating();
        
        let query = PQChain.query();
        query.orderByDescending("createdAt");
        if (PQ.currentUser.email != nil) {
            query.whereKey("location", nearGeoPoint: PQ.currentUser.location, withinKilometers: 100.0);
        }
        query.limit = 11;
        query.includeKey("photo");
        query.includeKey("photo.user");
        query.whereKey("gender", equalTo: self.gender);
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
                if let a = array as? [PQChain] {
                    self.chainArray2 = a;
                    self.collectionView.reloadData();
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
        self.activityIndicatorView.stopAnimating();
    }
    
    func imageClicked() {
        switch self.displayMode {
//        case 0:
//            if (self.chainArray0.count > 0) {
//                self.headerView.imageView.file = self.chainArray0[0].photo?.file;
//                self.headerView.imageView.loadInBackground();
//            }
        case 0:
            if (self.chainArray1.count > 0) {
                let photo = self.chainArray1[0].photo!;
                self.performSegueWithIdentifier("segueToPhoto", sender: photo);
            }
        case 1:
            if (self.chainArray2.count > 0) {
                let photo = self.chainArray2[0].photo!;
                self.performSegueWithIdentifier("segueToPhoto", sender: photo);
            }
        default:
            break;
        }
    }
    
    func setColumns(numberOfColumns: Int) {
        self.column = numberOfColumns;
        let itemWidth = self.view.frame.size.width / CGFloat(self.column);
        self.flowLayout.itemSize = CGSizeMake(itemWidth-1, itemWidth-1);
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageViewCell", forIndexPath: indexPath) as! PQPhotoCollectionViewCell;
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
            self.performSegueWithIdentifier("segueToPhoto", sender: photo);
        case 1:
            photo = self.chainArray2[indexPath.row + 1].photo!;
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

protocol HomeHeaderCollectionReusableViewProtocol {
    func imageClicked();
}

class HomeHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var imageView: AVImageView!;
    
    var delegate: HomeHeaderCollectionReusableViewProtocol!
    
    @IBAction func imageClicked(sender: UIButton) {
        self.delegate.imageClicked();
    }
    
}
//
//  HomeViewController.swift
//  PicQurate
//
//  Created by SongXujie on 24/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class HomeViewController: ViewPagerController, ViewPagerDelegate, ViewPagerDataSource {
    
    var controller: HomeDetailViewController!;
    var gender: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.dataSource = self;
        self.delegate = self;
    }
    
    //pragma mark - ViewPagerDataSource
    func numberOfTabsForViewPager(viewPager: ViewPagerController!) -> UInt {
        return 3;
    }
    
    func viewPager(viewPager: ViewPagerController!, viewForTabAtIndex index: UInt) -> UIView! {
        var label = UILabel();
        switch index {
        case 0:
            label.text = "World";
        case 1:
            label.text = "Daily";
        case 2:
            label.text = "Local";
        default:
            label.text = "New Tab";
        }
        label.sizeToFit();
        
        return label;
    }
    
    func viewPager(viewPager: ViewPagerController!, contentViewControllerForTabAtIndex index: UInt) -> UIViewController! {
        switch index {
        case 0:
            var VC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeDetail1") as! HomeDetailViewController;
            self.controller = VC;
            VC.gender = self.gender;
            VC.displayPhotoByWorld();
            return VC;
        case 1:
            var VC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeDetail2") as! HomeDetailViewController;
            self.controller = VC;
            VC.gender = self.gender;
            VC.displayPhotoByDay();
            return VC;
        case 2:
            var VC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeDetail3") as! HomeDetailViewController;
            self.controller = VC;
            VC.gender = self.gender;
            VC.displayPhotoByLocation();
            return VC;
        default:
            break;
        }
        return controller;
    }
    
    func viewPager(viewPager: ViewPagerController!, colorForComponent component: ViewPagerComponent, withDefault color: UIColor!) -> UIColor! {
        switch component {
        case ViewPagerComponent.Indicator:
            return PQ.primaryColor;
        default:
            return color;
        }
    }
    
    @IBAction func genderButtonClicked(sender: UIBarItem) {
        self.gender = !self.gender;
        self.controller.gender = !self.controller.gender;
        self.controller.reloadPhoto();
    }
}

class HomeDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
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
    
    func reloadPhoto() {
        //Display photo
        switch displayMode {
        case 0:
            self.displayPhotoByWorld();
        case 1:
            self.displayPhotoByDay();
        case 2:
            self.displayPhotoByLocation();
        default:
            break;
        }
    }
    
    func displayPhotoByWorld() {
        self.displayMode = 0;
        var query = PQChain.query();
        query.orderByDescending("createdAt");
        query.includeKey("photo.file");
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
        self.displayMode = 1;
        var query = PQChain.query();
        query.orderByAscending("createdAt");
        var yesterday = NSDate().dateByAddingTimeInterval(-86400.0);
        query.whereKey("createdAt", greaterThan: yesterday);
        query.limit = 10;
        query.includeKey("photo.file");
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
        self.displayMode = 2;
        var query = PQChain.query();
        query.whereKey("photo.user.gender", equalTo: self.gender);
        query.orderByDescending("createdAt");
        query.whereKey("location", nearGeoPoint: PQ.currentUser.location, withinKilometers: 100.0);
        query.limit = 10;
        query.includeKey("photo.file");
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
    }
    
    func setColumns(numberOfColumns: Int) {
        self.column = numberOfColumns;
        var itemWidth = self.view.frame.size.width / CGFloat(self.column);
        if (self.column != 1) {
            self.flowLayout.itemSize = CGSizeMake(itemWidth-1, itemWidth-1);
        } else {
            self.flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth + 120);
        }
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
                case 0:
                    if (self.chainArray0.count > 0) {
                        self.headerView.imageView.file = self.chainArray0[0].photo?.file;
                        self.headerView.imageView.loadInBackground();
                    }
                case 1:
                    if (self.chainArray1.count > 0) {
                        self.headerView.imageView.file = self.chainArray1[0].photo?.file;
                        self.headerView.imageView.loadInBackground();
                    }
                case 2:
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
        case 0:
            if (self.chainArray0.count > 0) {
                return self.chainArray0.count - 1;
            }
        case 1:
            if (self.chainArray1.count > 0) {
                return self.chainArray1.count - 1;
            }
        case 2:
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
        case 0:
            cell.initializeWithPhoto(self.chainArray0[indexPath.row + 1].photo!);
        case 1:
            cell.initializeWithPhoto(self.chainArray1[indexPath.row + 1].photo!);
        case 2:
            cell.initializeWithPhoto(self.chainArray2[indexPath.row + 1].photo!);
        default:
            break;
        }
        return cell;
    }
    
}

class HomeHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var imageView: AVImageView!;
    
}
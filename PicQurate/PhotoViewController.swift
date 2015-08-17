//
//  PhotoViewController.swift
//  PicQurate
//
//  Created by SongXujie on 10/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit



class PhotoViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: AVImageView!
    @IBOutlet weak var profileNameButton: UIButton!
    @IBOutlet weak var photoImageView: AVImageView!
    @IBOutlet weak var topLikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var chainButton: UIButton?
    @IBOutlet weak var locationButton: UIButton?
    @IBOutlet weak var captionTextView: UITextView?
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var locationArray: [AVGeoPoint] = [];
    var locationNameArray: [String]  = [];
    
    private var cachedPhoto: PQPhoto?
    var photo: PQPhoto!
    
    override func viewDidLoad() {
        self.initializeWithPhoto(photo);
    }
    
    func initializeWithPhoto(photo: PQPhoto) {
        
        self.photo = photo;
        
        if (self.cachedPhoto?.objectId == self.photo?.objectId) {
            //View already initialized, do nothing
        } else {
            self.cachedPhoto = photo;
            
            var tapRecognizer = UITapGestureRecognizer(target: self, action: "photoImageViewTapped:");
            tapRecognizer.numberOfTapsRequired = 2;
            
            NSLog("\(self.photoImageView) **** \(photo.file)");
            self.photoImageView.file = photo.file;
            self.photoImageView.loadInBackground();
            self.photoImageView.addGestureRecognizer(tapRecognizer);
            
            
            PQ.currentUser.hasLikedPhotoithCallback(photo, callback: { (liked, error) -> () in
                if let e = error {
                    //Do nothing
                } else {
                    if (liked) {
                        self.topLikeButton.setBackgroundImage(UIImage(named: "like-icon-1"), forState: .Normal);
                        self.likeButton.setImage(UIImage(named: "like-icon-1"), forState: .Normal);
                    } else {
                        self.topLikeButton.setBackgroundImage(UIImage(named: "icon_like_1"), forState: .Normal);
                        self.likeButton.setImage(UIImage(named: "like-icon"), forState: .Normal);
                    }
                }
            })
            
            var query0 = PQ.currentUser.relationforKey("photoLiked").query();
            query0.whereKey("objectId", equalTo: self.photo.objectId);
            query0.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
                if let e = error {
                    PQLog.e(e.localizedDescription);
                    //Haven't liked photo
                } else {
                    let liked = count == 1;
                    if (liked) {
                        
                    } else {
                        //Haven't liked photo
                    }
                }
            })
            
            var query1 = AVRelation.reverseQuery("_User", relationKey: "photoLiked", childObject: self.photo);
            query1.countObjectsInBackgroundWithBlock { (count, error) -> Void in
                if let e = error {
                    PQLog.e(e.localizedDescription);
                } else {
                    self.likeButton?.setTitle("\(count)", forState: .Normal);
                }
            }
            
            var query2 = PQChain.query();
            query2.whereKey("photo", equalTo: self.photo);
            query2.countObjectsInBackgroundWithBlock { (count, error) -> Void in
                if let e = error {
                    PQLog.e(e.localizedDescription);
                } else {
                    self.chainButton?.setTitle("\(count)", forState: .Normal);
                }
            }
            
            var query3 = PQChain.query();
            query3.whereKey("photo", equalTo: self.photo);
            query3.includeKey("original");
            query3.includeKey("original.original");
            query3.includeKey("original.original.original");
            query3.includeKey("original.original.original.original");
            query3.includeKey("user");
            query3.includeKey("original.user");
            query3.includeKey("original.original.user");
            query3.includeKey("original.original.original.user");
            query3.includeKey("original.original.original.original.user");
            query3.getObjectInBackgroundWithId(self.photo.lastChainId, block: { (object, error) -> Void in
                if let e = error {
                    PQLog.e(e.localizedDescription);
                } else {
                    if let chain = object as? PQChain {
                        
                        var name = chain.user?.profileName;
                        
                        if (chain.location != nil) {
                            self.locationNameArray.append((chain.user?.profileName)!);
                            self.locationArray.append(chain.location!);
                        }
                        if (chain.original?.location != nil) {
                            self.locationNameArray.append((chain.original?.user?.profileName)!);
                            self.locationArray.append((chain.original?.location)!);
                        }
                        if (chain.original?.original?.location != nil) {
                            self.locationNameArray.append((chain.original?.original?.user?.profileName)!);
                            self.locationArray.append((chain.original?.original?.location)!);
                        }
                        if (chain.original?.original?.original?.location != nil) {
                            self.locationNameArray.append((chain.original?.original?.original?.user?.profileName)!);
                            self.locationArray.append((chain.original?.original?.original?.location)!);
                        }
                        if (chain.original?.original?.original?.original?.location != nil) {
                            self.locationNameArray.append((chain.original?.original?.original?.original?.user?.profileName)!);
                            self.locationArray.append((chain.original?.original?.original?.original?.location)!);
                        }
                    } else {
                        NSLog("error passing object to PQChain");
                    }
                }
            })
            
            
            self.profileImageView.file = photo.user?.profileImage;
            self.profileImageView.loadInBackground();
            self.profileNameButton.setTitle(photo.user?.profileName, forState: .Normal);
            self.navigationItem.title = photo.user?.profileName;
            
            self.locationButton?.setTitle(self.photo.locationString, forState: .Normal);
            
            self.captionTextView?.text = self.photo.caption;
            
        }
    }
    
    @IBAction func topLikeButtonClicked(sender: UIButton) {
        if (self.topLikeButton.backgroundImageForState(.Normal) == UIImage(named: "icon_like_1")) {
            PQ.currentUser.likePhoto(self.photo, like: true);
            self.topLikeButton.setBackgroundImage(UIImage(named: "like-icon-1"), forState: .Normal);
            self.likeButton.setImage(UIImage(named: "like-icon-1"), forState: .Normal);
        } else {
            PQ.currentUser.likePhoto(self.photo, like: false);
            self.topLikeButton.setBackgroundImage(UIImage(named: "icon_like_1"), forState: .Normal);
            self.likeButton.setImage(UIImage(named: "like-icon"), forState: .Normal);
        }
    }
    
    @IBAction func likeButtonClicked(sender: UIButton) {
        var query = AVRelation.reverseQuery("_User", relationKey: "photoLiked", childObject: self.photo);
        self.performSegueWithIdentifier("segueToLikedUser", sender: query);
    }
    
    @IBAction func chainButtonClicked(sender: UIButton) {
        self.performSegueWithIdentifier("segueToChain", sender: self.photo);
        
//        if (photo.user == PQ.currentUser) {
//            PQ.promote("You can't chain your own selfie!");
//        } else {
//            var lastChain = PQChain(chainId: photo.lastChainId!);
//            PQ.currentUser.chainPhotoWithBlock(lastChain, block: { (chain, error) -> () in
//                if let e = error {
//                    PQ.showError(e);
//                } else {
//                    PQ.promote("Photo chained!");
//                }
//            })
//        }
    }
    
    @IBAction func locationButtonClicked(sender: UIButton) {
        if let location = self.photo.location {
            var coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude));
            var placemark = MKPlacemark(coordinate: coord, addressDictionary: nil);
            var mapItem = MKMapItem(placemark: placemark);
            mapItem.name = PQ.currentUser.profileName;
            mapItem.openInMapsWithLaunchOptions(nil);
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToLikedUser") {
            var VC = segue.destinationViewController as! UserTableViewController;
            VC.title = "Like"
            VC.query = sender as! AVQuery;
        } else if (segue.identifier == "segueToChain") {
            var VC = segue.destinationViewController as! MapViewController;
            VC.locationArray = self.locationArray;
            VC.locationNameArray = self.locationNameArray;
        }
    }
    
    func photoImageViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            topLikeButtonClicked(UIButton());
        }
    }

    
    
}
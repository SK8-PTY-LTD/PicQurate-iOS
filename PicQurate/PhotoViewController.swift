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
    @IBOutlet weak var photoImageView: AVImageView!
    @IBOutlet weak var topLikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var chainButton: UIButton?
    @IBOutlet weak var locationButton: UIButton?
    @IBOutlet weak var captionTextView: UITextView?
    
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
            
            self.photoImageView.file = photo.file;
            self.photoImageView.loadInBackground();
            
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
            
            self.locationButton?.setTitle(self.photo.locationString, forState: .Normal);
            
            self.captionTextView?.text = self.photo.caption;
            
        }
    }
    
    @IBAction func likeButtonClicked(sender: UIButton) {
        var query = AVRelation.reverseQuery("_User", relationKey: "photoLiked", childObject: self.photo);
        self.performSegueWithIdentifier("segueToLikedUser", sender: query);
    }
    
    @IBAction func chainButtonClicked(sender: UIButton) {
        self.performSegueWithIdentifier("segueToChain", sender: self.photo);
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
//            var VC = segue.destinationViewController as! UserTableViewController;
//            VC.title = "Like"
//            VC.query = sender as! AVQuery;
        }
    }
    
    

    
    
}
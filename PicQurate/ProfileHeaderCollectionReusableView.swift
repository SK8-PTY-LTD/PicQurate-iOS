//
//  ProfileCollectionReusableView.swift
//  PicQurate
//
//  Created by SongXujie on 3/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol ProfileHeaderCollectionReusableViewDelegate {
    
    func followerButtonClicked();
    func followeeButtonClicked();
    
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImageView: AVImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var followerButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var QptsLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    var delegate: ProfileHeaderCollectionReusableViewDelegate!;
    
    var user: PQUser!
    
    func initWithUser(user: PQUser) {
        
        self.user = user;
        
//        if let file = self.profileImageView.file {
//            //ImageView already loaded, do not reload.
//        } else {
            self.profileImageView.file = self.user!.profileImage;
            self.profileImageView.loadInBackground();
        NSLog("profile image has been reloaded");
//        }
        
        let query1 = self.user!.followeeQuery();
        let count1 = query1.countObjects();
        self.followingButton.setTitle("\(count1)", forState: .Normal);
        let query2 = self.user!.followerQuery();
        let count2 = query2.countObjects();
        self.followerButton.setTitle("\(count2)", forState: .Normal);
        if let currentUser = PQ.currentUser {
            let query3 = currentUser.followeeQuery();
            query3.whereKey("objectId", equalTo: self.user!.objectId);
            let count3 = query3.countObjects();
            if (count3 == 1) {
                self.followButton.setTitle("Unfollow", forState: .Normal);
            } else {
                self.followButton.setTitle("Follow", forState: .Normal);
            }
            if (currentUser.objectId != self.user!.objectId) {
                self.followButton.hidden = false;
                self.followButton.enabled = true;
            } else {
                self.followButton.hidden = true;
                self.followButton.enabled = false;
            }
        } else {
            self.followButton.enabled = false;
        }
        
        self.profileNameLabel.text = self.user.profileName;
        self.QptsLabel.text = String(self.user!.balance);
        self.summaryTextView.text = self.user!.bio;
        self.locationButton.setTitle(self.user!.locationString, forState: .Normal);
        self.urlButton.setTitle(self.user!.url, forState: .Normal);
    }
    
    @IBAction func followerButtonClicked(sender: UIButton) {
        self.delegate.followerButtonClicked();
    }
    
    @IBAction func followingButtonClicked(sender: UIButton) {
        self.delegate.followeeButtonClicked();
    }
    
    @IBAction func followButtonClicked(sender: UIButton) {
        if (self.followButton.titleForState(.Normal) == "Follow") {
            self.followButton.setTitle("Unfollow", forState: .Normal);
            PQ.currentUser.follow(user!.objectId, andCallback: nil);
        } else if (self.followButton.titleForState(.Normal) == "Unfollow") {
            self.followButton.setTitle("Follow", forState: .Normal);
            PQ.currentUser.unfollow(user!.objectId, andCallback: nil);
            //Send push to notify user
            let pushQuery = AVInstallation.query();
            pushQuery.whereKey("userId", equalTo: user!.objectId);
            
            let push = AVPush();
            push.setQuery(pushQuery);
            push.setMessage(user!.profileName! + " just started following you.");
            push.setData(["userId": user!.objectId, "badge": "Increment"]);
            push.sendPushInBackground();
        }
    }
    
    @IBAction func urlClicked(sender: UIButton) {
        if let urlString = PQ.currentUser.url {
            let url = NSURL(string: urlString);
            UIApplication.sharedApplication().openURL(url!);
        }
    }
    
    @IBAction func locationClicked(sender: UIButton) {
//        if let location = PQ.currentUser.location {
//            var coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude));
//            var placemark = MKPlacemark(coordinate: coord, addressDictionary: nil);
//            var mapItem = MKMapItem(placemark: placemark);
//            mapItem.name = PQ.currentUser.profileName;
//            mapItem.openInMapsWithLaunchOptions(nil);
//        }
    }
    
}

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
    
    var user: PQUser!
    
    func initWithUser(user: PQUser) {
        
        self.user = user;
        
        if let file = self.profileImageView.file {
            //ImageView already loaded, do not reload.
        } else {
            self.profileImageView.file = self.user!.profileImage;
            self.profileImageView.loadInBackground();
        }
        
        var query1 = self.user!.followeeQuery();
        var count1 = query1.countObjects();
        self.followingButton.setTitle("\(count1)", forState: .Normal);
        var query2 = self.user!.followerQuery();
        var count2 = query2.countObjects();
        self.followerButton.setTitle("\(count2)", forState: .Normal);
        if let currentUser = PQ.currentUser {
            var query3 = currentUser.followeeQuery();
            query3.whereKey("objectId", equalTo: self.user!.objectId);
            var count3 = query3.countObjects();
            if (count3 == 1) {
                self.followButton.setTitle("Unfollow", forState: .Normal);
            } else {
                self.followButton.setTitle("Follow", forState: .Normal);
            }
            self.followButton.enabled = true;
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
        
    }
    
    @IBAction func followingButtonClicked(sender: UIButton) {
        
    }
    
    @IBAction func followButtonClicked(sender: UIButton) {
        if (self.followButton.titleForState(.Normal) == "Follow") {
            self.followButton.setTitle("Unfollow", forState: .Normal);
            PQ.currentUser.follow(user!.objectId, andCallback: nil)
        } else if (self.followButton.titleForState(.Normal) == "Unfollow") {
            self.followButton.setTitle("Follow", forState: .Normal);
            PQ.currentUser.unfollow(user!.objectId, andCallback: nil)
        }
    }
    
    @IBAction func urlClicked(sender: UIButton) {
        if let urlString = PQ.currentUser.url {
            var url = NSURL(string: urlString);
            UIApplication.sharedApplication().openURL(url!);
        }
    }
    
    @IBAction func locationClicked(sender: UIButton) {
        if let location = PQ.currentUser.location {
            var coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude));
            var placemark = MKPlacemark(coordinate: coord, addressDictionary: nil);
            var mapItem = MKMapItem(placemark: placemark);
            mapItem.name = PQ.currentUser.profileName;
            mapItem.openInMapsWithLaunchOptions(nil);
        }
    }
    
    
}

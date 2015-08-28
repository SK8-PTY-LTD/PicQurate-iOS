//
//  PQActivityCollectionViewCell.swift
//  PicQurate
//
//  Created by ShaoweiZhang on 15/8/13.
//  Copyright (c) 2015年 SK8 PTY LTD. All rights reserved.
//

import Foundation

protocol ActivityToProfileProtocol {
    func showProfile(user: PQUser);
}

class PQActivityCollectionViewCell: UICollectionViewCell {
    var delegate: ActivityToProfileProtocol?
//    var user: PQUser!
    @IBOutlet weak var profileImageView: AVImageView!
    @IBOutlet weak var profileNameButton: UIButton!
    @IBOutlet weak var profileActionLabel: UILabel!
    @IBOutlet weak var photoImageView: AVImageView!
    @IBOutlet weak var activityView: UIView!

    var activity: PQPush!
    func initializeWithActivity(activity: PQPush){
        self.activity = activity;
        
        if let image = self.activity.sender?.profileImage {
            NSLog("Image exists");
            if let imageView = profileImageView {
                NSLog("ImageView exists");
                imageView.file = image;
                imageView.loadInBackground();
            }
        }else{
            NSLog("no profileimageView");
        }
        
        if let name = self.activity.sender?.profileName {
            profileNameButton.setTitle(name, forState: .Normal);
            profileNameButton.sizeThatFits(CGSize(width: 10, height: 20))
        } else {
            NSLog("no profileNameButton");
        }
        
        if let message = self.activity.message {
            profileActionLabel.text = message
            NSLog(message)
        } else {
            NSLog("\(self.activity.message): no profileActionLabel")
        }
        
        if let photo = self.activity.photo {
            photoImageView!.file = photo.file
            photoImageView!.loadInBackground()
        } else {
            NSLog("\(self.activity.photo): no photoImageView")
        }
    }

//    func showProfile(user: PQUser){
//        delegate?.showProfile(self.activity.sender);
//    }
    
    @IBAction func profileNameButtonClicked(sender: UIButton) {
        if let delegate = self.delegate {
            delegate.showProfile(self.activity.sender);
            NSLog("sender is \(self.activity.sender)");
        }else{
            NSLog("delegate is nil");
        }
    }
    
}

//
//  PQActivityCollectionViewCell.swift
//  PicQurate
//
//  Created by ShaoweiZhang on 15/8/13.
//  Copyright (c) 2015年 SK8 PTY LTD. All rights reserved.
//

import Foundation

class PQActivityCollectionViewCell: UICollectionViewCell {
    
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
            NSLog("\(self.activity.sender.profileImage): no profileimageView");
        }
        
        if let name = self.activity.sender.profileName {
            profileNameButton.setTitle(name, forState: .Normal);
            profileNameButton.sizeThatFits(CGSize(width: 10, height: 20))
        } else {
            NSLog("\(self.activity.sender.profileImage): no profileNameButton");
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
    
}

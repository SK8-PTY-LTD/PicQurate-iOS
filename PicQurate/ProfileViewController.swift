//
//  ProfileViewController.swift
//  PicQurate
//
//  Created by SongXujie on 1/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class ProfileViewController: UIViewController {
    
//    @IBOutlet weak var profileImageView: AVImageView!
    
    override func viewDidLoad() {
        if let user = PQ.currentUser {
            
//            self.navigationItem.title = user.profileName;
//            self.profileImageView.file = user.profileImage;
//            self.profileImageView.loadInBackground();
            
            
        } else {
            self.performSegueWithIdentifier("segueToLogin", sender: nil);
        }
    }
    
}
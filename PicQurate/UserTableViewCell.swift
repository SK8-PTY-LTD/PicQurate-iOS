//
//  UserTableViewCell.swift
//  PicQurate
//
//  Created by SongXujie on 7/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: AVImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    
    var user: PQUser!
    
    func initWithUser(user: PQUser) {
        
        self.user = user;
        
        if let _ = self.profileImageView.file {
            //ImageView already loaded, do not reload.
        } else {
            self.profileImageView.file = self.user!.profileImage;
            self.profileImageView.loadInBackground();
        }
        
        self.profileNameLabel.text = user.profileName;
    }
    
}
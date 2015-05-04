//
//  ProfileCollectionReusableView.swift
//  PicQurate
//
//  Created by SongXujie on 3/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

protocol ProfileCollectionReusableViewDelegate {
    func segmentSelected(index: Int);
}

class ProfileCollectionViewSegmentCell: UICollectionReusableView {
    
    @IBOutlet weak var postsLabel: UILabel!;
    
    var delegate: ProfileCollectionReusableViewDelegate!;
    
    @IBAction func segmentOneSelected(sender: UIButton) {
        self.delegate.segmentSelected(0);
    }
    
    @IBAction func segmentTwoSelected(sender: UIButton) {
        self.delegate.segmentSelected(1);
    }
    
    @IBAction func segmentThreeSelected(sender: UIButton) {
        self.delegate.segmentSelected(2);
    }
    
}
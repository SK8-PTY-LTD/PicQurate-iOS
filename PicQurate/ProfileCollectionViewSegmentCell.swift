//
//  ProfileCollectionReusableView.swift
//  PicQurate
//
//  Created by SongXujie on 3/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

protocol ProfileCollectionViewSegmentCellDelegate {
    func segmentSelected(index: Int);
}

class ProfileCollectionViewSegmentCell: UICollectionReusableView {
    
    @IBOutlet weak var postsLabel: UILabel!;
    @IBOutlet weak var chainSegmentButton: UIButton!
    
    @IBOutlet weak var likeSegmentButton: UIButton!
    
    @IBOutlet weak var locationSegmentButton: UIButton!
    
    var delegate: ProfileCollectionViewSegmentCellDelegate!;
    
    @IBAction func segmentOneSelected(sender: UIButton) {
        self.delegate.segmentSelected(0);
        
        likeSegmentButton.setImage(UIImage(named: "like-icon-1"), forState: .Normal);
        chainSegmentButton.setImage(UIImage(named: "chain-icon"), forState: .Normal);
        locationSegmentButton.setImage(UIImage(named: "location-icon"), forState: .Normal);
    }
    
    @IBAction func segmentTwoSelected(sender: UIButton) {
        self.delegate.segmentSelected(1);
        
        likeSegmentButton.setImage(UIImage(named: "like-icon"), forState: .Normal);
        chainSegmentButton.setImage(UIImage(named: "chain-icon-1"), forState: .Normal);
        locationSegmentButton.setImage(UIImage(named: "location-icon"), forState: .Normal);
    }
    
    @IBAction func segmentThreeSelected(sender: UIButton) {
        self.delegate.segmentSelected(2);
        
        likeSegmentButton.setImage(UIImage(named: "like-icon"), forState: .Normal);
        chainSegmentButton.setImage(UIImage(named: "chain-icon"), forState: .Normal);
        locationSegmentButton.setImage(UIImage(named: "location-icon-1"), forState: .Normal);
    }
    
}
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
    @IBOutlet weak var timeSegmentButton: UIButton!
    @IBOutlet weak var chainSegmentButton: UIButton!
    @IBOutlet weak var likeSegmentButton: UIButton!
    
    var delegate: ProfileCollectionViewSegmentCellDelegate!;
    
    @IBAction func segmentOneSelected(sender: UIButton) {
        self.delegate.segmentSelected(0);
        
        timeSegmentButton.setImage(UIImage(named: "icon_clock_1"), forState: .Normal);
        chainSegmentButton.setImage(UIImage(named: "icon_chain_0"), forState: .Normal);
        likeSegmentButton.setImage(UIImage(named: "icon_like_0"), forState: .Normal);
    }
    
    @IBAction func segmentTwoSelected(sender: UIButton) {
        self.delegate.segmentSelected(1);
        
        timeSegmentButton.setImage(UIImage(named: "icon_clock_0"), forState: .Normal);
        chainSegmentButton.setImage(UIImage(named: "icon_chain_1"), forState: .Normal);
        likeSegmentButton.setImage(UIImage(named: "icon_like_0"), forState: .Normal);
    }
    
    @IBAction func segmentThreeSelected(sender: UIButton) {
        self.delegate.segmentSelected(2);
        
        timeSegmentButton.setImage(UIImage(named: "icon_clock_0"), forState: .Normal);
        chainSegmentButton.setImage(UIImage(named: "icon_chain_0"), forState: .Normal);
        likeSegmentButton.setImage(UIImage(named: "icon_like_1"), forState: .Normal);
    }
    
}
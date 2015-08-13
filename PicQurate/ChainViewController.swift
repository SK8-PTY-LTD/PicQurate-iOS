//
//  ChainViewController.swift
//  PicQurate
//
//  Created by SongXujie on 6/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class ChainViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var profileImageView: AVImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var indicatorImageView: UIImageView = UIImageView(frame: CGRectMake(0, 0, 60, 60));
    var imageView: AVImageView!
    var chainArray: [PQChain] = [PQChain]();
    
    override func viewDidLoad() {
        
        self.profileImageView.file = PQ.currentUser.profileImage;
        self.profileImageView.loadInBackground();
        self.profileNameLabel.text = PQ.currentUser.profileName;
        
        //Config scroll view
        var contentSize = self.view.frame.size;
        contentSize.width = contentSize.width * 3;
        self.scrollView.frame.size = CGSizeMake(self.view.frame.width, self.view.frame.width);
        self.scrollView.contentSize = CGSizeMake(self.view.frame.width * 3, self.view.frame.width);
        
//        var leftImageView = UIImageView
        
        self.indicatorImageView.center.y = self.scrollView.center.y;
        self.indicatorImageView.image = UIImage(named: "icon_chain");
        self.view.addSubview(self.indicatorImageView);
        
        self.imageView = AVImageView(frame: CGRectMake(self.view.frame.width, 0, self.view.frame.width, self.view.frame.width));
        self.scrollView.addSubview(imageView);
        self.reloadData();
        
        self.downloadChains();
    }
    
    func downloadChains() {
        var query = PQChain.query();
        query.limit = 10;
        query.includeKey("photo.file");
        //        query.whereKey("user", notEqualTo: PQ.currentUser);
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            if let e = error {
                PQ.showError(e);
            } else {
                if let a = array as? [PQChain] {
                    self.chainArray = a;
                }
                self.reloadData();
            }
        }
    }
    
    func dismissImage() {
        if (self.chainArray.count > 1) {
            self.chainArray.removeLast();
        } else if (self.chainArray.count == 1) {
            self.chainArray.removeLast();
            self.downloadChains();
        } else  {
            NSLog("Image ran out");
        }
        self.reloadData();
    }
    
    func reloadData() {
        if (self.chainArray.count > 0) {
            self.imageView.file = self.chainArray.last?.photo!.file!;
            self.imageView.loadInBackground();
        }
        scrollView.scrollRectToVisible(CGRectMake(self.view.frame.width, 0, self.view.frame.width, self.view.frame.width), animated: false);
    }
    
    @IBAction func dismissButtonClicked(sender: UIButton) {
        self.scrollView.scrollRectToVisible(CGRectMake(self.view.frame.width * 2, 0, self.view.frame.width, self.view.frame.width), animated: true);
        self.dismissImage();
    }
    
    @IBAction func chainButtonClicked(sender: UIButton) {
        var chain = self.chainArray.last!
        PQ.currentUser.chainPhotoWithBlock(chain, block: { (success, error) -> () in
            
        });
        self.scrollView.scrollRectToVisible(CGRectMake(0, 0, self.view.frame.width, self.view.frame.width), animated: true);
        self.dismissImage();
    }
    
    //ScrollView delegate methods
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let x = self.view.frame.width - scrollView.contentOffset.x;
        if (x < 0) {
            self.indicatorImageView.frame.origin.x = -x - self.indicatorImageView.frame.width;
            self.indicatorImageView.alpha = (-x / self.view.frame.width);
            self.indicatorImageView.image = UIImage(named: "icon_dismiss");
        } else if (x == 0) {
            self.indicatorImageView.center.x = -100;
        } else {
            self.indicatorImageView.frame.origin.x = -x + self.view.frame.width;
            self.indicatorImageView.alpha = (x / self.view.frame.width);
            self.indicatorImageView.image = UIImage(named: "icon_chain");
        }
        if (self.scrollView.contentOffset.x == 0) {
            var chain = self.chainArray.last!
            PQ.currentUser.chainPhotoWithBlock(chain, block: { (success, error) -> () in
                
            });
            self.dismissImage();
        } else if (self.scrollView.contentOffset.x == self.view.frame.width * 2) {
            self.dismissImage();
        }
    }
    
}
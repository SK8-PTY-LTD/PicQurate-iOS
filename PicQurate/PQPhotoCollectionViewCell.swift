//
//  ImageViewCollectionViewCell.swift
//  PicQurate
//
//  Created by SongXujie on 4/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

protocol PhotoToProfileProtocol {
    func showLocation(locationArray: [AVGeoPoint], locationNameArray:[String]);
    func showLike(query: AnyObject);
    func showProfile(user: PQUser);
}

class PQPhotoCollectionViewCell: UICollectionViewCell {
    var delegate : PhotoToProfileProtocol?
    @IBOutlet weak var imageView: AVImageView!
    @IBOutlet weak var profileImageView: AVImageView?
    @IBOutlet weak var profileNameButton: UIButton?
    @IBOutlet weak var topLikeButton: UIButton?
    @IBOutlet weak var likeButton: UIButton?
    @IBOutlet weak var chainButton: UIButton?
    @IBOutlet weak var locationButton: UIButton?
    @IBOutlet weak var captionTextView: UITextView?
    
    private var cachedPhoto: PQPhoto?
    var photo: PQPhoto!
    
    var locationArray: [AVGeoPoint] = [];
    var locationNameArray: [String]  = [];
    
    func initializeWithPhoto(photo: PQPhoto) {
        
        self.photo = photo;
        if let image = self.photo.user?.profileImage {
            if let imageView = profileImageView {
                imageView.file = image;
                imageView.loadInBackground();
            }
        }
        if let label = profileNameButton {
            label.setTitle(self.photo.user?.profileName, forState: .Normal);
        }
        if let _ = topLikeButton {
            if (PQ.currentUser != nil && PQ.currentUser.email != nil) {
                PQ.currentUser.hasLikedPhotoithCallback(photo, callback: { (liked, error) -> () in
                    if (liked) {
                        self.topLikeButton?.setBackgroundImage(UIImage(named: "like-icon-1"), forState: .Normal);
                        self.likeButton?.setImage(UIImage(named: "like-icon-1"), forState: .Normal);
                    } else {
                        self.topLikeButton?.setBackgroundImage(UIImage(named: "icon_like_1"), forState: .Normal);
                        self.likeButton?.setImage(UIImage(named: "like-icon"), forState: .Normal);
                    }
                });
            }
        }
        
        if (self.cachedPhoto?.objectId == self.photo?.objectId) {
            //View already initialized, do nothing
        } else {
            self.cachedPhoto = photo;
            
            self.imageView.file = photo.file;
            self.imageView.loadInBackground();
            let query1 = AVRelation.reverseQuery("_User", relationKey: "photoLiked", childObject: self.photo);
            query1.countObjectsInBackgroundWithBlock { (count, error) -> Void in
                if let e = error {
                    PQLog.e(e.localizedDescription);
                } else {
                    self.likeButton?.setTitle("\(count)", forState: .Normal);
                }
            }
            
            let query2 = PQChain.query();
            query2.whereKey("photo", equalTo: self.photo);
            query2.countObjectsInBackgroundWithBlock { (count, error) -> Void in
                if let e = error {
                    PQLog.e(e.localizedDescription);
                } else {
                    self.chainButton?.setTitle("\(count)", forState: .Normal);
                }
            }
            
            let query3 = PQChain.query();
            query3.whereKey("photo", equalTo: self.photo);
            query3.includeKey("original");
            query3.includeKey("original.original");
            query3.includeKey("original.original.original");
            query3.includeKey("original.original.original.original");
            query3.includeKey("user");
            query3.includeKey("original.user");
            query3.includeKey("original.original.user");
            query3.includeKey("original.original.original.user");
            query3.includeKey("original.original.original.original.user");
//            query3.getObjectInBackgroundWithId(self.photo.lastChainId, block: { (object, error) -> Void in
//                if let e = error {
//                    PQLog.e(e.localizedDescription);
//                } else {
//                    if let chain = object as? PQChain {
//                        
//                        var name = chain.user?.profileName;
//                        
//                        if (chain.location != nil) {
//                            if let name = chain.user?.profileName {
//                                self.locationNameArray.append(name);
//                            } else {
//                                self.locationNameArray.append("Private user");
//                            }
//                            self.locationArray.append(chain.location!);
//                        }
//                        if (chain.original?.location != nil) {
//                            if let name = chain.original?.user?.profileName {
//                                self.locationNameArray.append(name);
//                            } else {
//                                self.locationNameArray.append("Private user");
//                            }
//                            self.locationArray.append((chain.original?.location)!);
//                        }
//                        if (chain.original?.original?.location != nil) {
//                            if let name = chain.original?.original?.user?.profileName {
//                                self.locationNameArray.append(name);
//                            } else {
//                                self.locationNameArray.append("Private user");
//                            }
//                            self.locationArray.append((chain.original?.original?.location)!);
//                        }
//                        if (chain.original?.original?.original?.location != nil) {
//                            if let name = chain.original?.original?.original?.user?.profileName {
//                                self.locationNameArray.append(name);
//                            } else {
//                                self.locationNameArray.append("Private user");
//                            }
//                            self.locationArray.append((chain.original?.original?.original?.location)!);
//                        }
//                        if (chain.original?.original?.original?.original?.location != nil) {
//                            if let name = chain.original?.original?.original?.original?.user?.profileName {
//                                self.locationNameArray.append(name);
//                            } else {
//                                self.locationNameArray.append("Private user");
//                            }
//                            self.locationArray.append((chain.original?.original?.original?.original?.location)!);
//                        }
//                    } else {
//                        NSLog("error passing object to PQChain");
//                    }
//                }
//            })

            
            
            self.locationButton?.setTitle(self.photo.locationString, forState: .Normal);
            
            self.captionTextView?.text = self.photo.caption;
            
        }
    }
    
    @IBAction func topLikeButtonClicked(sender: UIButton) {
        if (self.topLikeButton?.backgroundImageForState(.Normal) == UIImage(named: "icon_like_1")) {
            if (PQ.currentUser.email != nil) {
                PQ.currentUser.likePhoto(self.photo, like: true);
            }
            self.topLikeButton?.setBackgroundImage(UIImage(named: "like-icon-1"), forState: .Normal);
            self.likeButton?.setImage(UIImage(named: "like-icon-1"), forState: .Normal);
        } else {
            if (PQ.currentUser.email != nil) {
                PQ.currentUser.likePhoto(self.photo, like: false);
            }
            self.topLikeButton?.setBackgroundImage(UIImage(named: "icon_like_1"), forState: .Normal);
            self.likeButton?.setImage(UIImage(named: "like-icon"), forState: .Normal);
        }
    }
    @IBAction func chainButtonClicked(sender: UIButton) {
        if let delegate = self.delegate {
            delegate.showLocation(locationArray, locationNameArray: locationNameArray);
            NSLog("photo is \(self.photo)");
        }else{
            NSLog("delegate is nil");
        }
    }
    @IBAction func likeButtonClicked(sender: UIButton) {
        if let delegate = self.delegate {
            let query = AVRelation.reverseQuery("_User", relationKey: "photoLiked", childObject: self.photo);
            delegate.showLike(query);
        } else {
            NSLog("delegate is nil");
        }
    }
    @IBAction func profileNameButtonClicked(sender: UIButton) {
        if let delegate = self.delegate {
            delegate.showProfile(self.photo.user!);
            NSLog("sender is \(self.photo.user)");
        }else{
            NSLog("delegate is nil");
        }
    }
    
}
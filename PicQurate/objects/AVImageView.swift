//================================================================================
//  AVImageView.swift
//  Author: Xujie Song
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//================================================================================

import UIKit

class AVImageView: UIImageView {
    
    let MINIMUM_WIDTH: CGFloat = 160;
    let MINIMUM_Height: CGFloat = 160;
    internal var file: AVFile?;
    internal var scale: CGFloat = UIScreen.mainScreen().scale;
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        if let imageFile = file {
            self.loadInBackground();
        }
    }
    
    func loadInBackground() {
        if let imageFile = self.file {
            var width = self.frame.width;
            if (width < MINIMUM_WIDTH) {
                width = MINIMUM_WIDTH;
            }
            var height = self.frame.height;
            if (height < MINIMUM_Height) {
                height = MINIMUM_Height;
            }
            if (!imageFile.isDirty) {
                if let data = imageFile.getData() {
                    var image = UIImage(data: data);
                    self.image = image;
                } else {
                    PQLog.e("Failed to load becuase image file had not uploaded and its data is nil");
                }
            } else {
                imageFile.getThumbnail(false, width: Int32(width * self.scale), height: Int32(height * self.scale), withBlock: { (image, error) -> Void in
                    if let e = error {
                        PQLog.e(e.localizedDescription);
                    } else {
                        self.image = image;
                    }
                })
            }
        } else {
            PQLog.e("Error loading image: file hadn't been set.");
        }
    }
    
//    func loadInBackground(scaleToFit: Bool) {
//        if let imageFile = self.file {
//            var width = self.frame.width;
//            if (width < MINIMUM_WIDTH) {
//                width = MINIMUM_WIDTH;
//            }
//            var height = self.frame.height;
//            if (height < MINIMUM_Height) {
//                height = MINIMUM_Height;
//            }
//            if (!imageFile.isDirty) {
//                if let data = imageFile.getData() {
//                    var image = UIImage(data: data);
//                    self.image = image;
//                } else {
//                    PQLog.e("Failed to load becuase image file had not uploaded and its data is nil");
//                }
//            } else {
//                imageFile.getThumbnail(scaleToFit, width: Int32(width * self.scale), height: Int32(height * self.scale), withBlock: { (image, error) -> Void in
//                    if let e = error {
//                        PQLog.e(e.localizedDescription);
//                    } else {
//                        self.image = image;
//                    }
//                })
//            }
//        } else {
//            PQLog.e("Error loading image: file hadn't been set.");
//        }
//    }
    
    func loadInBackground(block: AVDataResultBlock!) {
        if let imageFile = self.file {
            var width = self.frame.width;
            if (width < MINIMUM_WIDTH) {
                width = MINIMUM_WIDTH;
            }
            var height = self.frame.height;
            if (height < MINIMUM_Height) {
                height = MINIMUM_Height;
            }
            if (!imageFile.isDirty) {
                if let data = imageFile.getData() {
                    var image = UIImage(data: data);
                    self.image = image;
                } else {
                    PQLog.e("Failed to load becuase image file had not uploaded and its data is nil");
                }
            } else {
                imageFile.getThumbnail(false, width: Int32(width * self.scale), height: Int32(height * self.scale), withBlock: { (downloadedImage, error) -> Void in
                    if let e = error {
                        block(nil, error);
                        PQLog.e(e.localizedDescription);
                    } else {
                        self.image = downloadedImage;
                        var data = UIImagePNGRepresentation(downloadedImage);
                        var query: AVFile?
                        block(data, nil);
                    }
                })
            }
        } else {
            PQLog.e("Error loading image: file hadn't been set.");
        }
    }
    
    func setAVFile(file: AVFile) {
        self.file = file;
    }
    
    
}


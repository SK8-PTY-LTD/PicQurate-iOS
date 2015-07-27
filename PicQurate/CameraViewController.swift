//
//  CameraViewController.swift
//  PicQurate
//
//  Created by SongXujie on 25/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

@objc public protocol CameraViewControllerDelegate {
    func onPhotoTaken(image: UIImage);
}

class CameraViewController: IMGLYCameraViewController {
    
    var delegate:CameraViewControllerDelegate?
    
    @objc override
    func image(image: UIImage, didFinishSavingWithError: NSError, contextInfo:UnsafePointer<Void>) {
        cameraView!.setLastImageFromRollAsPreview();
        //Custom methods
        self.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.delegate?.onPhotoTaken(image);
        });
    }
    
}

class CameraNoFilterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var pickerReference: UIImagePickerController!
    
}
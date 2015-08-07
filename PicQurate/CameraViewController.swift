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
    
    let image_size: CGFloat = 720;
    
    var delegate:CameraViewControllerDelegate!
    var pickerReference: UIImagePickerController!
    
    @IBOutlet weak var flashButton: UIButton!
    
    override func viewDidLoad() {
        self.flashButton.hidden = true;
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        self.pickerReference.dismissViewControllerAnimated(true, completion: { () -> Void in
            //Croping
            NSLog("Image size \(image.size)");
            var cropRect = CGRectMake((image.size.height-image.size.width), 0, image.size.width, image.size.width);
            NSLog("Crop size \(cropRect)");
            var imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
            var croppedImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation);
            //Resizing
            croppedImage!.resize(CGSizeMake(self.image_size, self.image_size), completionHandler: { (resizedImage, data) -> () in
                NSLog("Cropped & Resized Image size \(resizedImage.size)");
                self.delegate?.onPhotoTaken(resizedImage);
            });
        });
    }
    
    @IBAction func flashButtonClicked(sender: UIButton) {
        if (self.pickerReference.cameraFlashMode == .On) {
            self.pickerReference.cameraFlashMode = .Off;
            self.flashButton.setBackgroundImage(UIImage(named: "flash-off"), forState: .Normal);
        } else {
            self.pickerReference.cameraFlashMode = .On;
            self.flashButton.setBackgroundImage(UIImage(named: "flash-on"), forState: .Normal);
        }
    }
    
    @IBAction func flipButtonClicked(sender: UIButton) {
        if (self.pickerReference.cameraDevice == .Rear) {
            self.pickerReference.cameraDevice = .Front;
            self.flashButton.hidden = true;
        } else {
            self.pickerReference.cameraDevice = .Rear;
            self.flashButton.hidden = false;
        }
    }
    
    @IBAction func closeButtonClicked(sender: UIButton) {
        self.pickerReference.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        });
    }
    
    @IBAction func shutterButtonClicked(sender: UIButton) {
        self.pickerReference.takePicture();
    }
    
    
}
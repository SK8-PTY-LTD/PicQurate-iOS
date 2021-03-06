//
//  UploadViewController.swift
//  PicQurate
//
//  Created by SongXujie on 30/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class UploadViewController: UIViewController, UITextViewDelegate, CameraViewControllerDelegate {
    
    @IBOutlet weak var imageButton:UIButton!
    @IBOutlet weak var textView:UITextView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    var picker:UIImagePickerController!
    var overlay: CameraNoFilterViewController!
    
    var firsLaunch = true;
    var imageWidth: CGFloat = 320.0;
    
    override func viewDidAppear(animated: Bool) {
        if (firsLaunch) {
            self.launchCamera();
            self.firsLaunch = false;
        }
    }
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem!) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func saveButtonClicked(sender: UIBarButtonItem!) {
        self.uploadPhoto();
    }
    
    @IBAction func saveClicked(sender: UIButton!) {
        self.uploadPhoto();
    }
    
    func uploadPhoto() {
        
        if (self.activityIndicator.isAnimating()) {
            return;
        }
        
        self.activityIndicator.startAnimating();
        if let image = self.imageButton.backgroundImageForState(.Normal) {
            //Croping
            let originalWidth = image.size.width;
            let originalHeight = image.size.height;
            var cropRect: CGRect?
            var scale: CGFloat?
            if (originalWidth <= originalHeight) {
                let difference = (originalHeight - originalWidth) / 2;
                let y = difference;
                cropRect = CGRectMake(0, y, image.size.width, image.size.width);
                scale = 640/image.size.width;
            } else {
                let difference = (originalWidth - originalHeight) / 2;
                let x = difference;
                cropRect = CGRectMake(x, 0, image.size.height, image.size.height);
                scale = 640/image.size.height;
            }
            let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect!);
            let croppedImage = UIImage(CGImage: imageRef!, scale: scale!, orientation: image.imageOrientation);
            //Scaling
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageWidth, imageWidth), false, 0.0);
            croppedImage.drawInRect(CGRectMake(0, 0, imageWidth, imageWidth));
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow]);
            let ciImage = CIImage(image: scaledImage);
            _ = detector.featuresInImage(ciImage!);
            //Old iOS Default Facial Detection
//            if (features.count == 0) {
//                PQ.promote("Hey dear, to upload a selfie, please have a face in it. :)");
//                self.activityIndicator.stopAnimating();
//                return;
//            }
            //New KairosSDK Facial Detection
            KairosSDK.detectWithImage(scaledImage, selector: nil, success: { (response) -> Void in
                if let _ = response["Errors"] {
                    PQ.promote("Hey dear, to upload a selfie, please have a face in it. :)");
                    self.activityIndicator.stopAnimating();
                    return;
                } else {
                    //Successfully detected facec
                    PQ.currentUser.uploadPhotoWithBlock(scaledImage, caption: self.textView.text, block: { (success, error) -> () in
                        if let e = error{
                            PQ.showError(e);
                            self.activityIndicator.stopAnimating();
                        } else {
                            self.activityIndicator.stopAnimating();
                            PQ.promote("Photo chained!");
                            self.dismissViewControllerAnimated(true, completion: nil);
                        }
                    });

                }
                
                }, failure: { (response) -> Void in
                    //Failed to detect face
                    PQ.promote("Hey dear, to upload a selfie, please have a face in it. :)");
                    self.activityIndicator.stopAnimating();
                    return;
            })
        } else {
            PQ.promote("Please take a photo");
            self.activityIndicator.stopAnimating();
        }
    }
    
    func launchCamera() {
        //Old camera, with filter
//        self.performSegueWithIdentifier("segueToCamera", sender: nil);
        
        //New camera, without filter
        self.picker = UIImagePickerController();
        self.picker.sourceType = UIImagePickerControllerSourceType.Camera;
        self.picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo;
        self.picker.cameraDevice = .Front;
        self.picker.showsCameraControls = false;
        
        overlay = CameraNoFilterViewController(nibName: "CameraNoFilterViewController", bundle: nil);
        overlay.view.frame = self.picker.view.frame;
            overlay.pickerReference = self.picker;
        overlay.delegate = self;
            picker.cameraOverlayView?.addSubview(overlay.view);
            picker.delegate = overlay;
        
            self.presentViewController(picker, animated: true) { () -> Void in
                
            }
    }
    
    func onPhotoTaken(image: UIImage) {
        self.imageButton.setBackgroundImage(image, forState: .Normal);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToCamera") {
            let VC = segue.destinationViewController as! CameraNoFilterViewController;
            VC.delegate = self;
        }
    }
    
    @IBAction func imageButtonClicked(sender: UIButton) {
        self.launchCamera();
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView.text == "Write a caption...") {
            textView.text = nil;
        }
    }
}
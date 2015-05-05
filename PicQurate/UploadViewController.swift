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
        self.chainPhoto();
    }
    
    @IBAction func saveClicked(sender: UIButton!) {
        self.chainPhoto();
    }
    
    func chainPhoto() {
        self.activityIndicator.startAnimating();
        if let image = self.imageButton.backgroundImageForState(.Normal) {
            //Croping
            var originalWidth = image.size.width;
            var originalHeight = image.size.height;
            var cropRect: CGRect?
            var scale: CGFloat?
            if (originalWidth <= originalHeight) {
                var difference = (originalHeight - originalWidth) / 2;
                var y = difference;
                cropRect = CGRectMake(0, y, image.size.width, image.size.width);
                scale = 640/image.size.width;
            } else {
                var difference = (originalWidth - originalHeight) / 2;
                var x = difference;
                cropRect = CGRectMake(x, 0, image.size.height, image.size.height);
                scale = 640/image.size.height;
            }
            var imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect!);
            var croppedImage = UIImage(CGImage: imageRef, scale: scale!, orientation: image.imageOrientation);
            //Scaling
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageWidth, imageWidth), false, 0.0);
            croppedImage?.drawInRect(CGRectMake(0, 0, imageWidth, imageWidth));
            var scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            //Saving
            var file = AVFile.fileWithName("photo.jpg", data: UIImageJPEGRepresentation(scaledImage, 1.0)) as! AVFile;
            file.saveInBackgroundWithBlock({ (success, error) -> Void in
                if let e = error {
                    PQ.showError(e);
                    self.activityIndicator.stopAnimating();
                } else {
                    var photo = PQPhoto(file: file);
                    photo.caption = self.textView.text;
                    photo.user = PQ.currentUser;
                    photo.location = PQ.currentUser.location;
                    photo.locationString = PQ.currentUser.locationString;
                    
                    PQ.currentUser.chainPhotoWithCallBack(photo, originalChain: nil, callback: { (success, error) -> () in
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
            })
        } else {
            PQ.promote("Please take a photo");
            self.activityIndicator.stopAnimating();
        }
    }
    
    func launchCamera() {
        self.performSegueWithIdentifier("segueToCamera", sender: nil);
    }
    
    func onPhotoTaken(image: UIImage) {
        self.imageButton.setBackgroundImage(image, forState: .Normal);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToCamera") {
            var VC = segue.destinationViewController as! CameraViewController;
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
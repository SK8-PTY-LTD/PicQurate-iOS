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
        if let image = self.imageButton.imageForState(.Normal) {
            var file = AVFile.fileWithData(UIImageJPEGRepresentation(image, 1.0)) as! AVFile;
            file.setValue(self.textView.text, forKey: "caption");
            file.saveInBackgroundWithBlock({ (success, error) -> Void in
                if let e = error {
                    PQ.showError(e);
                    self.activityIndicator.stopAnimating();
                } else {
                    var chain = PQChain(photo: file);
                    chain.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if let e = error{
                            PQ.showError(e);
                            self.activityIndicator.stopAnimating();
                        } else {
                            self.activityIndicator.stopAnimating();
                            PQ.promote("Photo chained!");
                            self.dismissViewControllerAnimated(true, completion: nil);
                        }
                    })
                }
            })
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
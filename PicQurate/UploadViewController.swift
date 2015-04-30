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
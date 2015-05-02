//
//  TabViewController.swift
//  PicQurate
//
//  Created by SongXujie on 26/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class TabViewController: UITabBarController {
    
    override func viewWillAppear(animated: Bool) {
        var button = UIButton()
        var buttonImage = UIImage(named: "camera");
        button.frame = CGRectMake(0.0, 0.0, buttonImage!.size.width, buttonImage!.size.height);
        button.setBackgroundImage(buttonImage!, forState: .Normal);
        //        button.setBackgroundImage(highlightImage!, forState: .Highlighted);
        //        [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
        
        var heightDifference = buttonImage!.size.height - self.tabBar.frame.size.height;
        if (heightDifference < 0) {
            button.center = self.tabBar.center;
        } else {
            var center = self.tabBar.center;
            center.y = center.y - heightDifference/2.0;
            button.center = center;
        }
        
        button.addTarget(self, action: "cameraButtonClicked", forControlEvents: .TouchUpInside);
        
        self.view.addSubview(button);
    }
    
    func cameraButtonClicked() {
        self.performSegueWithIdentifier("segueToUpload", sender: nil);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToUpload") {
            var VC = segue.destinationViewController as! UploadViewController;
        }
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        if let user = PQ.currentUser {
            //User logged in, do nothing
        } else {
            self.performSegueWithIdentifier("segueToLogin", sender: nil);
        }
    }
    
    
}

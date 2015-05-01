//
//  HomeViewController.swift
//  PicQurate
//
//  Created by SongXujie on 24/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class HomeViewController: ViewPagerController, ViewPagerDelegate, ViewPagerDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.dataSource = self;
        self.delegate = self;
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let user = PQ.currentUser {
            //User logged in, do nothing
        } else {
            self.performSegueWithIdentifier("segueToLogin", sender: nil);
        }
    }
    
    //pragma mark - ViewPagerDataSource
    func numberOfTabsForViewPager(viewPager: ViewPagerController!) -> UInt {
        return 3;
    }
    
    func viewPager(viewPager: ViewPagerController!, viewForTabAtIndex index: UInt) -> UIView! {
        var label = UILabel();
        switch index {
        case 0:
            label.text = "World";
        case 1:
            label.text = "Daily";
        case 2:
            label.text = "Local";
        default:
            label.text = "New Tab";
        }
        label.sizeToFit();
        
        return label;
    }
    
//    func viewPager(viewPager: ViewPagerController!, contentViewControllerForTabAtIndex index: UInt) -> UIViewController! {
//        return nil;
//    }
    
    func viewPager(viewPager: ViewPagerController!, colorForComponent component: ViewPagerComponent, withDefault color: UIColor!) -> UIColor! {
        switch component {
        case ViewPagerComponent.Indicator:
            return PQ.primaryColor;
        default:
            return color;
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToLogin") {
            var VC = segue.destinationViewController as! LandingViewController;
        }
    }
}
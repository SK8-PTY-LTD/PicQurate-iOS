//
//  UserTableViewController.swift
//  PicQurate
//
//  Created by SongXujie on 7/05/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class UserTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var query: AVQuery!
    
    private var userArray: [PQUser] = [PQUser]();
    
    override func viewDidLoad() {
        
        self.downloadUser();
        
    }
    
    func downloadUser() {
//        self.query?
        PQUser.query().findObjectsInBackgroundWithBlock({ (array, error) -> Void in
            if let e = error {
                PQ.showError(e)
            } else {
                if let a = array as? [PQUser] {
                    self.userArray = a;
                    self.tableView.reloadData();
                } else {
                    PQLog.e("Error downcasting [AnyObject] to [AVUser]");
                }
            }
        });
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userArray.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserTableViewCell;
        let user = self.userArray[indexPath.row];
        cell.initWithUser(user);
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = self.userArray[indexPath.row];
        self.performSegueWithIdentifier("segueToProfile", sender: user);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToProfile") {
            var VC = segue.destinationViewController as! ProfileViewController;
            var user = sender as! PQUser;
            VC.user = user;
            VC.title = user.profileName;
        }
    }
}
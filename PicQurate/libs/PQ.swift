//
//  PQ.swift
//  DropShop
//
//  Created by SK8 Admin on 8/12/2014.
//  Copyright (c) 2014 Xujie Song. All rights reserved.
//

import Foundation

extension UIImage {
    public func resize(size:CGSize, completionHandler:(resizedImage:UIImage, data:NSData)->()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            var newSize:CGSize = size
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageData = UIImageJPEGRepresentation(newImage, 0.5)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(resizedImage: newImage, data:imageData)
            })
        })
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: String!) {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (count(cString) != 6) {
            self.init(
                red: CGFloat(255.0) / 255.0,
                green: CGFloat(102.0) / 255.0,
                blue: CGFloat(0.0) / 255.0,
                alpha: CGFloat(1.0)
            )
        } else {
            var rgbValue:UInt32 = 0
            NSScanner(string: cString).scanHexInt(&rgbValue)
            
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }
    }
    
    func toHexString() -> String {
        var red: CGFloat = 0.0;
        var green: CGFloat = 0.0;
        var blue: CGFloat = 0.0;
        var alpha: CGFloat = 0.0;
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha);
        
        var redString = String(Int(red), radix: 16);
        var greenString = String(Int(green), radix: 16);
        var blueString = String(Int(blue), radix: 16);
        var hex = "#" + redString + greenString + blueString;
        return hex;
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

@objc protocol PQProtocol: UITextFieldDelegate {
    optional func onUserRefreshed();
}

class PQ: NSObject {
    
    // Workaround:
    struct Static {
        
        // This is just for the sake of Android, has to have it
        
        static let AV_APP_ID = "x4o5c93khy5wlgcyu2mr3qtnztjtwdbylpr3h8qk8c9mriow";
        static let AV_APP_KEY = "t61bgn6q39woxr48vgnf49upxauigarg2glj8ktvri32jesg";
        
        static let PRIMARY_COLOR: UIColor = UIColor(hex: "#BE0004");
        
        static var currentUser: PQUser?;
        
        static var delegate: PQProtocol?;
    }
    
    class var primaryColor: UIColor {
        get { return Static.PRIMARY_COLOR }
    }
    
    class var currentUser: PQUser! {
        get { return Static.currentUser }
        set { Static.currentUser = newValue }
    }
    
    class var delegate: PQProtocol? {
        get { return Static.delegate }
        set { Static.delegate = newValue }
    }
    
    class func initialize(launchOption: [NSObject: AnyObject]!) {
        
        //When app starts, set up AV
        
        PQUser.registerSubclass();
        PQChain.registerSubclass();
        PQPhoto.registerSubclass();
        PQPush.registerSubclass();
        
        AVOSCloud.useAVCloudUS();
        AVOSCloud.setApplicationId(PQ.Static.AV_APP_ID, clientKey: PQ.Static.AV_APP_KEY);
        AVAnalytics.trackAppOpenedWithLaunchOptions(launchOption);
        
        PQUser.enableAutomaticUser();
        
        if let user = PQUser.currentUser() {
            PQ.currentUser = user;
        } else {
            AVAnonymousUtils .logInWithBlock({ (anonymousUser, error) -> Void in
                if let e = error {
                    
                } else {
                    PQ.currentUser = PQUser.currentUser();
                }
            })
        }
        
    }
    
    class func sendPush(query: AVQuery, message: String) -> NSError? {
        var error: NSError?
        var push = AVPush();
        push.setQuery(query);
        push.setMessage(message);
        push.sendPush(&error)
        return error;
    }
    
    class func sendPushWithCallBack(query: AVQuery, message: String, callback: AVBooleanResultBlock) {
        var notification = AVPush();
        notification.setQuery(query);
        notification.setMessage(message);
        notification.sendPushInBackgroundWithBlock(callback);
    }
    
    class func showError(error: NSError) {
        NSLog("Error: " + error.localizedDescription);
        var errorString = error.localizedDescription;
        let alert = UIAlertView()
        alert.title = "Oops";
        alert.message = errorString
        alert.addButtonWithTitle("OK!")
        alert.show()
    }
    
    class func promote(message: String) {
        NSLog("Info: " + message);
        let alert = UIAlertView()
        alert.title = "PicQurate";
        alert.message = message
        alert.addButtonWithTitle("OK!")
        alert.show()
    }
    
}

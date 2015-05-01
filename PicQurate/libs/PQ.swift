//
//  PQ.swift
//  DropShop
//
//  Created by SK8 Admin on 8/12/2014.
//  Copyright (c) 2014 Xujie Song. All rights reserved.
//

import Foundation

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
    optional func onSMSVerified();
    optional func onUserRefreshed();
    optional func onShopRefreshed();
    optional func onSellerRefreshed();
}

class PQ: NSObject, UITextFieldDelegate, UIAlertViewDelegate {
    
    // Workaround:
    struct Static {
        
        // This is just for the sake of Android, has to have it
        
        static let AV_APP_ID = "x4o5c93khy5wlgcyu2mr3qtnztjtwdbylpr3h8qk8c9mriow";
        static let AV_APP_KEY = "t61bgn6q39woxr48vgnf49upxauigarg2glj8ktvri32jesg";
        
//        static let YTX_ACCOUNT_SID = "8a48b5514b0b8727014b114f547e037d";
//        static let YTX_ACCOUNT_AUTH_TOKEN = "efe84f72028c4025ac83febe5f052fe7";
//        static let YTX_APP_ID = "ID8a48b5514b0b8727014b22a0d0d5108d";
        
        //	public static ECChatManager MESSAGE_MANAGER;
        //	public static ECGroupManager GROUP_MANAGER;
        
        // Verification code for mobile number verification
        static var verificationCode: Int?;
        
        // Custom Variables required by PQ Library, but is dependent on End App
        // Set them in init() method
        static let PRIMARY_COLOR: UIColor = UIColor(hex: "#BE0004");
//        static let ORANGE_SECONDARY: UIColor = UIColor(hex: "#ff9933");
//        static let WHITE: UIColor = UIColor(hex: "#ffffff");
//        static let GREY_LIGHTEST = UIColor(hex: "#f7f7f7");
//        static let GREY: UIColor = UIColor(hex: "#dddddd");
//        static let GREY_DARKEST: UIColor = UIColor(hex: "#777777");
//        static let BLACK: UIColor = UIColor(hex: "#222222");
        
        // Static variables for easy use
//        static var currentShop: SHShop?;
//        static var currentSeller: PQUser?;
        
        static var currentUser: PQUser?;
//        static var currentPurchase: SHPurchase?;
//        static var admin: PQUser?;
        
        static var delegate: PQProtocol?;
    }
    
    internal class var verificationCode: Int! {
        get { return Static.verificationCode }
        set { Static.verificationCode = newValue }
    }
    
    class var primaryColor: UIColor {
        get { return Static.PRIMARY_COLOR }
    }
//
//    class var currentSeller: PQUser! {
//        get { return Static.currentSeller }
//        set { Static.currentSeller = newValue }
//    }
    
    class var currentUser: PQUser! {
        get { return Static.currentUser }
        set { Static.currentUser = newValue }
    }
    
//    class var currentPurchase: SHPurchase! {
//        get { return Static.currentPurchase }
//        set { Static.currentPurchase = newValue }
//    }
//    
//    class var admin: PQUser! {
//        get { return Static.admin }
//        set { Static.admin = newValue }
//    }
    
    class var delegate: PQProtocol? {
        get { return Static.delegate }
        set { Static.delegate = newValue }
    }
    
    class func initialize(launchOption: [NSObject: AnyObject]!) {
        
        //When app starts, set up AV
//        SHAddress.registerSubclass();
//        SHCategory.registerSubclass();
//        SHComment.registerSubclass();
//        SHMembership.registerSubclass();
//        SHProduct.registerSubclass();
//        SHPurchase.registerSubclass();
//        SHPurchaseEntry.registerSubclass();
//        SHShop.registerSubclass();
        PQUser.registerSubclass();
        
        AVOSCloud.useAVCloudUS();
        AVOSCloud.setApplicationId(PQ.Static.AV_APP_ID, clientKey: PQ.Static.AV_APP_KEY);
        AVAnalytics.trackAppOpenedWithLaunchOptions(launchOption);
        AVAnalytics.setCrashReportEnabled(true);
        
        if let user = PQUser.currentUser() {
            PQ.currentUser = PQUser.currentUser();
        }
        
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
    
    class func sendSMS(receiver: String, message: String) -> NSError? {
        var error: NSError?
        var params = ["receiver": receiver, "message": message];
        AVCloud.callFunction("sendSMS", withParameters: params, error: &error);
        return error;
    }
    
    class func sendSMSWithCallback(receiver: String, message: String, callback: (message: String, error: NSError?) -> ()) {
        var params = ["receiver": receiver, "message": message];
        AVCloud.callFunctionInBackground("sendSMS", withParameters: params) { (message, error) -> Void in
            callback(message: message as! String, error: error);
        }
    }
    
    class func sendSMSVerificatonWithCallback(delegate: PQProtocol) {
        
        PQ.delegate = delegate;
        
        // Start an alert, asking number
        let alert = UIAlertView()
        alert.title = "What's your number?";
        alert.message = "For your security, mobile verification is required. Please enter your number, starting with the country code. e.g. 86 134xxxx4876, 61 449xxx149, or 65 82xxxx13."
        
        // Set an TextView view to get user input
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput;
        let textField = alert.textFieldAtIndex(0);
        textField?.placeholder = "8613482504876";
        textField?.delegate = delegate;
        textField?.keyboardType = UIKeyboardType.NumberPad;
        
        alert.addButtonWithTitle("Cancel")
        alert.addButtonWithTitle("Send SMS")
        
        alert.delegate = self;
        alert.show();
        
    }
    
    class func sendEmail(receiver: String, subject: String, message: String) -> NSError? {
        var error: NSError?
        var params = ["receiver": receiver, "subject": subject, "message": message];
        AVCloud.callFunction("sendEmail", withParameters: params, error: &error);
        return error;
    }
    
    class func sendEmailWithCallBack(receiver: String, subject: String, message: String, callback: (email: String, error: NSError?) -> ()) {
        var params = ["receiver": receiver, "subject": subject, "message": message];
        AVCloud.callFunctionInBackground("sendEmail", withParameters: params) { (email, error) -> Void in
            callback(email: email as! String, error: error);
        };
    }
    
    class func reportPhoto(photo: AVFile, message: String) {
//        var emailMessage = PQ.currentUser.profileName! + " said: " + message + ". Please reply to :" + PQ.currentUser.email;
//        PQ.sendEmail(PQ.currentShop.getEmail()!, subject: "New Feedback for photo: " + photo.url, message: emailMessage);
//        
//        var emailBody = PQ.currentUser.getProfileName()! + " reported photo " + photo.url + ", id: " + photo.url + ". Link: https://leancloud.cn/data.html?appid=x4o5c93khy5wlgcyu2mr3qtnztjtwdbylpr3h8qk8c9mriow#/";
//        PQ.sendEmailWithCallBack("sk8tech@163.com", subject: "New Feedback for photo: " + product.objectId, message: emailBody, callback: { (email, error) -> () in
//            if let e = error {
//                PQ.showError(e);
//            } else {
//                PQ.promote("Thank you for your feedback! We will get back to you soon!");
//            }
//        });
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
        var push = AVPush();
        push.setQuery(query);
        push.setMessage(message);
        push.sendPushInBackgroundWithBlock(callback);
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        var mobile: String?
        if (alertView.title == "What's your number?") {
            if (buttonIndex == 0) {
                //Cancel tapped, do nothing
            } else if (buttonIndex == 1) {
                // Get user phone number, and check if it's valid
                var testNumber = alertView.textFieldAtIndex(0)?.text;
                var f = NSNumberFormatter();
                
                if let number = f.numberFromString(testNumber!) {
                    // Call cloud function to send verification SMS
                    PQ.verificationCode = Int((arc4random() * 9 + 1) * 100000)
                    var message = "\(PQ.verificationCode) is your verification code from PQ, enjoy shopping! :)";
                    mobile = "+\(number)"
                    PQ.sendSMSWithCallback(mobile!, message: message, callback: { (message, error) -> () in
                        if let e = error {
                            PQ.promote("Verification SMS failed to send. Please try again later.");
                        } else {
                            var alert = UIAlertView()
                            alert.title = "SMS on its way!"
                            alert.message = "It should be there any second now. Please enter the verification code below."
                            alert.addButtonWithTitle("Cancel")
                            alert.addButtonWithTitle("Verify")
                            let textField = alert.textFieldAtIndex(0);
                            textField?.placeholder = "xxxxxx";
                            textField?.delegate = self;
                            textField?.keyboardType = UIKeyboardType.NumberPad;
                            alert.delegate = self;
                            alert.show();
                        }
                    })
                    
                } else {
                    NSLog(testNumber!);
                    //Phone number is not valid
                    var alert = UIAlertView();
                    alert.title = "Oops";
                    alert.message = "Please enter a valid phone number, starting with the country code."
                    alert.addButtonWithTitle("OK")
                    alert.show();
                }
            }
        } else if (alertView.title == "SMS on its way!") {
            if (buttonIndex == 0) {
                //Cancel tapped, do nothing
            } else if (buttonIndex == 1) {
                //Mobile phont verified
                var verificationCode = alertView.textFieldAtIndex(0)?.text.toInt();
                if (verificationCode == PQ.verificationCode) {
                    PQ.currentUser?["mobileNumber"] = mobile;
                    PQ.currentUser?.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if let e = error {
                            PQ.showError(e);
                        } else {
                            if let method = PQ.delegate?.onSMSVerified {
                                method();
                            }
                        }
                    });
                } else {
                    PQ.promote("Invalid verification code.");
                }
            }
            
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string);
        var expression = "^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        var regex : NSRegularExpression = NSRegularExpression(pattern: expression, options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!;
        var numberOfMatches = regex.numberOfMatchesInString(newString, options: nil, range: NSRange(location: 0, length: count(newString.utf16)));
        if (numberOfMatches == 0) {
            return false;
        } else {
            return true;
        }
    }
    
    class func playRefreshSound() {
        AudioServicesPlaySystemSound(1322);
    }
    
    class func playSentSound() {
        AudioServicesPlaySystemSound (1004);
    }
    
    class func playReceivedSound() {
        AudioServicesPlaySystemSound (1003);
    }
    
    class func playAlarmSound() {
        var fileURL = NSURL(string: "/System/Library/Audio/UISounds/sq_alarm.caf");
        var soundID = SystemSoundID();
        AudioServicesCreateSystemSoundID(fileURL, &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
    
    class func playTriTone() {
        AudioServicesPlaySystemSound (1016);
    }
    
    class func playCustomSound() {
        var soundPath = NSBundle.mainBundle().pathForResource("refresh", ofType: "mp3");
        var soundID = SystemSoundID();
        var fileURL = NSURL(fileURLWithPath: soundPath!);
        AudioServicesCreateSystemSoundID(fileURL, &soundID);
        AudioServicesPlaySystemSound (soundID);
    }
    
    class func muteShutterSound() {
        var soundPath = NSBundle.mainBundle().pathForResource("photoShutter2", ofType: "caf");
        var soundID = SystemSoundID();
        var fileURL = NSURL(fileURLWithPath: soundPath!);
        AudioServicesCreateSystemSoundID(fileURL, &soundID);
        AudioServicesPlaySystemSound (soundID);
    }
    
}

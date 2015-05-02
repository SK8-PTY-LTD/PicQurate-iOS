//================================================================================
//  PQUser is a subclass of AVUser
//  Class name: _User
//  Author: Xujie Song
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//================================================================================

import Foundation

public class PQUser : AVUser, AVSubclassing {
    
    // ================================================================================
    // Constructors
    // ================================================================================
    
    public class func parseClassName() -> String {
        return "_User"
    }
    
    override init() {
        super.init();
    }
    
    override init(className: String) {
        super.init(className: PQUser.parseClassName());
    }
    
    init(userId: String) {
        super.init();
        self.objectId = userId;
    }
    
    init(email: String, password: String, profileName: String) {
        super.init();
        self.username = email;
        self.email = email;
        self.password = password;
        self.balance = 0;
        self.profileName = profileName;
    }
    
    // ================================================================================
    // Class Properties
    // ================================================================================
    
    // ================================================================================
    // Shelf Methods
    // ================================================================================
    
    func isUser(user: PQUser) -> Bool {
        return self.objectId == user.objectId;
    }
    
    func isNotUser(user: PQUser) -> Bool {
        return !self.isUser(user);
    }
    
//    func hasLikedProductWithCallback(product: SHProduct, callback: (liked :Bool, error: NSError?) -> ()) {
//        var query = self.getProductLiked().query();
//        var productId = product.objectId;
//        query.whereKey("objectId", equalTo:productId);
//        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
//            if let e = error {
//                callback(liked: false, error: e);
//            } else {
//                var liked = (count == 1);
//                callback(liked: liked, error: nil);
//            }
//        }
//    }
    
    func hasVerifiedEmail() -> Bool {
        return self.objectForKey("emailVerified") as! Bool;
    }
    
//    func hasVerifiedMobileNumber() -> Bool {
//        if let mobileNumber = self.getMobileNumber() {
//            return true;
//        } else {
//            return false;
//        }
//    }
//    
//    func likeProduct(product: SHProduct, like: Bool) {
//        // Add product to like query
//        var relation = self.getProductLiked();
//        if (like) {
//            relation.addObject(product);
//        } else {
//            relation.removeObject(product);
//        }
//        self.saveInBackground();
//        // Send a notification to the owner;
//        var message = self.getProfileName()! + " just liked your " + product.getName()!;
//        var query = AVInstallation.query();
//        query.whereKey("userId", equalTo: product.getSeller()!.objectId);
//        Shelf.sendPush(query, message: message);
//    }
//    
//    func likeProductWithCallBack(product: SHProduct, like: Bool, callback: (liked :Bool, error: NSError?) -> ()) {
//        // Add product to like query
//        var relation = self.getProductLiked();
//        if (like) {
//            relation.addObject(product);
//        } else {
//            relation.removeObject(product);
//        }
//        self.saveInBackgroundWithBlock { (succeed, error) -> Void in
//            callback(liked: like, error: error);
//        }
//        // Send a notification to the owner;
//        var message = self.getProfileName()! + " just liked your " + product.getName()!;
//        var query = AVInstallation.query();
//        query.whereKey("userId", equalTo: product.getSeller()!.objectId);
//        Shelf.sendPush(query, message: message);
//    }
//    
//    func getAddressWithCallBack(callback: (address :SHAddress?, error: NSError?) -> ()) {
//        if let address = self.getAddress() {
//            address.fetchInBackgroundWithBlock({ (address, error) -> Void in
//                callback(address: address as? SHAddress, error: error);
//            })
//        } else {
//            var error = NSError(domain: "http://www.shelf.is", code: 400, userInfo: [description: "Address is nil"])
//            callback(address: nil, error: error);
//        }
//    }
    
//    func getCurrentUser() -> PQUser? {
//        return AVUser.currentUser() as? PQUser;
//    }
    
//    func getMembershipWithCallback(shop: SHShop, callback: (membership :SHMembership, error: NSError?) ->()) {
//        // Retrieve Membership
//        var query = SHMembership.query();
//        query.whereKey("user", equalTo: self);
//        query.whereKey("shop", equalTo: shop);
//        query.getFirstObjectInBackgroundWithBlock { (membership, error) -> Void in
//            callback(membership: membership as SHMembership, error: nil);
//        }
//    }
//    
//    func getProductLiked() -> AVRelation {
//        var likeRelation = self.relationforKey("productLiked");
//        likeRelation.targetClass = "Product";
//        return likeRelation;
//    }
//    
//    func getRatingWithCallback(callback: (rating: Int, error: NSError?) -> ()) {
//        // The object was retrieved successfully.
//        var query = SHPurchaseEntry.query();
//        query.whereKey("seller", equalTo: self);
//        query.findObjectsInBackgroundWithBlock { (list, error) -> Void in
//            if let e = error {
//                callback(rating: 5, error: e);
//            } else {
//                if (list.count != 0) {
//                    var rating = 0;
//                    for (var i = 0; i < list.count; i++) {
//                        var entry = list[i] as SHPurchaseEntry;
//                        rating += entry.getRating()!;
//                    }
//                    var result: Double = Double(rating) / Double(list.count)
//                    rating = Int(result);
//                    callback(rating: rating, error: nil);
//                } else {
//                    callback(rating: 5, error: nil);
//                }
//            }
//        }
//    }
//    
//    func getShopLiked() -> AVRelation {
//        var likeRelation = self.relationforKey("shopLiked");
//        likeRelation.targetClass = "Shop";
//        return likeRelation;
//    }
//    
//    func updateCard(token: STPToken) {
//        var params = ["tokenId": token.tokenId];
//        AVCloud.callFunctionInBackground("updateCard", withParameters: params, block: nil);
//    }
    
    // ================================================================================
    // Property setters and getters
    // ================================================================================
    
//    @NSManaged var addressId: String?
//    @NSManaged var backgroundImage: AVFile?
    @NSManaged var bio: String?
    @NSManaged var balance: Int
    @NSManaged var emailVerified: Bool
    @NSManaged var gender: Bool
    @NSManaged var installationId: String?
    @NSManaged var location: AVGeoPoint?
    @NSManaged var locationString: String?
//    @NSManaged var mobileNumber: String?
    @NSManaged var profileImage: AVFile?
    @NSManaged var profileName: String?
    @NSManaged var realName: String?
    @NSManaged var url: String?
    
//    var address: SHAddress? {
//        get {
//            if let id = self.addressId {
//                var address = SHAddress(addressId: id);
//                return address;
//            } else {
//                return nil;
//            }
//        }
//        set {
//            self.addressId = newValue?.objectId;
//        }
//    };
//    
//    func getAddress() -> SHAddress? {
//        if let addressId: AnyObject = self.objectForKey("addressId") {
//            var address = SHAddress(addressId: addressId as String);
//            return address;
//        } else {
//            return nil;
//        }
//    }
//    
//    func setAddress(address: SHAddress) {
//        self.setObject(address.objectId, forKey: "addressId");
//    }
//    
//    func getBackgroundImage() -> AVFile? {
//        return self.objectForKey("backgroundImage") as? AVFile;
//    }
//    
//    func setBackgroundImage(backgroundImage: UIImage) {
//        var imageFile: AVFile = AVFile.fileWithName("background.jpg", data: UIImageJPEGRepresentation(backgroundImage, 1.0)) as AVFile;
//        self.setObject(imageFile, forKey:"backgroundImage");
//        self.saveInBackground();
//    }
//    
//    func getBio() -> String? {
//        return self.objectForKey("bio") as? String;
//    }
//    
//    func setBio(bio: String) {
//        self.setObject(bio, forKey: "bio");
//    }
    
    func getInstallation() -> AVInstallation {
        if let installationId: String = self.objectForKey("installationId") as? String {
            var installation = AVInstallation(withoutDataWithObjectId: installationId);
            return installation;
        } else {
            var installation = AVInstallation.currentInstallation();
            self.setInstallation(installation);
            return installation;
        }
    }
    
    func setInstallation(installation: AVInstallation) {
        if let installationId = installation.objectId {
            self.setObject(installation.objectId, forKey: "installationId");
        } else {
            NSLog("Installation is nil");
        }
    }
    
    func getMobileNumber() -> String? {
        return self.objectForKey("mobileNumber") as? String;
    }
    
    func setMobileNumber(number: String) {
        self.setObject(number, forKey: "mobileNumber");
        self.setObject(true, forKey: "mobilePhoneVerified");
        self.saveInBackground();
    }
    
    func getProfileImage() -> AVFile? {
        return self.objectForKey("profileImage") as? AVFile;
    }

    func setProfileUIImage(profileImage: UIImage) {
        var imageFile: AVFile = AVFile.fileWithName("profile.jpg", data: UIImageJPEGRepresentation(profileImage, 1.0)) as! AVFile;
        imageFile.saveInBackgroundWithBlock { (success, error) -> Void in
            if let e = error {
                NSLog("Profile image failed to save, error: " + e.localizedDescription);
            } else {
                self.setObject(imageFile, forKey:"profileImage");
                self.saveInBackground();
            }
        }
    }

    func getProfileName() -> String? {
        return self.objectForKey("profileName") as? String;
    }

    private func setProfileName(profileName: String) {
        self.setObject(profileName, forKey: "profileName");
    }
    
    // ================================================================================
    // Export class
    // ================================================================================
    
}

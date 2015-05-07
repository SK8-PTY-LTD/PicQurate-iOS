//================================================================================
//  PQChain is a subclass of AVObject
//  Class name: Chain
//  Author: Xujie Song
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//================================================================================

import Foundation

class PQChain : AVObject, AVSubclassing {
    
    // ================================================================================
    // Constructors
    // ================================================================================
    
    class func parseClassName() -> String? {
        return "Chain"
    }
    
    override init() {
        super.init();
    }
    
    init(chainId: String) {
        super.init();
        self.objectId = chainId;
    }
    
    init(photo: PQPhoto) {
        super.init();
        self.photo = photo;
    }
    
    // ================================================================================
    // Class properties
    // ================================================================================
    
    // ================================================================================
    // Shelf Methods
    // ================================================================================
    
    func getUserWithBlock(block: (user: PQUser?, error: NSError?) -> ()) {
        if let user = self.user {
            var query = PQUser.query();
            query.getObjectInBackgroundWithId(user.objectId, block: { (user, error) -> Void in
                block(user: user as? PQUser, error: error);
            })
        } else {
            PQLog.e("getUserWithCallback: chain.user returns nil");
        }
    }
    
    // ================================================================================
    // Property setters and getters
    // ================================================================================
    
    @NSManaged var photo: PQPhoto?
    @NSManaged var user: PQUser?
    @NSManaged var gender: Bool
    @NSManaged var original: PQChain?
    @NSManaged var originalLocation: AVGeoPoint?
    @NSManaged var location: AVGeoPoint?
    @NSManaged var locationString: String?
    
//    func getOriginal() -> PQChain? {
//        return self.objectForKey("original") as? PQChain;
//    }
//    
//    func setOriginal(original: PQChain) {
//        self.setObject(original, forKey: "original");
//    }
//
//    
//    func getPhoto() -> AVFile? {
//        return self.objectForKey("photo") as? AVFile;
//    }
//    
//    func setPhoto(photo: AVFile) {
//        self.setObject(photo, forKey: "photo");
//    }
//    
//    func getUser() -> PQUser? {
//        return self.objectForKey("user") as? PQUser;
//    }
//    
//    func setUser(user: PQUser) {
//        self.setObject(user, forKey: "user");
//    }
    
    // ================================================================================
    // Export class
    // ================================================================================
    
}

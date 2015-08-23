//================================================================================
//  PQPhoto is a subclass of AVObject
//  Class name: Photo
//  Author: Xujie Song
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//================================================================================

import Foundation

class PQPhoto : AVObject, AVSubclassing {
    
    // ================================================================================
    // Constructors
    // ================================================================================
    
    class func parseClassName() -> String? {
        return "Photo"
    }
    
    override init() {
        super.init();
    }
    
    init(PhotoId: String) {
        super.init();
        self.objectId = PhotoId;
    }
    
    init(file: AVFile) {
        super.init();
        self.file = file;
        self.user = PQ.currentUser;
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
            PQLog.e("getUserWithCallback: Photo.user returns nil");
        }
    }
    
    // ================================================================================
    // Property setters and getters
    // ================================================================================
    
    @NSManaged var caption: String?
    @NSManaged var lastChainId: String?
    @NSManaged var file: AVFile?
    @NSManaged var gender: NSNumber
    @NSManaged var user: PQUser?
    @NSManaged var location: AVGeoPoint?
    @NSManaged var locationString: String?
    
    //    func getOriginal() -> PQPhoto? {
    //        return self.objectForKey("original") as? PQPhoto;
    //    }
    //
    //    func setOriginal(original: PQPhoto) {
    //        self.setObject(original, forKey: "original");
    //    }
    //
    //
    //    func getFile() -> AVFile? {
    //        return self.objectForKey("file") as? AVFile;
    //    }
    //
    //    func setFile(file: AVFile) {
    //        self.setObject(file, forKey: "file");
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

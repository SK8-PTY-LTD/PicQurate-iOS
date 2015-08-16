//================================================================================
//  PQPush is a subclass of AVObject
//  Class name: Photo
//  Author: Xujie Song
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//================================================================================

import Foundation

class PQPush : AVObject, AVSubclassing {
    
    // ================================================================================
    // Constructors
    // ================================================================================
    
    class func parseClassName() -> String? {
        return "Push"
    }
    
    override init() {
        super.init();
    }
    
    init(pushId: String) {
        super.init();
        self.objectId = pushId;
    }
    
    init(message: String, user: PQUser, photo: PQPhoto?) {
        super.init();
        self.sender = PQ.currentUser;
        self.user = user;
        self.message = message;
        if (photo != nil){
            self.photo = photo!
        }
    }
    
    // ================================================================================
    // Class properties
    // ================================================================================
    
    // ================================================================================
    // Shelf Methods
    // ================================================================================
    
    
    
    // ================================================================================
    // Property setters and getters
    // ================================================================================
    
    @NSManaged var user: PQUser!
    @NSManaged var sender: PQUser!
    @NSManaged var message: String!
    @NSManaged var photo: PQPhoto?
    
    // ================================================================================
    // Export class
    // ================================================================================
    
}

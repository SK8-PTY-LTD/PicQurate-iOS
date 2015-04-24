//
//  SHLog.swift
//  Maple
//
//  Created by SongXujie on 21/02/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class PQLog: NSObject {
    
    class func i(message: String, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        #if DEBUG
            println("\(file) \(function) [line: \(line)] \n" + message);
        #endif
    }
    
    class func e(message: String, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        #if DEBUG
            println("ERROR: \(file) \(function) [line: \(line)]: " + message);
        #endif
    }
}
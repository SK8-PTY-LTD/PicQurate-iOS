//
//  IMGLYA15Filter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYA15Filter: IMGLYResponseFilter {
    override init() {
        super.init()
        self.responseName = "A15"
        self.displayName = "A15"
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.A15
        }
    }
}

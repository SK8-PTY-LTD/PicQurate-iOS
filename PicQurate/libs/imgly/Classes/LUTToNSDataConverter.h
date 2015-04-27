//
//  LUTToNSDataConverter.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 29/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LUTToNSDataConverter : NSObject

/*
 This method reads an LUT image and converts it to a cube color space representation.
 The resulting data can be used to feed an CIColorCube filter, so that the transformation 
 realised by the LUT is applied with a core image standard filter 
 */
- (NSData*)colorCubeDataFromLUT:(NSString *)name;

@end

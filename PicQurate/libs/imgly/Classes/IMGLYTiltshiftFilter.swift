//
//  IMGLYTiltshiftFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 03/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation
import GLKit

@objc public enum IMGLYTiltshiftType: Int {
    case Off, Box, Circle
}


/**
    This class realizes a tilt-shit filter effect. That means that a part a of the image is blurred.
    The non-blurry part of the image can be defined either by a circle or a box, defined by the tiltShiftType variable.
    Both, circle and box, are described by the controlPoint1 and controlPoint2 variable, that mark 
    either two oppesite points on the radius of the circle, or two points on oppesite sides of the box.
*/
public class IMGLYTiltshiftFilter : CIFilter {
    /// A CIImage object that serves as input for the filter.
    public var inputImage:CIImage?
    /// One of the two points, marking the dimension and direction of the box or circle.
    public var controlPoint1 = CGPointZero
    /// One of the two points, marking the dimension and direction of the box or circle.
    public var controlPoint2 = CGPointZero
    /// Defines the mode the filter operates in. Possible values are Box, Circle, and Off.
    public var tiltShiftType = IMGLYTiltshiftType.Off
    /// The radius that is set to the gaussian filter during the whole process. Default is 4.
    public var blurRadius = CGFloat(4)
    
    private var center_ = CGPointMake(0.5, 0.5)
    private var radius_ = CGFloat(0.1)
    private var scaleVector_ = CGPointZero
    private var imageSize_ = CGSizeZero
    private var rect_ = CGRectZero
    
    /// Returns a CIImage object that encapsulates the operations configured in the filter. (read-only)
    public override var outputImage: CIImage! {
        get {
            if inputImage == nil {
                return CIImage.emptyImage()
            }
            if tiltShiftType == IMGLYTiltshiftType.Off {
                return inputImage!
            }
            
            rect_ = inputImage!.extent()
            imageSize_ = rect_.size
            calcScaleVector()
            calculateCenterAndRadius()
            var maskImage:CIImage?
            if tiltShiftType == IMGLYTiltshiftType.Circle {
                maskImage = createRadialMaskImage()
            }
            else if tiltShiftType == IMGLYTiltshiftType.Box {
                maskImage = createLinearMaskImage()
            }
            var blurredImage = bluredImage()
            var blendFilter = CIFilter(name: "CIBlendWithMask")
            blendFilter.setValue(blurredImage, forKey: kCIInputImageKey)
            blendFilter.setValue(inputImage!, forKey: "inputBackgroundImage")
            blendFilter.setValue(maskImage, forKey: "inputMaskImage")
            return blendFilter.outputImage
        }
    }
    

    private func calcScaleVector() {
        if (imageSize_.height > imageSize_.width) {
            scaleVector_ = CGPointMake(imageSize_.width / imageSize_.height, 1.0)
        }
        else {
            scaleVector_ = CGPointMake(1.0, imageSize_.height / imageSize_.width)
        }
    }
    
    // MARK:- Radial Mask-creation
    private func calculateCenterAndRadius() {
        center_ = CGPointMake((controlPoint1.x + controlPoint2.x) * 0.5,
            (controlPoint1.y + controlPoint2.y) * 0.5);
        var midVectorX = (center_.x - controlPoint1.x) * scaleVector_.x
        var midVectorY = (center_.y - controlPoint1.y) * scaleVector_.y
        radius_ = sqrt(midVectorX * midVectorX + midVectorY * midVectorY)
    }
    
    private func createRadialMaskImage() -> CIImage {
        var factor = imageSize_.width > imageSize_.height ? imageSize_.width : imageSize_.height
        var radiusInPixels = factor * radius_
        var fadeWidth = radiusInPixels * 0.4
        
        var filter = CIFilter(name: "CIRadialGradient")
        filter.setValue(radiusInPixels, forKey: "inputRadius0")
        filter.setValue(radiusInPixels + fadeWidth, forKey: "inputRadius1")
        
        var centerInPixels = CIVector(CGPoint: CGPointMake(rect_.width * center_.x, rect_.height * (1.0 - center_.y)))
        filter.setValue(centerInPixels, forKey: "inputCenter")
        
        var innerColor = CIColor(red: 0, green: 1, blue: 0, alpha: 1)
        var outerColor = CIColor(red:0, green: 1, blue: 0,alpha: 0)
        filter.setValue(innerColor, forKey: "inputColor1")
        filter.setValue(outerColor, forKey: "inputColor0")
        
        // somehow a CIRadialGradient demands cropping afterwards
        var rectAsVector = CIVector(CGRect: rect_)
        var cropFilter = CIFilter(name: "CICrop")
        cropFilter.setValue(filter.outputImage, forKey: kCIInputImageKey)
        cropFilter.setValue(rectAsVector, forKey: "inputRectangle")
        
        return cropFilter.outputImage
    }
    
    private func createLinearMaskImage() -> CIImage {
        var factor = imageSize_.width > imageSize_.height ? imageSize_.width : imageSize_.height
        var innerColor = CIColor(red: 0, green: 1, blue: 0, alpha: 1)
        var outerColor = CIColor(red:0, green: 1, blue: 0,alpha: 0)
        
        var controlPoint1InPixels = CGPointMake(rect_.width * controlPoint1.x, rect_.height * (1.0 - controlPoint1.y))
        var controlPoint2InPixels = CGPointMake(rect_.width * controlPoint2.x, rect_.height * (1.0 - controlPoint2.y))
       
        var diagonalVector = CGPointMake(controlPoint2InPixels.x - controlPoint1InPixels.x,
            controlPoint2InPixels.y - controlPoint1InPixels.y)
        var controlPoint1Extension = CGPointMake(controlPoint1InPixels.x - 0.3 * diagonalVector.x,
            controlPoint1InPixels.y - 0.3 * diagonalVector.y)
        var controlPoint2Extension = CGPointMake(controlPoint2InPixels.x + 0.3 * diagonalVector.x,
            controlPoint2InPixels.y + 0.3 * diagonalVector.y)
        
        var filter = CIFilter(name: "CILinearGradient")
        filter.setValue(innerColor, forKey: "inputColor0")
        filter.setValue(CIVector(CGPoint: controlPoint1Extension), forKey: "inputPoint0")
        filter.setValue(outerColor, forKey: "inputColor1")
        filter.setValue(CIVector(CGPoint: controlPoint1InPixels), forKey: "inputPoint1")
        
        // somehow a CILinearGradient demands cropping afterwards
        var rectAsVector = CIVector(CGRect: rect_)
        var cropFilter = CIFilter(name: "CICrop")
        cropFilter.setValue(filter.outputImage, forKey: kCIInputImageKey)
        cropFilter.setValue(rectAsVector, forKey: "inputRectangle")
        var gradient1 = cropFilter.outputImage

        filter.setValue(innerColor, forKey: "inputColor0")
        filter.setValue(CIVector(CGPoint: controlPoint2Extension), forKey: "inputPoint0")
        filter.setValue(outerColor, forKey: "inputColor1")
        filter.setValue(CIVector(CGPoint: controlPoint2InPixels), forKey: "inputPoint1")
        cropFilter.setValue(filter.outputImage, forKey: kCIInputImageKey)
        
        var gradient2 = cropFilter.outputImage
        var addFilter = CIFilter(name: "CIAdditionCompositing")
        addFilter.setValue(gradient1, forKey: kCIInputImageKey)
        addFilter.setValue(gradient2, forKey: kCIInputBackgroundImageKey)

        return addFilter.outputImage
    }
    
    // MARK:- Blur
    private func bluredImage() -> CIImage {
        var blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter.setValue(inputImage!, forKey: kCIInputImageKey)
        blurFilter.setValue(blurRadius, forKey: "inputRadius")
        
        var blurRect = rect_
       // blurRect.origin.x += blurRadius / 2.0
      //  blurRect.origin.y += blurRadius / 2.0
        
        var rectAsVector = CIVector(CGRect: blurRect)
        var cropFilter = CIFilter(name: "CICrop")
        cropFilter.setValue(blurFilter.outputImage, forKey: kCIInputImageKey)
        cropFilter.setValue(rectAsVector, forKey: "inputRectangle")
        return cropFilter.outputImage
    }
    
}

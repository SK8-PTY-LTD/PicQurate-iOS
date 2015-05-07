//
//  IMGLYCameraController.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 01/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit
import OpenGLES
import GLKit
import AVFoundation

private let kIMGLYIndicatorSize = CGFloat(75)

@objc public protocol IMGLYCameraControllerDelegate: class {
    func captureSessionStarted()
    func captureSessionStopped()
    func willToggleCamera()
    func didToggleCamera()
    func didSetFlashMode(flashMode:AVCaptureFlashMode)
}

/**
The camera-controller takes care about the communication with the capture devices.
It provides methods to start a capture session, toggle between cameras, or select a flash mode.
*/
public class IMGLYCameraController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public weak var delegate: IMGLYCameraControllerDelegate?
    public let tapGestureRecognizer = UITapGestureRecognizer()
    public let doubleTapGestureRecognizer = UITapGestureRecognizer()
    
    // MARK:- private vars
    private var glContext_ : EAGLContext!
    private var ciContext_ : CIContext!
    private var captureSession_ : AVCaptureSession?
    private var captureSessionQueue_ : dispatch_queue_t?
    private var videoDevice_: AVCaptureDevice? {
        willSet {
            removeCameraObservers()
        }
        
        didSet {
            if videoDevice_ != nil {
                addCameraObservers()
            }
        }
    }
    private var cameraObserversAdded = false
    private let focusIndicatorLayer = CALayer()
    private var previewView: UIView?
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoPreviewFrame = CGRectZero
    private var videoPreviewView : GLKView!
    private var currentVideoDimensions_ : CMVideoDimensions?
    private var videoDeviceInput_: AVCaptureDeviceInput!
    private var videoDataOutput_: AVCaptureVideoDataOutput!
    private var stillImageOutput_: AVCaptureStillImageOutput!
    private var cameraPosition_: AVCaptureDevicePosition
    private var videoPreviewAdded_ = false
    //private var flashMode_ = AVCaptureFlashMode.Auto
    private var flashModeIndex_ = 0
    private var supportedFlashModes_:[AVCaptureFlashMode] =  []
    
    // MARK: - computed vars
    
    /// The response filter that is applied to the live-feed.
    public var effectFilter: CIFilter?
    
    //Facial recognition
    let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]);
    
    // MARK:- init functions
    public init(previewView: UIView) {
        self.previewView = previewView
        cameraPosition_ = AVCaptureDevicePosition.Unspecified
        super.init()
    }

    deinit {
        removeCameraObservers()
    }
    
    // MARK:- setup code
    /**
    Call this in view did load of your view controller.
    
    :param: cameraPosition The camera position.
    */
    public func setupWithCameraPosition(cameraPosition:AVCaptureDevicePosition) {
        #if !((arch(i386) || arch(x86_64)) && os(iOS))
            cameraPosition_ = cameraPosition
            setupVideoPreview()
            setupVideoInputsAndSession()
            setupFocusIndicator()
        #endif
    }
    
    private func setupVideoInputsAndSession() {
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        if videoDevices.count > 0 {
            setupAndStartCaptureSession()
        }
    }
    
    private func setupVideoPreview() {
        if !videoPreviewAdded_ {
            let window = (UIApplication.sharedApplication().delegate?.window!)!
            glContext_ = EAGLContext(API:EAGLRenderingAPI.OpenGLES2)
            videoPreviewView = GLKView(frame: CGRectZero, context: glContext_)
            videoPreviewView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            
            let transformation = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            videoPreviewView.transform = transformation;
            
            if previewView != nil {
                videoPreviewView!.frame = previewView!.bounds
                previewView!.addSubview(videoPreviewView)
            } else {
                videoPreviewView!.frame = window.bounds
                window.addSubview(videoPreviewView)
            }
            
            // create the CIContext instance, note that this must be done after videoPreviewView is properly set up
            ciContext_ = CIContext(EAGLContext: glContext_, options:nil)
            videoPreviewView.bindDrawable()
            videoPreviewAdded_ = true
        }
    }
    
    private func setupFocusIndicator() {
        focusIndicatorLayer.borderColor = UIColor.whiteColor().CGColor
        focusIndicatorLayer.borderWidth = 1
        focusIndicatorLayer.frame.size = CGSize(width: kIMGLYIndicatorSize, height: kIMGLYIndicatorSize)
        focusIndicatorLayer.hidden = true
        focusIndicatorLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        previewView!.layer.addSublayer(focusIndicatorLayer)
        
        doubleTapGestureRecognizer.addTarget(self, action: "doubleTapped:")
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        videoPreviewView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        tapGestureRecognizer.addTarget(self, action: "tapped:")
        tapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
        videoPreviewView.addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupAndStartCaptureSession() {
        if (captureSessionQueue_ == nil) {
            captureSessionQueue_ = dispatch_queue_create("capture_session_queue", DISPATCH_QUEUE_SERIAL);
        }
        
        dispatch_async(captureSessionQueue_!) {
            var videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            self.videoDevice_  = nil
            
            for device in videoDevices {
                if device.position == self.cameraPosition_ {
                    self.videoDevice_ = device as? AVCaptureDevice
                }
            }
            
            self.updateSupportedFlashModeList()
            
            let preset = AVCaptureSessionPresetPhoto;
            if !self.videoDevice_!.supportsAVCaptureSessionPreset(preset) {
                println("Session preset not supported")
                return
            }
            self.setupCaptureSessionWithPreset(preset)
            self.addVideoInput()
            self.addVideoOutput()
            self.addStillImageOutput()
            
            //Adding a preview layer
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession_);
            self.previewLayer.backgroundColor = UIColor.blackColor().CGColor;
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            
            var bounds:CGRect = (self.delegate as! UIViewController).view.layer.bounds
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.previewLayer.bounds = bounds
            self.previewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
            var rootLayer = self.previewView?.layer;
            rootLayer?.addSublayer(self.previewLayer);
            
//            var rootLayer = self.previewView?.layer;
//            rootLayer?.masksToBounds = true;
//            self.previewLayer.frame = rootLayer!.bounds;
//            NSLog("\(self.previewLayer.frame)");
//            rootLayer?.addSublayer(self.previewLayer);
            
            self.captureSession_!.commitConfiguration()
            self.captureSession_!.startRunning()
            self.delegate?.captureSessionStarted()
            
            if self.isFlashPresent() {
                self.matchFlashmodeIfPossible()
                self.updateFlashMode()
            }
            
            self.delegate?.didToggleCamera()
        }
    }
    
    private func setupCaptureSessionWithPreset(preset:NSString!) {
        self.captureSession_ = AVCaptureSession()
        self.captureSession_!.sessionPreset = preset as! String
        self.captureSession_?.beginConfiguration()
    }
    
    private func addVideoInput() {
        var error : NSError? = nil
        self.videoDeviceInput_ = AVCaptureDeviceInput(device: self.videoDevice_, error: &error)
        if self.videoDeviceInput_ == nil {
            println("Error \(error?.description)")
        }
        self.captureSession_!.addInput(videoDeviceInput_)
    }
    
    
    private func addVideoOutput() {
        self.videoDataOutput_ = AVCaptureVideoDataOutput()
        self.videoDataOutput_.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA]
        self.videoDataOutput_.alwaysDiscardsLateVideoFrames = true
        
        self.videoDataOutput_.setSampleBufferDelegate(self, queue:self.captureSessionQueue_)
        //Facial recognition
        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
        
        if (self.captureSession_?.canAddOutput(self.videoDataOutput_) != nil) {
            self.captureSession_?.addOutput(self.videoDataOutput_)
        }
        
        // get the output for doing face detection.
        self.videoDataOutput_.connectionWithMediaType(AVMediaTypeVideo).enabled = true;
    }
    
    private func addStillImageOutput() {
        stillImageOutput_ = AVCaptureStillImageOutput()
        stillImageOutput_.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if (self.captureSession_?.canAddOutput(self.stillImageOutput_) != nil) {
            self.captureSession_?.addOutput(self.stillImageOutput_)
        }
    }
    
    /**
    Use this function to determin weather a camera with the desired position is available.
    :param: cameraPosition The desired camera position.
    
    :returns: True is a camera with the specified position is available, false otherwise.
    */
    public func isCameraPresentWithPosition(cameraPosition:AVCaptureDevicePosition) -> Bool {
        var videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var foundMatch = false
        
        for device in videoDevices {
            if device.position == cameraPosition {
                foundMatch = true
            }
        }
        return foundMatch
    }
    
    /**
    Use this function to determin weather more than one camera is available.
    Within the SDK this method is used to determin if the toggle button is visible.
    
    :returns: True if more than one camera is present, false otherwise.
    */
    public func isMoreThanOneCameraPresent() -> Bool {
        var videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        return (videoDevices.count > 1)
    }
    
    /**
    Check if the current device has a flash.
    
    :returns: True if a flash is presen, false otherwise.
    */
    public func isFlashPresent() -> Bool {
        #if !((arch(i386) || arch(x86_64)) && os(iOS))
            return videoDevice_!.hasFlash
            #else
            return true
        #endif
    }
    
    //  MARK:- session handling
    
    /**
    Starts the capture session.
    */
    public func startCaptureSession() {
        #if !((arch(i386) || arch(x86_64)) && os(iOS))
            if (!self.captureSession_!.running) {
                self.captureSession_!.startRunning()
                self.delegate?.captureSessionStarted()
            }
            #else
            println("startCaptureSession called")
        #endif
    }
    
    /**
    Stops the capture session.
    */
    public func stopCaptureSession() {
        #if !((arch(i386) || arch(x86_64)) && os(iOS))
            if (self.captureSession_!.running) {
                self.delegate?.captureSessionStopped()
                self.captureSession_!.stopRunning()
            }
            #else
            println("stopCaptureSession called")
        #endif
    }
    
    /**
    Toggle between front and back camera.
    */
    public func toggleCameraPosition() {
        delegate?.willToggleCamera()
        if cameraPosition_ == AVCaptureDevicePosition.Back {
            stopCaptureSession()
            cameraPosition_ = .Front
            setupWithCameraPosition(AVCaptureDevicePosition.Front)
        } else {
            stopCaptureSession()
            cameraPosition_ = .Back
            setupWithCameraPosition(AVCaptureDevicePosition.Back)
        }
    }
    
    /**
    Selects the next flash-mode. The order is Auto->On->Off.
    If the current device does not support auto-flash, this method
    just toggles between on and off.
    */
    public func selectNextFlashmode() {
        flashModeIndex_ = (flashModeIndex_ + 1) % supportedFlashModes_.count
        updateFlashMode()
    }
    
    private func updateFlashMode() {
        #if !((arch(i386) || arch(x86_64)) && os(iOS))
            var error:NSError? = nil
            self.captureSession_?.beginConfiguration()
            videoDevice_!.lockForConfiguration(&error)
            videoDevice_!.flashMode = supportedFlashModes_[flashModeIndex_]
            videoDevice_!.unlockForConfiguration()
            self.captureSession_?.commitConfiguration()
            if supportedFlashModes_.count > 0 {
                delegate?.didSetFlashMode(supportedFlashModes_[flashModeIndex_])
            }
        #endif
    }
    
    private func updateSupportedFlashModeList() {
        supportedFlashModes_ = []
        if isFlashPresent() {
            if videoDevice_!.isFlashModeSupported(AVCaptureFlashMode.Auto) {
                supportedFlashModes_.append(AVCaptureFlashMode.Auto)
            }
            if videoDevice_!.isFlashModeSupported(AVCaptureFlashMode.On) {
                supportedFlashModes_.append(AVCaptureFlashMode.On)
            }
            if videoDevice_!.isFlashModeSupported(AVCaptureFlashMode.Off) {
                supportedFlashModes_.append(AVCaptureFlashMode.Off)
            }
        }
    }
    
    private func matchFlashmodeIfPossible() {
        if supportedFlashModes_.count == 0 {
            return
        }
        var flashMode = supportedFlashModes_[flashModeIndex_]
        var matched = false
        
        // if the selected mode is still supported choose it again
        for var i = 0; i < supportedFlashModes_.count; i++ {
            var mode = supportedFlashModes_[i]
            if mode == flashMode {
                flashModeIndex_ = i
                matched = true
                break
            }
        }
        
        if !matched {
            flashModeIndex_ = 0
        }
    }
    
    // MARK:- photo taking
    /**
    Takes a photo and hands it over to the completion block.
    
    :param: completion A completion block that has an image and an error as parameters.
    If the image was taken sucessfuly, the error is nil.
    */
    public func takePhoto(completion:((image: UIImage?, error: NSError?) -> Void)?) {
        if completion == nil || self.stillImageOutput_ == nil {
            return
        }
        var imageOrientation = imageOrientationForDeviceOrientation(UIDevice.currentDevice().orientation)
        
        dispatch_async(self.captureSessionQueue_!, {
            self.stillImageOutput_.captureStillImageAsynchronouslyFromConnection(
                self.stillImageOutput_.connectionWithMediaType(AVMediaTypeVideo),completionHandler: {
                    (imageDataSampleBuffer: CMSampleBuffer?, error: NSError?) -> Void in
                    if imageDataSampleBuffer == nil || error != nil {
                        completion!(image:nil, error:error)
                    }
                    else if imageDataSampleBuffer != nil {
                        var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                        var image = UIImage(data: imageData)!
                        var orientedImage = UIImage(CGImage: image.CGImage, scale: 1.0, orientation: imageOrientation)
                        completion!(image:orientedImage, error:nil)
                    }
                }
            )
        })
    }
    
    
    private func imageOrientationForDeviceOrientation(orientation:UIDeviceOrientation) -> UIImageOrientation {
        var result = UIImageOrientation.Right
        switch (orientation) {
        case UIDeviceOrientation.Unknown:
            result = UIImageOrientation.Right
        case UIDeviceOrientation.Portrait: // Device oriented vertically, home button on the bottom
            result = UIImageOrientation.Right
        case UIDeviceOrientation.PortraitUpsideDown: // Device oriented vertically, home button on the top
            result = UIImageOrientation.Left
        case UIDeviceOrientation.LandscapeLeft: // Device oriented horizontally, home button on the right
            result = UIImageOrientation.Up
        case UIDeviceOrientation.LandscapeRight: // Device oriented horizontally, home button on the left
            result = UIImageOrientation.Down
        case UIDeviceOrientation.FaceUp: // Device oriented flat, face up
            result = UIImageOrientation.Right
        case UIDeviceOrientation.FaceDown: // Dev
            result = UIImageOrientation.Right
        }
        return result
    }
    
    
    // MARK:- AVCaptureVideoDataOutputSampleBufferDelegate
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer)
        let mediaType = CMFormatDescriptionGetMediaType(formatDesc)
        currentVideoDimensions_ = CMVideoFormatDescriptionGetDimensions(formatDesc)
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, CMAttachmentMode( kCMAttachmentMode_ShouldPropagate)).takeRetainedValue();
        let sourceImage = CIImage(CVPixelBuffer:imageBuffer as CVPixelBufferRef, options: attachments as [NSObject : AnyObject]);
        
        //Facial regocnition
        let filteredImage: CIImage?
        if let effectFilter = effectFilter {
            filteredImage = IMGLYPhotoProcessor.processWithCIImage(sourceImage, filters: [effectFilter])
        } else {
            filteredImage = sourceImage
        }
        
        //Facial detection
        var curDeviceOrientation = UIDevice.currentDevice().orientation;
        var features = self.detector.featuresInImage(sourceImage);
        // get the clean aperture
        // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
        // that represents image data valid for display.
        
        // get the clean aperture
        // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
        // that represents image data valid for display.
        var fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
        var cleanAperture = CMVideoFormatDescriptionGetCleanAperture(fdesc, 0);
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.drawFaces(features, clearAperture: cleanAperture, orientation: curDeviceOrientation);
        })
        
        let sourceExtent = sourceImage.extent()
        let targetRect = CGRect(x: 0, y: 0, width: videoPreviewView.drawableWidth, height: videoPreviewView.drawableHeight)
        
        videoPreviewFrame = fitRect(sourceExtent, intoTargetRect: targetRect, withContentMode: .ScaleAspectFit)
        
        if glContext_ != EAGLContext.currentContext() {
            EAGLContext.setCurrentContext(glContext_)
        }
        
        videoPreviewView.bindDrawable()
        
        glClearColor(0, 0, 0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        if let filteredImage = filteredImage {
            ciContext_.drawImage(filteredImage, inRect: videoPreviewFrame, fromRect: sourceExtent)
        }
        
        videoPreviewView.display()
    }
    
    //Facial recognition
    private func drawFaces(features: [AnyObject]!, clearAperture: CGRect, orientation: UIDeviceOrientation) {
        let sublayers = self.previewLayer.sublayers as! [CALayer];
        let sublayersCount = sublayers.count;
        var currentSublayer = 0;
        let featuresCount = features.count;
        var currentFeature = 0;
        
        CATransaction.begin();
        
        //hide all face layers
        for layer in sublayers {
            if let name = layer.name where name == "FaceLayer" {
                layer.hidden = true;
            }
        }
        
        if (featuresCount == 0) {
            CATransaction.commit();
            return;
        }
        
        let parentFrameSize = self.previewView!.frame.size;
        let gravity = self.previewLayer.videoGravity;
        var isMirrored = false;
        if (self.previewLayer.respondsToSelector("connection")) {
            isMirrored = self.previewLayer.connection.videoMirrored;
        } else {
//            inMirrored = self.previewLayer.isMirrord;
        }
        var previewBox = IMGLYCameraViewController.videoPreviewBoxForGravity(gravity, frameSize: parentFrameSize, apertureSize: clearAperture.size);
        
        for (var i = 0; i < features.count; i++) {
            var ff = features[i] as! CIFaceFeature;
            // find the correct position for the square layer within the previewLayer
            // the feature box originates in the bottom left of the video frame.
            // (Bottom right if mirroring is turned on)
            var faceRect = ff.bounds;
            
            // flip preview width and height
            var temp = faceRect.size.width;
            faceRect.size.width = faceRect.size.height;
            faceRect.size.height = temp;
            temp = faceRect.origin.x;
            faceRect.origin.x = faceRect.origin.y;
            faceRect.origin.y = temp;
            // scale coordinates so they fit in the preview box, which may be scaled
            var widthScaleBy = previewBox.size.width / clearAperture.size.height;
            var heightScaleBy = previewBox.size.height / clearAperture.size.width;
            faceRect.size.width *= widthScaleBy;
            faceRect.size.height *= heightScaleBy;
            faceRect.origin.x *= widthScaleBy;
            faceRect.origin.y *= heightScaleBy;
            
            if (isMirrored) {
                faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
            } else {
                faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
            }
            
            var featureLayer: CALayer!;
            
            // re-use an existing layer if possible
            while (featureLayer == nil && currentSublayer < sublayersCount ) {
                var currentLayer = sublayers[currentSublayer++];
                featureLayer = currentLayer;
                currentLayer.hidden = false;
            }
            
            // create a new one if necessary
            if (featureLayer == nil) {
                NSLog("featureLayer is nil");
                featureLayer = CALayer();
                featureLayer.borderColor = UIColor.yellowColor().CGColor;
                featureLayer.borderWidth = 1.0;
                featureLayer.name = "FaceLayer";
                self.previewLayer.addSublayer(featureLayer);
            }
            featureLayer.frame = faceRect;
            self.previewLayer.addSublayer(featureLayer);
            
            switch orientation {
            case .Portrait:
                featureLayer.setAffineTransform( CGAffineTransformMakeRotation(CGFloat(0/180.0*M_PI)));
                break;
            case .PortraitUpsideDown:
                featureLayer.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(180/180.0*M_PI)));
                break;
            case .LandscapeLeft:
                featureLayer.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(90/180.0*M_PI)));
                break;
            case .LandscapeRight:
                featureLayer.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(-90/180.0*M_PI)));
                break;
            default:
                break; // leave the layer in its last known orientation
            }
            currentFeature++;
        }
        CATransaction.commit();
        
    }
    
    // MARK: - Helpers
    
    private func fitRect(sourceRect: CGRect, intoTargetRect targetRect: CGRect, withContentMode contentMode: UIViewContentMode) -> CGRect {
        if !(contentMode == .ScaleAspectFit || contentMode == .ScaleAspectFill) {
            // Not implemented
            return CGRectZero
        }
        
        var scale = CGRectGetWidth(targetRect) / CGRectGetWidth(sourceRect)
        
        if contentMode == .ScaleAspectFit {
            if CGRectGetHeight(sourceRect) * scale > CGRectGetHeight(targetRect) {
                scale = CGRectGetHeight(targetRect) / CGRectGetHeight(sourceRect)
            }
        } else if contentMode == .ScaleAspectFill {
            if CGRectGetHeight(sourceRect) * scale < CGRectGetHeight(targetRect) {
                scale = CGRectGetHeight(targetRect) / CGRectGetHeight(sourceRect)
            }
        }
        
        let scaledWidth = CGRectGetWidth(sourceRect) * scale
        let scaledHeight = CGRectGetHeight(sourceRect) * scale
        let scaledX = CGRectGetWidth(targetRect) / 2 - scaledWidth / 2
        let scaledY = CGRectGetHeight(targetRect) / 2 - scaledHeight / 2
        
        return CGRect(x: scaledX, y: scaledY, width: scaledWidth, height: scaledHeight)
    }
    
    private var isFocusPointSupported: Bool {
        if let videoDevice = videoDevice_ {
            return videoDevice.focusPointOfInterestSupported && videoDevice.isFocusModeSupported(.AutoFocus) && videoDevice.isFocusModeSupported(.ContinuousAutoFocus)
        }
        
        return false
    }
    
    private var isExposurePointSupported: Bool {
        if let videoDevice = videoDevice_ {
            return videoDevice.exposurePointOfInterestSupported && videoDevice.isExposureModeSupported(.AutoExpose) && videoDevice.isExposureModeSupported(.ContinuousAutoExposure)
        }
        
        return false
    }
    
    private func addCameraObservers() {
        if cameraObserversAdded == false {
            if isFocusPointSupported {
                videoDevice_?.addObserver(self, forKeyPath: "focusMode", options: NSKeyValueObservingOptions.New, context: nil)
                videoDevice_?.addObserver(self, forKeyPath: "exposureMode", options: NSKeyValueObservingOptions.New, context: nil)
                cameraObserversAdded = true
            }
        }
    }
    
    private func removeCameraObservers() {
        if cameraObserversAdded == true {
            videoDevice_?.removeObserver(self, forKeyPath: "focusMode")
            videoDevice_?.removeObserver(self, forKeyPath: "exposureMode")
            cameraObserversAdded = false
        }
    }
    
    private func updateFocusIndicatorLayer() {
        if let videoDevice = videoDevice_ {
            if focusIndicatorLayer.hidden == false {
                if videoDevice.focusMode == .Locked && videoDevice.exposureMode == .Locked {
                    focusIndicatorLayer.borderColor = UIColor(white: 1, alpha: 0.5).CGColor
                }
            }
        }
    }
    
    private func updateFocusAndExposurePoints(pointOfInterest: CGPoint) {
        var error:NSError? = nil
        videoDevice_!.lockForConfiguration(&error)
        
        if isFocusPointSupported {
            videoDevice_!.focusPointOfInterest = pointOfInterest
            videoDevice_!.focusMode = .AutoFocus
        }
        
        if isExposurePointSupported {
            videoDevice_!.exposurePointOfInterest = pointOfInterest
            videoDevice_!.exposureMode = .AutoExpose
        }
        
        videoDevice_!.unlockForConfiguration()
    }
    
    private func resetFocusAndExposurePoints() {
        var error:NSError? = nil
        videoDevice_!.lockForConfiguration(&error)
        
        if isFocusPointSupported {
            videoDevice_!.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            videoDevice_!.focusMode = .ContinuousAutoFocus
        }
        
        if isExposurePointSupported {
            videoDevice_!.exposurePointOfInterest = CGPoint(x: 0.5, y: 0.5)
            videoDevice_!.exposureMode = .ContinuousAutoExposure
        }
        
        videoDevice_!.unlockForConfiguration()
    }
    
    private func showFocusIndicatorLayerAtLocation(location: CGPoint) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        focusIndicatorLayer.hidden = false
        focusIndicatorLayer.borderColor = UIColor.whiteColor().CGColor
        focusIndicatorLayer.position = location
        focusIndicatorLayer.transform = CATransform3DMakeScale(1.5, 1.5, 1)
        CATransaction.commit()
        
        focusIndicatorLayer.transform = CATransform3DIdentity
    }
    
    // MARK: - KVO
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        updateFocusIndicatorLayer()
    }
    
    // MARK: - Gesture Handling
    
    func tapped(recognizer: UITapGestureRecognizer) {
        if isFocusPointSupported || isExposurePointSupported {
            let focusPointLocation = recognizer.locationInView(videoPreviewView)
            let scaleFactor = videoPreviewView.contentScaleFactor
            let videoFrame = CGRectMake(CGRectGetMinX(videoPreviewFrame) / scaleFactor, CGRectGetMinY(videoPreviewFrame) / scaleFactor, CGRectGetWidth(videoPreviewFrame) / scaleFactor, CGRectGetHeight(videoPreviewFrame) / scaleFactor)
            
            if CGRectContainsPoint(videoFrame, focusPointLocation) {
                let focusIndicatorLocation = recognizer.locationInView(previewView)
                showFocusIndicatorLayerAtLocation(focusIndicatorLocation)
                
                let pointOfInterest = CGPoint(x: focusPointLocation.x / CGRectGetWidth(videoFrame), y: focusPointLocation.y / CGRectGetHeight(videoFrame))
                updateFocusAndExposurePoints(pointOfInterest)
            }
        }
    }
    
    func doubleTapped(recognizer: UITapGestureRecognizer) {
        if isFocusPointSupported || isExposurePointSupported {
            focusIndicatorLayer.hidden = true
            resetFocusAndExposurePoints()
        }
    }
}

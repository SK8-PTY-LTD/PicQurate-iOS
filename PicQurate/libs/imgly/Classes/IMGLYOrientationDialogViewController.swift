//
//  IMGLYOrientationDialogViewController.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 20/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public class IMGLYOrientationDialogViewController: UIViewController, IMGLYSubEditorViewControllerProtocol,
    IMGLYOrientationDialogViewDelegate {
    
    public var dialogView_:IMGLYOrientationDialogView?
    private var previewImage_:UIImage? = nil
    public var filteredImage_:UIImage? = nil
    public var filter = IMGLYOrientationCropFilter()
    private var oldCropRect_ = CGRectZero
    private var cropRect_ = CGRectZero
    private let cropRectComponent = IMGLYInstanceFactory.sharedInstance.cropRectComponent()
    private var cropRectLeftBound_:CGFloat = 0.0
    private var cropRectRightBound_:CGFloat = 0.0
    private var cropRectTopBound_:CGFloat = 0.0
    private var cropRectBottomBound_:CGFloat = 0.0
    
    private var completionHandler_:IMGLYSubEditorCompletionBlock?
    public var completionHandler:IMGLYSubEditorCompletionBlock? {
        get {
            return completionHandler_
        }
        set (handler) {
            completionHandler_ = handler
        }
    }
    
    private var fixedFilterStack_:IMGLYFixedFilterStack?
    public var fixedFilterStack:IMGLYFixedFilterStack? {
        get {
            return fixedFilterStack_
        }
        set (filterStack) {
            fixedFilterStack_ = filterStack
        }
    }
    
    public var dialogView:UIView? {
        get {
            return view
        }
        set(newView) {
            view = newView
        }
    }
    
    public override func loadView() {
        self.view = IMGLYOrientationDialogView(frame: UIScreen.mainScreen().bounds)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func viewDidAppear(animated: Bool) {
        if oldCropRect_.origin.x != 0 || oldCropRect_.origin.y != 0 ||
            oldCropRect_.size.width != 1.0 || oldCropRect_.size.height != 1.0 {
            cropRectComponent.present()
        }
        layoutCropRectViews()
    }
    
    public func setup() {
        dialogView_ = self.view as? IMGLYOrientationDialogView
        if dialogView_ != nil {
            dialogView_!.delegate = self
            filteredImage_ = previewImage
            oldCropRect_ = fixedFilterStack!.orientationCropFilter!.cropRect
            cropRect_ = oldCropRect_
            updatePreviewImage()
            cropRectComponent.cropRect = cropRect_
            cropRectComponent.setup(dialogView_!.transperentRectView, parentView: self.view, showAnchors: false)
        }
    }
    
    // MARK:- IMGLYSubEditorViewController
    public var previewImage:UIImage? {
        get {
            return previewImage_
        }
        set (image) {
            previewImage_ = image
        }
    }
    
    // MARK:- Completion-block handling
    public func doneButtonPressed() {
        if self.completionHandler != nil {
            //fixedFilterStack!.orientationCropFilter!.cropRect = oldCropRect_
            self.filteredImage_ = IMGLYPhotoProcessor.processWithUIImage(previewImage!,
                filters: fixedFilterStack!.activeFilters)

            self.completionHandler?(IMGLYEditorResult.Done, self.filteredImage_)
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    public func backButtonPressed() {
        fixedFilterStack!.orientationCropFilter!.cropRect = oldCropRect_
        self.completionHandler?(IMGLYEditorResult.Cancel, nil)
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    /*
        The preview image for this dialog is special, 
        since we render the full image and just draw the crop region on top
    */
    public func updatePreviewImage() {
        if fixedFilterStack != nil {
            fixedFilterStack!.orientationCropFilter!.cropRect = CGRectMake(0, 0, 1, 1)
            filteredImage_ = IMGLYPhotoProcessor.processWithUIImage(previewImage!,
                filters: fixedFilterStack!.activeFilters)
            fixedFilterStack!.orientationCropFilter!.cropRect = cropRect_
        }
        dialogView_!.previewImageView.image = filteredImage_
    }
    
    public func rotateLeftButtonPressed() {
        fixedFilterStack?.orientationCropFilter?.rotateLeft()
        rotateCropRectLeft()
        updatePreviewImage()
        layoutCropRectViews()
    }
    
    private func rotateCropRectLeft() {
        moveCropRectMidToOrigin()
        // rotatate
        let tempRect = cropRect_
        cropRect_.origin.x = tempRect.origin.y
        cropRect_.origin.y = -tempRect.origin.x
        cropRect_.size.width = tempRect.size.height
        cropRect_.size.height = -tempRect.size.width
        moveCropRectTopLeftToOrigin()
    }
    
    public func rotateRightButtonPressed() {
        fixedFilterStack?.orientationCropFilter?.rotateRight()
        rotateCropRectRight()
        updatePreviewImage()
        layoutCropRectViews()
    }
    
    private func rotateCropRectRight() {
        moveCropRectMidToOrigin()
        // rotatate
        let tempRect = cropRect_
        cropRect_.origin.x = -tempRect.origin.y
        cropRect_.origin.y = tempRect.origin.x
        cropRect_.size.width = -tempRect.size.height
        cropRect_.size.height = tempRect.size.width
        moveCropRectTopLeftToOrigin()
    }

    public func flipHorizontalButtonPressed() {
        fixedFilterStack?.orientationCropFilter?.flipHorizontal()
        flipCropRectHorizontal()
        updatePreviewImage()
        layoutCropRectViews()
    }
    
    private func flipCropRectHorizontal() {
        moveCropRectMidToOrigin()
        cropRect_.origin.x = -cropRect_.origin.x - cropRect_.size.width
        moveCropRectTopLeftToOrigin()
    }

    public func flipVerticalButtonPressed() {
        fixedFilterStack?.orientationCropFilter?.flipVertical()
        flipCropRectVertical()
        updatePreviewImage()
        layoutCropRectViews()
    }
    
    private func flipCropRectVertical() {
        moveCropRectMidToOrigin()
        cropRect_.origin.y = -cropRect_.origin.y - cropRect_.size.height
        moveCropRectTopLeftToOrigin()
    }
    
    private func moveCropRectMidToOrigin() {
        cropRect_.origin.x -= 0.5
        cropRect_.origin.y -= 0.5
    }
    
    private func moveCropRectTopLeftToOrigin() {
        cropRect_.origin.x += 0.5
        cropRect_.origin.y += 0.5
    }
    
    // MARK:- crop rect placement
    private func layoutCropRectViews() {
        reCalculateCropRectBounds()
        let viewWidth = cropRectRightBound_ - cropRectLeftBound_
        let viewHeight = cropRectBottomBound_ - cropRectTopBound_
        let x = cropRectLeftBound_ + viewWidth * cropRect_.origin.x
        let y = cropRectTopBound_ + viewHeight * cropRect_.origin.y
        let width = viewWidth * cropRect_.size.width
        let height = viewHeight * cropRect_.size.height
        let rect = CGRectMake(x, y, width, height)
        cropRectComponent.cropRect = rect
        cropRectComponent.layoutViewsForCropRect()
    }
    
    private func reCalculateCropRectBounds() {
        let size = scaledImageSize()
        let width = dialogView_!.transperentRectView.frame.size.width
        let height = dialogView_!.transperentRectView.frame.size.height
        cropRectLeftBound_ = (width - size.width) / 2.0
        cropRectRightBound_ = width - cropRectLeftBound_
        cropRectTopBound_ = (height - size.height) / 2.0
        cropRectBottomBound_ = height - cropRectTopBound_
    }
    
    private func scaledImageSize() -> CGSize {
        let widthRatio = dialogView_!.previewImageView.bounds.size.width / dialogView_!.previewImageView.image!.size.width
        let heightRatio = dialogView_!.previewImageView.bounds.size.height / dialogView_!.previewImageView.image!.size.height
        let scale = min(widthRatio, heightRatio)
        var size = CGSizeZero
        size.width = scale * dialogView_!.previewImageView.image!.size.width
        size.height = scale * dialogView_!.previewImageView.image!.size.height
        return size
    }
}
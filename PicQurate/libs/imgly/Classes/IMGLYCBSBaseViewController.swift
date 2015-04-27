//
//  IMGLYCBSBaseViewController.swift
//  imglyKit
//
//  This class is out to provide a generic view controller 
//  that can be used for contrast brightness and saturation dialogs.
//  Its ment to be inherited by the specific view controller.
//
//  Created by Carsten Przyluczky on 13/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public protocol IMGLYCBSBaseViewControllerDelegate: class {
    var caption:String { get }
    var minValue:Float { get }
    var maxValue:Float { get }
    var initialValue:Float { get }
    func setValue(value:Float)
}

public class IMGLYCBSBaseViewController: UIViewController, IMGLYSubEditorViewControllerProtocol, IMGLYSliderDialogViewDelegate {
    
    public var filterDialogView_:IMGLYOneSliderDialogView?
    private var previewImage_:UIImage? = nil
    public var filteredImage_:UIImage? = nil
    public var value_:Float = 0.0
    public var oldValue_:Float = 0.0
    public weak var delegate:IMGLYCBSBaseViewControllerDelegate?
    
    private var completionHandler_:IMGLYSubEditorCompletionBlock?
    public var completionHandler:IMGLYSubEditorCompletionBlock? {
        get {
            return completionHandler_
        }
        set (handler) {
            completionHandler_ = handler
        }
    }
    
    public var fixedFilterStack_:IMGLYFixedFilterStack?
    public var fixedFilterStack:IMGLYFixedFilterStack? {
        get {
            return fixedFilterStack_
        }
        set (filterStack){
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
        self.view = IMGLYOneSliderDialogView(frame: UIScreen.mainScreen().bounds)
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public func setup() {
        filterDialogView_ = self.view as? IMGLYOneSliderDialogView
        if filterDialogView_ != nil {
            filterDialogView_!.delegate = self
            filteredImage_ = previewImage
            oldValue_ = delegate!.initialValue
            value_ = oldValue_
            filterDialogView_!.slider_.minimumValue = delegate!.minValue
            filterDialogView_!.slider_.maximumValue = delegate!.maxValue
            filterDialogView_!.slider_.value = value_
            filterDialogView_!.navigationItem.title = delegate!.caption
            updatePreviewImage()
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
        if completionHandler != nil {
            delegate?.setValue(value_)
            completionHandler?(IMGLYEditorResult.Done, self.filteredImage_)
        }
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    public func backButtonPressed() {
        if completionHandler != nil {
            delegate?.setValue(oldValue_)
            completionHandler?(IMGLYEditorResult.Cancel, nil)
        }
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    
    public func sliderValueChanged(newValue: Float) {
        value_ = newValue
        updatePreviewImage()
    }
    
    public func updatePreviewImage() {
        if fixedFilterStack != nil {
            delegate?.setValue(value_)
            filteredImage_ = IMGLYPhotoProcessor.processWithUIImage(previewImage!, filters: fixedFilterStack!.activeFilters)
        }
        filterDialogView_!.previewImageView.image = filteredImage_
    }
}
//
//  IMGLYTextColorSelectorView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 05/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

@objc public protocol IMGLYTextColorSelectorViewDelegate: class {
    func selectedColor(color:UIColor)
}

public class IMGLYTextColorSelectorView: UIScrollView {
    public weak var menuDelegate:IMGLYTextColorSelectorViewDelegate? = nil
    
    private var colorArray_:[UIColor] = []
    private var buttonArray_:[IMGLYColorButton] = []
    
    private let kButtonYPosition = CGFloat(22)
    private let kButtonXPositionOffset = CGFloat(5)
    private let kButtonDistance = CGFloat(10)
    private let kButtonSideLength = CGFloat(50)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.autoresizesSubviews = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        configureColorArray()
        configureColorButtons()
    }
    
    private func configureColorArray() {
        UIColor(red: 1, green: 2, blue: 2, alpha: 3)
        colorArray_ = [
            UIColor.whiteColor(),
            UIColor.blackColor(),
            UIColor(red: CGFloat(0xec / 255.0), green:CGFloat(0x37 / 255.0), blue:CGFloat(0x13 / 255.0), alpha:1.0),
            UIColor(red: CGFloat(0xfc / 255.0), green:CGFloat(0xc0 / 255.0), blue:CGFloat(0x0b / 255.0), alpha:1.0),
            UIColor(red: CGFloat(0xa9 / 255.0), green:CGFloat(0xe9 / 255.0), blue:CGFloat(0x0e / 255.0), alpha:1.0),
            UIColor(red: CGFloat(0x0b / 255.0), green:CGFloat(0x6a / 255.0), blue:CGFloat(0xf9 / 255.0), alpha:1.0),
            UIColor(red: CGFloat(0xff / 255.0), green:CGFloat(0xff / 255.0), blue:CGFloat(0x00 / 255.0), alpha:1.0),
            UIColor(red: CGFloat(0xb5 / 255.0), green:CGFloat(0xe5 / 255.0), blue:CGFloat(0xff / 255.0), alpha:1.0),
            UIColor(red: CGFloat(0xff / 255.0), green:CGFloat(0xb5 / 255.0), blue:CGFloat(0xe0 / 255.0), alpha:1.0)]
    }
    
    private func configureColorButtons() {
        for color in colorArray_ {
            var button = IMGLYColorButton(frame: CGRectZero)
            self.addSubview(button)
            button.addTarget(self, action: "colorButtonTouchedUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
            buttonArray_.append(button)
            button.backgroundColor = color
            button.hasFrame = true
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutColorButtons()
    }
    
    private func layoutColorButtons() {
        var xPosition = kButtonXPositionOffset
        for var i = 0;i < colorArray_.count; i++ {
            var button =  buttonArray_[i]
            button.frame = CGRectMake(xPosition,
                kButtonYPosition,
                kButtonSideLength,
                kButtonSideLength)
            xPosition += (kButtonDistance + kButtonSideLength)
        }
        buttonArray_[0].hasFrame = true
        contentSize = CGSizeMake(xPosition + kButtonDistance, 0)
    }
    
    public func colorButtonTouchedUpInside(button:UIButton) {
        menuDelegate?.selectedColor(button.backgroundColor!)
    }
}

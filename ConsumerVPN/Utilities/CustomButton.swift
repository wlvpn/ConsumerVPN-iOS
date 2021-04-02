
//
//  CustomButton.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/30/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CustomButton : UIButton {
    
    fileprivate var isSetup = false
    fileprivate var multiplier : CGFloat = 0.5
    
    /// Corner radius multiplier is limited to values of 0-100.
    /// This is converted into a percentage decimal and applied to the corner radius property.
    /// The value for corner radius is set using this formula (layer.frame.height * cornerRadiusMultiplier).
    /// Example: A cornerRadiusMultiplier set to 50 in the storyboard inspector would become 0.5 and produce a rounded capped button.
    @IBInspectable var cornerRadiusMultiplier : CGFloat {
        get {
            return multiplier
        } set {
            multiplier = min(newValue, 100.0) / 100
        }
    }
    
    //MARK: - Properties
    @IBInspectable var fillColor : CGColor? {
        get {
            return layer.backgroundColor
        } set {
            layer.backgroundColor = newValue
        }
    }
    
    @IBInspectable var borderColor : CGColor? {
        get {
            return layer.borderColor
        } set {
            layer.borderColor = newValue
        }
    }
    
    @IBInspectable var borderWidth : CGFloat {
        get {
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }

    var isActive: Bool = true
    
    /// Override to visually alter custom button on enable/disable
    override var isEnabled: Bool {
        didSet {
            if !isEnabled && !isActive{
                alpha = 0.4
            } else {
                alpha = 1.0
            }
        }
    }
    
    //MARK: - Inteface Builder Managemenet
    override func prepareForInterfaceBuilder() {
        configureView()
    }
    
    //MARK: - View Configuration and Styling
    override func layoutSubviews() {
        super.layoutSubviews()
        configureView()
    }
    
    /// Configures the control UI elements and all styling options.
    internal func configureView() {
        if isSetup == false {
            isSetup = true
            styleView()
        }
    }
    
    /// Applies all the user defined runtime attributes. attriutes all have
    /// fallback values in case none were set in interface builder.
    fileprivate func styleView() {
        
        layer.backgroundColor = fillColor
        layer.cornerRadius = layer.frame.height * cornerRadiusMultiplier
        clipsToBounds = true
        
        layer.borderColor = borderColor
        layer.borderWidth = borderWidth
        
    }
}

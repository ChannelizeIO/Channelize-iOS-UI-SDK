//
//  CHUITextField+Extension.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

public extension UITextField {
    
    func setDeviceWiseFont(fontSize:CGFloat,weight:UIFont.Weight = .regular){
        self.adjustsFontSizeToFitWidth = true
        let scaleFactor = fontSize/375
        let newFontSize = scaleFactor*UIScreen.main.bounds.width
        self.font = UIFont.systemFont(ofSize: newFontSize, weight: weight)
    }
    
    func setLeftPadding(withPadding:CGFloat){
        let deviceSpecificPadding = (UIScreen.main.bounds.width*withPadding)/667
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: deviceSpecificPadding, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setLeftIcon(iconName: String, iconHeight: CGFloat) {
        let iconView = UIImageView(frame: CGRect(x: 7.5, y: 7.5, width: iconHeight - 7.5, height: iconHeight - 15))
        iconView.image = getImage(iconName)
        iconView.tintColor = CHUIConstants.conversationMessageColor
        iconView.contentMode = .scaleAspectFit
        self.leftView = iconView
        self.leftViewMode = .always
    }
    
    func addBottomBorder(){
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    func setBottomBorder() {
        self.borderStyle = UITextField.BorderStyle.none
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width,   width:  self.frame.size.width, height: 10)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}


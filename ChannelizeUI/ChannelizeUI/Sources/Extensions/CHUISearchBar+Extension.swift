//
//  CHUISearchBar+Extension.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/19/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

extension UISearchBar {
    /// Returns the`UITextField` that is placed inside the text field.
    var textField: UITextField? {
        #if compiler(>=5.1)
        if #available(iOS 13.0, *){
        return searchTextField
        } else {
        return self.value(forKey: "_searchField") as? UITextField
        }
        #else
        return self.value(forKey: "_searchField") as? UITextField
        #endif
        
    }
    
    func setTextFieldBackgroundColor(color: UIColor) {
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
        self.textField?.backgroundColor = color
        } else {
        if let bg = self.textField?.subviews.first {
        bg.backgroundColor = color
        bg.clipsToBounds = true
        bg.layer.cornerRadius = 10
        }
        }
        #else
        if #available(iOS 13.0, *) {
            self.textField?.backgroundColor = color
        } else {
            if let bg = self.textField?.subviews.first {
                bg.backgroundColor = color
                bg.clipsToBounds = true
                bg.layer.cornerRadius = 10
            }
        }
        #endif
    }
}


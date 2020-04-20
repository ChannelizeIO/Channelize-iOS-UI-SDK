//
//  CHUIFont+Extension.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

public enum FontStyle: String {

    case sourceSansProRegular = "Courier"
    case sourceSansProItalic = "Courier-Oblique"
    case sourceSansProSemiBoldItalic = "Courier-BoldOblique"
    case sourceSansProBold = "Courier-Bold"
    case sourceSansProSemiBold = "Helvetica"
    case robotoRegular = "Georgia"
    case robotoMedium = "Georgia-BoldItalic"
    case robotoItalic = "Georgia-Italic"
    case robotoBold = "Georgia-Bold"
    case robotoSlabBold = "RobotoSlab-Bold"
    case robotoSlabMedium = "RobotoSlab-Medium"
    case robotoSlabRegualar = "RobotoSlab-Regular"
    case robotoSlabSemiBold = "RobotoSlab-SemiBold"
    
}

public extension UIFont {
    
    private class MyDummyClass {}
    
    static func loadFontWith(name: String) {
        let frameworkBundle = Bundle(for: MyDummyClass.self)
        let pathForResourceString = frameworkBundle.path(forResource: name, ofType: "ttf")
        let fontData = NSData(contentsOfFile: pathForResourceString!)
        let dataProvider = CGDataProvider(data: fontData!)
        let fontRef = CGFont(dataProvider!)
        var errorRef: Unmanaged<CFError>? = nil

        if (CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false) {
            NSLog("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }

    static let loadMyFonts: () = {
        loadFontWith(name: "RobotoSlab-Bold")
        loadFontWith(name: "RobotoSlab-Medium")
        loadFontWith(name: "RobotoSlab-Regular")
        loadFontWith(name: "RobotoSlab-SemiBold")
    }()
    
    convenience init?(fontStyle: FontStyle, size: CGFloat) {
        self.init(name: fontStyle.rawValue, size: size)
    }
}


//
//  CHUIColor+Extension.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    /// Constructing color from hex string
    ///
    /// - Parameter hex: A hex string, can either contain # or not
    convenience init(hex string: String) {
        var hex = string.hasPrefix("#")
            ? String(string.dropFirst())
            : string
        guard hex.count == 3 || hex.count == 6
            else {
                self.init(white: 1.0, alpha: 0.0)
                return
        }
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }
        
        self.init(
            red:   CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0,
            green: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0,
            blue:  CGFloat((Int(hex, radix: 16)!) & 0xFF) / 255.0, alpha: 1.0)
    }
    
    static let customSystemBlue = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    static let customSystemGray = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1)
    static let customSystemGreen = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
    static let customSystemIndigo = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1)
    static let customSystemOrange = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
    static let customSystemPink = UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1)
    static let customSystemPurple = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 1)
    static let customSystemRed = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
    static let customSystemTeal = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1)
    static let customSystemYellow = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
    
    
    func imageFromColor()->UIImage?{
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
    
    func imageWithColor(width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    
}


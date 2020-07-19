//
//  CHUIImage+Extension.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/7/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func resizableImage() -> UIImage {
        let edge = UIEdgeInsets(top: size.height*0.45, left: size.width*0.45, bottom: size.height*0.45, right: size.width*0.45)
        let image = self.resizableImage(withCapInsets: edge, resizingMode: .tile)
        return image
    }
    
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context.clip(to: rect, mask: self.cgImage!)
        tintColor.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // For Compression
    
    func resizeToApprox(sizeInMB: Double, deltaInMB: Double = 0.2) -> Data {
        let allowedSizeInBytes = Int(sizeInMB * 1024 * 1024)
        let deltaInBytes = Int(deltaInMB * 1024 * 1024)
        var fullResImage = self.jpegData(compressionQuality: 1.0)
        if (fullResImage?.count)! < Int(deltaInBytes + allowedSizeInBytes) {
            return fullResImage!
        }
        fullResImage = nil
        var i = 0
        
        var left:CGFloat = 0.0, right: CGFloat = 1.0
        var mid = (left + right) / 2.0
        var newResImage = self.jpegData(compressionQuality: mid)//UIImageJPEGRepresentation(self, mid)
        
        while (true) {
            i += 1
            if (i > 13) {
                //print("Compression ran too many times ") // ideally max should be 7 times as  log(base 2) 100 = 6.6
                break
            }
            if ((newResImage?.count)! < (allowedSizeInBytes - deltaInBytes)) {
                left = mid
            } else if ((newResImage?.count)! > (allowedSizeInBytes + deltaInBytes)) {
                right = mid
            } else {
                return newResImage!
            }
            mid = (left + right) / 2.0
            newResImage = self.jpegData(compressionQuality: mid)
        }
        return newResImage!
    }
    
    // For Resizing Image
    
    func selfResize(targetSize: CGSize) -> UIImage{
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        if #available(iOS 10.0, *) {
            return UIGraphicsImageRenderer(size:newSize).image { _ in
                self.draw(in: CGRect(origin: .zero, size: newSize))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
            // Fallback on earlier versions
        }
    }
    
}



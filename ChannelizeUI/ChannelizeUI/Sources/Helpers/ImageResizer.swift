//
//  ImageResizer.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import SDWebImage

class ImageResizer: NSObject, SDWebImageManagerDelegate {
    
    var imageSize: CGSize = .zero
    
    private func resizeImage(_ image: UIImage, newSize: CGSize) -> UIImage {
        let scale = newSize.height / image.size.height
        let newWidth = image.size.width * scale
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    public func imageManager(_ imageManager: SDWebImageManager, transformDownloadedImage image: UIImage?, with imageURL: URL?) -> UIImage? {
        guard let _image = image else {
            return nil
        }
        return resizeImage(_image, newSize: imageSize)
    }
}



//
//  CHString+Extension.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/2/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

public extension String {
    
    func with(_ icon : UIImage?)->NSMutableAttributedString{
        
        let iconsSize = CGRect(x: 0, y: -2.5, width: 15, height: 15)
        
        let fullString = NSMutableAttributedString()
        let attchment = NSTextAttachment()
        attchment.image = icon?.imageWithColor(tintColor: CHUIConstant.recentConversationMessageColor)
        attchment.bounds = iconsSize
        let attachedImage = NSAttributedString(attachment: attchment)
        fullString.append(attachedImage)
        let textAttributedString = NSAttributedString(string: " "+self, attributes: [NSAttributedString.Key.font: CHCustomStyles.mediumSizeRegularFont!, NSAttributedString.Key.foregroundColor: CHUIConstant.recentConversationMessageColor])
        fullString.append(textAttributedString)
        return fullString
    }
    
    
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while ranges.last.map({ $0.upperBound < self.endIndex }) ?? true,
            let range = self.range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale)
        {
            ranges.append(range)
        }
        return ranges
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}


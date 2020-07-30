//
//  ChannelizeUIHelper.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MobileCoreServices

func loadImageFromDiskWith(fileName: String) -> UIImage? {

  let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

    let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

    if let dirPath = paths.first {
        let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
        let image = UIImage(contentsOfFile: imageUrl.path)
        return image

    }
    return nil
}

func getViewEndOriginX(view: UIView) -> CGFloat {
    return view.frame.size.width + view.frame.origin.x
}

func getViewEndOriginY(view: UIView) -> CGFloat {
    return view.frame.size.height + view.frame.origin.y
}

func getKeyWindow() -> UIWindow?{
    if #available(iOS 13.0, *) {
        let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
        return keyWindow
    } else {
        return UIApplication.shared.delegate?.window ?? nil
    }
}

func getDateFromString(value: String?) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    guard let dateString = value else {
        return nil
    }
    return formatter.date(from: dateString)
}

func getStringFromDate(date: Date?) -> String? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    guard date != nil else {
        return nil
    }
    return formatter.string(from: date!)
}

func getImage(_ name: String) -> UIImage? {
    let assetsImageBundle = Bundle(identifier: "com.channelize.ChannelizeUI")
    if let processedImage = UIImage(named: name, in: assetsImageBundle, compatibleWith: nil) {
        return processedImage
    } else {
        return UIImage(named: name, in: Bundle.init(for: ChUI.self), compatibleWith: nil)
    }
}

func getViewOriginXEnd(view: UIView) -> CGFloat {
    return view.frame.width + view.frame.origin.x
}

func getViewOriginYEnd(view: UIView) -> CGFloat {
    return view.frame.height + view.frame.origin.y
}

func getDeviceWiseAspectedHeight(constant: CGFloat) -> CGFloat {
    let scaleFactor = constant / 667
    let aspectedHeight = scaleFactor * 667
    return aspectedHeight
}

func getDeviceWiseAspectedWidth(constant: CGFloat) -> CGFloat {
    let scaleFactor = constant / 375
    let aspectedWidth = scaleFactor * 375
    return aspectedWidth
}

func resizeImage(_ image: UIImage, newSize: CGSize) -> UIImage {
    let scale = newSize.height / image.size.height
    let newWidth = image.size.width * scale
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

func createThumbsFromImage(image:UIImage)->UIImage{
    let imageData = image.pngData()!
    let options = [
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceThumbnailMaxPixelSize: 180] as CFDictionary
    let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
    let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
    let thumbnail = UIImage(cgImage: imageReference)
    return thumbnail
}

func generateThumbnail(url: URL) -> UIImage? {
    do {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                     actualTime: nil)
        return UIImage(cgImage: cgImage)
    } catch {
        print(error.localizedDescription)
        
        return nil
    }
}

func getTimeStamp(_ date: Date)-> String{
    
    //let timestampDate = Date(jsonDate: date)
    let dateFormatter = DateFormatter()
    if Calendar.current.isDateInToday(date){
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "jm", options: 0, locale: NSLocale.current)
        //dateFormatter.dateFormat = "hh:mm a"
    }else if Calendar.current.isDateInYesterday(date){
        dateFormatter.dateFormat = "EEEE"
    }else{
        dateFormatter.dateFormat = "dd/MM/yyyy"
    }
    return dateFormatter.string(from: date)
    
}

func showProgressView(superView: UIView?, string: String?) {
    IHProgressHUD.set(containerView: superView)
    IHProgressHUD.set(defaultStyle: CHAppConstant.themeStyle == .dark ? .dark : .light)
    IHProgressHUD.set(ringThickness: 5.0)
    IHProgressHUD.set(foregroundColor: CHUIConstants.appDefaultColor)
    //IHProgressHUD.set(backgroundColor: UIColor(hex: "#fefefe"))
    IHProgressHUD.set(borderColor: UIColor.lightGray)
    IHProgressHUD.set(borderWidth: 0.5)
    IHProgressHUD.set(defaultMaskType: .black)
    IHProgressHUD.set(minimumDismiss: 1.0)
    IHProgressHUD.set(maximumDismissTimeInterval: 1.5)
    IHProgressHUD.set(font: CHCustomStyles.normalSizeRegularFont!)
    IHProgressHUD.setHapticsEnabled(hapticsEnabled: true)
    IHProgressHUD.show(withStatus: string)
    
    
    /*
    SVProgressHUD.setDefaultMaskType(.black)
    if superView != nil {
        SVProgressHUD.setContainerView(superView)
    }
    SVProgressHUD.setRingThickness(5.0)
    SVProgressHUD.setDefaultStyle(.light)
    SVProgressHUD.setMinimumDismissTimeInterval(1.0)
    SVProgressHUD.setMaximumDismissTimeInterval(1.5)
    SVProgressHUD.setFont(UIFont(fontStyle: .robotoSlabSemiBold, size: 18.0)!)
    SVProgressHUD.setHapticsEnabled(true)
    SVProgressHUD.show(withStatus: string)
 */
}

func disMissProgressView() {
    IHProgressHUD.set(defaultStyle: CHAppConstant.themeStyle == .dark ? .dark : .light)
    IHProgressHUD.dismiss()
    //SVProgressHUD.dismiss()
}

func showProgressErrorView(superView: UIView?, errorString: String?) {
    IHProgressHUD.set(containerView: superView)
    IHProgressHUD.set(defaultStyle: CHAppConstant.themeStyle == .dark ? .dark : .light)
    IHProgressHUD.set(ringThickness: 5.0)
    IHProgressHUD.set(defaultMaskType: .black)
    IHProgressHUD.set(minimumDismiss: 1.0)
    //IHProgressHUD.set(backgroundColor: UIColor(hex: "#fefefe"))
    IHProgressHUD.set(borderColor: UIColor.lightGray)
    IHProgressHUD.set(borderWidth: 0.5)
    IHProgressHUD.set(maximumDismissTimeInterval: 1.5)
    IHProgressHUD.set(font: CHCustomStyles.normalSizeRegularFont!)
    IHProgressHUD.setHapticsEnabled(hapticsEnabled: true)
    IHProgressHUD.showError(withStatus: errorString)
}

func showProgressSuccessView(superView: UIView?, withStatusString: String?) {
    IHProgressHUD.set(containerView: superView)
    IHProgressHUD.set(defaultStyle: CHAppConstant.themeStyle == .dark ? .dark : .light)
    //IHProgressHUD.set(backgroundColor: UIColor(hex: "#fefefe"))
    IHProgressHUD.set(borderColor: UIColor.lightGray)
    IHProgressHUD.set(borderWidth: 0.5)
    IHProgressHUD.set(ringThickness: 5.0)
    IHProgressHUD.set(defaultMaskType: .black)
    IHProgressHUD.set(minimumDismiss: 1.0)
    IHProgressHUD.set(maximumDismissTimeInterval: 1.5)
    IHProgressHUD.set(font: CHCustomStyles.normalSizeRegularFont!)
    IHProgressHUD.setHapticsEnabled(hapticsEnabled: true)
    IHProgressHUD.showSuccesswithStatus(withStatusString)
}

// Frame Calculator

func getTextMessageSizeInfo(maxWidth: CGFloat, withText: NSAttributedString) -> (frameSize: CGSize, numberOfLines: Int, lastCharXPosition: CGFloat){
    let textContainer: NSTextContainer = {
        let size = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let container = NSTextContainer(size: size)
        container.lineFragmentPadding = 0
        container.lineBreakMode = .byWordWrapping
        container.maximumNumberOfLines = 0
        return container
    }()
    
    let textStorage = replicateUITextViewNSTextStorage(withString: withText)
    let layoutManager: NSLayoutManager = {
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        return layoutManager
    }()
    
    let message = NSAttributedString(string: withText.string)
    let lastGlyphIndex = layoutManager.glyphIndexForCharacter(at: message.length - 1)
    let lastLineFragmentRect = layoutManager.lineFragmentUsedRect(forGlyphAt: lastGlyphIndex, effectiveRange: nil)
    
    let rect = layoutManager.usedRect(for: textContainer)
    
    var numberOfLines = rect.size.height/UIFont.systemFont(ofSize: 17.0).lineHeight
    numberOfLines = round(numberOfLines)
    let finalNumberOfLines = Int(numberOfLines)
    
    //return rect.size
    return (rect.size,finalNumberOfLines,lastLineFragmentRect.maxX)
    
}

func replicateUITextViewNSTextStorage(withString: NSAttributedString) -> NSTextStorage {
    return NSTextStorage(attributedString: withString)
}


open class MarkDown{
    
    var currentMarkElement = ""
    var currentDelimitor = ""
    
    var initialIndex : Int!
    var endIndex : Int!
    var markElements = ["*","_","~","$"]
    
    var currentAttribute = ""
    var currentWord = ""
    public static var shared : MarkDown = {
        let instance = MarkDown()
        return instance
    }()
    
    public func tranverseString(string: String, startingIndex: Int, textColor: UIColor = .black, withFont: UIFont = UIFont.systemFont(ofSize: 14.0)) -> NSMutableAttributedString {
        
        let normalAttributes = [ NSAttributedString.Key.font: withFont, NSAttributedString.Key.foregroundColor: textColor ]
        
        let finalString = NSMutableAttributedString(string: "", attributes: normalAttributes)
        
        for (_,char) in string.enumerated(){
            let currentString = String(char)
            if markElements.contains(currentString){
                if currentMarkElement == ""{
                    
                    let normalAttributedString = NSAttributedString(string: currentWord,attributes:normalAttributes)
                    finalString.append(normalAttributedString)
                    currentWord = ""
                    
                    currentMarkElement = currentString
                    currentWord.append(char)
                } else{
                    if currentString == currentMarkElement{
                        currentWord.append(char)
                        
                        var rangeWord = String(currentWord.dropFirst())
                        rangeWord = String(rangeWord.dropLast())
                        
                        var attributes : [NSAttributedString.Key:Any]?
                        if currentMarkElement == "*"{
                            
                            attributes = [NSAttributedString.Key.font: UIFont(name: CHCustomStyles.normalSizeMediumFont!.fontName, size: withFont.pointSize)!, NSAttributedString.Key.foregroundColor: textColor]
                        } else if currentMarkElement == "_"{
                            
                            attributes = [ NSAttributedString.Key.font: UIFont(name: CHCustomStyles.mediumSizeMediumItalicFont!.fontName, size: withFont.pointSize)!, NSAttributedString.Key.foregroundColor: textColor]
                        } else if currentMarkElement == "~"{
                            
                            attributes = [ NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: UIFont(name: CHCustomStyles.normalSizeRegularFont!.fontName, size: withFont.pointSize)!]
                        } else if currentMarkElement == "$"{
                            attributes = [NSAttributedString.Key.font:UIFont(name: "Courier", size: withFont.pointSize)!,NSAttributedString.Key.foregroundColor:textColor]
                        }
                        
                        if attributes != nil{
                            let normalAttributedString = NSAttributedString(string: rangeWord, attributes: attributes!)
                            finalString.append(normalAttributedString)
                            currentWord = ""
                            currentMarkElement = ""
                        } else{
                            let normalAttributedString = NSAttributedString(string: rangeWord)
                            finalString.append(normalAttributedString)
                            currentWord = ""
                            currentMarkElement = ""
                        }
                    } else{
                        currentWord.append(char)
                    }
                }
            } else{
                currentWord.append(char)
            }
        }
        
        if currentMarkElement != "" && currentWord != ""{
            if currentWord.count < 2{
                let finalWord = "\(currentWord)"
                let normalAttributedString = NSAttributedString(string: finalWord, attributes: normalAttributes)
                finalString.append(normalAttributedString)
            } else{
                let finalWord = "\(currentWord)"
                let normalAttributedString = NSAttributedString(string: finalWord, attributes: normalAttributes)
                finalString.append(normalAttributedString)
            }
            
        } else if currentWord != ""{
            let finalWord = "\(currentWord)"
            let normalAttributedString = NSAttributedString(string: finalWord, attributes: normalAttributes)
            finalString.append(normalAttributedString)
        }
        
        currentWord = ""
        currentMarkElement = ""
        currentAttribute = ""
        
        return finalString
    }
}

func getAttributedLabelHeight(attributedString: NSAttributedString, maximumWidth: CGFloat, numberOfLines: Int = 0)->CGFloat{
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: maximumWidth, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = numberOfLines
    label.attributedText = attributedString
    label.sizeToFit()
    let labelHeight = label.frame.size.height
    label.removeFromSuperview()
    return labelHeight
}

func getAttributedLabelWidth(attributedString: NSAttributedString,maximumHeight: CGFloat, numberOfLines: Int = 0) -> CGFloat{
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: maximumHeight))
    label.numberOfLines = numberOfLines
    label.attributedText = attributedString
    label.sizeToFit()
    let labelHeight = label.frame.size.width
    label.removeFromSuperview()
    return labelHeight
}

func CHLocalized(key: String) -> String{
    let s =  NSLocalizedString(key, tableName: "CHLocalizable", bundle: Bundle.main, value: "", comment: "")
    return s
}

func timeAgoSinceDate(_ date:Date,currentDate:Date, numericDates:Bool) -> String {
    
    let calendar = Calendar.current
    
    let now = currentDate
    
    let earliest = (now as NSDate).earlierDate(date)
    
    let latest = (earliest == now) ? date : now
    
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    
    
    if (components.year! >= 2) {
        
        return String(format: CHLocalized(key: "pmYearsAgo"), "\(components.year!)")
        //return "\(components.year!) years ago"
        
    } else if (components.year! >= 1){
        
        if (numericDates){
            return CHLocalized(key: "pmOneYearAgo")
            //return "1 year ago"
        } else {
            return CHLocalized(key: "pmLastYear")
            //return "last year"
            
        }
        
    } else if (components.month! >= 2) {
        return String(format: CHLocalized(key: "pmMonthsAgo"), "\(components.month!)")
        //return "\(components.month!) months ago"
        
    } else if (components.month! >= 1){
        
        if (numericDates){
            return CHLocalized(key: "pmOneMonthAgo")
            //return "1 month ago"
        } else {
            return CHLocalized(key: "pmLastMonth")
            //return "last month"
        }
        
    } else if (components.weekOfYear! >= 2) {
        return String(format: CHLocalized(key: "pmWeeksAgo"), "\(components.weekOfYear!)")
        //return "\(components.weekOfYear!) weeks ago"
        
    } else if (components.weekOfYear! >= 1){
        
        if (numericDates){
            return CHLocalized(key: "pmOneWeekAgo")
            //return "1 week ago"
        } else {
            return CHLocalized(key: "pmLastWeek")
            //return "last week"
        }
        
    } else if (components.day! >= 2) {
        return String(format: CHLocalized(key: "pmDaysAgo"), "\(components.day!)")
        //return "\(components.day!) days ago"
        
    } else if (components.day! >= 1){
        
        if (numericDates){
            
            return CHLocalized(key: "pmOneDayAgo")
            //return "1 day ago"
            
        } else {
            return CHLocalized(key: "pmYesterday")
            //return "Yesterday"
        }
        
    } else if (components.hour! >= 2) {
        return String(format: CHLocalized(key: "pmHoursAgo"), "\(components.hour!)")
        //return "\(components.hour!) hours ago"
        
    } else if (components.hour! >= 1){
        
        if (numericDates){
            return CHLocalized(key: "pmOneHourAgo")
            //return "1 hour ago"
        } else {
            return CHLocalized(key: "pmAnHourAgo")
            //return "an hour ago"
            
        }
        
    } else if (components.minute! >= 2) {
        return String(format: CHLocalized(key: "pmMinutesAgo"), "\(components.minute!)")
        //return "\(components.minute!) minutes ago"
        
    } else if (components.minute! >= 1){
        
        if (numericDates){
            return CHLocalized(key: "pmOneMinAgo")
            //return "1 minute ago"
        } else {
            return CHLocalized(key: "pmAMinAgo")
            //return "a min ago"
            
        }
        
    } else if (components.second! >= 0) {
        return String(format: CHLocalized(key: "pmSecondsAgo"), "\(components.second!)")
        //return "\(components.second!) sec ago"
    } else {
        return CHLocalized(key: "pmJustNow")
    }
    
    
    
}

func showIpadActionSheet(sourceView: UIView, popoverController: UIPopoverPresentationController) {
    popoverController.sourceView = sourceView
    popoverController.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
    popoverController.permittedArrowDirections = []
    
}

func getLastSeen(lastSeenDate: Date?) -> String {
    if let timestampDate = lastSeenDate {
        let date = Date()
        return CHLocalized(key: "pmLastSeen")+" "+timeAgoSinceDate(
            timestampDate, currentDate: date, numericDates: false)
    }
    return ""
}



class ImageEncoder {
    func encodeImage(storageUrl: URL, image: UIImage?, format: CHImageFormat, maxPixelSize: CGSize) -> Bool {
        guard let originalImage = image else {
            return false
        }

        guard let imageRef = originalImage.cgImage else {
            return false
        }

        var imageFormat = format

        if format == .undefined {
            let hasAlpha = self.cgImageContainsAlpha(imageRef)
            if hasAlpha {
                imageFormat = .png
            } else {
                imageFormat = .jpeg
            }
        }

        let imageUTType = Data.sd_UTType(from: imageFormat)

        var imageDestination: CGImageDestination? = nil
        imageDestination = CGImageDestinationCreateWithURL(storageUrl as CFURL, imageUTType, 1, nil)

        guard let newImageDestination = imageDestination else {
            return false
        }

        var properties: [AnyHashable : Any] = [:]
        let exifOrientation = self.exifOrientation(fromImageOrientation: originalImage.imageOrientation)
        properties[kCGImagePropertyOrientation as String] = NSNumber(value: exifOrientation.rawValue)
        //properties[kCGImageDestinationLossyCompressionQuality as String] = NSNumber(value: 1.0)
        

        let pixelWidth = CGFloat(imageRef.width)
        let pixelHeight = CGFloat(imageRef.height)
        if maxPixelSize.width > 0 && maxPixelSize.height > 0 && pixelWidth > maxPixelSize.width && pixelHeight > maxPixelSize.height {
            let pixelRatio = CGFloat(pixelWidth / pixelHeight)
            let maxPixelSizeRatio: CGFloat = maxPixelSize.width / maxPixelSize.height
            var finalPixelSize: CGFloat
            if pixelRatio > maxPixelSizeRatio {
                finalPixelSize = maxPixelSize.width
            } else {
                finalPixelSize = maxPixelSize.height
            }
            properties[kCGImageDestinationImageMaxPixelSize as String] = NSNumber(value: Float(finalPixelSize))
        }

        CGImageDestinationAddImage(newImageDestination, imageRef, properties as CFDictionary)
        if CGImageDestinationFinalize(newImageDestination) == false {
            return false
        }
        return true
    }

    func cgImageContainsAlpha(_ cgImage: CGImage?) -> Bool {
        if cgImage == nil {
            return false
        }
        let alphaInfo = cgImage?.alphaInfo
        let hasAlpha = !(alphaInfo == CGImageAlphaInfo.none || alphaInfo == .noneSkipFirst || alphaInfo == .noneSkipLast)
        return hasAlpha
    }

    func exifOrientation(fromImageOrientation imageOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        var exifOrientation: CGImagePropertyOrientation = .up
        switch imageOrientation {
            case .up:
                exifOrientation = .up
            case .down:
                exifOrientation = .down
            case .left:
                exifOrientation = .left
            case .right:
                exifOrientation = .right
            case .upMirrored:
                exifOrientation = .upMirrored
            case .downMirrored:
                exifOrientation = .downMirrored
            case .leftMirrored:
                exifOrientation = .leftMirrored
            case .rightMirrored:
                exifOrientation = .rightMirrored
            default:
                break
        }
        return exifOrientation
    }

    func get(from data: Data) -> CHImageFormat {
        switch data[0] {
        case 0x89:
            return .png
        case 0xFF:
            return .jpeg
        case 0x47:
            return .gif
        case 0x49, 0x4D:
            return .tiff
        case 0x52 where data.count >= 12:
            let subdata = data[0...11]

            if let dataString = String(data: subdata, encoding: .ascii),
                dataString.hasPrefix("RIFF"),
                dataString.hasSuffix("WEBP")
            {
                return .webP
            }
            break
        case 0x00 where data.count >= 12 :
            let subdata = data[8...11]

            if let dataString = String(data: subdata, encoding: .ascii),
                Set(["heic", "heix", "hevc", "hevx"]).contains(dataString)
                ///OLD: "ftypheic", "ftypheix", "ftyphevc", "ftyphevx"
            {
                return .heic
            }
            break
        case 0x25:
            if (data.count) >= 4 {
                //%PDF
                var testString: String? = nil
                if let range = Range(NSRange(location: 1, length: 3)) {
                    let subdata = data.subdata(in: range)
                    testString = String(data: subdata, encoding: .ascii)
                    if testString?.lowercased() == "PDF".lowercased() {
                        return .pdf
                    }
                }
            }
        case 0x3c:
            if (data.count) > 100 {
                // Check end with SVG tag
                var testString: String? = nil
                if let range = Range(NSRange(location: data.count - 100, length: 100)) {
                    let subdata = data.subdata(in: range)
                    testString = String(data: subdata, encoding: .ascii)
                    if testString?.contains("</svg>") == true {
                        return .svg
                    }
                }
            }
            break
        default:
            break
        }
        return .undefined
    }
}

enum CHImageFormat : Int {
    case undefined = -1
    case jpeg = 0
    case png = 1
    case gif = 2
    case tiff = 3
    case webP = 4
    case heic = 5
    case heif = 6
    case pdf = 7
    case svg = 8
}

extension Data {
    static func sd_UTType(from format: CHImageFormat) -> CFString {
        var UTType: CFString?
        switch format {
        case .jpeg:
                UTType = kUTTypeJPEG
        case .png:
                UTType = kUTTypePNG
        case .gif:
                UTType = kUTTypeGIF
        case .tiff:
                UTType = kUTTypeTIFF
        case .webP:
                UTType = "public.webp" as CFString
        case .heic:
                UTType = "public.heic" as CFString
        case .heif:
                UTType = "public.heif" as CFString
        case .pdf:
                UTType = kUTTypePDF
        case .svg:
                UTType = kUTTypeScalableVectorGraphics
        default:
            UTType = kUTTypePNG
        }
        return UTType ?? "" as CFString
    }
}


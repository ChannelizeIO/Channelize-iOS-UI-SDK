//
//  CHCustomStyles.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 4/19/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit


public var emojiCodes = [
"like":"\u{1f44d}", "dislike":"\u{1f44e}", "laughing":"\u{1f606}", "angry":"\u{1f621}", "crying":"\u{1f622}", "smile eyes":"\u{1f60a}", "star":"\u{1f31f}", "party":"\u{1f389}", "gift":"\u{1f381}"]

open class CHCustomStyles {
    static var main : CHCustomStyles {
        let style = CHCustomStyles()
        return style
    }
    
    // MARK: - Tab Bar Customization
    // Change Recent Screen Tab Bar image
    public static var recentScreenTabImage: UIImage? = getImage("recentTabIcon")
    public static var recentScreenSelectedTabImage: UIImage? = nil
    public static var recentScreenTabTitle: String? = nil

    // Change Contacts Screen Tab Bar Image
    public static var contactScreenTabImage:UIImage? = getImage("contactTabIcon")
    public static var contactScreenSelectedTabImage: UIImage? = nil
    public static var contactScreenTabTitle: String? = nil

    // Change Groups Screen Tab Bar Image
    public static var groupsScreenTabImage:UIImage? = getImage("groupsTabIcon")
    public static var groupsScreenSelectedTabImage: UIImage? = nil
    public static var groupsScreenTabTitle: String? = nil

    // Change Call Screens Tab Bar Image
    public static var callScreenTabImage:UIImage? = getImage("callsTabIcon")
    public static var callScreenSelectedTabImage: UIImage? = nil
    public static var callScreenTabTitle: String? = nil

    // Changes Settings Screen Tab Bar Image
    public static var settingsScreenTabImage:UIImage? = getImage("settingsTabIcon")
    public static var settingsScreenSelectedTabImage: UIImage? = nil
    public static var settingsScreenTabTitle: String? = nil
    
    // MARK: - Fonts
    
    public static var largeSizeRegularFont = UIFont(fontStyle: .regular, size: 19.0)
    public static var normalSizeRegularFont = UIFont(fontStyle: .regular, size: 17.0)
    public static var mediumSizeRegularFont = UIFont(fontStyle: .regular, size: 15.0)
    public static var smallSizeRegularFont = UIFont(fontStyle: .regular, size: 13.0)
    public static var extraSmallSizeRegularFont = UIFont(fontStyle: .regular, size: 11.0)
    
    public static var largeSizeMediumFont = UIFont(fontStyle: .medium, size: 19.0)
    public static var normalSizeMediumFont = UIFont(fontStyle: .medium, size: 17.0)
    public static var mediumSizeMediumFont = UIFont(fontStyle: .medium, size: 15.0)
    public static var smallSizeMediumFont = UIFont(fontStyle: .medium, size: 13.0)
    
    public static var normalSizeMediumItalicFont = UIFont(fontStyle: .mediumItalic, size: 17.0)
    public static var mediumSizeMediumItalicFont = UIFont(fontStyle: .mediumItalic, size: 15.0)
    
    public static var textMessageFont = UIFont(fontStyle: .regular, size: 17.0)
    public static var metaMessageFont = UIFont(fontStyle: .regular, size: 15.0)
    // Font for Meta Messages
    
    
    //Mark:- Colors Variables for UI
    
    public static var shimmeringColor = UIColor(white: 0.98, alpha: 1.0)
    
    //MARK:- Variables for Text Message Bubble
    
    /// Default UIColor(hex: "#3A3C4C")
    public static var incomingMessageTextColor : UIColor = UIColor(hex: "#3A3C4C")
    /// Default White
    public static var outgoingMessageTextColor : UIColor = UIColor.white
    public static var incomingMessageFont : UIFont = UIFont.systemFont(ofSize: 16.0)
    public static var outgoingMessageFont : UIFont = UIFont.systemFont(ofSize: 16.0)
    public static var incomingMessageEdgeInsets : UIEdgeInsets = UIEdgeInsets(top: 10, left: 19, bottom: 10, right: 15)
    public static var outgoingMessageEdgeInsets : UIEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 19)
    /// Default Blue
    public static var quotedIncomingMessageColor : UIColor = UIColor.blue
    /// Default Black
    public static var quotedOutgoingMessageColor : UIColor = UIColor.black
    
    //MARK:- Variables For Photo and Video Message Bubble
    public static var gifStickerMessageBubbleSize = CGSize(width: 220, height: 175)
    public static var locationMessageBubbleImageSize = CGSize(width: 260, height: 150)
    public static var audioMessageBubbleSize = CGSize(width: 260, height: 80)
    public static var videoMessageBubbleSize = CGSize(width: 210, height: 260)
    public static var imageMessageBubbleSize = CGSize(width: 230, height: 190)
    public static var docMessageBubbleSize = CGSize(width: 230, height: 110)
    
    
    
    
    public static var photoBubbleSize : CGSize = CGSize(width: 260, height: 240)
    public static var videoMessageSize : CGSize = CGSize(width: 220, height: 270)
    public static var gifStickerMessageSize: CGSize = CGSize(width: 220, height: 175)
    public static var stickerMessageSize : CGSize = CGSize(width: 100, height: 100)
    public static var gifMessageSize : CGSize = CGSize(width: 210, height: 136)
    public static var locationMessageSize : CGSize = CGSize(width: 210, height: 136)
    public static var squarePhotoSize : CGSize = CGSize(width: 210, height: 210)
    public static var audioMessageSize: CGSize = CGSize(width: 280, height: 80)
    public static var docMessageSize: CGSize = CGSize(width: 230, height: 110)
    //MARK:- Varibles For Base Message Bubble
    
    /// Default hex color #E6ECF2
    public static var baseMessageIncomingBackgroundColor : UIColor = UIColor(hex: "E6ECF2")
    /// Default Dark Sky Blue
    public static var baseMessageOutgoingBackgroundColor : UIColor = CHUIConstants.appDefaultColor
    /// Default Dark Gray
    public static var messageDateSeperatorColor : UIColor = UIColor(hex: "#8a8a8a")
    public static var messadeDateSeparatorFont : UIFont? = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
    
    //MARK:- Variables for Recent Message Screen Customization
    
    public static var recentScreenNameLabelFont = UIFont.systemFont(ofSize: 15.0)
    /// Default Black
    public static var recentScreenNameLabelColor = UIColor.black
    /// Default DarkGary
    public static var recentScreenMessageLabelColor = UIColor.darkGray
    public static var recentScreenTimeLabelFont = UIFont.systemFont(ofSize: 12.0)
    /// Default Gray
    public static var recentScreenTimeLabelColor = UIColor.gray
    /// Default White
    public static var recentScreenMessageCountColor = UIColor.white
    /// Default appColor
    public static var recentScreenMessageCountBgColor = CHUIConstants.appDefaultColor
    /// Default White
    public static var recentScreenTableBackgroundColor = UIColor.white
    /// Default White
    public static var recentScreenTableCellBackgroundColor = UIColor.white
    
    //MARK:- Variables for Groups List Screen Customization
    /// Default Black
    public static var groupNameLabelColor = UIColor.black
    public static var groupNameLabelFont = UIFont.systemFont(ofSize: 14.0)
    /// Default Gray
    public static var groupStatusLabelColor = UIColor.gray
    public static var groupStatusLabelFont = UIFont.systemFont(ofSize: 12.0)
    /// Default Black
    public static var groupMemberCountLabelColor = UIColor.black
    public static var groupMemberCountLabelFont = UIFont.systemFont(ofSize: 14.0)
    /// Default White
    public static var groupCellBackgroundColor = UIColor.white
    /// Default White
    public static var groupsTableBackgroundColor = UIColor.white
    /// Default LightGray
    public static var groupsTableCellShadowColor = UIColor.lightGray.cgColor
    
    //MARK:- Variables For Contacts List Screen Customization
    public static var contactNameLabelFont = UIFont.systemFont(ofSize: 15.0)
    /// Default Black
    public static var contactNameLabelColor = UIColor.black
    
    //MARK:- Variables for Contact Screen Customization
    
    //MARK:- Variables to Set Custom text and Images for Tab Bar Controllers
    /// Default True
    public static var groupScreenTabTitle = CHLocalized(key: "pmGroups")
    
    //MARK:- Variables for Seachbar
    
    /// Default Clear
    public static var searchBarBackgroundColor : UIColor = UIColor.white
    /// Default White
    public static var searchBarTextColor : UIColor = UIColor.black
    /// Default White
    public static var searchBarTintColor : UIColor = UIColor.white
    
}

open class CHCustomOptions {
    
    //MARK:- Variables for Message Options
    public static var enableMessageForwarding : Bool = true
    public static var enableMessageQuoting : Bool = true
    public static var enableAudioMessages : Bool = true
    public static var enableImageMessages : Bool = true
    public static var enableVideoMessages : Bool = true
    public static var enableLocationMessages : Bool = true
    public static var enableStickerAndGifMessages : Bool = true
    public static var enableDocSharingMessage: Bool = true
    public static var enableMessageReactions: Bool = true
    
    //MARK:- Variables for Attachments Limits In MB
    public static var maximumImageSize : CGFloat = 50.0
    public static var maximumVideoSize : CGFloat = 50.0
    public static var maximumAudioSize : CGFloat = 25.0
    public static var maximumDocumentSize: CGFloat = 50.0
    
    //MARK:- Variables For Chat Screen
    public static var enableAttachments = true
    
    //MARK:- Variables for Contact Screen
    public static var showOnlineUsers = true
    public static var contactTableSeperatorType : UITableViewCell.SeparatorStyle = .singleLine
    public static var contactTableSeperatorColor : UIColor = .lightGray
    public static var contactTableBackgroundColor : UIColor = .white
    public static var contactsTableCellBackgroundColor : UIColor = .white
    
    //MARK:- Variables For other Options on Conversation Screen
    public static var enableQuoteMessage : Bool = true
    public static var enableUserOnlineStatus : Bool = true
    public static var enableLastSeenStatus : Bool = true
    public static var showMemberCountInHeader : Bool = true
    
    
    //MARK:- Other Variables related to Sysytem Like Keyboards etc.
    public static var keyboardAppearance : UIKeyboardAppearance = .light
    
    //MARK:- Global Functionalaties
    public static var enableSearching : Bool = true
    
    // MARK:- Show View Profile Button on user Profile
    public static var enableViewProfileButton : Bool = true
    
    // MARK:- Show Logout Button. Ignore -> just for Testing
    public static var showLogoutButton : Bool = false
    
    public static var callModuleEnabled: Bool = true
    
    static var isAllUserSearchEnabled: Bool = false
    
}

class CHStyle{

    static var main: CHStyle = {
        let style = CHStyle()
        return style
    }()
    
    class var hasNotchAvailable: Bool {
        let maxLength = max(UIScreen.main.bounds.size.width,UIScreen.main.bounds.size.height)
        return (UIDevice.current.userInterfaceIdiom == .phone && maxLength >= 812.0)
    }
    
    class var isIPhoneX:Bool{
        let maxLength = max(UIScreen.main.bounds.size.width,UIScreen.main.bounds.size.height)
        return (UIDevice.current.userInterfaceIdiom == .phone && maxLength == 812.0)
    }
    
    class var isIPhone5:Bool{
        let maxLength = max(UIScreen.main.bounds.size.width,UIScreen.main.bounds.size.height)
        return (UIDevice.current.userInterfaceIdiom == .phone && maxLength == 568.0)
    }
    
}

func getTheme() {
    let themetype = ThemeType(rawValue: "dark")
}

//MARK:- Config Class
class CHConfig{
    
    public var pageLimit = 30
    
    static var main: CHConfig = {
        let config = CHConfig()
        return config
    }()
    
    class var isIPhoneX:Bool{
        let maxLength = max(UIScreen.main.bounds.size.width,UIScreen.main.bounds.size.height)
        return (UIDevice.current.userInterfaceIdiom == .phone && maxLength == 812.0)
    }
    
    class var isIPhone5:Bool{
        let maxLength = max(UIScreen.main.bounds.size.width,UIScreen.main.bounds.size.height)
        return (UIDevice.current.userInterfaceIdiom == .phone && maxLength == 568.0)
    }
    
    class var isIphoneXR:Bool {
        let maxLength = max(UIScreen.main.bounds.size.width,UIScreen.main.bounds.size.height)
        return (UIDevice.current.userInterfaceIdiom == .phone && maxLength == 896.0)
    }
    class var topPadding:CGFloat {
        if isIPhoneX || isIphoneXR{
            return 88
        } else {
            return 64
        }
    }
    
}


//MARK:- For Themes
enum ThemeType : String {
    
    case Dark = "dark"
    case White = "white"
    case Normal = "normal"
    
    //Recent Screen Variables
    var recentScreenNameColor : UIColor {
        switch self {
        case .Dark :
            return .white
        case .White:
            return .black
        case .Normal:
            return .black
        }
    }
    
    var recentScreenMessageColor : UIColor {
        switch self {
        case .Dark:
            return .white
        case .White:
            return .white
        case .Normal:
            return .white
        }
    }

}


//
//  CHCustomStyles.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 4/19/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

open class CHCustomStyles {
    static var main : CHCustomStyles {
        let style = CHCustomStyles()
        return style
    }
    
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
    
    public static var photoBubbleSize : CGSize = CGSize(width: 210, height: 136)
    public static var stickerMessageSize : CGSize = CGSize(width: 100, height: 100)
    public static var gifMessageSize : CGSize = CGSize(width: 210, height: 136)
    public static var locationMessageSize : CGSize = CGSize(width: 210, height: 136)
    public static var videoMessageSize : CGSize = CGSize(width: 210, height: 136)
    public static var squarePhotoSize : CGSize = CGSize(width: 210, height: 210)
    
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
    public static var showTabNames : Bool = true
    public static var recentScreenTabTitle = CHLocalized(key: "pmRecent")
    public static var contactScreenTabTitle = CHLocalized(key: "pmContacts")
    public static var groupScreenTabTitle = CHLocalized(key: "pmGroups")
    public static var settingsScreenTabTitle = CHLocalized(key: "pmSettings")
    
    public static var recentScreenTabImage = getImage("recent")
    public static var contactScreenTabImage = getImage("contacts")
    public static var groupsScreenTabImage = getImage("groups")
    public static var settingsScreenTabImage = getImage("settings")
    
    public static var recentScreenSelectedTabImage = getImage("recent_filled")
    public static var contactScreenSelectedTabImage = getImage("contacts_filled")
    public static var groupsScreenSelectedTabImage = getImage("groups_filled")
    public static var settingsScreenSelectedTabImage = getImage("settings_filled")
    
    /// Default White
    public static var tabBarBgColor : UIColor = .white
    /// Defult AppColor
    public static var tabBarTintColor : UIColor = CHUIConstants.appDefaultColor
    /// Default False
    public static var isTabBarSolid : Bool = false
    /// Default Gray
    public static var tabBarItemImageColor : UIColor = .gray
    /// Default Gray
    public static var tabBarItemTextColor : UIColor = .gray
    
    //MARK:- Variables for NavigationBar
    /// Default app Default Color
    public static var navigationBarTintColor : UIColor = CHUIConstants.appDefaultColor
    /// Default White
    public static var navigationBarBarTintColor : UIColor = UIColor.white
    /// Default False
    public static var isNavigationBarSolid : Bool = false
    /// Default Dark or .default
    public static var navigationBarStatusStyle : UIStatusBarStyle = UIStatusBarStyle.default
    
    //MARK:- Variables for Seachbar
    
    /// Default Clear
    public static var searchBarBackgroundColor : UIColor = UIColor.clear
    /// Default White
    public static var searchBarTextColor : UIColor = UIColor.white
    /// Default White
    public static var searchBarTintColor : UIColor = UIColor.white
    
}

open class CHCustomOptions {
    
    //MARK:- Variables for Message Options
    public static var enableMessageForwarding : Bool = true
    public static var enableMessageQuoting : Bool = true
    public static var enableSearching : Bool = true
    public static var enableUserLastSeen : Bool = true
    public static var enableUserOnlineIndicator : Bool = true
    public static var enableAudioMessages : Bool = true
    public static var enableImageMessages : Bool = true
    public static var enableVideoMessages : Bool = true
    public static var enableLocationMessages : Bool = true
    public static var enableStickerAndGifMessages : Bool = true
    public static var enableDocSharingMessage: Bool = true
    
    //MARK:- Variables for Attachments Limits In MB
    public static var maximumImageSize : CGFloat = 50.0
    public static var maximumVideoSize : CGFloat = 25.0
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
    public static var allowSearching : Bool = true
    
    // MARK:- Call SKD Module Enabled or Not
    public static var enableCallModule : Bool = false
    
    // MARK:- Show View Profile Button on user Profile
    public static var enableViewProfileButton : Bool = true
    
    // MARK:- Show Logout Button. Ignore -> just for Testing
    public static var showLogoutButton : Bool = false
    
}

class CHStyle{

    static var main: CHStyle = {
        let style = CHStyle()
        return style
    }()
    
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

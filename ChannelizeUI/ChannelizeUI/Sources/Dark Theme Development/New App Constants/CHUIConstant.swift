//
//  CHUIConstant.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/23/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import UIKit

class CHUIConstant {
    
    static var CHConversationTitleColor = UIColor(hex: "#e6e6e6")
    static var CHConversationMessageColor = UIColor(hex: "#e6e6e6")
    static var CHConversationLastUpdatedColor = UIColor(hex: "#e6e6e6")
    static var CHContactNameColor = UIColor(hex: "#e6e6e6")
    
    // MARK: - Global
    static var appTintColor: UIColor {
        switch CHAppConstant.themeStyle {
        case .dark:
            return CHDarkThemeColors.tintColor
        default:
            return CHLightThemeColors.tintColor
        }
    }
    
    // MARK: - Recent Conversation Screen Colors
    static var recentConversationTitleColor: UIColor {
        if CHAppConstant.themeStyle == .dark {
            return CHDarkThemeColors.primaryColor
        } else {
            return CHLightThemeColors.primaryColor
        }
    }
    
    static var recentConversationMessageColor: UIColor {
        if CHAppConstant.themeStyle == .dark {
            return CHDarkThemeColors.secondaryColor
        } else {
            return CHLightThemeColors.secondaryColor
        }
    }
    
    static var recentConversationLastUpdatedColor: UIColor {
        if CHAppConstant.themeStyle == .dark {
            return CHDarkThemeColors.tertiaryColor
        } else {
            return CHLightThemeColors.tertiaryColor
        }
    }
    
    static var recentScreenMessageStatusColor: UIColor {
        if CHAppConstant.themeStyle == .dark {
            return CHDarkThemeColors.tertiaryColor
        } else {
            return CHLightThemeColors.tertiaryColor
        }
    }
    
    static var recentScreenTypingColor: UIColor {
        if CHAppConstant.themeStyle == .dark {
            return CHDarkThemeColors.tintColor
        } else {
            return CHLightThemeColors.tintColor
        }
    }
    
    static var recentConversationTitleFont = UIFont(fontStyle: .regular, size: 17.0)
    static var recentConversationMessageFont = UIFont(fontStyle: .regular, size: 15.0)
    static var recentConversationLastUpdatedFont = UIFont(fontStyle: .regular, size: 13.0)
    
    // MARK: - Contacts Screen Colors and Fonts
    static var contactNameColor: UIColor {
        if CHAppConstant.themeStyle == .dark {
            return CHDarkThemeColors.primaryColor
        } else {
            return CHLightThemeColors.primaryColor
        }
    }
    static var contactNameFont = UIFont(fontStyle: .regular, size: 17.0)
    
    // MARK: - Settings Screen Color
    static var settingsScreenMainLabelColor: UIColor {
        switch CHAppConstant.themeStyle {
        case .dark:
            return CHDarkThemeColors.primaryColor
        default:
            return CHLightThemeColors.primaryColor
        }
    }
    
    static var settingsScreenSecondaryLabelColor: UIColor {
        switch CHAppConstant.themeStyle {
        case .dark:
            return CHDarkThemeColors.secondaryColor
        default:
            return CHLightThemeColors.secondaryColor
        }
    }
    
    static var settingsSceenDiscloseIndicatorColor: UIColor {
        switch CHAppConstant.themeStyle {
        case .dark:
            return CHDarkThemeColors.secondaryColor
        default:
            return CHLightThemeColors.secondaryColor
        }
    }
    
    // MARK: - Recent Conversation Colors
    
    // MARK: - Message Bubble Colors
    static var incomingTextMessageBackGroundColor: UIColor {
        if CHAppConstant.themeStyle == .dark {
            return CHDarkThemeColors.incomingTextMessageBackGroundColor
        } else {
            return CHLightThemeColors.incomingTextMessageBackGroundColor
        }
    }
    
    static var incomingTextMessageColor: UIColor {
        if CHAppConstant.themeStyle == .dark {
            return CHDarkThemeColors.incomingTextMessageColor
        } else {
            return CHLightThemeColors.incomingTextMessageColor
        }
    }
    
    
    
    
    static var outGoingTextMessageBackGroundColor: UIColor {
        switch CHAppConstant.themeStyle {
        case .dark:
            return CHDarkThemeColors.outGoingTextMessageBackGroundColor
        default:
            return CHLightThemeColors.outGoingTextMessageBackGroundColor
        }
    }
    static var outGoingTextMessageColor: UIColor {
        switch CHAppConstant.themeStyle {
        case .dark:
            return CHDarkThemeColors.outGoingTextMessageColor
        default:
            return CHLightThemeColors.outGoingTextMessageColor
        }
    }
    
    static var textMessageFontSize: CGFloat = 16.0
    static var textMessageFont: UIFont = UIFont(fontStyle: .regular, size: 17.0)!
    
    // MARK: - Message Bubble Size
    static var gifStickerMessageBubbleSize = CGSize(width: 220, height: 175)
    static var locationMessageBubbleImageSize = CGSize(width: 260, height: 150)
    static var audioMessageBubbleSize = CGSize(width: 260, height: 80)
    static var videoMessageBubbleSize = CGSize(width: 210, height: 260)
    static var imageMessageBubbleSize = CGSize(width: 230, height: 190)
    static var docMessageBubbleSize = CGSize(width: 230, height: 110)
}


//
//  CHUIConstants.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/23/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

public class CHConstants {
    public static var isChannelizeCallAvailable = true
    public static var isGifStickerMessageEnabled = true
    public static var isDocumentMessageEnabled = true
}

public class CHUIConstants {
    // Theme Default Color
    public static var appDefaultColor = UIColor(hex: "#2175f5")
    
    // Constant Colors
    public static var onlineStatusColor = UIColor(hex: "#64BA00")
    
    // Fonts
    public static var smallFontSize: CGFloat = 13.0
    public static var mediumFontSize: CGFloat = 15.0
    public static var normalFontSize: CGFloat = 17.0
    public static var largeFontSize: CGFloat = 20.0
    public static var extraLargeFontSize: CGFloat = 22.0
    
    // Text Message Bubble Color
    public static var incomingTextMessageBackgroundColor = UIColor(hex: "E6ECF2")
    public static var outgoingTextMessageBackgroundColor = CHUIConstants.appDefaultColor
    
    // Conversations Screen
    public static var incomingTextMessageBubbleColor = UIColor(hex: "#F5F5F5")
    public static var outGoingTextMessageBubbleColor = UIColor(hex: "#1b6df5")
    
    // Contacts Screens
    public static var contactNameColor = UIColor(hex: "#4a505a")
    public static var contactNameFont = UIFont(fontStyle: .robotoSlabRegualar, size: CHUIConstants.normalFontSize)
    
    // Recent Conversation Screen
    public static var conversationTitleColor = UIColor(hex: "#3a3c4c")
    public static var conversationTitleFont = UIFont(fontStyle: .robotoSlabRegualar, size: CHUIConstants.normalFontSize)
    public static var conversationMessageColor = UIColor(hex: "#4a505a")
    public static var conversationMessageFont = UIFont(fontStyle: .robotoSlabRegualar, size: CHUIConstants.mediumFontSize)
    public static var conversationUpdatedTimeColor = UIColor(hex: "#8b8b8b")
    public static var conversationUpdatedTimeFont = UIFont(fontStyle: .robotoSlabRegualar, size: CHUIConstants.smallFontSize)
}



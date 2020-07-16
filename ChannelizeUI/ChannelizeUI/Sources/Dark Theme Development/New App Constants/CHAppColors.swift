//
//  CHAppColors.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/4/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import UIKit

public class CHDarkThemeColors {
    
    public static var instance: CHDarkThemeColors = {
        let instance = CHDarkThemeColors()
        return instance
    }()
    
    public static var primaryColor: UIColor = UIColor(hex: "#ffffff")
    public static var secondaryColor: UIColor = UIColor(hex: "#E6E6E6")
    public static var tertiaryColor: UIColor = UIColor(hex: "#E6E6E6")
    public static var buttonsTintColor: UIColor = UIColor(hex: "#ffffff")
    public static var tintColor: UIColor = UIColor.customSystemBlue
    public static var tableCellBackGroundColor = UIColor(hex: "#1c1c1c")
    public static var plainTableBackGroundColor = UIColor(hex: "#1c1c1c")
    public static var groupedTableBackGroundColor = UIColor(hex: "#010101")
    public static var seperatorColor: UIColor = UIColor(hex: "#38383a")
    public static var conversationHeaderBackGroundColor: UIColor = UIColor(hex: "#1c1c1c")
    public static var incomingTextMessageBackGroundColor = UIColor(hex: "#232124")
    public static var navigationHeaderTitleColor = UIColor.white
    
    // Text Color for incoming text and quoted messages.
    public static var incomingTextMessageColor = UIColor(hex: "#ffffff")

    // Background color for outgoing Text and Quoted Messages.
    public static var outGoingTextMessageBackGroundColor = UIColor(hex: "#2176f5")

    // Text color for outgoing text and quoted messages.
    public static var outGoingTextMessageColor = UIColor(hex: "#ffffff")
    
    public var buttonTintColor: UIColor = UIColor.customSystemBlue
    public var seperatorColor: UIColor = UIColor(hex: "#38383a")
    public var groupedTableBackGroundColor = UIColor(hex: "#010101")
    public var plainTableBackGroundColor = UIColor(hex: "#1c1c1c")
    
}

public class CHLightThemeColors {
    public static var instance: CHLightThemeColors = {
        let instance = CHLightThemeColors()
        return instance
    }()
    
    public static var primaryColor: UIColor = UIColor(hex: "#4a505a")
    public static var secondaryColor: UIColor = UIColor(hex: "#3a3c4c")
    public static var tertiaryColor: UIColor = UIColor(hex: "#8b8b8b")
    public static var buttonsTintColor: UIColor = UIColor(hex: "#2176f5")
    public static var tintColor: UIColor = UIColor(hex: "#2176f5")
    public static var tableCellBackGroundColor = UIColor.white
    public static var groupedTableBackGroundColor = UIColor(hex: "#f2f2f8")
    public static var plainTableBackGroundColor = UIColor.white
    public static var seperatorColor: UIColor = UIColor(hex: "#c6c6c8")
    public static var conversationHeaderBackGroundColor: UIColor = UIColor(hex: "#ffffff")
    public static var navigationHeaderTitleColor = UIColor(hex: "#4a505a")
    // Background color for incoming Text and Quoted Messages.
    public static var incomingTextMessageBackGroundColor = UIColor(hex: "#e6e6e6")

    // Text Color for incoming text and quoted messages.
    public static var incomingTextMessageColor = UIColor(hex: "#3b3c4d")

    // Background color for outgoing Text and Quoted Messages.
    public static var outGoingTextMessageBackGroundColor = UIColor(hex: "#2176f5")

    // Text color for outgoing text and quoted messages.
    public static var outGoingTextMessageColor = UIColor(hex: "#ffffff")
    
    public var buttonTintColor: UIColor = UIColor(hex: "#2176f5")
    public var seperatorColor: UIColor = UIColor(hex: "#c6c6c8")
    public var groupedTableBackGroundColor = UIColor(hex: "#f2f2f8")
    public var plainTableBackGroundColor = UIColor.white
    
}



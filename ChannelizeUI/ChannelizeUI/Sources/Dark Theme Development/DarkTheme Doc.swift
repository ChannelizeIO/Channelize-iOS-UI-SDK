//
//  DarkTheme Doc.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/11/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation


import Foundation

class CHFontStyle {
    
    static var instance: CHFontStyle = {
        let instance = CHFontStyle()
        return instance
    }()
    
    func configureChannelizeFonts() {
        //CHCustomStyles
    }
    
}

/*
 
 ## Dark Theme Support
 By default, the dark theme support feature is OFF in UI SDK. If you want to turn Off this feature set
 
 ```swift
    CHCustomOptions.enableDarkThemeSupport = true
 ```
 
 ### Colors For Dark Themes
 All default Colors are set in `CHDarkThemeColors` class. Following are default values
 
 ```swift
 
 // Primary Color. Mainly used for Titles in views headers, tables and collectionviews cell's main label text Colors.
 public static var primaryColor: UIColor = UIColor(hex: "#ffffff")
 
 // Secondary Color. Mainly Used for Secondary titles.
 public static var secondaryColor: UIColor = UIColor(hex: "#E6E6E6")
 
 // Tertiary color. Mainly used for tertiary titles like date timestamps, etc.
 public static var tertiaryColor: UIColor = UIColor(hex: "#E6E6E6")
 
 // Tint Color to be Used for CTAs in all Screens.
 public static var tintColor: UIColor = UIColor.customSystemBlue
 
 // Navigation Header Background color
 public static var conversationHeaderBackGroundColor: UIColor = UIColor(hex: "#1c1c1c")
 
 // Seperator Colors used in table cells, collectionview cells and headers seperator color.
 public static var seperatorColor: UIColor = UIColor(hex: "#38383a")
 
 // Grouped Tabled background color. Used in Search Screen, Send location screen, Create New Group Scree and Group profile screen
 public static var groupedTableBackGroundColor = UIColor(hex: "#010101")
 
 // Plain table Background color. Used in all screen other than grouped tabled mentioned above.
 public static var plainTableBackGroundColor = UIColor(hex: "#1c1c1c")
 
 // Background color for incoming Text and Quoted Messages.
 public static var incomingTextMessageBackGroundColor = UIColor(hex: "#232124")
 
 // Text Color for incoming text and quoted messages.
 public static var incomingTextMessageColor = UIColor(hex: "#ffffff")
 
 // Background color for outgoing Text and Quoted Messages
 public static var outGoingTextMessageBackGroundColor = UIColor(hex: "#2176f5")
 
 // Text color for outgoing text and quoted messages.
 public static var outGoingTextMessageColor = UIColor(hex: "#ffffff")
 
 // Cells Background Color for table views and collection views
 public static var cellBackgroundColors = UIColor(hex: "#1c1c1c")
 
 ```
 
 ### Colors for Light Theme
 
 All default Colors are set in `CHLightThemeColors` class. Following are default values
 
 ```swift
 
 // Primary Color. Mainly used for Titles in views headers, tables and collectionviews cell's main label text Colors.
 public static var primaryColor: UIColor = UIColor(hex: "#4a505a")
 
 // Secondary Color. Mainly Used for Secondary titles.
 public static var secondaryColor: UIColor = UIColor(hex: "#3a3c4c")
 
 // Tertiary color. Mainly used for tertiary titles like date timestamps, etc.
 public static var tertiaryColor: UIColor = UIColor(hex: "#8b8b8b")
 
 // Tint Color to be Used for CTAs in all Screens.
 public static var tintColor: UIColor = UIColor(hex: "#2176f5")
 
 // Navigation Header Background color
 public static var conversationHeaderBackGroundColor: UIColor = UIColor(hex: "#ffffff")
 
 // Seperator Colors used in table cells, collectionview cells and headers seperator color.
 public static var seperatorColor: UIColor = UIColor(hex: "#c6c6c8")
 
 // Grouped Tabled background color. Used in Search Screen, Send location screen, Create New Group Scree and Group profile screen
 public static var groupedTableBackGroundColor = UIColor(hex: "#f2f2f8")
 
 // Plain table Background color. Used in all screen other than grouped tabled mentioned above.
 public static var plainTableBackGroundColor = UIColor(hex: "#ffffff")
 
 // Background color for incoming Text and Quoted Messages.
 public static var incomingTextMessageBackGroundColor = UIColor(hex: "#e6e6e6")
 
 // Text Color for incoming text and quoted messages.
 public static var incomingTextMessageColor = UIColor(hex: "#3b3c4d")
 
 // Background color for outgoing Text and Quoted Messages
 public static var outGoingTextMessageBackGroundColor = UIColor(hex: "#2176f5")
 
 // Text color for outgoing text and quoted messages.
 public static var outGoingTextMessageColor = UIColor(hex: "#ffffff")
 
 // Cells Background Color for table views and collection views
 public static var cellBackgroundColors = UIColor(hex: "#ffffff")
 
 ```
 
 
 
 */

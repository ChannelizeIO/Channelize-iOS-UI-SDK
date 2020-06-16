import Foundation
import UIKit

public enum ThemeStyle {
    case dark
    case light
}

public class CHAppConstant {
    public static var themeStyle: ThemeStyle = CHAppConstant.getThemeStyle()
    public static var lightThemeTintColor: UIColor = UIColor(hex: "#2176f5")
    public static var isCallModuleEnabled = true
    
    public static func getThemeStyle() -> ThemeStyle{
        if let isDarkTheme = UserDefaults.standard.value(forKey: "CHDarkThemOn") as? Bool {
            if isDarkTheme {
                return .dark
            } else {
                return .light
            }
        } else {
            return .dark
        }
    }
}

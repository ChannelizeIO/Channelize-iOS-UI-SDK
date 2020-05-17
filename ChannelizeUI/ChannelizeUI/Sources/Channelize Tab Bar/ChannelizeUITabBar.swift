//
//  ChannelizeUITabBar.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit
/*
class DarkModeAwareNavigationController: UINavigationController {
  
  override init(rootViewController: UIViewController) {
       super.init(rootViewController: rootViewController)
       self.updateBarTintColor()
  }
  
  required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       self.updateBarTintColor()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
       super.traitCollectionDidChange(previousTraitCollection)
       self.updateBarTintColor()
  }
  
  private func updateBarTintColor() {
       if #available(iOS 13.0, *) {
            self.navigationBar.barTintColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
  }
  }
}

*/
class ChannelizeUITabBar: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        #endif
        UIFont.loadMyFonts
        //UINavigationBar.appearance(whenContainedInInstancesOf: [ChannelizeUITabBar.self]).tintColor =
        UIApplication.shared.delegate?.window??.tintColor = CHUIConstants.appDefaultColor
        UINavigationBar.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).tintColor = CHUIConstants.appDefaultColor
        #if compiler(>=5.1)
        if #available(iOS 13.0, *){
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = CHUIConstants.appDefaultColor
        UINavigationBar.appearance(whenContainedInInstancesOf: [ChannelizeUITabBar.self]).tintColor = .white
        UINavigationBar.appearance(whenContainedInInstancesOf: [ChannelizeUITabBar.self]).standardAppearance = navBarAppearance
        UINavigationBar.appearance(whenContainedInInstancesOf: [ChannelizeUITabBar.self]).scrollEdgeAppearance = navBarAppearance
        } else {
        UINavigationBar.appearance().barTintColor = CHUIConstants.appDefaultColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().tintColor = CHUIConstants.appDefaultColor
        //UITabBar.appearance().barTintColor = UIColor(hex: "#1a1a1a")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        }
        #else
        UINavigationBar.appearance().barTintColor = CHUIConstants.appDefaultColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().tintColor = CHUIConstants.appDefaultColor
        //UITabBar.appearance().barTintColor = UIColor(hex: "#1a1a1a")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        #endif
        
        
        let recentTabTitle = CHCustomStyles.recentScreenTabTitle
        let contactTabTitle = CHCustomStyles.contactScreenTabTitle
        let groupTabTitle = CHCustomStyles.groupScreenTabTitle
        let settingsTabTitle = CHCustomStyles.settingsScreenTabTitle
        
        let recentTabImage = CHCustomStyles.recentScreenTabImage
        
        let contactTabImage = CHCustomStyles.contactScreenTabImage
        
        let groupsTabImage = CHCustomStyles.groupsScreenTabImage
        
        let settingsTabImage = CHCustomStyles.settingsScreenTabImage
        
        let recentTabSelectedImage = CHCustomStyles.recentScreenSelectedTabImage
        let contactTabSelectedImage = CHCustomStyles.contactScreenSelectedTabImage
        let groupsTabSelectedImage = CHCustomStyles.groupsScreenSelectedTabImage
        let settingsTabSelectedImage = CHCustomStyles.settingsScreenSelectedTabImage
        
        
        
        
        let recentConversationController = UIRecentConversationController()
        let recentNavigationController = UINavigationController(rootViewController: recentConversationController)
        recentNavigationController.tabBarItem.image = recentTabImage
        recentNavigationController.tabBarItem.selectedImage = recentTabSelectedImage
        recentNavigationController.tabBarItem.title = recentTabTitle
        //recentNavigationController.tabBarItem.imageInsets = imageInsets
        
        let contactsViewController = UIContactsViewController()
        let contactsNavigationController = UINavigationController(rootViewController: contactsViewController)
        contactsNavigationController.tabBarItem.image = contactTabImage
        contactsNavigationController.tabBarItem.selectedImage = contactTabSelectedImage
        contactsNavigationController.tabBarItem.title = contactTabTitle
        //contactsNavigationController.tabBarItem.imageInsets = imageInsets
        
        let layout = UICollectionViewFlowLayout()
        let groupListViewController = UIGroupsViewController(collectionViewLayout: layout)
        let groupNavigationController = UINavigationController(rootViewController: groupListViewController)
        groupNavigationController.tabBarItem.image = groupsTabImage
        groupNavigationController.tabBarItem.selectedImage = groupsTabSelectedImage
        groupNavigationController.tabBarItem.title = groupTabTitle
        //groupNavigationController.tabBarItem.imageInsets = imageInsets
        
        let settingsViewController = UISettingsViewController()
        let settingNavigationController = UINavigationController(rootViewController: settingsViewController)
        settingNavigationController.tabBarItem.image = settingsTabImage
        settingNavigationController.tabBarItem.selectedImage = settingsTabSelectedImage
        settingNavigationController.tabBarItem.title = settingsTabTitle
        //settingNavigationController.tabBarItem.imageInsets = imageInsets
        
        let recentCallViewController = UIRecentCallsViewController()
        let recentCallNavigationController = UINavigationController(rootViewController: recentCallViewController)
        recentCallNavigationController.tabBarItem.image = getImage("chTabBarCallIcon")
        recentCallNavigationController.tabBarItem.selectedImage = nil
        recentCallNavigationController.tabBarItem.title = "Calls"
        //recentCallNavigationController.tabBarItem.imageInsets = imageInsets
        if CHConstants.isChannelizeCallAvailable {
            viewControllers = [recentNavigationController,contactsNavigationController,groupNavigationController,recentCallNavigationController,
            settingNavigationController]
        } else {
            viewControllers = [recentNavigationController,contactsNavigationController,groupNavigationController,
            settingNavigationController]
        }
        
    }
}

//extension UITabBar {
//    override open func sizeThatFits(_ size: CGSize) -> CGSize {
//        super.sizeThatFits(size)
//        guard let window = UIApplication.shared.keyWindow else {
//            return super.sizeThatFits(size)
//        }
//        var sizeThatFits = super.sizeThatFits(size)
//        if #available(iOS 11.0, *) {
//            if CHCustomStyles.showTabNames {
//                sizeThatFits.height = window.safeAreaInsets.bottom + 55
//            } else {
//                sizeThatFits.height = window.safeAreaInsets.bottom + 42
//            }
//            //sizeThatFits.height = window.safeAreaInsets.bottom + 55
//        }else{
//            sizeThatFits.height = 55
//        }
//        return sizeThatFits
//    }
//}

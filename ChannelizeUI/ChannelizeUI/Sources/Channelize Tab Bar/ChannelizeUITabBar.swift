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
        
        let recentConversationController = UIRecentConversationController()
        let recentNavigationController = UINavigationController(rootViewController: recentConversationController)
        recentNavigationController.tabBarItem.image = getImage("chTabBarChatIcon")
        recentNavigationController.tabBarItem.selectedImage = nil
        recentNavigationController.tabBarItem.title = "Recent"
        
        let contactsViewController = UIContactsViewController()
        let contactsNavigationController = UINavigationController(rootViewController: contactsViewController)
        contactsNavigationController.tabBarItem.image = getImage("chTabBarContactsIcon")
        contactsNavigationController.tabBarItem.selectedImage = nil
        contactsNavigationController.tabBarItem.title = "Contacts"
        
        let layout = UICollectionViewFlowLayout()
        let groupListViewController = UIGroupsViewController(collectionViewLayout: layout)
        let groupNavigationController = UINavigationController(rootViewController: groupListViewController)
        groupNavigationController.tabBarItem.image = getImage("chTabBarGroupIcon")
        groupNavigationController.tabBarItem.selectedImage = nil
        groupNavigationController.tabBarItem.title = "Groups"
        
        let settingsViewController = UISettingsViewController()
        let settingNavigationController = UINavigationController(rootViewController: settingsViewController)
        settingNavigationController.tabBarItem.image = getImage("chTabBarSettingIcon")
        settingNavigationController.tabBarItem.selectedImage = nil
        settingNavigationController.tabBarItem.title = "Settings"
        
        let recentCallViewController = UIRecentCallsViewController()
        let recentCallNavigationController = UINavigationController(rootViewController: recentCallViewController)
        recentCallNavigationController.tabBarItem.image = getImage("chTabBarCallIcon")
        recentCallNavigationController.tabBarItem.selectedImage = nil
        recentCallNavigationController.tabBarItem.title = "Calls"
        
        /*
        let contactsViewController = UIContactsViewController2()
        let contactsNavigationController = UINavigationController(rootViewController: contactsViewController)
        contactsNavigationController.tabBarItem.image = getImage("chTabBarContactsIcon")
        contactsNavigationController.tabBarItem.selectedImage = nil
        contactsNavigationController.tabBarItem.title = "Contacts"
        
        let layout = UICollectionViewFlowLayout()
        let groupListViewController = UIGroupsViewController(collectionViewLayout: layout)
        let groupNavigationController = UINavigationController(rootViewController: groupListViewController)
        groupNavigationController.tabBarItem.image = getImage("chTabBarGroupIcon")
        groupNavigationController.tabBarItem.selectedImage = nil
        groupNavigationController.tabBarItem.title = "Groups"
        
        let settingsViewController = UISettingsViewController()
        let settingNavigationController = UINavigationController(rootViewController: settingsViewController)
        settingNavigationController.tabBarItem.image = getImage("chTabBarSettingIcon")
        settingNavigationController.tabBarItem.selectedImage = nil
        settingNavigationController.tabBarItem.title = "Settings"
        
        viewControllers = [recentNavigationController, contactsNavigationController, groupNavigationController, settingNavigationController]
    */
        //AllFriends.getInitialContacts()
        if CHConstants.isChannelizeCallAvailable {
            viewControllers = [recentNavigationController,contactsNavigationController,groupNavigationController,recentCallNavigationController,
            settingNavigationController]
        } else {
            viewControllers = [recentNavigationController,contactsNavigationController,groupNavigationController,
            settingNavigationController]
        }
        
    }
}


//
//  CHTabBarController.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

class CHTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Channelize.connect()
        UIFont.loadMyFonts
        
        //UIApplication.shared.delegate?.window??.tintColor = UIColor.systemTeal
        UINavigationBar.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).tintColor = UIColor.customSystemBlue
        UINavigationBar.appearance(whenContainedInInstancesOf: [UIImagePickerController.self]).tintColor = UIColor.customSystemBlue
        UINavigationBar.appearance(whenContainedInInstancesOf: [CHTabBarController.self]).tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.buttonsTintColor : CHLightThemeColors.buttonsTintColor
        
        let recentConversationController = CHRecentConversationsController()
        let recentNavigationController = CHNavigationController(rootViewController: recentConversationController)
        recentNavigationController.tabBarItem.image = CHCustomStyles.recentScreenTabImage
        recentNavigationController.tabBarItem.selectedImage = CHCustomStyles.recentScreenSelectedTabImage
        recentNavigationController.tabBarItem.title = CHCustomStyles.recentScreenTabTitle
        if CHCustomStyles.recentScreenTabTitle == nil {
            recentNavigationController.tabBarItem.setImageOnly()
        }
        
        let contactsViewController = CHContactViewController()
        let contactsNavigationController = CHNavigationController(rootViewController: contactsViewController)
        contactsNavigationController.tabBarItem.image = CHCustomStyles.contactScreenTabImage
        contactsNavigationController.tabBarItem.selectedImage = CHCustomStyles.contactScreenSelectedTabImage
        contactsNavigationController.tabBarItem.title = CHCustomStyles.contactScreenTabTitle
        if CHCustomStyles.contactScreenTabTitle == nil {
            contactsNavigationController.tabBarItem.setImageOnly()
        }
        
        let groupsViewController = CHGroupsTableViewController()
        let groupsNavigationController = CHNavigationController(rootViewController: groupsViewController)
        groupsNavigationController.tabBarItem.image = CHCustomStyles.groupsScreenTabImage
        groupsNavigationController.tabBarItem.selectedImage = CHCustomStyles.groupsScreenSelectedTabImage
        groupsNavigationController.tabBarItem.title = CHCustomStyles.groupsScreenTabTitle
        if CHCustomStyles.groupsScreenTabTitle == nil {
            groupsNavigationController.tabBarItem.setImageOnly()
        }
        
        let recentCallViewController = CHRecentCallsViewController()
        let recentCallNavViewController = CHNavigationController(rootViewController: recentCallViewController)
        recentCallNavViewController.tabBarItem.image = CHCustomStyles.callScreenTabImage
        recentCallNavViewController.tabBarItem.selectedImage = CHCustomStyles.callScreenSelectedTabImage
        recentCallNavViewController.tabBarItem.title = CHCustomStyles.callScreenTabTitle
        if CHCustomStyles.callScreenTabTitle == nil {
            recentCallNavViewController.tabBarItem.setImageOnly()
        }
        
        let mainSettingsViewController = CHSettingsViewController()
        let mainSettingsNavigationController = CHNavigationController(rootViewController: mainSettingsViewController)
        mainSettingsNavigationController.tabBarItem.image = CHCustomStyles.settingsScreenTabImage
        mainSettingsNavigationController.tabBarItem.selectedImage = CHCustomStyles.settingsScreenSelectedTabImage
        mainSettingsNavigationController.tabBarItem.title = CHCustomStyles.settingsScreenTabTitle
        if CHCustomStyles.settingsScreenTabTitle == nil {
            mainSettingsNavigationController.tabBarItem.setImageOnly()
        }
        
        if CHConstants.isChannelizeCallAvailable {
            viewControllers = [recentNavigationController, contactsNavigationController, groupsNavigationController, recentCallNavViewController, mainSettingsNavigationController]
        } else {
            viewControllers = [recentNavigationController, contactsNavigationController, groupsNavigationController, mainSettingsNavigationController]
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            self.viewControllers?.removeAll()
            Channelize.removeAllUserEventsDelegates()
            Channelize.removeAllConversationsEventDelegates()
            ChUserCache.instance.users.removeAll()
            CHConversationCache.instance.conversations.removeAll()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UITabBarItem {
   func setImageOnly(){
       imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
       setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.clear], for: .selected)
       setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.clear], for: .normal)
   }
}


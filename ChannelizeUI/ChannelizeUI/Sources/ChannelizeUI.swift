//
//  ChannelizeUI.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit
import ChannelizeAPI

public class ChannelizeUI {
    
    fileprivate var notificationData: [AnyHashable : Any]?
    open var chCurrentChatId: String?
    open var currentChatIdUserName: String = ""
    
    open var isCHOpen = false
    public static var instance: ChannelizeUI = {
        let instance = ChannelizeUI()
        return instance
    }()
    
    public static func launchChannelize(navigationController: UINavigationController?, data:[AnyHashable : Any]? = nil) {
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.tabBarController?.tabBar.isHidden = true
        if ChannelizeAPI.getCurrentUserId() != "" {
            if UserDefaults.standard.value(forKey: ChannelizeKeys.isUserOnline.key()) as? Bool == true {
                ChannelizeAPI.setUserOnline()
            }
            if(!instance.isCHOpen) {
                instance.isCHOpen = true
                instance.notificationData = data
                let tabBarController = ChannelizeUITabBar()
                navigationController?.pushViewController(
                    tabBarController, animated: true)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "channelizeNotification"), object: nil, userInfo: data)
            }
        }
    }
    
    func getData()-> [AnyHashable : Any]? {
        return notificationData
    }
    
}


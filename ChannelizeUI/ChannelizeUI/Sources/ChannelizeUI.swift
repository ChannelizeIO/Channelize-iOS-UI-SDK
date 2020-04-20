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
    internal var giphyKey: String?
    
    open var isCHOpen = false
    public static var instance: ChannelizeUI = {
        let instance = ChannelizeUI()
        return instance
    }()
    
    public static func launchChannelize(navigationController: UINavigationController?, data:[AnyHashable : Any]? = nil) {
        
        
        if let path = Bundle.main.path(forResource: "Channelize-Info", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                if let giphyKey = dict["GIPHY_API_KEY"] as? String{
                    self.instance.giphyKey = giphyKey
                }
            }
        }
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
    
    func getGiphyKey() -> String {
        return self.giphyKey ?? ""
    }
    
}


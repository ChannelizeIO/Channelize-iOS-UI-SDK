//
//  ChUI.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit
import ChannelizeAPI

public class ChUI {
    
    fileprivate var notificationData: [AnyHashable : Any]?
    open var chCurrentChatId: String?
    open var currentChatIdUserName: String = ""
    
    open var isCHOpen = false
    public static var instance: ChUI = {
        let instance = ChUI()
        return instance
    }()
    
    // MARK: - Configure Channelize
    public static func configure() {
        if let path = Bundle.main.path(forResource: "Channelize-Info", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                if let giphyKey = dict["GIPHY_API_KEY"] as? String {
                    CHGifyService.configureGiphy(with: giphyKey)
                }
            }
        }
    }
    
    public static func launchChannelize(navigationController: UINavigationController?, data:[AnyHashable : Any]? = nil) {
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.tabBarController?.tabBar.isHidden = true
        configure()
        if Channelize.getCurrentUserId() != "" {
            if UserDefaults.standard.value(forKey: ChannelizeKeys.isUserOnline.key()) as? Bool == true {
                Channelize.setUserOnline()
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


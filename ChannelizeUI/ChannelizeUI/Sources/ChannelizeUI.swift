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
    
    public init() {
        
    }
    
    var mapKey: String?
    
    var isEndToEndEncryptionEnabled = false
    var virgilAppId: String?
    var virgilAppKeyId: String?
    var virgilAppKey: String?
    
    // MARK: - Configure Channelize
    public static func configure() {
        if let path = Bundle.main.path(forResource: "Channelize-Info", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                if let giphyKey = dict["GIPHY_API_KEY"] as? String {
                    CHGifyService.configureGiphy(with: giphyKey)
                }
                if let mapKey = dict["MAP_API_KEY"] as? String {
                    instance.mapKey = mapKey
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
                ChannelizeAPIService.getEnabledModules(completion: {(modules,errorString) in
                    if let enabledModules = modules {
                       self.instance.processModulesKeys(modulesArray: enabledModules)
                    }
                })
                
                self.instance.checkIsAllUserSearchIsEnabled()
                instance.isCHOpen = true
                instance.notificationData = data
                let tabBarController = CHTabBarController()
                navigationController?.pushViewController(tabBarController, animated: true)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "channelizeNotification"), object: nil, userInfo: data)
            }
        }
    }
    
    func getData()-> [AnyHashable : Any]? {
        return notificationData
    }
    
    func getMapKey() -> String {
        return self.mapKey ?? ""
    }
    
    func checkIsAllUserSearchIsEnabled() {
        ChannelizeAPIService.isAllUsearchEnable(completion: {(isEnabled,errorString) in
            guard errorString == nil else {
                return
            }
            CHCustomOptions.isAllUserSearchEnabled = isEnabled
        })
    }
    
    private func processModulesKeys(modulesArray: NSArray) {
        modulesArray.forEach({
            if let moduleInfo = $0 as? NSDictionary {
                if moduleInfo.value(forKey: "identifier") as? String == "end-to-end-encryption" {
                    if let settingsArray = moduleInfo.value(forKey: "settings") as? NSArray {
                        settingsArray.forEach({
                            if let singleSettingInfo = $0 as? [String:String] {
                                
                                print(singleSettingInfo)
                                if singleSettingInfo["key"] == "appId" {
                                    self.virgilAppId = singleSettingInfo["value"]
                                    self.setVirgilAppId()
                                } else if singleSettingInfo["key"] == "appKeyId" {
                                    self.virgilAppKeyId = singleSettingInfo["value"]
                                } else if singleSettingInfo["key"] == "appKey" {
                                    self.virgilAppKey = singleSettingInfo["value"]
                                }
                            }
                        })
                    }
                    /*
                    ChVirgilE3Kit.initializeEthree(completion: { (successfull,error) in
                        if successfull {
                            ChVirgilE3Kit.checkAndRegisterUser(completion: {(status,error) in
                                
                            })
                        }
                    })
                    ChVirgilE3Kit.isEndToEndEncryptionEnabled = true
                     */
                } else if moduleInfo.value(forKey: "identifier") as? String == "real-time-language-translate" {
                    if let settingsArray = moduleInfo.value(forKey: "settings") as? NSArray {
                        settingsArray.forEach({
                            if let singleSettingInfo = $0 as? [String:String] {
                                if let apiKey = singleSettingInfo["value"], apiKey != "" {
                                    CHGoogleTranslation.isGoogleTranslationModuleEnabled = true
                                    CHGoogleTranslation.googleTranslateApiKey = apiKey
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    
    func setVirgilAppId() {
        UserDefaults.standard.set(self.virgilAppId, forKey: "channelize_virgile_appId")
    }
    
    func getSavedVirgilAppId() -> String {
        return UserDefaults.standard.value(forKey: "channelize_virgile_appId") as? String ?? ""
    }
    
    func getVirgilAppId() -> String {
        return self.virgilAppId ?? ""
    }
}





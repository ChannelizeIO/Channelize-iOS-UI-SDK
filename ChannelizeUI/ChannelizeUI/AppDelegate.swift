//
//  AppDelegate.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 4/17/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import ChannelizeCall

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let controller = LoginTableController()
        let navigationController = UINavigationController(rootViewController: controller)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.tintColor = .blue
        self.window?.makeKeyAndVisible()
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = .blue
        
        Channelize.configure()
        CHCall.configureVoiceVideo()
        return true
    }

    // MARK: UISceneSession Lifecycle
}


//
//  CHNavigationController.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class CHNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if CHAppConstant.themeStyle == .dark {
            return .lightContent
        } else {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        }
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return nil
    }
}

extension UINavigationController {
    func updateStatusBarStyle() {
        self.setNeedsStatusBarAppearanceUpdate()
    }
}

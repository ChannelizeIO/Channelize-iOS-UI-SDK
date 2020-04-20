//
//  CHUIViewcontroller+Extension.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 4/4/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect = .zero) {
        addChild(child)
        view.addSubview(child.view)
        UIView.animate(withDuration: 0.33, animations: {
            child.view.frame = frame
        })
        child.didMove(toParent: self)
    }

    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

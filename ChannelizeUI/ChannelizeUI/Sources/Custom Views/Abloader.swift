//
//  ShimmeringLoader.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

public class ABLoader {
    public init() {}
    public func startShining(_ view: UIView) {
        view.layoutIfNeeded()
        animate(view: view, start: true)
    }
    
    public func stopShining(_ view: UIView) {
        animate(view: view, start: false)
    }
    
    public func startSmartShining(_ view: UIView) {
        addLoader(view, start: true)
    }
    
    public func stopSmartShining(_ view: UIView) {
        addLoader(view, start: false)
    }
    
    private func addLoader(_ view: UIView, start: Bool) {
        view.layoutIfNeeded()
        for subView in view.subviews {
            animate(view: subView, start: start)
        }
    }
    
    private func animate(view:UIView, start: Bool) {
        if start {
            let shimmeringColor = UIColor(hex: "#eaeaea")
            // 1. Add Color Layer
            let colorLayer = CALayer()
            colorLayer.backgroundColor = UIColor(white: 0.90, alpha: 1).cgColor
            colorLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
            colorLayer.name = "colorLayer"
            view.layer.addSublayer(colorLayer)
            view.autoresizesSubviews = true
            view.clipsToBounds = true
            
            // 2. Add loader Layer
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [shimmeringColor.cgColor,
                                    shimmeringColor.cgColor,
                                    shimmeringColor.cgColor]
            gradientLayer.locations = [0,0.4,0.8, 1]
            gradientLayer.name = "loaderLayer"
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
            view.layer.addSublayer(gradientLayer)
            
            // 3. Animate loader layer
            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.duration = 0.8
            animation.fromValue = -view.frame.width
            animation.toValue = view.frame.width
            animation.repeatCount = Float.infinity
            gradientLayer.add(animation, forKey: "smartLoader")
        } else {
            if let smartLayers = view.layer.sublayers?.filter({$0.name == "colorLayer" || $0.name == "loaderLayer"}) {
                smartLayers.forEach({$0.removeFromSuperlayer()})
            }
        }
    }
}


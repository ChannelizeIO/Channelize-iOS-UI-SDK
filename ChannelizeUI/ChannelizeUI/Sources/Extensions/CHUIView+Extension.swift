//
//  UIView+Extension.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit

public extension Double{
    
    func stringFromTimeInterval() -> String {
        
        let timeInterval = self
        if (timeInterval < 60) {
            return String.init(format: "0:%02d",Int(Darwin.round(timeInterval)))
        }
        else if (timeInterval < 3600) {
            return String.init(format: "%d:%02d",Int(timeInterval) / 60, Int(timeInterval) % 60)
        }
        return String.init(format: "%d:%02d:%02d",Int(timeInterval) / 3600,Int(timeInterval) / 60, Int(timeInterval) % 60)
        
    }
    
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
      formatter.unitsStyle = style
      guard let formattedString = formatter.string(from: self) else { return "" }
      return formattedString
    }
}

public extension UIView {
    
    func setTopAnchor(relatedConstraint: NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: CGFloat) {
        let scaleFactor = constant/667
        let aspectedConstant = scaleFactor * 667
        self.topAnchor.constraint(equalTo: relatedConstraint, constant: aspectedConstant).isActive = true
    }
    
    func setBottomAnchor(relatedConstraint: NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: CGFloat) {
        let scaleFactor = constant/667
        let aspectedConstant = scaleFactor * 667
        self.bottomAnchor.constraint(equalTo: relatedConstraint, constant: aspectedConstant).isActive = true
    }
    
    func setLeftAnchor(relatedConstraint: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat) {
        
        let scaleFactor = constant / 375
        let aspectedConstant = scaleFactor * 375
        self.leftAnchor.constraint(equalTo: relatedConstraint, constant: aspectedConstant).isActive = true
    }
    
    func setRightAnchor(relatedConstraint: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat) {
        
        let scaleFactor = constant / 375
        let aspectedConstant = scaleFactor * 375
        self.rightAnchor.constraint(equalTo: relatedConstraint, constant: aspectedConstant).isActive = true
    }
    
    func setHeightAnchor(constant: CGFloat) {
        let scaleFactor = constant / 667
        let aspectedConstant = scaleFactor * 667
        self.heightAnchor.constraint(equalToConstant: aspectedConstant).isActive = true
    }
    
    func setWidthAnchor(constant: CGFloat) {
        let scaleFactor = constant / 375
        let aspectedConstant = scaleFactor * 375
        self.widthAnchor.constraint(equalToConstant: aspectedConstant).isActive = true
    }
    
    func setCenterXAnchor(relatedConstraint: NSLayoutAnchor<NSLayoutXAxisAnchor>, constant: CGFloat) {
        let scaleFactor = constant / 375
        let aspectedConstant = scaleFactor * 375
        self.centerXAnchor.constraint(equalTo: relatedConstraint, constant: aspectedConstant).isActive  = true
    }
    
    func setCenterYAnchor(relatedConstraint: NSLayoutAnchor<NSLayoutYAxisAnchor>, constant: CGFloat) {
        let scaleFactor = constant / 375
        let aspectedConstant = scaleFactor * 375
        self.centerYAnchor.constraint(equalTo: relatedConstraint, constant: aspectedConstant).isActive  = true
    }
    
    func setViewAsCircle(circleWidth: CGFloat) {
        let scaleFactor = circleWidth / 375
        let aspectedConstant = scaleFactor * 375
        let circleRadius = aspectedConstant / 2.0
        
        self.widthAnchor.constraint(equalToConstant: aspectedConstant).isActive = true
        self.heightAnchor.constraint(equalToConstant: aspectedConstant).isActive = true
        self.layer.cornerRadius = circleRadius
        if self.layer.masksToBounds == false {
            self.layer.masksToBounds = true
        }
    }
    
    func pinEdgeToSuperView(superView: UIView) {
        self.setLeftAnchor(relatedConstraint: superView.leftAnchor, constant: 0)
        self.setRightAnchor(relatedConstraint: superView.rightAnchor, constant: 0)
        self.setTopAnchor(relatedConstraint: superView.topAnchor, constant: 0)
        self.setBottomAnchor(relatedConstraint: superView.bottomAnchor, constant: 0)
    }
    
    func setViewsAsSquare(squareWidth: CGFloat) {
        let scaleFactor = squareWidth / 375
        let aspectedConstant = scaleFactor * 375
        self.widthAnchor.constraint(equalToConstant: aspectedConstant).isActive = true
        self.heightAnchor.constraint(equalToConstant: aspectedConstant).isActive = true
    }
    
    func addRightBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        border.frame = CGRect(x: frame.size.width - borderWidth, y: 0, width: borderWidth, height: frame.size.height)
        addSubview(border)
    }
    
    func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }
    
    func addBottomBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }
    
    func addLeftBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: borderWidth, height: frame.size.height)
        border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        addSubview(border)
    }
    
    enum AnimationKeyPath: String {
        case opacity = "opacity"
    }
    
    func flash(animation: AnimationKeyPath ,withDuration duration: TimeInterval = 1.0, repeatCount: Float = 5){
        let flash = CABasicAnimation(keyPath: AnimationKeyPath.opacity.rawValue)
        flash.duration = duration
        flash.fromValue = 1 // alpha
        flash.toValue = 0 // alpha
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = Float.greatestFiniteMagnitude
        layer.add(flash, forKey: nil)
    }
    
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated()
        {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
    
}


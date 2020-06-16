//
//  MessageLoaderView.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/15/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialActivityIndicator

class MessageLoaderView: UIView {

    private var containerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#3c3c3c") : UIColor(hex: "#e6e6e6")
        return view
    }()
    
    private var indicatorView: MDCActivityIndicator = {
        let indicator = MDCActivityIndicator()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.radius = 17.5
        indicator.cycleColors = [CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor]
        indicator.strokeWidth = 5
        indicator.startAnimating()
        
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        
        self.addSubview(self.containerView)
        self.containerView.frame.size = self.frame.size
        self.containerView.frame.origin = .zero
        self.containerView.setViewCircular()
        
        self.containerView.addSubview(self.indicatorView)
        
        self.indicatorView.setViewsAsSquare(squareWidth: 45)
        self.indicatorView.setCenterXAnchor(relatedConstraint: self.containerView.centerXAnchor, constant: 0)
        self.indicatorView.setCenterYAnchor(relatedConstraint: self.containerView.centerYAnchor, constant: 0)
    }
    
    func showSpinnerView() {
        indicatorView.startAnimating()
    }
    
    func hideSpinnerView() {
        indicatorView.stopAnimating()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

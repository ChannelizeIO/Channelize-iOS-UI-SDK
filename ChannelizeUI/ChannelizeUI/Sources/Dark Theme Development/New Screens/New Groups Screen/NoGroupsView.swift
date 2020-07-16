//
//  NoGroupsView.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class NoGroupsView: UIView {

    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var noConversationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.image = getImage("noGroups.png")
        return imageView
    }()
    
    private var noConversationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#3b3c4c")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .regular, size: 16.0)
        label.text = "No Groups found. To start a new one, tap on '+' icon."
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.plainTableBackGroundColor : CHLightThemeColors.instance.plainTableBackGroundColor
        self.setUpViews()
        self.setUpViewsFrames()
        self.updateColors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(containerView)
        self.containerView.addSubview(noConversationImageView)
        self.containerView.addSubview(noConversationLabel)
    }
    
    private func setUpViewsFrames() {
        
        self.containerView.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 0)
        self.containerView.setRightAnchor(relatedConstraint: self.rightAnchor, constant: 0)
        self.containerView.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: -10)
        self.containerView.setHeightAnchor(constant: 180)
        
        self.noConversationImageView.setViewsAsSquare(squareWidth: 120)
        self.noConversationImageView.setCenterXAnchor(relatedConstraint: self.containerView.centerXAnchor, constant: 0)
        self.noConversationImageView.setTopAnchor(relatedConstraint: self.containerView.topAnchor, constant: 10)
        
        self.noConversationLabel.setLeftAnchor(relatedConstraint: self.containerView.leftAnchor, constant: 15)
        self.noConversationLabel.setRightAnchor(relatedConstraint: self.containerView.rightAnchor, constant: -15)
        self.noConversationLabel.setTopAnchor(relatedConstraint: self.noConversationImageView.bottomAnchor, constant: 10)
        self.noConversationLabel.setHeightAnchor(constant: 45)
    }
    
    func updateColors() {
        self.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.plainTableBackGroundColor : CHLightThemeColors.instance.plainTableBackGroundColor
        self.noConversationLabel.textColor = CHUIConstant.recentConversationTitleColor
    }

}


//
//  CHNavHeaderView.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/26/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit

class CHNavHeaderView: UIView {

    var backButton: UIButton = {
        let button = UIButton()
        button.setImage(getImage("chNavBackIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var searchButton: UIButton = {
        let button = UIButton()
        button.setImage(getImage("chNavSearchIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var chatOptionButton: UIButton = {
        let button = UIButton()
        button.setImage(getImage("chNavMessageIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Conversations"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(fontStyle: .medium, size: 17.0)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var chatPlusButtonPressed: (() -> Void)?
    var onSearchButtonPressed: (() -> Void)?
    var onBackButtonPressed: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        self.addSubview(backButton)
        self.addSubview(searchButton)
        self.addSubview(chatOptionButton)
        self.addSubview(titleLabel)
        self.addSubview(seperatorView)
        self.chatOptionButton.addTarget(self, action: #selector(chatPlusButtonTouched(sender:)), for: .touchUpInside)
        self.searchButton.addTarget(self, action: #selector(searchButtonPressed(sender:)), for: .touchUpInside)
        self.backButton.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
    }
    
    func setUpViewsFrames() {
        self.backButton.setViewsAsSquare(squareWidth: 30)
        self.backButton.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 5)
        self.backButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        self.chatOptionButton.setViewsAsSquare(squareWidth: 30)
        self.chatOptionButton.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -5)
        self.chatOptionButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        self.searchButton.setViewsAsSquare(squareWidth: 30)
        self.searchButton.setRightAnchor(relatedConstraint: self.chatOptionButton.leftAnchor, constant: -15)
        self.searchButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        self.titleLabel.setCenterXAnchor(relatedConstraint: self.centerXAnchor, constant: 0)
        self.titleLabel.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        self.titleLabel.setHeightAnchor(constant: 30)
        self.titleLabel.setWidthAnchor(constant: 150)
        
        self.seperatorView.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: -10)
        self.seperatorView.setRightAnchor(relatedConstraint: self.rightAnchor, constant: 10)
        self.seperatorView.setHeightAnchor(constant: 0.5)
        self.seperatorView.setBottomAnchor(relatedConstraint: self.bottomAnchor, constant: 0)
        
        //self.addBottomBorder(with: UIColor(hex: "#e6e6e6"), andWidth: 0.5)
    }
    
    func assignTitle(text: String?) {
        self.titleLabel.text = text
    }
    
    func updateViewsColors() {
        self.titleLabel.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.navigationHeaderTitleColor : CHLightThemeColors.navigationHeaderTitleColor
        self.seperatorView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor
        self.backButton.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.buttonsTintColor : CHLightThemeColors.buttonsTintColor
        self.searchButton.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.buttonsTintColor : CHLightThemeColors.buttonsTintColor
        self.chatOptionButton.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.buttonsTintColor : CHLightThemeColors.buttonsTintColor
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    @objc private func chatPlusButtonTouched(sender: UIButton) {
        self.chatPlusButtonPressed?()
    }
    
    @objc private func searchButtonPressed(sender: UIButton) {
        self.onSearchButtonPressed?()
    }
    
    @objc private func backButtonPressed(sender: UIButton) {
        self.onBackButtonPressed?()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}



//
//  CHNewCallTableCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/2/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class CHNewCallTableCell: UITableViewCell {

    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var contactNameLabel: UILabel = {
        let label = UILabel()
        label.font = CHCustomStyles.normalSizeRegularFont
        label.backgroundColor = .clear
        return label
    }()
    
    var onlineIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen
        return view
    }()
    
    var videoCallButton: UIButton = {
        let button = UIButton()
        button.setImage(getImage("chVideoCallIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var voiceCallButton: UIButton = {
        let button = UIButton()
        button.setImage(getImage("chVoiceCallIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var seperatorLineView: UIView = {
        let view = UIView()
        return view
    }()
    
    var onVoiceCallButtonPressed: ((_ user: CHUser?) -> Void)?
    var onVideoCallButtonPressed: ((_ user: CHUser?) -> Void)?
    
    var user: CHUser?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        self.addSubview(profileImageView)
        self.addSubview(contactNameLabel)
        self.addSubview(seperatorLineView)
        self.addSubview(videoCallButton)
        self.addSubview(voiceCallButton)
        
        self.videoCallButton.addTarget(self, action: #selector(videoCallButtonPressed(sender:)), for: .touchUpInside)
        self.voiceCallButton.addTarget(self, action: #selector(voiceCallButtonPressed(sender:)), for: .touchUpInside)
    }
    
    func setUpViewsFrames() {
        self.profileImageView.frame.size = CGSize(width: 50, height: 50)
        self.profileImageView.frame.origin.x = 15
        self.profileImageView.center.y = self.frame.height/2
        self.profileImageView.setViewCircular()
        
        self.videoCallButton.frame.size = CGSize(width: 25, height: 25)
        self.videoCallButton.frame.origin.x = self.frame.width - 40
        self.videoCallButton.center.y = self.frame.height/2
        
        self.voiceCallButton.frame.size = CGSize(width: 25, height: 25)
        self.voiceCallButton.frame.origin.x = self.videoCallButton.frame.origin.x - 40
        self.voiceCallButton.center.y = self.frame.height/2
        
        self.contactNameLabel.frame.size.height = 30
        self.contactNameLabel.frame.origin.x = getViewEndOriginX(view: self.profileImageView) + 12.5
        self.contactNameLabel.frame.size.width = self.voiceCallButton.frame.origin.x -  self.contactNameLabel.frame.origin.x
        self.contactNameLabel.center.y = self.profileImageView.center.y
        
        self.onlineIndicatorView.frame.size = CGSize(width: 15, height: 15)
        let xTheta = CGFloat(cos(315*Double.pi/180))
        let yTheta = CGFloat(sin(315*Double.pi/180))
        
        let xPoint = self.profileImageView.center.x+((self.profileImageView.frame.height/2)*xTheta)
        let yPoint = self.profileImageView.center.y-((self.profileImageView.frame.height/2)*yTheta)
        self.onlineIndicatorView.center = CGPoint(x: xPoint, y: yPoint)
        self.onlineIndicatorView.setViewCircular()
        
        self.seperatorLineView.frame.size.height = 0.7
        self.seperatorLineView.frame.origin.x = self.contactNameLabel.frame.origin.x
        self.seperatorLineView.frame.size.width = self.frame.width - self.seperatorLineView.frame.origin.x
        self.seperatorLineView.frame.origin.y = self.frame.height - self.seperatorLineView.frame.height
        self.separatorInset.left = self.contactNameLabel.frame.origin.x
    }
    
    func setUpUIProperties() {
        self.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.profileImageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#3c3c3c") : UIColor(hex: "#acacac")
        self.contactNameLabel.textColor = CHUIConstant.recentConversationTitleColor
        self.onlineIndicatorView.layer.borderWidth = 2.0
        self.onlineIndicatorView.layer.borderColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c").cgColor : UIColor.white.cgColor
        self.seperatorLineView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor
        self.voiceCallButton.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        self.videoCallButton.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
    }
    
    func assignData() {
        guard let userData = self.user else {
            return
        }
        self.contactNameLabel.text = userData.displayName?.capitalized
        self.onlineIndicatorView.isHidden = !(userData.isOnline ?? false)
        if let profileImageUrl = URL(string: userData.profileImageUrl ?? "") {
            self.profileImageView.sd_imageIndicator = CHAppConstant.themeStyle == .dark ? SDWebImageActivityIndicator.white : SDWebImageActivityIndicator.gray
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil, options: [.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: userData.displayName?.capitalized ?? "", imageSize: self.profileImageView.frame.size)
            let image = imageGenerator.generateImage(with: 20.0)
            self.profileImageView.image = image
        }
    }
    
    func hideCallButtons() {
        self.voiceCallButton.isHidden = true
        self.videoCallButton.isHidden = true
    }
    
    @objc private func voiceCallButtonPressed(sender: UIButton) {
        self.onVoiceCallButtonPressed?(self.user)
    }
    
    @objc private func videoCallButtonPressed(sender: UIButton) {
        self.onVideoCallButtonPressed?(self.user)
    }

}


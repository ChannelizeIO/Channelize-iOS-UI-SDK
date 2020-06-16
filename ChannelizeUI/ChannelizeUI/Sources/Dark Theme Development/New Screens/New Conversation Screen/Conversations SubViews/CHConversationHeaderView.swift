//
//  CHConversationHeaderView.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class CHConversationHeaderView: UIView {

   var backButton: UIButton = {
        let button = UIButton()
        button.setImage(getImage("chBackButton"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(hex: "#3c3c3c")
        return imageView
    }()
    
    var conversationInfoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var conversationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .medium, size: 14.0)
        label.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#4a505a")
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var conversationInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .regular, size: 12.0)
        label.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#4a505a")
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var menuOptionButton: UIButton = {
        let button = UIButton()
        button.setImage(getImage("chMenuOption"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var videoCallButton: UIButton = {
        let button = UIButton()
        button.setImage(getImage("chVideoCallIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.buttonTintColor : CHLightThemeColors.instance.buttonTintColor
        return button
    }()
    
    var voiceCallButton: UIButton = {
        let button = UIButton()
        button.setImage(getImage("chVoiceCallIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.buttonTintColor : CHLightThemeColors.instance.buttonTintColor
        return button
    }()
    
    var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.seperatorColor : CHLightThemeColors.instance.seperatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(CHLocalized(key: "pmDone"), for: .normal)
        button.setTitleColor(CHUIConstant.recentConversationTitleColor, for: .normal)
        button.titleLabel?.font = CHCustomStyles.mediumSizeRegularFont
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var conversationTitleHeightConstraint: NSLayoutConstraint!
    var conversationInfoHeightConstraint: NSLayoutConstraint!
    
    var backButtonPressed: (() -> ())?
    var voiceCallButtonPressed: (() -> Void)?
    var videoCallButtonPressed: (() -> Void)?
    var menuButtonPressed: (() -> Void)?
    var onInfoContainerPressed: (() -> Void)?
    var onDonebuttonPressed: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        self.addSubview(backButton)
        self.addSubview(profileImageView)
        self.addSubview(conversationInfoContainer)
        self.conversationInfoContainer.addSubview(conversationTitleLabel)
        self.conversationInfoContainer.addSubview(conversationInfoLabel)
        self.addSubview(seperatorView)
        self.addSubview(menuOptionButton)
        self.addSubview(videoCallButton)
        self.addSubview(voiceCallButton)
        self.addSubview(doneButton)
        
        self.backButton.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        self.voiceCallButton.addTarget(self, action: #selector(voiceCallButtonPressed(sender:)), for: .touchUpInside)
        self.videoCallButton.addTarget(self, action: #selector(videoCallButtonPressed(sender:)), for: .touchUpInside)
        self.menuOptionButton.addTarget(self, action: #selector(menuButtonPressed(sender:)), for: .touchUpInside)
        self.doneButton.addTarget(self, action: #selector(doneButtonPressed(sender:)), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(infoContainerTouced(gesture:)))
        self.conversationInfoContainer.addGestureRecognizer(tapGesture)
        
    }
    
    func setUpViewsFrames() {
        self.backButton.setViewsAsSquare(squareWidth: 30)
        self.backButton.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 5)
        self.backButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        self.profileImageView.setViewAsCircle(circleWidth: 30)
        self.profileImageView.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        self.profileImageView.setLeftAnchor(relatedConstraint: self.backButton.rightAnchor, constant: 7.5)
        
        self.conversationInfoContainer.setTopAnchor(relatedConstraint: self.profileImageView.topAnchor, constant: 0)
        self.conversationInfoContainer.setLeftAnchor(relatedConstraint: self.profileImageView.rightAnchor, constant: 7.5)
        self.conversationInfoContainer.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -120)
        self.conversationInfoContainer.setHeightAnchor(constant: 30)
        
        self.conversationTitleLabel.setTopAnchor(relatedConstraint: self.conversationInfoContainer.topAnchor, constant: 0)
        self.conversationTitleLabel.setLeftAnchor(relatedConstraint: self.conversationInfoContainer.leftAnchor, constant: 0)
        self.conversationTitleLabel.setRightAnchor(relatedConstraint: self.conversationInfoContainer.rightAnchor, constant: 0)
        self.conversationTitleHeightConstraint = NSLayoutConstraint(item: self.conversationTitleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 17)
        self.conversationTitleHeightConstraint.isActive = true
        self.addConstraint(self.conversationTitleHeightConstraint)
        
        self.conversationInfoLabel.setTopAnchor(relatedConstraint: self.conversationTitleLabel.bottomAnchor, constant: 0)
        self.conversationInfoLabel.setLeftAnchor(relatedConstraint: self.conversationInfoContainer.leftAnchor, constant: 0)
        self.conversationInfoLabel.setRightAnchor(relatedConstraint: self.conversationInfoContainer.rightAnchor, constant: 0)
        self.conversationInfoHeightConstraint = NSLayoutConstraint(item: self.conversationInfoLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 13)
        self.conversationInfoHeightConstraint.isActive = true
        self.addConstraint(self.conversationInfoHeightConstraint)
        
        self.seperatorView.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: -10)
        self.seperatorView.setRightAnchor(relatedConstraint: self.rightAnchor, constant: 10)
        self.seperatorView.setHeightAnchor(constant: 0.75)
        self.seperatorView.setBottomAnchor(relatedConstraint: self.bottomAnchor, constant: 0)
        
        self.menuOptionButton.setViewsAsSquare(squareWidth: 25)
        self.menuOptionButton.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -2.5)
        self.menuOptionButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        self.videoCallButton.setViewsAsSquare(squareWidth: 25)
        self.videoCallButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        self.videoCallButton.setRightAnchor(relatedConstraint: self.menuOptionButton.leftAnchor, constant: -10)
        
        self.voiceCallButton.setViewsAsSquare(squareWidth: 25)
        self.voiceCallButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        self.voiceCallButton.setRightAnchor(relatedConstraint: self.videoCallButton.leftAnchor, constant: -10)
        
        self.doneButton.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -5)
        self.doneButton.setWidthAnchor(constant: 70)
        self.doneButton.setHeightAnchor(constant: 30)
        self.doneButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        self.doneButton.isHidden = true
        
    }
    
    func assignData(conversation: CHConversation?) {
        self.setUpViewsFrames()
        let profileImageUrlString = conversation?.isGroup == true ? conversation?.profileImageUrl ?? "" : conversation?.conversationPartner?.profileImageUrl ?? ""
        let conversationTitle = conversation?.isGroup == true ? conversation?.title ?? "" : conversation?.conversationPartner?.displayName?.capitalized ?? ""
        
        self.conversationTitleLabel.text = conversationTitle
        if conversation?.isGroup == true {
            self.conversationInfoLabel.text = String(format: CHLocalized(key: "pmMembersCountText"), "\(conversation?.membersCount ?? 0)")
        } else {
            self.updatePartnerStatus(conversation: conversation)
        }
        
        if let profileImageUrl = URL(string: profileImageUrlString) {
            self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil, options: [.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: conversationTitle, imageSize: CGSize(width: 30, height: 30))
            let image = imageGenerator.generateImage(with: 16.0)
            self.profileImageView.image = image
        }
        
        if CHAppConstant.isCallModuleEnabled {
            if conversation?.isGroup == true {
                self.hideCallButtons()
            }
        } else {
            self.hideCallButtons()
        }
    }
    
    func updateBlockStatus(conversation: CHConversation?) {
        if let conversationMembers = conversation?.members {
            if conversationMembers.count < 2 {
                UIView.animate(withDuration: 0.33, delay: 0.0, options: [.layoutSubviews], animations: {
                    self.conversationInfoHeightConstraint.constant = 0
                    self.conversationTitleHeightConstraint.constant = 30
                    self.layoutIfNeeded()
                }, completion: {_ in
                    self.disableCallButtons()
                })
            } else {
                UIView.animate(withDuration: 0.33, delay: 0.0, options: [.layoutSubviews], animations: {
                    self.conversationInfoHeightConstraint.constant = 13
                    self.conversationTitleHeightConstraint.constant = 17
                    self.layoutIfNeeded()
                }, completion: { _ in
                    self.enableCallButtons()
                })
            }
        }
    }
    
    func updatePartnerStatus(conversation: CHConversation?) {
        if conversation?.conversationPartner?.isOnline == true {
            self.conversationInfoLabel.text = CHLocalized(key: "pmOnline")
        } else {
            self.conversationInfoLabel.text = getLastSeen(lastSeenDate: conversation?.conversationPartner?.lastSeen)
        }
    }
    
    func updateGroupMembersInfo(conversation: CHConversation?) {
        guard conversation?.isGroup == true else {
            return
        }
        self.conversationTitleLabel.text = conversation?.title
        self.conversationInfoLabel.text = String(format: CHLocalized(key: "pmMembersCountText"), "\(conversation?.membersCount ?? 0)")
    }
    
    func setTypingText(string: String?) {
        self.conversationInfoLabel.text = string
    }
    
    func updateGroupInformation(conversation: CHConversation?) {
        let profileImageUrlString = conversation?.profileImageUrl ?? ""
        let conversationTitle = conversation?.title ?? ""
        self.conversationTitleLabel.text = conversationTitle
        if let profileImageUrl = URL(string: profileImageUrlString) {
            self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil, options: [.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: conversationTitle, imageSize: CGSize(width: 30, height: 30))
            let image = imageGenerator.generateImage(with: 16.0)
            self.profileImageView.image = image
        }
    }
    
    // MARK: - Button Targets
    @objc private func backButtonPressed(sender: UIButton) {
        self.backButtonPressed?()
    }
    
    @objc private func voiceCallButtonPressed(sender: UIButton) {
        self.voiceCallButtonPressed?()
    }
    
    @objc private func videoCallButtonPressed(sender: UIButton) {
        self.videoCallButtonPressed?()
    }
    
    @objc private func menuButtonPressed(sender: UIButton) {
        self.menuButtonPressed?()
    }
    
    @objc private func infoContainerTouced(gesture: UITapGestureRecognizer) {
        self.onInfoContainerPressed?()
    }
    
    @objc private func doneButtonPressed(sender: UIButton) {
        self.onDonebuttonPressed?()
    }
    

    // MARK: - Other Functions
    func hideCallButtons() {
        self.voiceCallButton.isHidden = true
        self.videoCallButton.isHidden = true
    }
    
    func enableCallButtons() {
        self.voiceCallButton.isEnabled = true
        self.videoCallButton.isEnabled = true
    }
    
    func disableCallButtons() {
        self.voiceCallButton.isEnabled = false
        self.videoCallButton.isEnabled = false
    }
    
    func showDoneButton() {
        self.doneButton.isHidden = false
        self.menuOptionButton.isHidden = true
        self.videoCallButton.isHidden = true
        self.voiceCallButton.isHidden = true
    }
    
    func hideDoneButton(isGroup: Bool = false) {
        self.doneButton.isHidden = true
        self.menuOptionButton.isHidden = true
        if CHCustomOptions.callModuleEnabled {
            if !isGroup {
                self.videoCallButton.isHidden = false
                self.voiceCallButton.isHidden = false
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

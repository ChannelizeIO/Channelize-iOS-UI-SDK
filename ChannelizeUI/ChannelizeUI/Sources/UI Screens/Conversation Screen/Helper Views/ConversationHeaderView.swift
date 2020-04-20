//
//  ConversationHeaderView.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import SDWebImage
import UIKit

class ConversationHeaderView: UIView {

    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var detailContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(getImage("chBackButton"), for: .normal)
        return button
    }()
    
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var conversationTitleLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 14.0)
        label.textColor = .white
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.text = "Conversations"
        return label
    }()
    
    private var conversationInfoLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 12.5)
        label.textColor = .white
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.text = "Conversation Info"
        return label
    }()
    
    private var voiceCallButton: CHCallButton = {
        let button = CHCallButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(getImage("chVoiceCallIcon"), for: .normal)
        return button
    }()
    
    private var videoCallButton: CHCallButton = {
        let button = CHCallButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.tintColor = UIColor.white
        button.setImage(getImage("chVideoCallIcon"), for: .normal)
        return button
    }()
    
    private var menuOptionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.tintColor = UIColor.white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.setImage(getImage("chVerticalDotsIcon"), for: .normal)
        return button
    }()
    
    private var muteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.white
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = getImage("chMuteIcon")
        return imageView
    }()
    
    private var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(fontStyle: .robotoRegular, size: CHUIConstants.mediumFontSize)
        button.backgroundColor = .clear
        return button
    }()
    
    var onBackButtonPressed: ((_ sender: UIButton) -> Void)?
    var onVoiceCallButtonPressed: ((_ sender: UIButton) -> Void)?
    var onVideoCallButtonPressed: ((_ sender: UIButton) -> Void)?
    var onMenuButtonPressed: ((_ sender: UIButton) -> Void)?
    var onDoneButtonPressed: ((_ sender: UIButton) -> Void)?
    var onInfoContainerViewPressed: ((_ sender: UITapGestureRecognizer) -> Void)?
    
    var muteIconWidthConstraint: NSLayoutConstraint!
    
    var conversationTitleHeightConstraint: NSLayoutConstraint!
    var conversationInfoHeightConstraint: NSLayoutConstraint!
    
    //var delegate: ConversationHeaderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
        self.setUpViewsFrame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(containerView)
        self.containerView.addSubview(backButton)
        self.containerView.addSubview(detailContainerView)
        self.detailContainerView.addSubview(profileImageView)
        self.detailContainerView.addSubview(conversationTitleLabel)
        self.detailContainerView.addSubview(conversationInfoLabel)
        //self.containerView.addSubview(muteIcon)
        self.containerView.addSubview(doneButton)
        self.containerView.addSubview(menuOptionButton)
        self.containerView.addSubview(videoCallButton)
        self.containerView.addSubview(voiceCallButton)
        
        self.doneButton.isHidden = true
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(didTapDetailInfoView(gesture:)))
        self.detailContainerView.addGestureRecognizer(tapgesture)
        self.backButton.addTarget(self, action: #selector(didPressBakcButton(sender:)), for: .touchUpInside)
        self.menuOptionButton.addTarget(self, action: #selector(didPressMenuOptionButton(sender:)), for: .touchUpInside)
        self.voiceCallButton.addTarget(self, action: #selector(didPressVoiceCallButton(sender:)), for: .touchUpInside)
        self.videoCallButton.addTarget(self, action: #selector(didPressVideoCallButton(sender:)), for: .touchUpInside)
        self.doneButton.addTarget(self, action: #selector(didPressDoneButton(sender:)), for: .touchUpInside)
        
    }
    
    @objc private func didPressDoneButton(sender: UIButton) {
        self.onDoneButtonPressed?(sender)
    }
    
    @objc private func didPressVoiceCallButton(sender: UIButton) {
        self.onVoiceCallButtonPressed?(sender)
    }
    
    @objc private func didPressVideoCallButton(sender: UIButton) {
        self.onVideoCallButtonPressed?(sender)
    }
    
    @objc private func didPressMenuOptionButton(sender: UIButton) {
        self.onMenuButtonPressed?(sender)
    }
    
    @objc func didTapDetailInfoView(gesture: UITapGestureRecognizer) {
        self.onInfoContainerViewPressed?(gesture)
    }
    
    @objc private func didPressBakcButton(sender: UIButton) {
        self.onBackButtonPressed?(sender)
    }
    
    private func setUpViewsFrame() {
        self.containerView.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 0)
        self.containerView.setRightAnchor(relatedConstraint: self.rightAnchor, constant: 0)
        self.containerView.setBottomAnchor(relatedConstraint: self.bottomAnchor, constant: 0)
        self.containerView.setTopAnchor(relatedConstraint: self.topAnchor, constant: 0)
        
        self.backButton.setViewsAsSquare(squareWidth: 35)
        self.backButton.setCenterYAnchor(relatedConstraint: self.containerView.centerYAnchor, constant: 0)
        self.backButton.setLeftAnchor(relatedConstraint: self.containerView.leftAnchor, constant: 0)
        
        self.menuOptionButton.setViewsAsSquare(squareWidth: 30)
        self.menuOptionButton.setRightAnchor(relatedConstraint: self.containerView.rightAnchor, constant: -10)
        self.menuOptionButton.setCenterYAnchor(relatedConstraint: self.containerView.centerYAnchor, constant: 0)
        
        self.videoCallButton.setViewsAsSquare(squareWidth: 30)
        self.videoCallButton.setRightAnchor(relatedConstraint: self.menuOptionButton.leftAnchor, constant: -7.5)
        self.videoCallButton.setCenterYAnchor(relatedConstraint: self.containerView.centerYAnchor, constant: 0)
        
        self.voiceCallButton.setViewsAsSquare(squareWidth: 30)
        self.voiceCallButton.setRightAnchor(relatedConstraint: self.videoCallButton.leftAnchor, constant: -7.5)
        self.voiceCallButton.setCenterYAnchor(relatedConstraint: self.containerView.centerYAnchor, constant: 0)
        
        self.detailContainerView.setLeftAnchor(relatedConstraint: self.backButton.rightAnchor, constant: 5)
        self.detailContainerView.setTopAnchor(relatedConstraint: self.containerView.topAnchor, constant: 0)
        self.detailContainerView.setBottomAnchor(relatedConstraint: self.containerView.bottomAnchor, constant: 0)
        self.detailContainerView.setRightAnchor(relatedConstraint: self.voiceCallButton.leftAnchor, constant: -5)
        
        self.profileImageView.setViewAsCircle(circleWidth: 35)
        self.profileImageView.setCenterYAnchor(relatedConstraint: self.detailContainerView.centerYAnchor, constant: 0)
        self.profileImageView.setLeftAnchor(relatedConstraint: self.detailContainerView.leftAnchor, constant: 0)
        
        self.conversationTitleLabel.setLeftAnchor(relatedConstraint: self.profileImageView.rightAnchor, constant: 7.5)
        self.conversationTitleLabel.setTopAnchor(relatedConstraint: self.profileImageView.topAnchor, constant: 0)
        self.conversationTitleLabel.setRightAnchor(relatedConstraint: self.detailContainerView.rightAnchor, constant: -2.5)
        self.conversationTitleHeightConstraint = NSLayoutConstraint(item: self.conversationTitleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
        self.conversationTitleHeightConstraint.isActive = true
        self.addConstraint(conversationTitleHeightConstraint)
        //self.conversationTitleLabel.setHeightAnchor(constant: 20.0)
        
        self.conversationInfoLabel.setLeftAnchor(relatedConstraint: self.profileImageView.rightAnchor, constant: 7.5)
        self.conversationInfoLabel.setTopAnchor(relatedConstraint: self.conversationTitleLabel.bottomAnchor, constant: 0)
        self.conversationInfoLabel.setRightAnchor(relatedConstraint: self.detailContainerView.rightAnchor, constant: -2.5)
        self.conversationInfoHeightConstraint = NSLayoutConstraint(item: self.conversationInfoLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
        self.conversationInfoHeightConstraint.isActive = true
        self.addConstraint(conversationInfoHeightConstraint)
        
        self.doneButton.setRightAnchor(relatedConstraint: self.containerView.rightAnchor, constant: -10)
        self.doneButton.setHeightAnchor(constant: 30)
        self.doneButton.setWidthAnchor(constant: 50)
        self.doneButton.setCenterYAnchor(relatedConstraint: self.containerView.centerYAnchor, constant: 0)
    }
    
    
    func updateProfileImageView(imageUrlString: String?, conversationTitle: String?) {
        
        if let imageUrl = URL(string: imageUrlString ?? "") {
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.profileImageView.sd_setImage(with: imageUrl, completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: conversationTitle ?? "", imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 50), height: getDeviceWiseAspectedWidth(constant: 50)))
            let image = imageGenerator.generateImage()
            self.profileImageView.image = image
        }
    }
    
    func updateConversationTitleView(conversationTitle: String?) {
        self.conversationTitleLabel.text = conversationTitle
    }
    
    func updateConversationInfoView(infoString: String?) {
        UIView.animate(withDuration: 0.3, animations: {
            if infoString == nil || infoString == "" {
                self.conversationTitleHeightConstraint.constant = 35
                self.conversationInfoHeightConstraint.constant = 0
            } else {
                self.conversationTitleHeightConstraint.constant = 20
                self.conversationInfoHeightConstraint.constant = 15
            }
            self.layoutIfNeeded()
        })
        self.conversationInfoLabel.text = infoString
    }
    
    func disableCallButtons() {
        self.voiceCallButton.isEnabled = false
        self.videoCallButton.isEnabled = false
    }
    
    func enableCallButtons() {
        self.voiceCallButton.isEnabled = true
        self.videoCallButton.isEnabled = true
        
        self.voiceCallButton.imageView?.tintColor = .white
        self.videoCallButton.imageView?.tintColor = .white
    }
    
    func hidesCallButton() {
        self.voiceCallButton.isHidden = true
        self.videoCallButton.isHidden = true
    }
    
    func showDoneButton() {
        self.videoCallButton.isHidden = true
        self.voiceCallButton.isHidden = true
        self.menuOptionButton.isHidden = true
        self.doneButton.isHidden = false
    }
    
    func hideDoneButton() {
        self.videoCallButton.isHidden = false
        self.voiceCallButton.isHidden = false
        self.menuOptionButton.isHidden = false
        self.doneButton.isHidden = true
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

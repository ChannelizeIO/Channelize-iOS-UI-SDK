//
//  CreateGroupUserSelectCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/2/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

protocol CreateGroupUserCellDelegate {
    func didPressVoiceCallButton(user: CHUser?)
    func didPressVideoCallButton(user: CHUser?)
}

class CreateGroupUserSelectCell: UITableViewCell {

    var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor(hex: "#eaeaea")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var userDisplayName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.textColor = CHUIConstants.contactNameColor
        label.font = CHUIConstants.contactNameFont
        return label
    }()
    
    var unSelectedCircleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = getImage("chUnSelectedCircelcon")
        return imageView
    }()
    
    var selectedCirlceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = CHUIConstants.appDefaultColor
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = getImage("chSelectedCircleIcon")
        return imageView
    }()
    
    var voiceCallButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .clear
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(getImage("chVoiceCallIcon"), for: .normal)
        return button
    }()
    
    var videoCallButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .clear
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(getImage("chVideoCallIcon"), for: .normal)
        return button
    }()
    
    var userModel: CHUser? {
        didSet {
            self.assignData()
        }
    }
    
    var delegate: CreateGroupUserCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .black
        self.selectionStyle = .none
        self.setUpViews()
        self.setUpViewsFrame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(userImageView)
        self.addSubview(userDisplayName)
        self.addSubview(unSelectedCircleImageView)
        self.addSubview(selectedCirlceImageView)
        self.addSubview(voiceCallButton)
        self.addSubview(videoCallButton)
        
        self.voiceCallButton.addTarget(self, action: #selector(didPressVoiceCallButton(sender:)), for: .touchUpInside)
        self.videoCallButton.addTarget(self, action: #selector(didPressVideoCallButton(sender:)), for: .touchUpInside)
    }
    
    private func setUpViewsFrame() {
        self.userImageView.setViewAsCircle(circleWidth: 50)
        self.userImageView.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        self.userImageView.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 12.5)
        
        self.userDisplayName.setLeftAnchor(relatedConstraint: self.userImageView.rightAnchor, constant: 12.5)
        self.userDisplayName.setCenterYAnchor(relatedConstraint: self.userImageView.centerYAnchor, constant: 0)
        self.userDisplayName.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -90)
        self.userDisplayName.setHeightAnchor(constant: 30)
        
        self.videoCallButton.setViewsAsSquare(squareWidth: 40)
        self.videoCallButton.setCenterYAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        self.videoCallButton.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -15)
        
        self.voiceCallButton.setViewsAsSquare(squareWidth: 40)
        self.voiceCallButton.setCenterYAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        self.voiceCallButton.setRightAnchor(relatedConstraint: self.videoCallButton.leftAnchor, constant: -10)
        
        self.selectedCirlceImageView.setViewAsCircle(circleWidth: 25)
        self.selectedCirlceImageView.setCenterYAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        self.selectedCirlceImageView.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -15)
        
        self.unSelectedCircleImageView.setViewAsCircle(circleWidth: 25)
        self.unSelectedCircleImageView.setCenterYAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        self.unSelectedCircleImageView.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -15)
        
        self.separatorInset.left = getDeviceWiseAspectedWidth(constant: 75)
    }
    
    private func assignData() {
        
        guard let userData = self.userModel else {
            return
        }
        
        self.userDisplayName.text = userData.displayName?.capitalized
        
        let profileImage = userData.profileImageUrl ?? ""
        if let imageUrl = URL(string: profileImage) {
            self.userImageView.sd_imageTransition = .fade
            let thumbnailSize = CGSize(width: getDeviceWiseAspectedWidth(constant: 50*UIScreen.main.scale*2), height: getDeviceWiseAspectedWidth(constant: 50*UIScreen.main.scale*2))
            self.userImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.continueInBackground,.highPriority], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: userData.displayName?.capitalized ?? "", imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 50), height: getDeviceWiseAspectedWidth(constant: 50)))
            let image = imageGenerator.generateImage()
            self.userImageView.image = image
        }
        
    }
    
    func assignExtraData(imageUrl: String?, title: String?) {
        self.imageView?.image = nil
        let diplayTitle = title ?? ""
        self.userDisplayName.text = diplayTitle
        //self.onlineStatusView.isHidden = true
        if let imageUrlString = imageUrl {
            let imageUrl = URL(string: imageUrlString)
            self.userImageView.sd_imageTransition = .fade
            self.userImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.userImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.highPriority,.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: diplayTitle, imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 50), height: getDeviceWiseAspectedWidth(constant: 50)))
            let image = imageGenerator.generateImage()
            self.userImageView.image = image
        }
    }
    
    @objc private func didPressVoiceCallButton(sender: UIButton) {
        self.delegate?.didPressVoiceCallButton(user: self.userModel)
    }
    
    @objc private func didPressVideoCallButton(sender: UIButton) {
        self.delegate?.didPressVideoCallButton(user: self.userModel)
    }
    
    func hideAllButtons() {
        self.selectedCirlceImageView.isHidden = true
        self.unSelectedCircleImageView.isHidden = true
        self.videoCallButton.isHidden = true
        self.voiceCallButton.isHidden = true
    }
    
    func activateSelectionMode() {
        self.selectedCirlceImageView.isHidden = false
        self.unSelectedCircleImageView.isHidden = false
        
        self.videoCallButton.isHidden = true
        self.voiceCallButton.isHidden = true
    }
    
    func activateCallModel() {
        self.selectedCirlceImageView.isHidden = true
        self.unSelectedCircleImageView.isHidden = true
        
        self.videoCallButton.isHidden = false
        self.voiceCallButton.isHidden = false
    }
}


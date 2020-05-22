//
//  UIRecentCallTableCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class UIRecentCallTableCell: UITableViewCell {

    private var callPartnerNameLabel: UILabel = {
        let label = UILabel()
        label.font = CHUIConstants.conversationTitleFont
        label.textColor = CHUIConstants.conversationTitleColor
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        return label
    }()
    
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(hex: "#f8f8f8")
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var onlineStatusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = CHUIConstants.onlineStatusColor
        view.layer.borderWidth = 2.0
        return view
    }()
    
    private var callStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private var callTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.tintColor = UIColor.customSystemGray
        return imageView
    }()
    
    private var callDurationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = CHUIConstants.conversationMessageColor
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 15.0)
        label.backgroundColor = .clear
        return label
    }()
    
    private var lastCallTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = CHUIConstants.conversationMessageColor
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 15.0)
        label.backgroundColor = .clear
        label.textAlignment = .right
        return label
    }()
    
    var recentCallModel: CHRecentCall? {
        didSet {
            self.assignData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .white
        self.accessoryType = .disclosureIndicator
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(callPartnerNameLabel)
        self.contentView.addSubview(onlineStatusView)
        self.contentView.addSubview(callStateImageView)
        self.contentView.addSubview(callTypeImageView)
        self.contentView.addSubview(callDurationLabel)
        self.contentView.addSubview(lastCallTimeLabel)
    }
    
    private func setUpViewsFrames() {
        self.profileImageView.setViewAsCircle(circleWidth: 50)
        self.profileImageView.setLeftAnchor(relatedConstraint: self.contentView.leftAnchor, constant: 12.5)
        self.profileImageView.setCenterYAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        
        self.callPartnerNameLabel.setLeftAnchor(relatedConstraint: self.profileImageView.rightAnchor, constant: 12.5)
        self.callPartnerNameLabel.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -105)
        self.callPartnerNameLabel.setBottomAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        self.callPartnerNameLabel.setHeightAnchor(constant: 25)
        
        
        self.onlineStatusView.setViewAsCircle(circleWidth: 15)
        self.onlineStatusView.setRightAnchor(relatedConstraint: self.profileImageView.rightAnchor, constant: 0)
        self.onlineStatusView.setBottomAnchor(relatedConstraint: self.profileImageView.bottomAnchor, constant: -2.5)
        
        self.callStateImageView.setViewsAsSquare(squareWidth: 15)
        self.callStateImageView.setLeftAnchor(relatedConstraint: self.profileImageView.rightAnchor, constant: 12.5)
        self.callStateImageView.setTopAnchor(relatedConstraint: self.callPartnerNameLabel.bottomAnchor, constant: 10)
        
        self.callTypeImageView.setViewsAsSquare(squareWidth: 15)
        self.callTypeImageView.setLeftAnchor(relatedConstraint: self.callStateImageView.rightAnchor, constant: 5)
        self.callTypeImageView.setTopAnchor(relatedConstraint: self.callPartnerNameLabel.bottomAnchor, constant: 10)
        
        self.callDurationLabel.setLeftAnchor(relatedConstraint: self.callTypeImageView.rightAnchor, constant: 5)
        self.callDurationLabel.setWidthAnchor(constant: 100)
        self.callDurationLabel.setHeightAnchor(constant: 20)
        self.callDurationLabel.setTopAnchor(relatedConstraint: self.callPartnerNameLabel.bottomAnchor, constant: 5)
        
        self.lastCallTimeLabel.setCenterYAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        self.lastCallTimeLabel.setWidthAnchor(constant: 100)
        self.lastCallTimeLabel.setHeightAnchor(constant: 30)
        self.lastCallTimeLabel.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -5)
        
        self.separatorInset.left = 75
    }
    
    private func assignData() {
        guard let callData = self.recentCallModel else {
            return
        }
        
        let callPartnerName = callData.callPartnerMember?.user?.displayName?.capitalized
        let profileImageUrl = callData.callPartnerMember?.user?.profileImageUrl
        var callState: CallType?
        let mineCallRecipient = callData.callPartnerMember?.lastCall?.recipients?.first(where: {
            $0.userId == Channelize.getCurrentUserId()
        })
        callState = mineCallRecipient?.state
        switch callState ?? .Out {
        case .Out:
            self.callStateImageView.image = getImage("chOutgoingCallIcon")
            self.callStateImageView.tintColor = UIColor.customSystemGreen
            break
        case .In:
            self.callStateImageView.image = getImage("chIncomingCallIcon")
            self.callStateImageView.tintColor = CHUIConstants.appDefaultColor
            break
        case .Missed:
            self.callStateImageView.image = getImage("chMissedCallIcon")
            self.callStateImageView.tintColor = UIColor.customSystemRed
            break
        case .Rejected:
            self.callStateImageView.image = getImage("chRejectedCallIcon")
            self.callStateImageView.tintColor = UIColor.customSystemGray
            break
        }
        
        let callType = callData.callPartnerMember?.lastCall?.callType
        switch callType ?? .voice {
        case .video:
            self.callTypeImageView.image = getImage("chVideoCallIcon")
            break
        case .voice:
            self.callTypeImageView.image = getImage("chVoiceCallIcon")
            break
        }
        
        let callDuration = mineCallRecipient?.duration ?? 0.0
        self.callDurationLabel.text = (callDuration/1000).asString(style: .abbreviated)
        
        self.callPartnerNameLabel.text = callPartnerName
        self.lastCallTimeLabel.text = getTimeStamp(callData.callPartnerMember?.lastCall?.createdAt ?? Date())
        
        if callData.callPartnerMember?.user?.isOnline == true {
            self.onlineStatusView.isHidden = false
        } else {
            self.onlineStatusView.isHidden = true
        }
        
        if let imageUrl = URL(string: profileImageUrl ?? "") {
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.profileImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: callPartnerName ?? "", imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 60), height: getDeviceWiseAspectedWidth(constant: 60)))
            let image = imageGenerator.generateImage()
            self.profileImageView.image = image
        }
    }
}

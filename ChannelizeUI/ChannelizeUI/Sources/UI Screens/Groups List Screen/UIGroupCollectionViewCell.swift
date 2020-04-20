//
//  UIGroupCollectionViewCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/15/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class UIGroupCollectionViewCell: UICollectionViewCell {
    
    private var groupProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = CHUIConstants.conversationTitleColor
        label.font = CHUIConstants.conversationTitleFont
        return label
    }()
    
    private var activeStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = CHUIConstants.conversationMessageColor
        label.font = CHUIConstants.conversationMessageFont
        return label
    }()
    
    private var dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var memberCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = CHUIConstants.conversationMessageColor
        label.font = CHUIConstants.conversationMessageFont
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    var conversation: CHConversation? {
        didSet {
            self.assignData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.contentView.addSubview(groupProfileImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(activeStatusLabel)
        self.contentView.addSubview(dividerLine)
        self.contentView.addSubview(memberCountLabel)
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 2.5
        layer.cornerRadius = 2.5
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    private func setUpViewsFrames() {
        self.groupProfileImageView.setViewAsCircle(circleWidth: 70)
        self.groupProfileImageView.setTopAnchor(relatedConstraint: self.contentView.topAnchor, constant: 20)
        self.groupProfileImageView.setCenterXAnchor(relatedConstraint: self.contentView.centerXAnchor, constant: 0)
        
        self.titleLabel.setLeftAnchor(relatedConstraint: self.contentView.leftAnchor, constant: 5)
        self.titleLabel.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -5)
        self.titleLabel.setTopAnchor(relatedConstraint: self.groupProfileImageView.bottomAnchor, constant: 20)
        self.titleLabel.setHeightAnchor(constant: 30)
        
        self.activeStatusLabel.setLeftAnchor(relatedConstraint: self.contentView.leftAnchor, constant: 5)
        self.activeStatusLabel.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -5)
        self.activeStatusLabel.setTopAnchor(relatedConstraint: self.titleLabel.bottomAnchor, constant: 5)
        self.activeStatusLabel.setHeightAnchor(constant: 25)
        
        self.dividerLine.setLeftAnchor(relatedConstraint: self.contentView.leftAnchor, constant: 0)
        self.dividerLine.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: 0)
        self.dividerLine.setTopAnchor(relatedConstraint: self.activeStatusLabel.bottomAnchor, constant: 10)
        self.dividerLine.setHeightAnchor(constant: 0.5)
        
        self.memberCountLabel.setLeftAnchor(relatedConstraint: self.contentView.leftAnchor, constant: 0)
        self.memberCountLabel.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: 0)
        self.memberCountLabel.setBottomAnchor(relatedConstraint: self.contentView.bottomAnchor, constant: 0)
        self.memberCountLabel.setTopAnchor(relatedConstraint: self.dividerLine.bottomAnchor, constant: 0)
    }
    
    private func assignData() {
        guard let conversationData = self.conversation else {
            return
        }
        self.titleLabel.text = conversationData.coversationTitle
        self.memberCountLabel.text = "\(conversationData.membersCount ?? 0) Members"
        
        self.activeStatusLabel.text = "Active \(timeAgoSinceDate(conversationData.lastUpDatedAt ?? Date(), currentDate: Date(), numericDates: false))"
        
        let profileImage = conversationData.conversationProfileImage ?? ""
        if let imageUrl = URL(string: profileImage) {
            self.groupProfileImageView.sd_imageTransition = .fade
            self.groupProfileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.groupProfileImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.highPriority,.continueInBackground], completed: nil)
        } else {
            
            let imageGenerator = ImageFromStringProvider(name: conversationData.title ?? "", imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 70), height: getDeviceWiseAspectedWidth(constant: 70)))
            let image = imageGenerator.generateImage()
            self.groupProfileImageView.image = image
        }
    }
}


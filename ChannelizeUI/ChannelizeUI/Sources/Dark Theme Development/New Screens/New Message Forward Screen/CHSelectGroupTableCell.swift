//
//  CHSelectGroupTableCell.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/11/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class CHSelectGroupTableCell: UITableViewCell {

    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
        
     var titleLabel: UILabel = {
        let label = UILabel()
        label.font = CHUIConstant.recentConversationTitleFont
        label.backgroundColor = .clear
        return label
     }()
    
     var memberCountLabel: UILabel = {
        let label = UILabel()
        label.font = CHUIConstant.recentConversationMessageFont
        label.backgroundColor = .clear
        return label
     }()
    
    var unSelectedCircleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chUnSelectedCircelcon")
        return imageView
    }()
    
    var selectedCirlceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : UIColor(hex: "#8b8b8b")
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chSelectedCircleIcon")
        return imageView
    }()
    
    var conversation: CHConversation?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        self.addSubview(profileImageView)
        self.addSubview(titleLabel)
        self.addSubview(memberCountLabel)
        self.addSubview(unSelectedCircleImageView)
        self.addSubview(selectedCirlceImageView)
    }
    
    func setUpViewsFrames() {
        
        self.profileImageView.frame.size = CGSize(width: 50, height: 50)
        self.profileImageView.center.y = self.frame.height/2
        self.profileImageView.frame.origin.x = 15
        self.profileImageView.setViewCircular()
        
        self.titleLabel.frame.origin.y = self.profileImageView.frame.origin.y
        self.titleLabel.frame.origin.x = getViewEndOriginX(view: self.profileImageView) + 12.5
        self.titleLabel.frame.size.height = 25
        self.titleLabel.frame.size.width = self.frame.width - self.titleLabel.frame.origin.x - 80
        
        self.memberCountLabel.frame.origin.y = getViewEndOriginY(view: self.titleLabel)
        self.memberCountLabel.frame.origin.x = getViewEndOriginX(view: self.profileImageView) + 12.5
        self.memberCountLabel.frame.size.height = 25
        self.memberCountLabel.frame.size.width = self.frame.width - self.memberCountLabel.frame.origin.x - 80
        
        self.selectedCirlceImageView.frame.size = CGSize(width: 25, height: 25)
        self.selectedCirlceImageView.frame.origin.x = self.frame.width - 40
        self.selectedCirlceImageView.center.y = self.frame.height/2
        self.selectedCirlceImageView.setViewCircular()
        
        self.unSelectedCircleImageView.frame.size = CGSize(width: 25, height: 25)
        self.unSelectedCircleImageView.frame.origin.x = self.frame.width - 40
        self.unSelectedCircleImageView.center.y = self.frame.height/2
        self.unSelectedCircleImageView.setViewCircular()
        
        self.selectedCirlceImageView.isHidden = true
        
        self.separatorInset.left = self.titleLabel.frame.origin.x
    }
    
    func setUpUIProperties() {
        self.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.profileImageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#3c3c3c") : UIColor(hex: "#acacac")
        self.titleLabel.textColor = CHUIConstant.recentConversationTitleColor
        self.memberCountLabel.textColor = CHUIConstant.recentConversationMessageColor
    }
    
    func assignData() {
        guard let conversationData = self.conversation else {
            return
        }
        let profileImageUrlString = conversationData.isGroup == true ? conversationData.profileImageUrl ?? "" : conversationData.conversationPartner?.profileImageUrl ?? ""
        let conversationTitle = conversationData.isGroup == true ? conversationData.title ?? "" : conversationData.conversationPartner?.displayName?.capitalized ?? ""
        
        self.titleLabel.text = conversationTitle
        self.memberCountLabel.text = "\(conversationData.membersCount ?? 0) Members"
        
        if let profileImageUrl = URL(string: profileImageUrlString) {
            self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil, options: [.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: conversationTitle, imageSize: self.profileImageView.frame.size)
            let image = imageGenerator.generateImage(with: 20.0)
            self.profileImageView.image = image
        }
    }
    
    func setCellSelected() {
        self.selectedCirlceImageView.isHidden = false
        self.unSelectedCircleImageView.isHidden = true
    }
    
    func setCellUnselected() {
        self.selectedCirlceImageView.isHidden = true
        self.unSelectedCircleImageView.isHidden = false
    }

}


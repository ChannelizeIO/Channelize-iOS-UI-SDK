//
//  CHGroupConversationCell.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class CHGroupConversationCell: UITableViewCell {

    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
        
     var titleLabel: UILabel = {
        let label = UILabel()
        label.font = CHCustomStyles.normalSizeRegularFont
        label.backgroundColor = .clear
        return label
     }()
    
     var memberCountLabel: UILabel = {
        let label = UILabel()
        label.font = CHCustomStyles.mediumSizeRegularFont
        label.backgroundColor = .clear
        return label
     }()
     
     var lastUpdatedAtLabel: UILabel = {
         let label = UILabel()
        label.font = CHCustomStyles.smallSizeRegularFont
         label.backgroundColor = .clear
         label.textAlignment = .right
         return label
     }()
     
     var conversation: CHConversation?
     
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     func setUpViews() {
         self.addSubview(profileImageView)
         self.addSubview(titleLabel)
         self.addSubview(memberCountLabel)
         self.addSubview(lastUpdatedAtLabel)
     }
     
     func setUpViewsFrames() {
         self.profileImageView.frame.size = CGSize(width: 50, height: 50)
         self.profileImageView.center.y = self.frame.height/2
         self.profileImageView.frame.origin.x = 15
         //self.profileImageView.frame.origin = CGPoint(x: 15, y: 12.5)
         self.profileImageView.setViewCircular()
         
         self.titleLabel.frame.origin.y = self.profileImageView.frame.origin.y
         self.titleLabel.frame.origin.x = getViewEndOriginX(view: self.profileImageView) + 12.5
         self.titleLabel.frame.size.height = 25
         self.titleLabel.frame.size.width = self.frame.width - self.titleLabel.frame.origin.x - 110
         
         self.memberCountLabel.frame.origin.y = getViewEndOriginY(view: self.titleLabel)
         self.memberCountLabel.frame.origin.x = getViewEndOriginX(view: self.profileImageView) + 12.5
         self.memberCountLabel.frame.size.height = 25
         self.memberCountLabel.frame.size.width = self.frame.width - self.memberCountLabel.frame.origin.x - 80
         
         self.lastUpdatedAtLabel.frame.size = CGSize(width: 90, height: 25)
         self.lastUpdatedAtLabel.center.y = self.titleLabel.center.y
         self.lastUpdatedAtLabel.frame.origin.x = self.frame.width - 100
         
         self.separatorInset.left = self.titleLabel.frame.origin.x
     }
     
     func setUpUIProperties() {
         self.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
         self.profileImageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#3c3c3c") : UIColor(hex: "#acacac")
         self.titleLabel.textColor = CHUIConstant.recentConversationTitleColor
         self.memberCountLabel.textColor = CHUIConstant.recentConversationMessageColor
         self.lastUpdatedAtLabel.textColor = CHUIConstant.recentConversationLastUpdatedColor
     }
     
     func assignData() {
         guard let conversationData = self.conversation else {
             return
         }
         let profileImageUrlString = conversationData.isGroup == true ? conversationData.profileImageUrl ?? "" : conversationData.conversationPartner?.profileImageUrl ?? ""
         let conversationTitle = conversationData.isGroup == true ? conversationData.title ?? "" : conversationData.conversationPartner?.displayName?.capitalized ?? ""
         
         self.titleLabel.text = conversationTitle
         self.memberCountLabel.text = "\(conversationData.membersCount ?? 0) Members"
         
         if let lastUpdatedDate = conversationData.lastMessage?.createdAt {
             let lastUpdatedTimeString = getTimeStamp(lastUpdatedDate)
             self.lastUpdatedAtLabel.text = lastUpdatedTimeString
         } else {
             self.lastUpdatedAtLabel.text = nil
         }
         
         if let profileImageUrl = URL(string: profileImageUrlString) {
            self.profileImageView.sd_imageIndicator = CHAppConstant.themeStyle == .dark ? SDWebImageActivityIndicator.white : SDWebImageActivityIndicator.gray
             self.profileImageView.sd_imageTransition = .fade
             self.profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil, options: [.continueInBackground], completed: nil)
         } else {
             let imageGenerator = ImageFromStringProvider(name: conversationTitle, imageSize: self.profileImageView.frame.size)
             let image = imageGenerator.generateImage(with: 20.0)
             self.profileImageView.image = image
         }
     }
     
     
     override func awakeFromNib() {
         super.awakeFromNib()
         // Initialization code
     }

     override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)

         // Configure the view for the selected state
     }

}

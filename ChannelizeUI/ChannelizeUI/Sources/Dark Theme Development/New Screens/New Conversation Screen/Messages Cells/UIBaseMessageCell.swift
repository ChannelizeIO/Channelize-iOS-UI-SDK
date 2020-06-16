//
//  CHBaseMessageCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/29/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit

class CHBaseMessageCell: UICollectionViewCell {
    
    var unreadMessageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var unreadMessageLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#232124") : UIColor(hex: "#8b8b8b")
        label.textColor = UIColor(hex: "#ffffff")
        label.textAlignment = .center
        label.font = UIFont(fontStyle: .regular, size: 14.0)
        label.layer.masksToBounds = true
        label.text = CHLocalized(key: "pmUnreadMessagesText")
        return label
    }()
    
    var dateSeperatorContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var dateSeperatorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#232124") : UIColor(hex: "#8b8b8b")
        label.textColor = UIColor(hex: "#ffffff")
        label.textAlignment = .center
        label.font = UIFont(fontStyle: .regular, size: 14.0)
        label.layer.masksToBounds = true
        return label
    }()
    
    var senderNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#e6e6e6") : UIColor(hex: "#5b5b5b")
        label.font = UIFont(fontStyle: .regular, size: 14.0)
        return label
    }()
    
    var bubbleContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        return view
    }()
    
    var unSelectedCircleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chUnSelectedCircelcon")
        return imageView
    }()
    
    var selectedCirlceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = CHUIConstant.appTintColor
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chSelectedCircleIcon")
        return imageView
    }()
    
    var reactionsContainerView: ReactionView = {
        let view = ReactionView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.contentView.layer.masksToBounds = true
        self.contentView.addSubview(unreadMessageContainerView)
        self.unreadMessageContainerView.addSubview(unreadMessageLabel)
        self.contentView.addSubview(dateSeperatorContainer)
        self.dateSeperatorContainer.addSubview(dateSeperatorLabel)
        //self.contentView.addSubview(dateSeperatorLabel)
        self.contentView.addSubview(senderNameLabel)
        self.contentView.addSubview(bubbleContainerView)
        self.contentView.addSubview(selectedCirlceImageView)
        self.contentView.addSubview(unSelectedCircleImageView)
    }
    
    func assignChatItem(chatItem: ChannelizeChatItem) {
        
        if chatItem.isMessageSelectorOn {
            if chatItem.isMessageSelected {
                self.selectedCirlceImageView.isHidden = false
                self.unSelectedCircleImageView.isHidden = true
            } else {
                self.selectedCirlceImageView.isHidden = true
                self.unSelectedCircleImageView.isHidden = false
            }
            
        }
        
        let selectedCircleOriginX: CGFloat = chatItem.isMessageSelectorOn ? 10 : -30
        let unselectedCircleOririginX: CGFloat = chatItem.isMessageSelectorOn ? 10 : -30
        
        let selectedCircleWidthHeight: CGFloat = chatItem.isMessageSelectorOn ? 25 : 0
        let unSelectedCircleWidthHeight: CGFloat = chatItem.isMessageSelectorOn ? 25 : 0
        
        let unreadMessageContainerHeight: CGFloat = chatItem.showUnreadMessageLabel ? 40 : 0
        let unreadMessageContainerWidth = self.frame.width
        
        let dateSeperatorHeight: CGFloat = chatItem.showDataSeperator ? 40 : 0
        let dateSeperatorWidth = chatItem.messageDate.toRelativeDateString().width(withConstrainedHeight: dateSeperatorHeight, font: UIFont(fontStyle: .regular, size: 14.0)!)
        
        let senderNameHeight: CGFloat = chatItem.showSenderName ? 25 : 0
        let senderNameWidth: CGFloat = self.frame.width - 30
        
        let extraBottomMargin: CGFloat = chatItem.showMessageStatusView ? 7.5 : 0
        
        let senderNameOriginX: CGFloat = chatItem.isMessageSelectorOn && chatItem.isIncoming ? 35 : 15
        let messageBubbleOriginX: CGFloat = chatItem.isMessageSelectorOn && chatItem.isIncoming ? 35 : 0
        
        self.unreadMessageContainerView.frame.size = CGSize(width: unreadMessageContainerWidth, height: unreadMessageContainerHeight)
        self.unreadMessageContainerView.frame.origin.y = 0
        self.unreadMessageContainerView.frame.origin.x = 0
        
        self.unreadMessageLabel.frame.origin.x = 5
        self.unreadMessageLabel.frame.origin.y = 7.5
        
        if chatItem.showUnreadMessageLabel {
            self.unreadMessageLabel.frame.size.width = self.unreadMessageContainerView.frame.width - 10
            self.unreadMessageLabel.frame.size.height = self.unreadMessageContainerView.frame.height - 15
        } else {
            self.unreadMessageLabel.frame.size = .zero
        }
        
        self.dateSeperatorContainer.frame.size = CGSize(width: self.frame.width, height: dateSeperatorHeight)
        self.dateSeperatorContainer.frame.origin.y = getViewEndOriginY(view: self.unreadMessageContainerView)
        self.dateSeperatorContainer.frame.origin.x = 0
        
        self.dateSeperatorLabel.frame.size.width = dateSeperatorWidth + 20
        self.dateSeperatorLabel.frame.size.height = max(dateSeperatorHeight - 15, 0)
        self.dateSeperatorLabel.frame.origin.y = 5
        self.dateSeperatorLabel.center.x = self.frame.width/2
        self.dateSeperatorLabel.layer.cornerRadius = self.dateSeperatorLabel.frame.height/2
            
        self.senderNameLabel.frame.size = CGSize(width: senderNameWidth, height: senderNameHeight)
        self.senderNameLabel.frame.origin.x = senderNameOriginX
        self.senderNameLabel.frame.origin.y = getViewEndOriginY(view: self.dateSeperatorContainer)
        
        self.bubbleContainerView.frame.origin.y = getViewEndOriginY(view: self.senderNameLabel)
        self.bubbleContainerView.frame.origin.x = messageBubbleOriginX
        self.bubbleContainerView.frame.size.width = self.frame.width
        self.bubbleContainerView.frame.size.height = self.frame.height - self.bubbleContainerView.frame.origin.y - extraBottomMargin
        
        self.selectedCirlceImageView.frame.size = CGSize(width: selectedCircleWidthHeight, height: selectedCircleWidthHeight)
        self.selectedCirlceImageView.frame.origin.x = selectedCircleOriginX
        self.selectedCirlceImageView.center.y = bubbleContainerView.center.y//selectedCircleCenterY
        self.selectedCirlceImageView.layer.cornerRadius = selectedCircleWidthHeight/2
        
        
        self.unSelectedCircleImageView.frame.size = CGSize(width: unSelectedCircleWidthHeight, height: unSelectedCircleWidthHeight)
        self.unSelectedCircleImageView.frame.origin.x = unselectedCircleOririginX
        self.unSelectedCircleImageView.center.y = bubbleContainerView.center.y//unselectedCircleCenterY
        self.unSelectedCircleImageView.layer.cornerRadius = unSelectedCircleWidthHeight/2
        
        // Assign Data
        self.dateSeperatorLabel.text = chatItem.messageDate.toRelativeDateString()
        self.senderNameLabel.text = chatItem.senderName.capitalized
    }
    
    func calculateReactionViewHeight(chatItem: ChannelizeChatItem) -> CGFloat{
        let reactionsModels = chatItem.reactions
        guard reactionsModels.count > 0 else {
            return 0
        }
        var initialOriginX: CGFloat = 5
        var initialOriginY: CGFloat = 2.5
        //let selfWidth = self.view.frame.width
        var currentItemWidth: CGFloat = 0
        reactionsModels.forEach({
            let reaction = $0
            if reaction.counts == 1 {
                currentItemWidth = 30
            } else {
                let emojiString = reaction.unicode ?? ""
                let emojiWidth = emojiString.width(withConstrainedHeight: 30, font: UIFont.systemFont(ofSize: 20.0, weight: .medium))
                let count = reaction.counts ?? 0
                let countsWidth = "\(count)".width(withConstrainedHeight: 30, font: UIFont.systemFont(ofSize: 20.0, weight: .regular))
                let totalWidth = 2.5 + emojiWidth + 2.5 + countsWidth + 2.5
                currentItemWidth = totalWidth
            }
            if initialOriginX + currentItemWidth < getReactionViewMaxWidth(chatItemType: chatItem.messageType) - 5 {
                initialOriginX = initialOriginX + currentItemWidth + 5
            } else {
                initialOriginY += 32.5
                initialOriginX = 5 + currentItemWidth + 2.5
            }
        })
        return initialOriginY + 30 + 2.5
    }
        
    private func getReactionViewMaxWidth(chatItemType: BaseMessageType) -> CGFloat {
        switch chatItemType {
        case .image:
            return CHCustomStyles.imageMessageBubbleSize.width
        case .gifSticker:
            return CHCustomStyles.gifStickerMessageBubbleSize.width
        case .video:
            return CHCustomStyles.videoMessageBubbleSize.width
        case .audio:
            return CHCustomStyles.audioMessageBubbleSize.width
        case .location:
            return CHCustomStyles.locationMessageBubbleImageSize.width
        case .quotedMessage:
            return 250
        case .doc:
            return CHCustomStyles.docMessageBubbleSize.width
        default:
            return 0
        }
    }
}


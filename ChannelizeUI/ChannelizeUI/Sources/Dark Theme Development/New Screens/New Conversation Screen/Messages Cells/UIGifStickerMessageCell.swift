//
//  UIGifStickerMessageCell.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/10/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImageFLPlugin

class UIGifStickerMessageCell: CHBaseMessageCell {
    private var imageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.runLoopMode = RunLoop.Mode.default.rawValue
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#4c4c4c") : UIColor(hex: "#e6e6e6")
        imageView.layer.borderColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#4c4c4c").cgColor : UIColor(hex: "#e6e6e6").cgColor
        imageView.layer.borderWidth = 0.5
        return imageView
    }()
    
    var messageStatusViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var messageTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .regular, size: 11.0)
        label.textAlignment = .right
        label.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#8b8b8b")
        return label
    }()
    
    var messageStatusView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    var reactionButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setImage(getImage("chReactionIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = UIColor(hex: "#c5c5c5")
        button.imageView?.layer.masksToBounds = true
        return button
    }()
    
    var gifStickerMessageItem: GifStickerMessageItem?
    var longPressGesture: UILongPressGestureRecognizer!
    var cellTappedGesture: UITapGestureRecognizer!
    var onLongPressGifStickerBubble: ((_ chatItem: GifStickerMessageItem?) -> Void)?
    var onReactionButtonPressed: ((_ cell: UIGifStickerMessageCell) -> Void)?
    var onCellTapped: ((_ cell: UIGifStickerMessageCell) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(self.imageView)
        self.bubbleContainerView.addSubview(messageStatusViewContainer)
        self.bubbleContainerView.addSubview(self.reactionsContainerView)
        self.bubbleContainerView.addSubview(reactionButton)
        self.messageStatusViewContainer.addSubview(self.messageTimeLabel)
        self.messageStatusViewContainer.addSubview(self.messageStatusView)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(gifStickerBubbleLongPressed(gesture:)))
        self.imageView.addGestureRecognizer(longPressGesture)
        
        cellTappedGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(gesture:)))
        self.addGestureRecognizer(cellTappedGesture)
        
        self.reactionButton.addTarget(self, action: #selector(reactionButtonPressed(sender:)), for: .touchUpInside)
    }
    
    @objc private func gifStickerBubbleLongPressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.onLongPressGifStickerBubble?(self.gifStickerMessageItem)
        }
    }
    
    @objc private func cellTapped(gesture: UITapGestureRecognizer) {
        self.onCellTapped?(self)
    }
    
    @objc private func reactionButtonPressed(sender: UIButton) {
        self.onReactionButtonPressed?(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: ChannelizeChatItem) {
        super.assignChatItem(chatItem: chatItem)
        guard let gifStickerMessageModel = chatItem as? GifStickerMessageItem else {
            return
        }
        self.gifStickerMessageItem = gifStickerMessageModel
        
        if gifStickerMessageModel.messageStatus == .sending {
            self.longPressGesture.isEnabled = false
            self.cellTappedGesture.isEnabled = false
        } else {
            if gifStickerMessageModel.isMessageSelectorOn {
                self.longPressGesture.isEnabled = false
                self.cellTappedGesture.isEnabled = true
                self.reactionButton.isEnabled = false
            } else {
                self.longPressGesture.isEnabled = true
                self.cellTappedGesture.isEnabled = false
                self.reactionButton.isEnabled = true
            }
        }
        
        let imageViewSize = CGSize(width: 220, height: 175)
        self.imageView.frame.size = CHCustomStyles.gifStickerMessageBubbleSize
        self.imageView.frame.origin.y = 0
        if gifStickerMessageModel.isIncoming {
            self.imageView.frame.origin.x = 15
        } else {
            self.imageView.frame.origin.x = self.bubbleContainerView.frame.width - imageViewSize.width - 15
        }
        
        if chatItem.isIncoming {
            self.reactionButton.isHidden = false
            self.reactionButton.frame.size = CGSize(width: 22, height: 22)
            self.reactionButton.frame.origin.x = getViewEndOriginX(view: self.imageView) + 2.5
            self.reactionButton.frame.origin.y = self.imageView.frame.origin.y + 2.5
        } else {
            self.reactionButton.isHidden = true
            self.reactionButton.frame = .zero
        }
        
        let reactionViewHeight = super.calculateReactionViewHeight(chatItem: chatItem)
        let reactionViewWidth: CGFloat = CHCustomStyles.gifStickerMessageBubbleSize.width
        
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = self.imageView.frame.origin.x
        self.reactionsContainerView.frame.origin.y = getViewEndOriginY(view: self.imageView) - 15
        
        self.messageStatusViewContainer.frame.size = CGSize(width: 80, height: 35)
        self.messageStatusViewContainer.frame.origin.y = getViewEndOriginY(view: self.imageView) - self.messageStatusViewContainer.frame.size.height - 2.5
        if gifStickerMessageModel.isIncoming {
            self.messageStatusViewContainer.frame.origin.x = getViewEndOriginX(view: self.imageView) + 5
        } else {
            self.messageStatusViewContainer.frame.origin.x = self.imageView.frame.origin.x - self.messageStatusViewContainer.frame.width - 5
        }
        
        self.messageStatusView.frame.size = CGSize(width: 20, height: 20)
        self.messageStatusView.frame.origin.y = 0
        self.messageStatusView.frame.origin.x = gifStickerMessageModel.isIncoming == true ? 0 : self.messageStatusViewContainer.frame.width - self.messageStatusView.frame.width
        
        self.messageTimeLabel.frame.size = CGSize(width: 80, height: 15)
        self.messageTimeLabel.frame.origin.x = 0
        self.messageTimeLabel.frame.origin.y = getViewEndOriginY(view: self.messageStatusView)
        
        let messageTime = chatItem.messageDate
        self.messageTimeLabel.text = messageTime.toRelateTimeString()
        
        switch chatItem.messageStatus {
        case .sending:
            self.messageStatusView.tintColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#E6E6E6") : UIColor(hex: "#8a8a8a")
            self.messageStatusView.image = getImage("chSendingIcon")
            break
        case .sent:
            self.messageStatusView.tintColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#E6E6E6") : UIColor(hex: "#8a8a8a")
            self.messageStatusView.image = getImage("chSingleTickIcon")
            break
        case .seen:
            self.messageStatusView.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
            self.messageStatusView.image = getImage("chDoubleTickIcon")
            break
        }
        
        if chatItem.isIncoming {
            self.messageStatusView.isHidden = true
            self.messageTimeLabel.textAlignment = .left
        } else {
            self.messageStatusView.isHidden = false
            self.messageTimeLabel.textAlignment = .right
        }
        self.reactionsContainerView.assignReactions(reactions: gifStickerMessageModel.reactions)
        
        if chatItem.showMessageStatusView {
            self.messageStatusViewContainer.isHidden = false
        } else {
            self.messageStatusViewContainer.isHidden = true
        }
        
        if let downSampledUrl = gifStickerMessageModel.gifStickerData?.downSampledUrl {
            if let gifUrl = URL(string: downSampledUrl) {
                self.imageView.sd_imageTransition = .fade
                self.imageView.sd_imageIndicator = CHAppConstant.themeStyle == .dark ? SDWebImageActivityIndicator.white : SDWebImageActivityIndicator.gray
                self.imageView.sd_setImage(with: gifUrl, completed: nil)
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = reactionButton.hitTest(reactionButton.convert(point, from: self), with: event)
        if view == nil {
            view = super.hitTest(point, with: event)
        }

        return view
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) {
            return true
        }

        return !reactionButton.isHidden && reactionButton.point(inside: reactionButton.convert(point, from: self), with: event)
    }
}


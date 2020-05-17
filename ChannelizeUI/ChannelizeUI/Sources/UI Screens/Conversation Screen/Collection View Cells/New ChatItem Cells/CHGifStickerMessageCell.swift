//
//  CHGifStickerMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/27/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImageFLPlugin

class CHGifStickerMessageCell: BaseChatItemCollectionCell {
    
    private var messageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var imageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.runLoopMode = RunLoop.Mode.default.rawValue
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor(hex: "#e6e6e6").cgColor
        imageView.layer.borderWidth = 0.5
        imageView.backgroundColor = UIColor(hex: "#ffffff")
        return imageView
    }()
    
    var reactionButton: UIButton = {
        let button = UIButton()
        //button.layer.masksToBounds = true
        button.setImage(getImage("chReactionIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = UIColor(hex: "#c5c5c5")
        button.imageView?.layer.masksToBounds = true
        button.isUserInteractionEnabled = true
        button.isEnabled = true
        return button
    }()
    
    private var smileIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(hex: "#1c1c1c")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.image = getImage("chReactionIcon")
        return imageView
    }()
    
    var gifStickerModel: GifStickerMessageModel?
    
    var onReactionButtonPressed: ((_ model: CHGifStickerMessageCell?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(messageContainerView)
        self.messageContainerView.addSubview(imageView)
        self.messageContainerView.addSubview(reactionButton)
        self.messageContainerView.addSubview(reactionsContainerView)
        //self.messageContainerView.addSubview(self.smileIconView)
        self.reactionButton.addTarget(self, action: #selector(didTapOnReactionButton(sender:)), for: .touchUpInside)
        //self.bubbleContainerView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: BaseMessageItemProtocol) {
        super.assignChatItem(chatItem: chatItem)
        guard let gifStickerModel = chatItem as? GifStickerMessageModel else {
            return
        }
        //self.bubbleTapGesture.isEnabled = false
        self.cellTapGesture.isEnabled = false
        self.longPressTapGesture.isEnabled = false
        self.gifStickerModel = gifStickerModel
        
        let containerSize = CGSize(width: CHCustomStyles.gifStickerMessageSize.width, height: self.bubbleContainerView.frame.height)
        let containerYOrigin: CGFloat = 0
        self.messageContainerView.frame.size = containerSize
        self.messageContainerView.frame.origin.y = containerYOrigin
        
        if gifStickerModel.isIncoming {
            self.messageContainerView.frame.origin.x = 15
        } else {
            self.messageContainerView.frame.origin.x = self.bubbleContainerView.frame.width - containerSize.width - 15
        }
        
        let imageViewSize = CHCustomStyles.gifStickerMessageSize
        self.imageView.frame.size = imageViewSize
        self.imageView.frame.origin = .zero
        
        
        self.reactionButton.frame.size = CGSize(width: 22, height: 22)
        self.reactionButton.frame.origin.x = getViewOriginXEnd(view: self.imageView) + 2.5
        self.reactionButton.frame.origin.y = self.imageView.frame.origin.y
        
        if gifStickerModel.isIncoming {
            if CHCustomOptions.enableMessageReactions {
                self.reactionButton.isHidden = false
            } else {
                self.reactionButton.isHidden = true
            }
        } else {
            self.reactionButton.isHidden = true
        }
        
        let reactionViewHeight = super.calculateReactionViewHeight(chatItem: chatItem)
        let reactionViewWidth = CHCustomStyles.gifStickerMessageSize.width
        
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = 0
        self.reactionsContainerView.frame.origin.y = getViewOriginYEnd(view: self.imageView) - 15
        
        self.reactionsContainerView.assignReactions(reactions: chatItem.reactions)
        //self.reactionsContainerView.assignReactions(reactions: super.createReactionModels(chatItem: chatItem))
        
        if let downSampledUrl = gifStickerModel.downSampledUrl {
            if let gifUrl = URL(string: downSampledUrl) {
                self.imageView.sd_imageTransition = .fade
                self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.imageView.sd_setImage(with: gifUrl, completed: nil)
            }
        }
    }
    
    override func didTapOnBubble(tapGesture: UITapGestureRecognizer) {
        self.onReactionButtonPressed?(self)
        //self.onBubbleTapped?(self)
    }
    
    override func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == .began {
            self.onLongPressedBubble?(self)
        }
    }
    
    override func didSelectDeSelectCell(tapGesture: UITapGestureRecognizer) {
        self.onCellTapped?(self)
    }
    
    @objc private func didTapOnReactionButton(sender: UIButton) {
        self.onReactionButtonPressed?(self)
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

//
//  CHImageMessageCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/30/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import SDWebImage
import MaterialComponents.MaterialProgressView

class UIImageMessageCell: CHBaseMessageCell {
    
    private var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#4c4c4c") : UIColor(hex: "#e6e6e6")
        imageView.layer.borderColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#4c4c4c").cgColor : UIColor(hex: "#e6e6e6").cgColor
        imageView.layer.borderWidth = 1.0
        return imageView
    }()
    
    private var progressView: MDCActivityIndicator = {
        let progressView = MDCActivityIndicator()
        progressView.radius = 20
        progressView.cycleColors = [CHUIConstant.appTintColor]
        progressView.strokeWidth = 5.0
        progressView.startAnimating()
        return progressView
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
    
    var imageMessageItem: ImageMessageItem?
    var longPressGesture: UILongPressGestureRecognizer!
    var cellTappedGesture: UITapGestureRecognizer!
    var imageBubbleTappedGesture: UITapGestureRecognizer!
    var onLongPressImageView: ((_ chatItem: ImageMessageItem?) -> Void)?
    var onReactionButtonPressed: ((_ cell: UIImageMessageCell) -> Void)?
    var onCellTapped: ((_ cell: UIImageMessageCell) -> Void)?
    var onImageBubbleTapped: ((_ chatItem: ImageMessageItem?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(imageContainerView)
        self.bubbleContainerView.addSubview(self.reactionsContainerView)
        self.bubbleContainerView.addSubview(self.messageStatusViewContainer)
        self.bubbleContainerView.addSubview(reactionButton)
        self.imageContainerView.addSubview(imageView)
        self.imageContainerView.addSubview(progressView)
        self.messageStatusViewContainer.addSubview(self.messageStatusView)
        self.messageStatusViewContainer.addSubview(self.messageTimeLabel)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(textViewLongPressed(gesture:)))
        self.imageContainerView.addGestureRecognizer(longPressGesture)
        
        cellTappedGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(gesture:)))
        self.addGestureRecognizer(cellTappedGesture)
        
        imageBubbleTappedGesture = UITapGestureRecognizer(target: self, action: #selector(imageBubbleTapped(gesture:)))
        self.imageContainerView.addGestureRecognizer(imageBubbleTappedGesture)
        
        self.reactionButton.addTarget(self, action: #selector(reactionButtonPressed(sender:)), for: .touchUpInside)
    }
    
    @objc private func textViewLongPressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.onLongPressImageView?(self.imageMessageItem)
        }
    }
    
    @objc private func cellTapped(gesture: UITapGestureRecognizer) {
        self.onCellTapped?(self)
    }
    
    @objc private func reactionButtonPressed(sender: UIButton) {
        self.onReactionButtonPressed?(self)
    }
    
    @objc private func imageBubbleTapped(gesture: UITapGestureRecognizer) {
        self.onImageBubbleTapped?(self.imageMessageItem)
    }
    
    override func assignChatItem(chatItem: ChannelizeChatItem) {
        super.assignChatItem(chatItem: chatItem)
        guard let imageMessageModel = chatItem as? ImageMessageItem else {
            return
        }
        self.imageMessageItem = imageMessageModel
        
        if imageMessageModel.messageStatus == .sending {
            self.cellTappedGesture.isEnabled = false
            self.imageBubbleTappedGesture.isEnabled = false
            self.longPressGesture.isEnabled = false
            self.progressView.isHidden = false
            self.progressView.startAnimating()
            self.reactionButton.isEnabled = false
        } else {
            if imageMessageModel.isMessageSelectorOn {
                self.cellTappedGesture.isEnabled = true
                self.longPressGesture.isEnabled = false
                self.imageBubbleTappedGesture.isEnabled = false
                self.reactionButton.isEnabled = false
            } else {
                self.cellTappedGesture.isEnabled = false
                self.longPressGesture.isEnabled = true
                self.imageBubbleTappedGesture.isEnabled = true
                self.reactionButton.isEnabled = true
            }
            self.progressView.isHidden = true
            self.progressView.stopAnimating()
        }
        
        let containerViewSize = CHCustomStyles.imageMessageBubbleSize
        self.imageContainerView.frame.size = containerViewSize
        self.imageContainerView.frame.origin.y = 0
        if imageMessageModel.isIncoming {
            self.imageContainerView.frame.origin.x = 15
        } else {
            self.imageContainerView.frame.origin.x = self.bubbleContainerView.frame.width - containerViewSize.width - 15
        }
        
        if chatItem.isIncoming {
            self.reactionButton.isHidden = false
            self.reactionButton.frame.size = CGSize(width: 22, height: 22)
            self.reactionButton.frame.origin.x = getViewEndOriginX(view: self.imageContainerView) + 2.5
            self.reactionButton.frame.origin.y = self.imageContainerView.frame.origin.y + 2.5
        } else {
            self.reactionButton.isHidden = true
            self.reactionButton.frame = .zero
        }
        
        self.messageStatusViewContainer.frame.size = CGSize(width: 80, height: 35)
        self.messageStatusViewContainer.frame.origin.y = getViewEndOriginY(view: self.imageContainerView) - self.messageStatusViewContainer.frame.size.height
        if imageMessageModel.isIncoming {
            self.messageStatusViewContainer.frame.origin.x = getViewEndOriginX(view: self.imageContainerView) + 5
        } else {
            self.messageStatusViewContainer.frame.origin.x = self.imageContainerView.frame.origin.x - self.messageStatusViewContainer.frame.width - 5
        }
        
        self.messageStatusView.frame.size = CGSize(width: 20, height: 20)
        self.messageStatusView.frame.origin.y = 0
        self.messageStatusView.frame.origin.x = imageMessageModel.isIncoming == true ? 0 : self.messageStatusViewContainer.frame.width - self.messageStatusView.frame.width
        
        self.messageTimeLabel.frame.size = CGSize(width: 80, height: 15)
        self.messageTimeLabel.frame.origin.x = 0
        self.messageTimeLabel.frame.origin.y = getViewEndOriginY(view: self.messageStatusView)
        
        
        let imageViewSize = CHCustomStyles.imageMessageBubbleSize
        self.imageView.frame.size = imageViewSize
        self.imageView.frame.origin.x = 0
        self.imageView.frame.origin.y = 0
        
        let reactionViewHeight = super.calculateReactionViewHeight(chatItem: chatItem)
        let reactionViewWidth: CGFloat = CHCustomStyles.imageMessageBubbleSize.width
        
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = self.imageContainerView.frame.origin.x
        self.reactionsContainerView.frame.origin.y = getViewEndOriginY(view: self.imageView) - 15
        
        self.progressView.frame.size = CGSize(width: 70, height: 70)
        self.progressView.center = self.imageView.center
        
        self.reactionsContainerView.assignReactions(reactions: imageMessageModel.reactions)
        
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
        self.reactionsContainerView.assignReactions(reactions: imageMessageModel.reactions)
        
        if chatItem.showMessageStatusView {
            self.messageStatusViewContainer.isHidden = false
        } else {
            self.messageStatusViewContainer.isHidden = true
        }
        if imageMessageModel.imageMessageData?.imageSource == .local {
            if let localImage = imageMessageModel.imageMessageData?.localImage {
                SDImageCache.shared.store(localImage, forKey: imageMessageModel.messageId, completion: nil)
            }
        }
        if let image = SDImageCache.shared.imageFromCache(forKey: imageMessageModel.messageId) {
            self.imageView.image = image
        } else {
            if imageMessageModel.imageMessageData?.imageSource == .local {
                self.imageView.image = imageMessageModel.imageMessageData?.localImage
            } else {
                
                self.imageView.image = imageMessageModel.imageMessageData?.localImage
                if let imageUrlString = imageMessageModel.imageMessageData?.imageUrlString {
                    self.imageView.sd_imageTransition = imageMessageModel.imageMessageData?.localImage == nil ? .fade : .none
                    self.imageView.sd_imageIndicator = imageMessageModel.imageMessageData?.localImage == nil ? (CHAppConstant.themeStyle == .dark ? SDWebImageActivityIndicator.white : SDWebImageActivityIndicator.gray) : .none
                    let imageUrl = URL(string: imageUrlString)
                    self.imageView.sd_setImage(with: imageUrl, placeholderImage: imageMessageModel.imageMessageData?.localImage, options: [.refreshCached,.continueInBackground], completed: {(image,error,cache,url) in
                        if image != nil {
                            imageMessageModel.imageMessageData?.localImage = nil
                        }
                    })
                }
            }
        }
    }
    
    func updateProgress(fromValue: Double, toValue: Double) {
        if toValue != 1.0 {
            progressView.setIndicatorMode(.determinate, animated: true)
            progressView.progress = Float(toValue)
            progressView.startAnimating()
        } else {
            self.progressView.setIndicatorMode(.indeterminate, animated: true)
            self.progressView.startAnimating()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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



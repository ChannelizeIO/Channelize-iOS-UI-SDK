//
//  CHImageMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/27/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import SDWebImage
import MaterialComponents.MaterialProgressView

class CHImageMessageCell: BaseChatItemCollectionCell {
    
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
        imageView.backgroundColor = UIColor(hex: "#fafafa")
        imageView.layer.borderColor = UIColor(hex: "#e6e6e6").cgColor
        imageView.layer.borderWidth = 1.0
        return imageView
    }()
    
    private var progressView: MDCActivityIndicator = {
        let progressView = MDCActivityIndicator()
        progressView.radius = 20
        progressView.cycleColors = [CHUIConstants.appDefaultColor]
        progressView.strokeWidth = 5.0
        progressView.startAnimating()
        return progressView
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
    
    private var smileIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.tintColor = UIColor(hex: "#1c1c1c")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chReactionIcon")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(imageContainerView)
        self.imageContainerView.addSubview(imageView)
        self.imageContainerView.addSubview(progressView)
        self.imageContainerView.addSubview(reactionButton)
        self.imageContainerView.addSubview(reactionsContainerView)
        self.reactionButton.addTarget(self, action: #selector(didTapOnReactionButton(sender:)), for: .touchUpInside)
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnImageView(gesture:)))
        self.imageView.addGestureRecognizer(tapgesture)
        //self.reactionButton.isEnabled = false
        //let reactionTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapReactionButton))
        //reactionTapGesture.numberOfTapsRequired = 2
        //self.smileIconView.addGestureRecognizer(reactionTapGesture)
    }
    
    var imageMessageModel: ImageMessageModel?
    
    var onReactionButtonPressed: ((_ model: CHImageMessageCell?) -> Void)?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: BaseMessageItemProtocol) {
        super.assignChatItem(chatItem: chatItem)
        //super.bubbleTapGesture.isEnabled = false
        //self.bubbleTapGesture.isEnabled = false
        guard let imageMessageModel = chatItem as? ImageMessageModel else {
            return
        }
        self.imageMessageModel = imageMessageModel
        
        if imageMessageModel.messageStatus == .sending {
            self.progressView.isHidden = false
            self.progressView.startAnimating()
        } else {
            self.progressView.isHidden = true
            self.progressView.stopAnimating()
        }
        
        let containerViewSize = CGSize(width: CHCustomStyles.photoBubbleSize.width, height: self.bubbleContainerView.frame.height)
        self.imageContainerView.frame.size = containerViewSize
        self.imageContainerView.frame.origin.y = 0
        if imageMessageModel.isIncoming {
            self.imageContainerView.frame.origin.x = 15
        } else {
            self.imageContainerView.frame.origin.x = self.bubbleContainerView.frame.width - containerViewSize.width - 15
        }
        
        let imageViewSize = CGSize(width: CHCustomStyles.photoBubbleSize.width, height: CHCustomStyles.photoBubbleSize.height)
        self.imageView.frame.size = imageViewSize
        self.imageView.frame.origin.x = 0
        self.imageView.frame.origin.y = 0
        
        let reactionViewHeight = super.calculateReactionViewHeight(chatItem: chatItem)
        let reactionViewWidth = CHCustomStyles.photoBubbleSize.width
        
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = 0
        self.reactionsContainerView.frame.origin.y = getViewOriginYEnd(view: self.imageView) - 15
        
        
        
//        if imageMessageModel.isIncoming {
//            self.imageView.frame.origin.x = 15
//        } else {
//            self.imageView.frame.origin.x = self.bubbleContainerView.frame.width - imageViewSize.width - 15
//        }
        
        self.progressView.frame.size = CGSize(width: 70, height: 70)
        self.progressView.center = self.imageView.center
        
        self.reactionButton.frame.size = CGSize(width: 22, height: 22)
        self.reactionButton.frame.origin.x = getViewOriginXEnd(view: self.imageView) + 2.5
        self.reactionButton.frame.origin.y = self.imageView.frame.origin.y
        
        if imageMessageModel.isIncoming {
            if CHCustomOptions.enableMessageReactions {
                self.reactionButton.isHidden = false
            } else {
                self.reactionButton.isHidden = true
            }
        } else {
            self.reactionButton.isHidden = true
        }
        
        
        
        self.reactionsContainerView.assignReactions(reactions: imageMessageModel.reactions)
        //self.reactionsContainerView.assignReactions(reactions: super.createReactionModels(chatItem: chatItem))
        
        if imageMessageModel.messageSource == .local {
            self.imageView.image = imageMessageModel.localImage
        } else {
            
            self.imageView.image = imageMessageModel.localImage
            if let imageUrlString = imageMessageModel.imageUrl {
                self.imageView.sd_imageTransition = imageMessageModel.localImage == nil ? .fade : .none
                self.imageView.sd_imageIndicator = imageMessageModel.localImage == nil ? SDWebImageActivityIndicator.gray : .none
                let imageUrl = URL(string: imageUrlString)
                self.imageView.sd_setImage(with: imageUrl, placeholderImage: imageMessageModel.localImage, options: [.refreshCached,.continueInBackground], completed: {(image,error,cache,url) in
                    if image != nil {
                        imageMessageModel.localImage = nil
                    }
                })
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
    
    @objc private func didTapReactionButton() {
        self.onReactionButtonPressed?(self)
    }
    
    @objc private func didTapOnReactionButton(sender: UIButton) {
        self.onReactionButtonPressed?(self)
    }
    
    @objc private func didTapOnImageView(gesture: UITapGestureRecognizer) {
        guard self.imageMessageModel?.messageStatus != .sending else {
            return
        }
        self.onBubbleTapped?(self)
    }
    
    override func didTapOnBubble(tapGesture: UITapGestureRecognizer) {
        guard self.imageMessageModel?.messageStatus != .sending else {
            return
        }
        //self.onBubbleTapped?(self)
    }
    
    override func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
        guard self.imageMessageModel?.messageStatus != .sending else {
            return
        }
        if longPressGesture.state == .began {
            self.onLongPressedBubble?(self)
        }
    }
    
    override func didSelectDeSelectCell(tapGesture: UITapGestureRecognizer) {
        guard self.imageMessageModel?.messageStatus != .sending else {
            return
        }
        self.onCellTapped?(self)
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

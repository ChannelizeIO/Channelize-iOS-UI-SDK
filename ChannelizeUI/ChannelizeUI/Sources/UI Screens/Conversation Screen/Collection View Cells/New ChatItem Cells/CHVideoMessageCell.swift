//
//  CHVideoMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage
import MaterialComponents.MaterialProgressView

class CHVideoMessageCell: BaseChatItemCollectionCell {
    
    private var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
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
    
    private var videoPlayButtonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = getImage("chPlayButton")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.tintColor = CHUIConstants.appDefaultColor
        imageView.backgroundColor = .white
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(imageContainerView)
        self.imageContainerView.addSubview(imageView)
        self.imageContainerView.addSubview(reactionsContainerView)
        self.imageContainerView.addSubview(progressView)
        self.imageContainerView.addSubview(reactionButton)
        self.imageContainerView.addSubview(videoPlayButtonImageView)
        self.reactionButton.addTarget(self, action: #selector(didTapOnReactionButton(sender:)), for: .touchUpInside)
    }
    
    var videoMessageModel: VideoMessageModel?
    
    var onReactionButtonPressed: ((_ model: CHVideoMessageCell?) -> Void)?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: BaseMessageItemProtocol) {
        super.assignChatItem(chatItem: chatItem)
        guard let videoMessageModel = chatItem as? VideoMessageModel else {
            return
        }
        self.videoMessageModel = videoMessageModel
        
        if videoMessageModel.messageStatus == .sending {
            self.progressView.isHidden = false
            self.videoPlayButtonImageView.isHidden = true
            self.progressView.startAnimating()
        } else {
            self.progressView.isHidden = true
            self.videoPlayButtonImageView.isHidden = false
            self.progressView.stopAnimating()
        }
        
        let imageContainerSize = CGSize(width: CHCustomStyles.videoMessageSize.width, height: self.bubbleContainerView.frame.height)
        self.imageContainerView.frame.size = imageContainerSize
        self.imageContainerView.frame.origin.y = 0
        if videoMessageModel.isIncoming {
            self.imageContainerView.frame.origin.x = 15
        } else {
            self.imageContainerView.frame.origin.x = self.bubbleContainerView.frame.width - imageContainerSize.width - 15
        }
        
        let imageViewSize = CHCustomStyles.videoMessageSize
        self.imageView.frame.size = imageViewSize
        self.imageView.frame.origin = .zero
        
        self.progressView.frame.size = CGSize(width: 70, height: 70)
        self.progressView.center = self.imageView.center
        
        self.videoPlayButtonImageView.frame.size = CGSize(width: 50, height: 50)
        self.videoPlayButtonImageView.center = self.imageView.center
        self.videoPlayButtonImageView.layer.cornerRadius = 25
        
        self.reactionButton.frame.size = CGSize(width: 22, height: 22)
        self.reactionButton.frame.origin.x = getViewOriginXEnd(view: self.imageView) + 2.5
        self.reactionButton.frame.origin.y = self.imageView.frame.origin.y
        
        if videoMessageModel.isIncoming {
            if CHCustomOptions.enableMessageReactions {
                self.reactionButton.isHidden = false
            } else {
                self.reactionButton.isHidden = true
            }
        } else {
            self.reactionButton.isHidden = true
        }
        
        let reactionContainerHeight = self.bubbleContainerView.frame.height - imageViewSize.height
        let reactionContainerXorigin: CGFloat = 0
        let reactionContainerYorigin = getViewOriginYEnd(view: self.imageView) - 15
        
        self.reactionsContainerView.frame = CGRect(x: reactionContainerXorigin, y: reactionContainerYorigin, width: imageContainerSize.width, height: reactionContainerHeight)
        
        self.reactionsContainerView.assignReactions(reactions: videoMessageModel.reactions)
        
        //self.reactionsContainerView.assignReactions(reactions: super.createReactionModels(chatItem: chatItem))
        
        if videoMessageModel.messageSource == .local {
            self.imageView.image = videoMessageModel.localImage
        } else {
            self.imageView.image = videoMessageModel.localImage
            if let imageUrlString = videoMessageModel.thumbnailUrl {
                self.imageView.sd_imageTransition = videoMessageModel.localImage == nil ? .fade : .none
                self.imageView.sd_imageIndicator = videoMessageModel.localImage == nil ? SDWebImageActivityIndicator.gray : .none
                let imageUrl = URL(string: imageUrlString)
                self.imageView.sd_setImage(with: imageUrl, placeholderImage: videoMessageModel.localImage, options: [.refreshCached,.continueInBackground], completed: {(image,error,cache,url) in
                    if let _image = image {
                        videoMessageModel.localImage = nil
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
    
    override func didTapOnBubble(tapGesture: UITapGestureRecognizer) {
        guard self.videoMessageModel?.messageStatus != .sending else {
            return
        }
        self.onBubbleTapped?(self)
    }
    
    override func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
        guard self.videoMessageModel?.messageStatus != .sending else {
            return
        }
        if longPressGesture.state == .began {
            self.onLongPressedBubble?(self)
        }
    }
    
    override func didSelectDeSelectCell(tapGesture: UITapGestureRecognizer) {
        guard self.videoMessageModel?.messageStatus != .sending else {
            return
        }
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

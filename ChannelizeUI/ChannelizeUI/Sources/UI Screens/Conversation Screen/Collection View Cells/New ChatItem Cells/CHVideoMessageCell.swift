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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(imageView)
        self.bubbleContainerView.addSubview(progressView)
        self.bubbleContainerView.addSubview(videoPlayButtonImageView)
    }
    
    var videoMessageModel: VideoMessageModel?
    
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
        
        let imageViewSize = CGSize(width: 220, height: self.bubbleContainerView.frame.height)
        self.imageView.frame.size = imageViewSize
        if videoMessageModel.isIncoming {
            self.imageView.frame.origin.x = 15
        } else {
            self.imageView.frame.origin.x = self.bubbleContainerView.frame.width - imageViewSize.width - 15
        }
        
        self.progressView.frame.size = CGSize(width: 70, height: 70)
        self.progressView.center = self.imageView.center
        
        self.videoPlayButtonImageView.frame.size = CGSize(width: 50, height: 50)
        self.videoPlayButtonImageView.center = self.imageView.center
        self.videoPlayButtonImageView.layer.cornerRadius = 25
        
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
}

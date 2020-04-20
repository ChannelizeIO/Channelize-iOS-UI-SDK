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
    
    var gifStickerModel: GifStickerMessageModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: BaseMessageItemProtocol) {
        super.assignChatItem(chatItem: chatItem)
        guard let gifStickerModel = chatItem as? GifStickerMessageModel else {
            return
        }
        self.gifStickerModel = gifStickerModel
        let imageViewSize = CGSize(width: 220, height: self.bubbleContainerView.frame.height)
        self.imageView.frame.size = imageViewSize
        if gifStickerModel.isIncoming {
            self.imageView.frame.origin.x = 15
        } else {
            self.imageView.frame.origin.x = self.bubbleContainerView.frame.width - imageViewSize.width - 15
        }
        
        if let downSampledUrl = gifStickerModel.downSampledUrl {
            if let gifUrl = URL(string: downSampledUrl) {
                self.imageView.sd_imageTransition = .fade
                self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.imageView.sd_setImage(with: gifUrl, completed: nil)
            }
        }
    }
    
    override func didTapOnBubble(tapGesture: UITapGestureRecognizer) {
        self.onBubbleTapped?(self)
    }
    
    override func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == .began {
            self.onLongPressedBubble?(self)
        }
    }
    
    override func didSelectDeSelectCell(tapGesture: UITapGestureRecognizer) {
        self.onCellTapped?(self)
    }
    
}

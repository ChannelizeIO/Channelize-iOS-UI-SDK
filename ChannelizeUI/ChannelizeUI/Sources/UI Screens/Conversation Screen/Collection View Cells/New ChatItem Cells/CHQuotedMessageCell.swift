//
//  CHQuotedMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/29/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class CHQuotedMessageCell: BaseChatItemCollectionCell {
    
    var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.customSystemTeal
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        view.layer.borderColor = UIColor(hex: "#f1f1f1").cgColor
        view.layer.borderWidth = 1.0
        return view
    }()
    
    private var quotedMessageView: QuotedMessageContainerView = {
        let view = QuotedMessageContainerView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    private var textView: UITextView = {
        let textView = CHMessageTextView()
        UIView.performWithoutAnimation({ () -> Void in // fixes iOS 8 blinking when cell appears
            textView.backgroundColor = UIColor.clear
        })
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .all
        textView.scrollsToTop = false
        textView.isScrollEnabled = false
        textView.bounces = false
        textView.bouncesZoom = false
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.isExclusiveTouch = true
        textView.textContainer.lineFragmentPadding = 0
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 15
        return textView
    }()
    
    var quotedMessageModel: QuotedMessageModel?
    
    var onContainerViewTapped: ((_ parentMessageId: String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(containerView)
        self.containerView.addSubview(quotedMessageView)
        self.containerView.addSubview(textView)
        
        self.quotedMessageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onContainerViewTapped(tapGesture:))))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: BaseMessageItemProtocol) {
        super.assignChatItem(chatItem: chatItem)
        guard let quotedMessageModel = chatItem as? QuotedMessageModel else {
            return
        }
        self.quotedMessageModel = quotedMessageModel
        
        let textMessageAttributedString = quotedMessageModel.attributedString ?? NSAttributedString()
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 280, withText: textMessageAttributedString)
        let frameSize = frameSizeInfo.frameSize
        var containerWidth = frameSize.width + 26
        let containerHeight = frameSize.height + 24
        if containerWidth < 280 {
            containerWidth = 280
        }
        
        var messageBubbleOriginX: CGFloat = 0
        if quotedMessageModel.isIncoming {
            messageBubbleOriginX = 15
        } else {
            messageBubbleOriginX = self.frame.width - containerWidth - 15
        }
        self.containerView.frame.size = CGSize(width: containerWidth, height: self.bubbleContainerView.frame.height)
        self.containerView.center.y = self.bubbleContainerView.frame.height/2
        self.containerView.frame.origin.x = messageBubbleOriginX
        
        self.quotedMessageView.frame.origin = CGPoint(x: 10, y: 7.5)
        self.quotedMessageView.frame.size = CGSize(width: self.containerView.frame.width - 20, height: 60)
        
        self.textView.frame.origin = CGPoint(x: 0, y: 67.5)
        self.textView.frame.size = CGSize(width: self.containerView.frame.width, height: self.containerView.frame.height - 75)
        
        
        self.quotedMessageView.quotedViewModel = quotedMessageModel.quotedMessageModel
        
        self.containerView.backgroundColor = quotedMessageModel.isIncoming ? CHUIConstants.incomingTextMessageBackgroundColor : CHUIConstants.outgoingTextMessageBackgroundColor
        
        self.quotedMessageView.backgroundColor = self.containerView.backgroundColor?.darker(by: 10.0)
        
        self.textView.attributedText = quotedMessageModel.attributedString
    }
    
    @objc func onContainerViewTapped(tapGesture: UITapGestureRecognizer) {
        self.onContainerViewTapped?(self.quotedMessageModel?.quotedMessageModel?.parentMessageId ?? "")
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

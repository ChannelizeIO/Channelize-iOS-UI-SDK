//
//  CHTextMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class CHTextMessageCell: BaseChatItemCollectionCell {
    
    private var textContainerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
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
        textView.dataDetectorTypes = .link
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
    
    var textMessageModel: TextMessageModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(textContainerView)
        self.textContainerView.addSubview(textView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: BaseMessageItemProtocol) {
        super.assignChatItem(chatItem: chatItem)
        guard let textMessageModel = chatItem as? TextMessageModel else {
            return
        }
        if chatItem.isIncoming {
            self.textView.linkTextAttributes = [
                NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: CHUIConstants.normalFontSize)!,
                NSAttributedString.Key.foregroundColor: UIColor(hex: "#3A3C4C")
            ]
        } else {
            self.textView.linkTextAttributes = [
                NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: CHUIConstants.normalFontSize)!,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
        }
        self.textMessageModel = textMessageModel
        let textMessageAttributedString = textMessageModel.attributedString ?? NSAttributedString()
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 280, withText: textMessageAttributedString)
        let frameSize = frameSizeInfo.frameSize
        let containerWidth = frameSize.width + 26
        let containerHeight = frameSize.height + 24
        
        self.textContainerView.backgroundColor = textMessageModel.isIncoming ? CHUIConstants.incomingTextMessageBackgroundColor : CHUIConstants.outgoingTextMessageBackgroundColor
        
        self.textContainerView.frame.origin.x = textMessageModel.isIncoming ? 15 : self.bubbleContainerView.frame.width - containerWidth - 15
        self.textContainerView.frame.origin.y = 0
        self.textContainerView.frame.size = CGSize(width: containerWidth, height: containerHeight)
        
        self.textView.frame.origin = .zero
        self.textView.frame.size = self.textContainerView.frame.size
        
        self.textView.attributedText = textMessageModel.attributedString
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

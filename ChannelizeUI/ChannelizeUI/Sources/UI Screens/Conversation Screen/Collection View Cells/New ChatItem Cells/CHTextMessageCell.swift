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
    
    var reactionButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setImage(getImage("chReactionIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = UIColor(hex: "#c5c5c5")
        button.imageView?.layer.masksToBounds = true
        return button
    }()
    
    var textMessageModel: TextMessageModel?
    var onReactionButtonPressed: ((_ model: CHTextMessageCell?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(textContainerView)
        self.bubbleContainerView.addSubview(self.reactionButton)
        self.bubbleContainerView.addSubview(self.reactionsContainerView)
        self.textContainerView.addSubview(textView)
        self.reactionButton.addTarget(self, action: #selector(didTapOnReactionButton(sender:)), for: .touchUpInside)
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
                NSAttributedString.Key.foregroundColor: CHCustomStyles.incomingMessageTextColor
            ]
        } else {
            self.textView.linkTextAttributes = [
                NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: CHUIConstants.normalFontSize)!,
                NSAttributedString.Key.foregroundColor: CHCustomStyles.outgoingMessageTextColor
            ]
        }
        self.textMessageModel = textMessageModel
        let textMessageAttributedString = textMessageModel.attributedString ?? NSAttributedString()
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 280, withText: textMessageAttributedString)
        let frameSize = frameSizeInfo.frameSize
        var containerWidth = frameSize.width + 26
        var containerHeight = frameSize.height + 24
        
        
        let nonZeroCountReactions = self.textMessageModel?.reactionCountsInfo.filter({
            $0.value > 0
        })
        if nonZeroCountReactions?.count ?? 0 > 0 {
            let reactionSize = self.calculateReactionViewSize(chatItem: chatItem)
            print("Reaction Container Size is \(reactionSize)")
            if reactionSize.width > containerWidth {
                containerWidth = reactionSize.width
            }
        }
        containerHeight = containerHeight + (nonZeroCountReactions?.count ?? 0 > 0 ? 5 : 0)
        
        self.textContainerView.backgroundColor = textMessageModel.isIncoming ? CHCustomStyles.baseMessageIncomingBackgroundColor : CHCustomStyles.baseMessageOutgoingBackgroundColor
        
        self.textContainerView.frame.origin.x = textMessageModel.isIncoming ? 15 : self.bubbleContainerView.frame.width - containerWidth - 15
        self.textContainerView.frame.origin.y = 0
        self.textContainerView.frame.size = CGSize(width: containerWidth, height: containerHeight)
        
        self.reactionButton.frame.size = CGSize(width: 22, height: 22)
        self.reactionButton.frame.origin.x = getViewOriginXEnd(view: self.textContainerView) + 2.5
        self.reactionButton.frame.origin.y = self.textContainerView.frame.origin.y
        
        
        
        if textMessageModel.isDeletedMessage == true {
            self.reactionButton.isHidden = true
        } else {
            if textMessageModel.isIncoming {
                if CHCustomOptions.enableMessageReactions {
                    self.reactionButton.isHidden = false
                } else {
                    self.reactionButton.isHidden = true
                }
            } else {
                self.reactionButton.isHidden = true
            }
        }
        
        
        
        let reactionViewHeight = super.calculateReactionViewHeight(chatItem: chatItem)
        let reactionViewWidth: CGFloat = 280
        
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = self.textContainerView.frame.origin.x
        self.reactionsContainerView.frame.origin.y = getViewOriginYEnd(view: self.textContainerView) - 15
        
        self.textView.frame.origin = .zero
        self.textView.frame.size = CGSize(width: frameSize.width + 26, height: frameSize.height + 24)
        
        self.textView.attributedText = textMessageModel.attributedString
        
        self.reactionsContainerView.assignReactions(reactions: textMessageModel.reactions)
        
        //self.reactionsContainerView.assignReactions(reactions: super.createReactionModels(chatItem: chatItem))
    }
    
    
    func calculateReactionViewSize(chatItem: BaseMessageItemProtocol) -> CGSize{
        var reactionsModels = [ReactionModel]()
        let reactionCountInfo = chatItem.reactionCountsInfo.sorted(by: { $0.value > $1.value })
        reactionCountInfo.forEach({
            let model = ReactionModel()
            model.counts = $0.value
            model.unicode = emojiCodes[$0.key]
            if model.counts ?? 0 > 0 {
                reactionsModels.append(model)
            }
        })
        
        guard reactionsModels.count > 0 else {
            return .zero
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
            if initialOriginX + currentItemWidth < 280 - 5{
                initialOriginX = initialOriginX + currentItemWidth + 5
            } else {
                initialOriginY += 32.5
                initialOriginX = 5 + currentItemWidth + 2.5
            }
        })
        
        if initialOriginY > 30 {
            return CGSize(width: 280, height: initialOriginY)
        } else {
            return CGSize(width: initialOriginX, height: initialOriginY)
        }
        
        //containerView.sizeToFit()
        //return containerView.frame.size
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

class CHMessageTextView: UITextView {
    
    override var canBecomeFirstResponder: Bool {
        return false
    }
    
    // See https://github.com/badoo/Chatto/issues/363
    override var gestureRecognizers: [UIGestureRecognizer]? {
        set {
            super.gestureRecognizers = newValue
        }
        get {
            return super.gestureRecognizers?.filter({ (gestureRecognizer) -> Bool in
                return type(of: gestureRecognizer) == UILongPressGestureRecognizer.self && gestureRecognizer.delaysTouchesEnded
            })
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override var selectedRange: NSRange {
        get {
            return NSRange(location: 0, length: 0)
        }
        set {
            // Part of the heaviest stack trace when scrolling (when updating text)
            // See https://github.com/badoo/Chatto/pull/144
        }
    }
    
    override var contentOffset: CGPoint {
        get {
            return .zero
        }
        set {
            // Part of the heaviest stack trace when scrolling (when bounds are set)
            // See https://github.com/badoo/Chatto/pull/144
        }
    }
}

//
//  CHTextMessageCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/29/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI

class UITextMessageCell: CHBaseMessageCell {
    
    private var textContainerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        return view
    }()
    
    private var textView: CHMessageTextView = {
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
    
    var messageStatusViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var messageTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .medium, size: 13.0)
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
    
    
    var longPressGesture: UILongPressGestureRecognizer!
    var cellTappedGesture: UITapGestureRecognizer!
    var textMessageItem: TextMessageItem?
    var onLongPressTextView: ((_ chatItem: TextMessageItem?) -> Void)?
    var onReactionButtonPressed: ((_ cell: UITextMessageCell) -> Void)?
    var onCellTapped: ((_ cell: UITextMessageCell) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(textContainerView)
        self.bubbleContainerView.addSubview(self.reactionsContainerView)
        self.bubbleContainerView.addSubview(self.messageStatusViewContainer)
        self.bubbleContainerView.addSubview(self.reactionButton)
        self.textContainerView.addSubview(self.textView)
        self.messageStatusViewContainer.addSubview(self.messageStatusView)
        self.messageStatusViewContainer.addSubview(self.messageTimeLabel)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(textViewLongPressed(gesture:)))
        self.textView.addGestureRecognizer(longPressGesture)
        
        cellTappedGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(gesture:)))
        self.addGestureRecognizer(cellTappedGesture)
        
        self.reactionButton.addTarget(self, action: #selector(reactionButtonPressed(sender:)), for: .touchUpInside)
    }
    
    @objc private func textViewLongPressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.onLongPressTextView?(self.textMessageItem)
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
        
        guard let textMessageModel = chatItem as? TextMessageItem else {
            return
        }
        self.textMessageItem = textMessageModel
        
        if textMessageModel.messageStatus == .sending {
            self.cellTappedGesture.isEnabled = false
            self.longPressGesture.isEnabled = false
            self.reactionButton.isEnabled = false
        } else {
            if textMessageModel.isMessageSelectorOn {
                self.cellTappedGesture.isEnabled = true
                self.longPressGesture.isEnabled = false
                self.reactionButton.isEnabled = false
            } else {
                self.cellTappedGesture.isEnabled = false
                self.longPressGesture.isEnabled = true
                self.reactionButton.isEnabled = true
            }
        }
        
        if chatItem.isIncoming {
            self.textView.linkTextAttributes = [
                NSAttributedString.Key.font: CHUIConstant.textMessageFont,
                NSAttributedString.Key.foregroundColor: CHUIConstant.incomingTextMessageColor
            ]
        } else {
            self.textView.linkTextAttributes = [
                NSAttributedString.Key.font: CHUIConstant.textMessageFont,
                NSAttributedString.Key.foregroundColor: CHUIConstant.outGoingTextMessageColor
            ]
        }
        let textMessageAttributedString = textMessageModel.attributedString ?? NSAttributedString()
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 250, withText: textMessageAttributedString)
        let frameSize = frameSizeInfo.frameSize
        var containerWidth = frameSize.width + 26
        var containerHeight = frameSize.height + 24
        
        let nonZeroCountReactions = self.textMessageItem?.reactionCountsInfo.filter({
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
        
        self.textContainerView.backgroundColor = textMessageModel.isIncoming ? CHUIConstant.incomingTextMessageBackGroundColor : CHUIConstant.outGoingTextMessageBackGroundColor
        
        self.textContainerView.frame.origin.x = textMessageModel.isIncoming ? 15 : self.bubbleContainerView.frame.width - containerWidth - 15
        self.textContainerView.frame.origin.y = 0
        self.textContainerView.frame.size = CGSize(width: containerWidth, height: containerHeight)
        
        self.textView.frame.origin = .zero
        self.textView.frame.size = CGSize(width: frameSize.width + 26, height: frameSize.height + 24)
        
        if chatItem.isIncoming {
            if textMessageModel.isDeletedMessage == true {
                self.reactionButton.isHidden = true
                self.reactionButton.frame = .zero
            } else {
                self.reactionButton.isHidden = false
                self.reactionButton.frame.size = CGSize(width: 22, height: 22)
                self.reactionButton.frame.origin.x = getViewEndOriginX(view: self.textContainerView) + 2.5
                self.reactionButton.frame.origin.y = self.textContainerView.frame.origin.y + 2.5
            }
        } else {
            self.reactionButton.isHidden = true
            self.reactionButton.frame = .zero
        }
        
        self.messageStatusViewContainer.frame.size = CGSize(width: 80, height: 30)
        self.messageStatusViewContainer.frame.origin.y = getViewEndOriginY(view: self.textContainerView) - self.messageStatusViewContainer.frame.size.height - 2.5
        if textMessageModel.isIncoming {
            self.messageStatusViewContainer.frame.origin.x = getViewEndOriginX(view: self.textContainerView) + 5
        } else {
            self.messageStatusViewContainer.frame.origin.x = self.textContainerView.frame.origin.x - self.messageStatusViewContainer.frame.width - 5
        }
        
        self.messageStatusView.frame.size = CGSize(width: 15, height: 15)
        self.messageStatusView.frame.origin.y = 0
        self.messageStatusView.frame.origin.x = textMessageModel.isIncoming == true ? 0 : self.messageStatusViewContainer.frame.width - self.messageStatusView.frame.width
        
        self.messageTimeLabel.frame.size = CGSize(width: 80, height: 15)
        self.messageTimeLabel.frame.origin.x = 0
        self.messageTimeLabel.frame.origin.y = getViewEndOriginY(view: self.messageStatusView)
        
        
        let reactionViewHeight = super.calculateReactionViewHeight(chatItem: chatItem)
        let reactionViewWidth: CGFloat = 250
        
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = self.textContainerView.frame.origin.x
        self.reactionsContainerView.frame.origin.y = getViewEndOriginY(view: self.textContainerView) - 15
        
        self.textView.attributedText = textMessageModel.attributedString
        self.reactionsContainerView.assignReactions(reactions: textMessageModel.reactions)
        
        if chatItem.showMessageStatusView {
            self.messageStatusViewContainer.isHidden = false
        } else {
            self.messageStatusViewContainer.isHidden = true
        }
        
        if chatItem.isIncoming {
            self.messageStatusView.isHidden = true
            self.messageTimeLabel.textAlignment = .left
        } else {
            self.messageStatusView.isHidden = false
            self.messageTimeLabel.textAlignment = .right
        }
        
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
    }
    
    func calculateReactionViewSize(chatItem: ChannelizeChatItem) -> CGSize{
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
            if initialOriginX + currentItemWidth < 250 - 5{
                initialOriginX = initialOriginX + currentItemWidth + 5
            } else {
                initialOriginY += 32.5
                initialOriginX = 5 + currentItemWidth + 2.5
            }
        })
        
        if initialOriginY > 30 {
            return CGSize(width: 250, height: initialOriginY)
        } else {
            return CGSize(width: initialOriginX, height: initialOriginY)
        }
        
        //containerView.sizeToFit()
        //return containerView.frame.size
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
    
    private var _font: UIFont?
    
    override var canBecomeFirstResponder: Bool {
        return false
    }
    
    override var font: UIFont? {
        didSet {
            _font = font
        }
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
    
    override func insertText(_ text: String) {
        fixTypingFont()
        super.insertText(text)
        fixTypingFont()
    }
    
    override func paste(_ sender: Any?) {
        fixTypingFont()
        super.paste(sender)
        fixTypingFont()
    }
    
    func fixTypingFont() {
        let fontAttribute = NSAttributedString.Key.font
        guard (typingAttributes[fontAttribute] as? UIFont)?.fontName == "AppleColorEmoji" else {
            return
        }
        typingAttributes[fontAttribute] = _font
    }
}



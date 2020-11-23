//
//  CHQuotedMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/29/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class UIQuotedMessageCell: CHBaseMessageCell {
    
    var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.customSystemTeal
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        view.layer.borderColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor.cgColor : CHLightThemeColors.seperatorColor.cgColor
        view.layer.borderWidth = 0.5
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
    
    private var translatedTextContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var translatedTextContainerDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        view.layer.cornerRadius = 1.25
        view.layer.masksToBounds = true
        return view
    }()
    
    private var translatedTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
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
    
    var quotedItem: QuotedMessageItem?
    var longPressGesture: UILongPressGestureRecognizer!
    var cellTappedGesture: UITapGestureRecognizer!
    var containerViewTapGesture: UITapGestureRecognizer!
    var onLongPressQuotedView: ((_ chatItem: QuotedMessageItem?) -> Void)?
    var onCellTapped: ((_ cell: UIQuotedMessageCell) -> Void)?
    var onContainerViewTapped: ((_ parentMessageId: String) -> Void)?
    var onReactionButtonPressed: ((_ model: UIQuotedMessageCell?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(containerView)
        self.bubbleContainerView.addSubview(self.reactionsContainerView)
        self.bubbleContainerView.addSubview(self.reactionButton)
        self.bubbleContainerView.addSubview(self.messageStatusViewContainer)
        self.containerView.addSubview(quotedMessageView)
        self.containerView.addSubview(textView)
        
        self.containerView.addSubview(self.translatedTextContainerView)
        self.translatedTextContainerView.addSubview(self.translatedTextContainerDividerView)
        self.translatedTextContainerView.addSubview(self.translatedTextLabel)
        
        self.messageStatusViewContainer.addSubview(self.messageStatusView)
        self.messageStatusViewContainer.addSubview(self.messageTimeLabel)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(quotedViewLongPressed(gesture:)))
        self.textView.addGestureRecognizer(longPressGesture)
        
        cellTappedGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(gesture:)))
        self.addGestureRecognizer(cellTappedGesture)
        
        containerViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(onContainerViewTapped(tapGesture:)))
        self.quotedMessageView.addGestureRecognizer(containerViewTapGesture)
        
        self.reactionButton.addTarget(self, action: #selector(didTapOnReactionButton(sender:)), for: .touchUpInside)
        
    }
    
    @objc private func quotedViewLongPressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.onLongPressQuotedView?(self.quotedItem)
        }
    }
    
    @objc private func cellTapped(gesture: UITapGestureRecognizer) {
        self.onCellTapped?(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: ChannelizeChatItem) {
        super.assignChatItem(chatItem: chatItem)
        guard let quotedMessageItem = chatItem as? QuotedMessageItem else {
            return
        }
        self.quotedItem = quotedMessageItem
        
        if quotedMessageItem.messageStatus == .sending {
            self.cellTappedGesture.isEnabled = false
            self.longPressGesture.isEnabled = false
            self.reactionButton.isEnabled = false
            self.containerViewTapGesture.isEnabled = false
        } else {
            if quotedMessageItem.isMessageSelectorOn {
                self.cellTappedGesture.isEnabled = true
                self.longPressGesture.isEnabled = false
                self.reactionButton.isEnabled = false
                self.containerViewTapGesture.isEnabled = false
            } else {
                self.cellTappedGesture.isEnabled = false
                self.longPressGesture.isEnabled = true
                self.reactionButton.isEnabled = true
                self.containerViewTapGesture.isEnabled = true
            }
        }
        
        let textMessageAttributedString = quotedMessageItem.attributedString ?? NSAttributedString()
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 250, withText: textMessageAttributedString)
        let frameSize = frameSizeInfo.frameSize
        var containerWidth = frameSize.width + 26
        var containerHeight = frameSize.height + 24
            
        if containerWidth < 250 {
            containerWidth = 250
        }
        
        //containerHeight = containerHeight + (chatItem.reactions.count > 0 ? 15 : 0)
        var messageBubbleOriginX: CGFloat = 0
        if quotedMessageItem.isIncoming {
            messageBubbleOriginX = 15
        } else {
            messageBubbleOriginX = self.frame.width - containerWidth - 15
        }
        
        if quotedMessageItem.isTranslated == true {
            let labelHeight = getAttributedLabelHeight(attributedString: quotedMessageItem.translatedAttributedString ?? NSAttributedString(), maximumWidth: 250 - 27.5, numberOfLines: 0)
            containerHeight += labelHeight + 15 //(nonZeroCountReactions?.count ?? 0 > 0 ? 12 : 0)
            self.translatedTextContainerDividerView.isHidden = false
            self.translatedTextContainerView.isHidden = false
            self.translatedTextLabel.isHidden = false
        } else {
            self.translatedTextContainerDividerView.isHidden = true
            self.translatedTextContainerView.isHidden = true
            self.translatedTextLabel.isHidden = true
        }
        
        
        self.containerView.frame.size = CGSize(width: containerWidth, height: containerHeight + 48)
        self.containerView.frame.origin.y = 0
        self.containerView.frame.origin.x = messageBubbleOriginX
        
        self.messageStatusViewContainer.frame.size = CGSize(width: 80, height: 30)
        self.messageStatusViewContainer.frame.origin.y = getViewEndOriginY(view: self.containerView) - self.messageStatusViewContainer.frame.size.height - 2.5
        if quotedMessageItem.isIncoming {
            self.messageStatusViewContainer.frame.origin.x = getViewEndOriginX(view: self.containerView) + 5
        } else {
            self.messageStatusViewContainer.frame.origin.x = self.containerView.frame.origin.x - self.messageStatusViewContainer.frame.width - 5
        }
        
        self.messageStatusView.frame.size = CGSize(width: 15, height: 15)
        self.messageStatusView.frame.origin.y = 0
        self.messageStatusView.frame.origin.x = quotedMessageItem.isIncoming == true ? 0 : self.messageStatusViewContainer.frame.width - self.messageStatusView.frame.width
        
        self.messageTimeLabel.frame.size = CGSize(width: 80, height: 15)
        self.messageTimeLabel.frame.origin.x = 0
        self.messageTimeLabel.frame.origin.y = getViewEndOriginY(view: self.messageStatusView)
        
        
        self.reactionButton.frame.size = CGSize(width: 22, height: 22)
        self.reactionButton.frame.origin.x = getViewOriginXEnd(view: self.containerView) + 2.5
        self.reactionButton.frame.origin.y = self.containerView.frame.origin.y
        
        
        if quotedMessageItem.isIncoming {
            if CHCustomOptions.enableMessageReactions {
                self.reactionButton.isHidden = false
            } else {
                self.reactionButton.isHidden = true
            }
        } else {
            self.reactionButton.isHidden = true
        }
        
        self.quotedMessageView.frame.origin = CGPoint(x: 10, y: 2.5)
        self.quotedMessageView.frame.size = CGSize(width: self.containerView.frame.width - 20, height: 43)
        
        self.textView.frame.origin = CGPoint(x: 0, y: 45.5)
        self.textView.frame.size = CGSize(width: self.containerView.frame.width, height: frameSize.height + 24)
        
        self.translatedTextContainerView.frame.origin = CGPoint(x: 0, y: getViewOriginYEnd(view: self.textView))
        self.translatedTextContainerView.frame.size = CGSize(width: self.containerView.frame.width, height: self.containerView.frame.height - getViewOriginYEnd(view: self.textView))
        
        self.translatedTextContainerDividerView.frame.origin = CGPoint(x: 13, y: 0)
        self.translatedTextContainerDividerView.frame.size.width = 2.5
        
        self.translatedTextLabel.frame.origin = CGPoint(x: getViewOriginXEnd(view: self.translatedTextContainerDividerView) + 4.5, y: 0)
        self.translatedTextLabel.frame.size.width = self.translatedTextContainerView.frame.width - self.translatedTextLabel.frame.origin.x - 7.5
        self.translatedTextLabel.frame.size.height = self.translatedTextContainerView.frame.height - 18// - (nonZeroCountReactions?.count ?? 0 > 0 ? 12 : 0)
        self.translatedTextContainerDividerView.frame.size.height = self.translatedTextLabel.frame.height
        
        
        let reactionViewHeight = super.calculateReactionViewHeight(chatItem: chatItem)
        let reactionViewWidth: CGFloat = 280
        
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = messageBubbleOriginX
        self.reactionsContainerView.frame.origin.y = getViewOriginYEnd(view: self.containerView) - 15
        
        self.reactionsContainerView.assignReactions(reactions: quotedMessageItem.reactions)
        
        //self.reactionsContainerView.assignReactions(reactions: super.createReactionModels(chatItem: chatItem))
        
        
        self.quotedMessageView.quotedViewModel = quotedMessageItem.quotedMessageData?.quotedMessageModel
        
        self.containerView.backgroundColor = quotedMessageItem.isIncoming ? CHUIConstant.incomingTextMessageBackGroundColor : CHUIConstant.outGoingTextMessageBackGroundColor
        
        self.quotedMessageView.backgroundColor = .clear
        
        self.textView.attributedText = quotedMessageItem.attributedString
        self.translatedTextLabel.attributedText = NSAttributedString(string: quotedMessageItem.translatedString ?? "", attributes: [NSAttributedString.Key.foregroundColor: quotedMessageItem.isIncoming == true ? CHUIConstant.incomingTextMessageColor : CHUIConstant.outGoingTextMessageColor, NSAttributedString.Key.font: CHCustomStyles.textMessageFont! ])
        
        
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
        
        self.translatedTextContainerDividerView.backgroundColor = quotedMessageItem.isIncoming ? (CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor) : UIColor.white
        
    }
    
    @objc func onContainerViewTapped(tapGesture: UITapGestureRecognizer) {
        self.onContainerViewTapped?(self.quotedItem?.parentMessage?.id ?? "")
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




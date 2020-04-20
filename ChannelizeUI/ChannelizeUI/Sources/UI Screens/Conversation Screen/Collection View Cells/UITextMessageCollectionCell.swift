//
//  UITextMessageCollectionCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/18/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class UITextMessageCollectionCell: UICollectionViewCell {
    
    var dateSeperatorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        return label
    }()
    
    var senderNameLabel: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        return label
    }()
    
    
    var bubbleContainerView: UIView = {
        let view = UIView()
        //view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.customSystemTeal
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        view.layer.borderColor = UIColor(hex: "#f1f1f1").cgColor
        view.layer.borderWidth = 1.0
        return view
    }()
    
    var outGoingMessageContainerView: UIView = {
        let view = UIView()
        //view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.customSystemTeal
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        view.layer.borderColor = UIColor(hex: "#f1f1f1").cgColor
        view.layer.borderWidth = 1.0
        return view
    }()
    
    var unSelectedCircleImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .gray
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chUnSelectedCircelcon")
        return imageView
    }()
    
    var selectedCirlceImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor.customSystemBlue
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chSelectedCircleIcon")
        return imageView
    }()
    
    private var textView: UITextView = {
        let textView = CHMessageTextView()
        UIView.performWithoutAnimation({ () -> Void in // fixes iOS 8 blinking when cell appears
            textView.backgroundColor = UIColor.clear
        })
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
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
    
    private var dateMessageLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 14.0)
        label.textAlignment = .right
        return label
    }()
    
    private var messageStatus: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        imageView.tintColor = .white
        return imageView
    }()

    var textMessageModel: TextMessageModel? {
        didSet {
            self.setUpViewsFrames()
        }
    }
    
    var bubbleTapGesture: UITapGestureRecognizer!
    var longPressTapGesture: UILongPressGestureRecognizer!
    var cellTapGesture: UITapGestureRecognizer!
    
    var onBubbleTapped: ((_ cell: UITextMessageCollectionCell) -> Void)?
    var onLongPressedBubble: ((_ cell: UITextMessageCollectionCell) -> Void)?
    var onCellTapped: ((_ cell: UITextMessageCollectionCell) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
        
        bubbleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnBubble(tapGesture:)))
        longPressTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressBubble(longPressGesture:)))
        cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectDeSelectCell(tapGesture:)))
        
        self.bubbleContainerView.addGestureRecognizer(longPressTapGesture)
        self.bubbleContainerView.addGestureRecognizer(bubbleTapGesture)
        self.addGestureRecognizer(cellTapGesture)
        self.cellTapGesture.isEnabled = false
        self.bubbleTapGesture.isEnabled = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(dateSeperatorLabel)
        self.addSubview(senderNameLabel)
        self.addSubview(bubbleContainerView)
        self.bubbleContainerView.addSubview(textView)
        self.bubbleContainerView.addSubview(dateMessageLabel)
        self.bubbleContainerView.addSubview(messageStatus)
        self.addSubview(unSelectedCircleImageView)
        self.addSubview(selectedCirlceImageView)
    }
    
    private func setUpViewsFrames() {
        guard let modelData = self.textMessageModel else {
            return
        }
        
        if modelData.isMessageSelectorOn {
            self.cellTapGesture.isEnabled = true
            self.bubbleTapGesture.isEnabled = false
            self.longPressTapGesture.isEnabled = false
            
            if modelData.isMessageSelected {
                self.selectedCirlceImageView.isHidden = false
                self.unSelectedCircleImageView.isHidden = true
            } else {
                self.selectedCirlceImageView.isHidden = true
                self.unSelectedCircleImageView.isHidden = false
            }
            
        } else {
            self.cellTapGesture.isEnabled = false
            self.bubbleTapGesture.isEnabled = true
            self.longPressTapGesture.isEnabled = true
        }
        
        // Selected and Unselected Circle Frames
        let selectedCircleOriginX: CGFloat = modelData.isMessageSelectorOn ? 15 : -30
        let unselectedCircleOririginX: CGFloat = modelData.isMessageSelectorOn ? 15 : -30
        let selectedCircleCenterY = self.frame.height/2
        let unselectedCircleCenterY = self.frame.height/2
        
        let selectedCircleWidthHeight: CGFloat = modelData.isMessageSelectorOn ? 30 : 0
        let unSelectedCircleWidthHeight: CGFloat = modelData.isMessageSelectorOn ? 30 : 0
        
        let textMessageAttributedString = modelData.attributedString ?? NSAttributedString()
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 280, withText: textMessageAttributedString)
        let frameSize = frameSizeInfo.frameSize
        var containerWidth = frameSize.width + 32
        let containerHeight = frameSize.height + 30
        if containerWidth < 80 {
            containerWidth = 80
        }
        
        let dateSeperatorHeight: CGFloat = modelData.showDataSeperator ? 30 : 0
        let dateSeperatorWidth = self.frame.width
        
        let senderNameHeight: CGFloat = modelData.showSenderName ? 25 : 0
        let senderNameWidth = self.frame.width - 40
        let bubbleContainerViewWidth = containerWidth
        let bubbleContainerViewHeight = self.frame.height - dateSeperatorHeight - senderNameHeight//containerHeight
        
        
        var messageBubbleOriginX: CGFloat = 0
        if modelData.isIncoming {
            messageBubbleOriginX = modelData.isMessageSelectorOn ? 60 : 15
        } else {
            messageBubbleOriginX = self.frame.width - bubbleContainerViewWidth - 15
        }
        
        let messageTime = modelData.messageDate
        self.dateMessageLabel.text = messageTime.toRelateTimeString()
        self.dateMessageLabel.sizeToFit()
        let messageTimeLabelWidth = self.dateMessageLabel.frame.width + 10
        let messageTimeLabelHeight = self.dateMessageLabel.frame.height + 10
        let messageStatusViewHeight: CGFloat = 15
        let messageStatusViewWidth = modelData.isIncoming ? 0 : messageStatusViewHeight
        
        self.dateSeperatorLabel.frame.origin = .zero
        self.dateSeperatorLabel.frame.size = CGSize(width: dateSeperatorWidth, height: dateSeperatorHeight)
        
        self.senderNameLabel.frame.size = CGSize(width: senderNameWidth, height: senderNameHeight)
        self.senderNameLabel.frame.origin.x = messageBubbleOriginX
        self.senderNameLabel.frame.origin.y = getViewOriginYEnd(view: self.dateSeperatorLabel)
        
        
        self.bubbleContainerView.frame.size = CGSize(width: bubbleContainerViewWidth, height: bubbleContainerViewHeight)
        self.bubbleContainerView.frame.origin.y = getViewOriginYEnd(view: self.senderNameLabel)
        self.bubbleContainerView.frame.origin.x = messageBubbleOriginX
        
        
        self.selectedCirlceImageView.frame.size = CGSize(width: selectedCircleWidthHeight, height: selectedCircleWidthHeight)
        self.selectedCirlceImageView.frame.origin.x = selectedCircleOriginX
        self.selectedCirlceImageView.center.y = bubbleContainerView.center.y//selectedCircleCenterY
        self.selectedCirlceImageView.layer.cornerRadius = selectedCircleWidthHeight/2
        
        
        self.unSelectedCircleImageView.frame.size = CGSize(width: unSelectedCircleWidthHeight, height: unSelectedCircleWidthHeight)
        self.unSelectedCircleImageView.frame.origin.x = unselectedCircleOririginX
        self.unSelectedCircleImageView.center.y = bubbleContainerView.center.y//unselectedCircleCenterY
        self.unSelectedCircleImageView.layer.cornerRadius = unSelectedCircleWidthHeight/2
        
        
        
        self.textView.frame.origin = .zero
        self.textView.frame.size = self.bubbleContainerView.frame.size
        
        self.messageStatus.frame.size = CGSize(width: messageStatusViewWidth, height: messageStatusViewHeight)
        self.messageStatus.frame.origin.x = self.bubbleContainerView.frame.width - 12.5 - messageStatusViewWidth
        self.messageStatus.frame.origin.y = self.bubbleContainerView.frame.height - 7.5 - messageStatusViewHeight
        
        self.dateMessageLabel.frame.size = CGSize(width: messageTimeLabelWidth, height: messageTimeLabelHeight)
        self.dateMessageLabel.center.y = self.messageStatus.center.y
        self.dateMessageLabel.frame.origin.x = self.messageStatus.frame.origin.x - messageTimeLabelWidth - 2.5
        
        
        self.assignData(textData: modelData)
    }
    
    private func assignData(textData: TextMessageModel) {
        self.bubbleContainerView.backgroundColor = textData.isIncoming ? CHUIConstants.incomingTextMessageBubbleColor : CHUIConstants.outGoingTextMessageBubbleColor
        
        self.textView.attributedText = textData.attributedString
        self.senderNameLabel.text = textData.senderName.capitalized
        self.dateSeperatorLabel.text = textData.messageDate.toRelativeDateString()
        
        self.dateMessageLabel.textColor = textData.isIncoming ? UIColor(hex: "#1c1c1c") : UIColor.white
        
        switch textData.messageStatus {
        case .sending:
            self.messageStatus.image = getImage("chSendingIcon")
            break
        case .sent:
            self.messageStatus.image = getImage("chSingleTickIcon")
            break
        case .seen:
            self.messageStatus.image = getImage("chDoubleTickIcon")
            break
        }
    }
    
    @objc func didTapOnBubble(tapGesture: UITapGestureRecognizer) {
        self.onBubbleTapped?(self)
    }
    
    @objc func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == .began {
            self.onLongPressedBubble?(self)
        }
    }
    
    @objc func didSelectDeSelectCell(tapGesture: UITapGestureRecognizer) {
        self.onCellTapped?(self)
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

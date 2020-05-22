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
    
    var reactionButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setImage(getImage("chReactionIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = UIColor(hex: "#c5c5c5")
        button.imageView?.layer.masksToBounds = true
        return button
    }()
    
    var quotedMessageModel: QuotedMessageModel?
    
    var onContainerViewTapped: ((_ parentMessageId: String) -> Void)?
    var onReactionButtonPressed: ((_ model: CHQuotedMessageCell?) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(containerView)
        self.bubbleContainerView.addSubview(self.reactionsContainerView)
        self.bubbleContainerView.addSubview(self.reactionButton)
        self.containerView.addSubview(quotedMessageView)
        self.containerView.addSubview(textView)
        
        self.quotedMessageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onContainerViewTapped(tapGesture:))))
        self.reactionButton.addTarget(self, action: #selector(didTapOnReactionButton(sender:)), for: .touchUpInside)
        
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
        var containerHeight = frameSize.height + 24
        if containerWidth < 280 {
            containerWidth = 280
        }
//        let nonZeroCountReactions = self.quotedMessageModel?.reactionCountsInfo.filter({
//            $0.value > 0
//        })
        
        //containerHeight = containerHeight + (nonZeroCountReactions?.count ?? 0 > 0 ? 15 : 0)
        containerHeight = containerHeight + (chatItem.reactions.count > 0 ? 15 : 0)
        var messageBubbleOriginX: CGFloat = 0
        if quotedMessageModel.isIncoming {
            messageBubbleOriginX = 15
        } else {
            messageBubbleOriginX = self.frame.width - containerWidth - 15
        }
        self.containerView.frame.size = CGSize(width: containerWidth, height: containerHeight + 67.5)
        self.containerView.frame.origin.y = 0
        self.containerView.frame.origin.x = messageBubbleOriginX
        
        self.reactionButton.frame.size = CGSize(width: 22, height: 22)
        self.reactionButton.frame.origin.x = getViewOriginXEnd(view: self.containerView) + 2.5
        self.reactionButton.frame.origin.y = self.containerView.frame.origin.y
        
        
        if quotedMessageModel.isIncoming {
            if CHCustomOptions.enableMessageReactions {
                self.reactionButton.isHidden = false
            } else {
                self.reactionButton.isHidden = true
            }
        } else {
            self.reactionButton.isHidden = true
        }
        
        self.quotedMessageView.frame.origin = CGPoint(x: 10, y: 7.5)
        self.quotedMessageView.frame.size = CGSize(width: self.containerView.frame.width - 20, height: 60)
        
        self.textView.frame.origin = CGPoint(x: 0, y: 67.5)
        self.textView.frame.size = CGSize(width: self.containerView.frame.width, height: frameSize.height + 24)
        
        let reactionViewHeight = super.calculateReactionViewHeight(chatItem: chatItem)
        let reactionViewWidth: CGFloat = 280
        
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = messageBubbleOriginX
        self.reactionsContainerView.frame.origin.y = getViewOriginYEnd(view: self.containerView) - 15
        
        self.reactionsContainerView.assignReactions(reactions: quotedMessageModel.reactions)
        
        //self.reactionsContainerView.assignReactions(reactions: super.createReactionModels(chatItem: chatItem))
        
        
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

class QuotedMessageContainerView: UIView {

    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        //view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        //view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.lightGray
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var senderNameLabel: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 18.0)
        label.textColor = UIColor.customSystemBlue
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()
    
    private var typeOfMessageLabel: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()
    
    var quotedViewModel: QuotedViewModel? {
        didSet {
            self.setUpViewsFrames()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(containerView)
        self.containerView.addSubview(dividerView)
        self.containerView.addSubview(imageView)
        self.containerView.addSubview(senderNameLabel)
        self.containerView.addSubview(typeOfMessageLabel)
    }
    
    private func setUpViewsFrames() {
        guard let quotedViewModel = self.quotedViewModel else {
            return
        }
        self.containerView.frame.origin = .zero
        self.containerView.frame.size = CGSize(width: self.frame.width, height: self.frame.height)
        
        self.dividerView.frame.origin.x = 0
        self.dividerView.frame.origin.y = 5
        self.dividerView.frame.size.width = 3.5
        self.dividerView.frame.size.height = self.containerView.frame.height - 10
        
        self.imageView.frame.origin.x = getViewOriginXEnd(view: self.dividerView) + 5
        
        if quotedViewModel.imageUrl == nil {
            self.imageView.frame.origin.y = 10
            if quotedViewModel.typeOfMessage == .text {
                self.imageView.frame.size = .zero
            } else {
                self.imageView.contentMode = .scaleAspectFit
                self.imageView.frame.size = CGSize(width: 40, height: 40)
            }
        } else {
            if quotedViewModel.typeOfMessage == .doc {
                self.imageView.frame.origin.y = 15
                self.imageView.frame.size = CGSize(width: 30, height: 30)
                self.imageView.contentMode = .scaleAspectFit
            } else {
                self.imageView.frame.origin.y = 10
                self.imageView.contentMode = .scaleAspectFill
                self.imageView.frame.size = CGSize(width: 40, height: 40)
            }
        }
        
        self.senderNameLabel.frame.origin.x = getViewOriginXEnd(view: self.imageView) + 5
        self.senderNameLabel.frame.origin.y = 10
        self.senderNameLabel.frame.size.height = 20
        self.senderNameLabel.frame.size.width = self.containerView.frame.width - self.senderNameLabel.frame.origin.x - 10
        
        self.typeOfMessageLabel.frame.origin.x = getViewOriginXEnd(view: self.imageView) + 5
        self.typeOfMessageLabel.frame.origin.y = getViewOriginYEnd(view: self.senderNameLabel)
        self.typeOfMessageLabel.frame.size.height = 20
        self.typeOfMessageLabel.frame.size.width = self.containerView.frame.width - self.typeOfMessageLabel.frame.origin.x - 10
        
        self.assignData(data: quotedViewModel)
    }
    
    private func assignData(data: QuotedViewModel) {
        self.senderNameLabel.text = data.senderId == Channelize.getCurrentUserId() ? "You" : data.senderName?.capitalized
        
        self.senderNameLabel.textColor = data.isIncoming ? UIColor(hex: "#3A3C4C") : .white
        
        if data.imageUrl == nil {
            if data.typeOfMessage == .text {
                self.typeOfMessageLabel.attributedText = data.textMessage
            } else {
                self.imageView.backgroundColor = .clear
                self.imageView.tintColor = data.isIncoming ? CHUIConstants.appDefaultColor : .white
                self.typeOfMessageLabel.textColor = data.isIncoming ? UIColor(hex: "#3A3C4C") : .white
                switch data.typeOfMessage {
                case .image:
                    self.typeOfMessageLabel.text = "Image"
                    self.imageView.image = getImage("chPhotoIcon")
                    break
                case .video:
                    self.typeOfMessageLabel.text = "Video"
                    self.imageView.image = getImage("chVideoCallIcon")
                    break
                case .location:
                    self.typeOfMessageLabel.text = "Location"
                    self.imageView.image = getImage("chLocationIcon")
                    break
                case .gifSticker:
                    self.typeOfMessageLabel.text = "GIF"
                    self.imageView.image = getImage("chGifIcon")
                    break
                case .audio:
                    self.typeOfMessageLabel.text = "Audio"
                    self.imageView.image = getImage("chAudioIcon")
                    break
                default:
                    break
                }
            }
        } else {
            if data.typeOfMessage == .doc {
                self.imageView.backgroundColor = .clear
                self.typeOfMessageLabel.attributedText = data.textMessage
                self.imageView.image = getImage(data.imageUrl ?? "")
                self.typeOfMessageLabel.attributedText = data.textMessage
            } else {
                self.imageView.backgroundColor = .lightGray
                let imageUrl = URL(string: data.imageUrl ?? "")
                self.imageView.sd_imageTransition = .fade
                self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.imageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.highPriority, .continueInBackground], completed: nil)
                
                self.typeOfMessageLabel.textColor = data.isIncoming ? UIColor(hex: "#3A3C4C") : .white
                switch data.typeOfMessage {
                case .image:
                    self.typeOfMessageLabel.text = "Image"
                    break
                case .video:
                    self.typeOfMessageLabel.text = "Video"
                    break
                case .location:
                    self.typeOfMessageLabel.text = "Location"
                    break
                case .gifSticker:
                    self.typeOfMessageLabel.text = "GIF"
                    break
                case .audio:
                    self.typeOfMessageLabel.text = "Audio"
                    break
                default:
                    break
                }
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


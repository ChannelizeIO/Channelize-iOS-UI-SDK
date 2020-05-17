//
//  BaseChatItemCollectionCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/27/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class BaseChatItemCollectionCell: UICollectionViewCell {
    
    var dateSeperatorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = CHCustomStyles.messageDateSeperatorColor
        label.textAlignment = .center
        label.font = CHCustomStyles.messadeDateSeparatorFont
        return label
    }()
    
    var senderNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor(hex: "#8a8a8a")
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        return label
    }()
    
    var unSelectedCircleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chUnSelectedCircelcon")
        return imageView
    }()
    
    var selectedCirlceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = CHUIConstants.appDefaultColor
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chSelectedCircleIcon")
        return imageView
    }()
    
    var bubbleContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        //view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        //view.layer.borderColor = UIColor(hex: "#f1f1f1").cgColor
        //view.layer.borderWidth = 1.0
        return view
    }()
    
    var messageStatusView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    var allMessageTimeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.customSystemPink
        return label
    }()
    
    private var messageTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.backgroundColor = .clear
        label.textColor = UIColor(hex: "#8a8a8a")
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: CHUIConstants.smallFontSize)
        return label
    }()
    
    var reactionsContainerView: ReactionView = {
        let view = ReactionView()
        //view.backgroundColor = .black
        return view
    }()
    
    private var messageStatusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        imageView.tintColor = UIColor(hex: "#8a8a8a")
        return imageView
    }()
    
    var bubbleTapGesture: UITapGestureRecognizer!
    var longPressTapGesture: UILongPressGestureRecognizer!
    var cellTapGesture: UITapGestureRecognizer!
    
    var onBubbleTapped: ((_ cell: BaseChatItemCollectionCell) -> Void)?
    var onLongPressedBubble: ((_ cell: BaseChatItemCollectionCell) -> Void)?
    var onCellTapped: ((_ cell: BaseChatItemCollectionCell) -> Void)?
    
    
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
    
    @objc func didTapOnBubble(tapGesture: UITapGestureRecognizer) {
        
    }
    
    @objc func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
    }
    
    @objc func didSelectDeSelectCell(tapGesture: UITapGestureRecognizer) {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.contentView.addSubview(dateSeperatorLabel)
        self.contentView.addSubview(senderNameLabel)
        self.contentView.addSubview(bubbleContainerView)
        //self.contentView.addSubview(reactionsContainerView)
        self.contentView.addSubview(messageStatusView)
        self.contentView.addSubview(allMessageTimeLabel)
        self.contentView.addSubview(selectedCirlceImageView)
        self.contentView.addSubview(unSelectedCircleImageView)
        self.messageStatusView.addSubview(messageTimeLabel)
        self.messageStatusView.addSubview(messageStatusImageView)
    }
    
    func assignChatItem(chatItem: BaseMessageItemProtocol) {
        
        if chatItem.isMessageSelectorOn {
            self.cellTapGesture.isEnabled = true
            self.bubbleTapGesture.isEnabled = false
            self.longPressTapGesture.isEnabled = false
            
            if chatItem.isMessageSelected {
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
        
        let selectedCircleOriginX: CGFloat = chatItem.isMessageSelectorOn ? 15 : -30
        let unselectedCircleOririginX: CGFloat = chatItem.isMessageSelectorOn ? 15 : -30
        
        let selectedCircleWidthHeight: CGFloat = chatItem.isMessageSelectorOn ? 30 : 0
        let unSelectedCircleWidthHeight: CGFloat = chatItem.isMessageSelectorOn ? 30 : 0
        
        
        let dateSeperatorHeight: CGFloat = chatItem.showDataSeperator ? 30 : 0
        let dateSeperatorWidth: CGFloat = self.frame.width
        
        let senderNameHeight: CGFloat = chatItem.showSenderName ? 25 : 0
        let senderNameWidth: CGFloat = self.frame.width - 30
        
        let messageStatusViewHeight: CGFloat = chatItem.showMessageStatusView ? 25 : 0
        let messageStatusViewWidth = self.frame.width
        
        let reactionViewHeigth: CGFloat = 0
        
        let bubbleContainerHeight = self.frame.height - dateSeperatorHeight - senderNameHeight - messageStatusViewHeight - reactionViewHeigth
        let bubbleContainerWidth = self.frame.width
        
        let senderNameOriginX: CGFloat = chatItem.isMessageSelectorOn && chatItem.isIncoming ? 60 : 15
        let messageBubbleOriginX: CGFloat = chatItem.isMessageSelectorOn && chatItem.isIncoming ? 60 : 0
        
        self.dateSeperatorLabel.frame.origin = CGPoint(x: 0, y: 0)
        self.dateSeperatorLabel.frame.size = CGSize(width: dateSeperatorWidth, height: dateSeperatorHeight)
        
        self.senderNameLabel.frame.origin = CGPoint(x: senderNameOriginX, y: getViewOriginYEnd(view: self.dateSeperatorLabel))
        self.senderNameLabel.frame.size = CGSize(width: senderNameWidth, height: senderNameHeight)
        
        self.bubbleContainerView.frame.origin = CGPoint(x: messageBubbleOriginX, y: getViewOriginYEnd(view: self.senderNameLabel))
        self.bubbleContainerView.frame.size = CGSize(width: bubbleContainerWidth, height: bubbleContainerHeight)
        
//        self.reactionsContainerView.frame.origin = CGPoint(x: messageBubbleOriginX + 15, y: getViewOriginYEnd(view: self.bubbleContainerView) - 15)
//        self.reactionsContainerView.frame.size = CGSize(width: CHCustomStyles.photoBubbleSize.width, height: reactionViewHeigth)
        
        self.messageStatusView.frame.origin = CGPoint(x: 0, y: getViewOriginYEnd(view: self.bubbleContainerView))
        self.messageStatusView.frame.size = CGSize(width: messageStatusViewWidth, height: messageStatusViewHeight)
        
        self.allMessageTimeLabel.frame.size = CGSize(width: 100, height: 30)
        self.allMessageTimeLabel.frame.origin.x = self.contentView.frame.width + 5
        self.allMessageTimeLabel.center.y = self.contentView.frame.height/2
        
        
        self.selectedCirlceImageView.frame.size = CGSize(width: selectedCircleWidthHeight, height: selectedCircleWidthHeight)
        self.selectedCirlceImageView.frame.origin.x = selectedCircleOriginX
        self.selectedCirlceImageView.center.y = bubbleContainerView.center.y//selectedCircleCenterY
        self.selectedCirlceImageView.layer.cornerRadius = selectedCircleWidthHeight/2
        
        
        self.unSelectedCircleImageView.frame.size = CGSize(width: unSelectedCircleWidthHeight, height: unSelectedCircleWidthHeight)
        self.unSelectedCircleImageView.frame.origin.x = unselectedCircleOririginX
        self.unSelectedCircleImageView.center.y = bubbleContainerView.center.y//unselectedCircleCenterY
        self.unSelectedCircleImageView.layer.cornerRadius = unSelectedCircleWidthHeight/2
        
        /// ASSIGN Data
        self.dateSeperatorLabel.text = chatItem.messageDate.toRelativeDateString()
        self.senderNameLabel.text = chatItem.senderName.capitalized
        
        let messageTime = chatItem.messageDate
        self.messageTimeLabel.text = messageTime.toRelateTimeString()
        self.messageTimeLabel.sizeToFit()
        let messageTimeLabelWidth = self.messageTimeLabel.frame.width
        let messageTimeLabelHeight = self.messageTimeLabel.frame.height
        
        let statusViewHeight: CGFloat = 20
        let statusViewWidth = chatItem.isIncoming ? 0 : statusViewHeight
        
        if chatItem.isIncoming {
            self.messageTimeLabel.frame.origin.x = 15
            self.messageTimeLabel.center.y = self.messageStatusView.frame.height/2
            self.messageTimeLabel.frame.size = CGSize(width: messageTimeLabelWidth, height: messageTimeLabelHeight)
            self.messageStatusImageView.frame = .zero
            self.messageStatusImageView.isHidden = true
            self.messageTimeLabel.textAlignment = .left
        } else {
            self.messageStatusImageView.isHidden = false
            self.messageStatusImageView.frame.size = CGSize(width: statusViewWidth, height: statusViewHeight)
            self.messageStatusImageView.frame.origin.x = self.messageStatusView.frame.width - statusViewWidth - 15
            self.messageStatusImageView.center.y = self.messageStatusView.frame.height/2
            self.messageTimeLabel.textAlignment = .right
            self.messageTimeLabel.frame.size = CGSize(width: messageTimeLabelWidth, height: messageTimeLabelHeight)
            self.messageTimeLabel.frame.origin.x = self.messageStatusImageView.frame.origin.x - messageTimeLabelWidth - 2.5
            self.messageTimeLabel.center.y = self.messageStatusView.frame.height/2
            
        }
        
        if chatItem.showMessageStatusView {
            self.messageStatusView.isHidden = false
        } else {
            self.messageStatusView.isHidden = true
        }
        //self.reactionsContainerView.assignReactions(reactions: self.createReactionModels(chatItem: chatItem))
        
        switch chatItem.messageStatus {
        case .sending:
            self.messageStatusImageView.tintColor = UIColor(hex: "#8a8a8a")
            self.messageStatusImageView.image = getImage("chSendingIcon")
            break
        case .sent:
            self.messageStatusImageView.tintColor = UIColor(hex: "#8a8a8a")
            self.messageStatusImageView.image = getImage("chSingleTickIcon")
            break
        case .seen:
            self.messageStatusImageView.tintColor = CHUIConstants.appDefaultColor
            self.messageStatusImageView.image = getImage("chDoubleTickIcon")
            break
        }
    }
    
    func createReactionModels(chatItem: BaseMessageItemProtocol) -> [ReactionModel] {
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
        return reactionsModels
    }
    
    func calculateReactionViewHeight(chatItem: BaseMessageItemProtocol) -> CGFloat{
        let reactionsModels = chatItem.reactions
        
//        var reactionsModels = [ReactionModel]()
//        let reactionCountInfo = chatItem.reactionCountsInfo.sorted(by: { $0.value > $1.value })
//        reactionCountInfo.forEach({
//            let model = ReactionModel()
//            model.counts = $0.value
//            model.unicode = emojiCodes[$0.key]
//            if model.counts ?? 0 > 0 {
//                reactionsModels.append(model)
//            }
//        })
        
        guard reactionsModels.count > 0 else {
            return 0
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
            if initialOriginX + currentItemWidth < getReactionViewMaxWidth(chatItemType: chatItem.messageType) - 5 {
                initialOriginX = initialOriginX + currentItemWidth + 5
            } else {
                initialOriginY += 32.5
                initialOriginX = 5 + currentItemWidth + 2.5
            }
        })
        return initialOriginY + 30 + 2.5
    }
    
    private func getReactionViewMaxWidth(chatItemType: BaseMessageType) -> CGFloat {
        switch chatItemType {
        case .image:
            return CHCustomStyles.photoBubbleSize.width
        case .gifSticker:
            return CHCustomStyles.gifStickerMessageSize.width
        case .video:
            return CHCustomStyles.videoMessageSize.width
        case .audio:
            return CHCustomStyles.audioMessageSize.width
        case .location:
            return 280
        case .quotedMessage:
            return 280
        default:
            return 0
        }
    }
    
}

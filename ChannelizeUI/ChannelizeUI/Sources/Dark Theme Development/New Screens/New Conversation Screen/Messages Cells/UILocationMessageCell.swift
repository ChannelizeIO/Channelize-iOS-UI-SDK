//
//  CHLocationMessageCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/3/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage
import MapKit

class UILocationMessageCell: CHBaseMessageCell {
    
    private var locationContainerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        return view
    }()
    
    private var locationImageView: UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor(hex: "#fafafa")
        return view
    }()
    
    private var locationNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .left
        return label
    }()
    
    private var locationAddressLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.numberOfLines = 2
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
        label.font = UIFont(fontStyle: .regular, size: 11.0)
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
    
    var locationMessageModel: LocationMessageItem?
    var longPressGesture: UILongPressGestureRecognizer!
    var cellTappedGesture: UITapGestureRecognizer!
    var locationBubbleTappedGesture: UITapGestureRecognizer!
    var onLongPressLocationBubble: ((_ chatItem: LocationMessageItem?) -> Void)?
    var onReactionButtonPressed: ((_ cell: UILocationMessageCell) -> Void)?
    var onCellTapped: ((_ cell: UILocationMessageCell) -> Void)?
    var onLocationBubbleTapped: ((_ chatItem: LocationMessageItem?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(locationContainerView)
        self.bubbleContainerView.addSubview(self.reactionsContainerView)
        self.bubbleContainerView.addSubview(self.reactionButton)
        self.bubbleContainerView.addSubview(self.messageStatusViewContainer)
        self.locationContainerView.addSubview(locationImageView)
        self.locationContainerView.addSubview(locationNameLabel)
        self.locationContainerView.addSubview(locationAddressLabel)
        self.messageStatusViewContainer.addSubview(self.messageStatusView)
        self.messageStatusViewContainer.addSubview(self.messageTimeLabel)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(locationBubbleLongPressed(gesture:)))
        self.locationContainerView.addGestureRecognizer(longPressGesture)
        
        cellTappedGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(gesture:)))
        self.addGestureRecognizer(cellTappedGesture)
        
        locationBubbleTappedGesture = UITapGestureRecognizer(target: self, action: #selector(locationBubbleTapped(gesture:)))
        self.locationContainerView.addGestureRecognizer(locationBubbleTappedGesture)
        
        self.reactionButton.addTarget(self, action: #selector(reactionButtonPressed(sender:)), for: .touchUpInside)
    }
    
    @objc private func locationBubbleLongPressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.onLongPressLocationBubble?(self.locationMessageModel)
        }
    }
       
    @objc private func cellTapped(gesture: UITapGestureRecognizer) {
        self.onCellTapped?(self)
    }
   
    @objc private func reactionButtonPressed(sender: UIButton) {
        self.onReactionButtonPressed?(self)
    }
   
    @objc private func locationBubbleTapped(gesture: UITapGestureRecognizer) {
        self.onLocationBubbleTapped?(self.locationMessageModel)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func assignChatItem(chatItem: ChannelizeChatItem) {
        super.assignChatItem(chatItem: chatItem)
        guard let locationMessageModel = chatItem as? LocationMessageItem else {
            return
        }
        self.locationMessageModel = locationMessageModel
        
        if locationMessageModel.messageStatus == .sending {
            self.cellTappedGesture.isEnabled = false
            self.locationBubbleTappedGesture.isEnabled = false
            self.longPressGesture.isEnabled = false
            self.reactionButton.isEnabled = false
        } else {
            if locationMessageModel.isMessageSelectorOn {
                self.cellTappedGesture.isEnabled = true
                self.longPressGesture.isEnabled = false
                self.locationBubbleTappedGesture.isEnabled = false
                self.reactionButton.isEnabled = false
            } else {
                self.cellTappedGesture.isEnabled = false
                self.longPressGesture.isEnabled = true
                self.locationBubbleTappedGesture.isEnabled = true
                self.reactionButton.isEnabled = true
            }
        }
        
        let locationImageViewSize = CHCustomStyles.locationMessageBubbleImageSize
        let locationNameLabelHeight: CGFloat = locationMessageModel.locationData?.locationName == nil || locationMessageModel.locationData?.locationName == "" ? 0 : 22.5
        
        let attributedAddress = locationMessageModel.locationData?.locationAddressAttributedString ?? NSAttributedString()
        let height = getAttributedLabelHeight(attributedString: attributedAddress, maximumWidth: CHCustomStyles.locationMessageBubbleImageSize.width - 10, numberOfLines: 2)
        
        let locationAddressHeight: CGFloat = height == 0 ? 0 : height
        
        let locationContainerHeight = locationImageViewSize.height + locationNameLabelHeight + locationAddressHeight + 10 + (chatItem.reactions.count > 0 ? 15 : 0)
        
        self.locationContainerView.frame.size = CGSize(width: CHCustomStyles.locationMessageBubbleImageSize.width, height: locationContainerHeight)
        self.locationContainerView.frame.origin.y = .zero
        self.locationContainerView.frame.origin.x = chatItem.isIncoming ? 15 : self.bubbleContainerView.frame.width - self.locationContainerView.frame.width - 15
        
        self.locationImageView.frame.size = locationImageViewSize
        self.locationImageView.frame.origin = .zero
        
        self.locationNameLabel.frame.size = CGSize(width: self.locationContainerView.frame.width - 10, height: locationNameLabelHeight)
        self.locationNameLabel.frame.origin.x = 5
        self.locationNameLabel.frame.origin.y = getViewEndOriginY(view: self.locationImageView)
        
        self.locationAddressLabel.frame.size = CGSize(width: self.locationContainerView.frame.width - 10, height: locationAddressHeight)
        self.locationAddressLabel.frame.origin.x = 5
        self.locationAddressLabel.frame.origin.y = getViewEndOriginY(view: self.locationNameLabel) + 5
        
        if chatItem.isIncoming {
            self.reactionButton.isHidden = false
            self.reactionButton.frame.size = CGSize(width: 22, height: 22)
            self.reactionButton.frame.origin.x = getViewEndOriginX(view: self.locationContainerView) + 2.5
            self.reactionButton.frame.origin.y = self.locationContainerView.frame.origin.y + 2.5
        } else {
            self.reactionButton.isHidden = true
            self.reactionButton.frame = .zero
        }
        
        self.messageStatusViewContainer.frame.size = CGSize(width: 80, height: 35)
        self.messageStatusViewContainer.frame.origin.y = getViewEndOriginY(view: self.locationContainerView) - self.messageStatusViewContainer.frame.size.height - 2.5
        if locationMessageModel.isIncoming {
            self.messageStatusViewContainer.frame.origin.x = getViewEndOriginX(view: self.locationContainerView) + 5
        } else {
            self.messageStatusViewContainer.frame.origin.x = self.locationContainerView.frame.origin.x - self.messageStatusViewContainer.frame.width - 5
        }
        
        self.messageStatusView.frame.size = CGSize(width: 20, height: 20)
        self.messageStatusView.frame.origin.y = 0
        self.messageStatusView.frame.origin.x = locationMessageModel.isIncoming == true ? 0 : self.messageStatusViewContainer.frame.width - self.messageStatusView.frame.width
        
        self.messageTimeLabel.frame.size = CGSize(width: 80, height: 15)
        self.messageTimeLabel.frame.origin.x = 0
        self.messageTimeLabel.frame.origin.y = getViewEndOriginY(view: self.messageStatusView)
        
        if chatItem.isIncoming {
            self.messageStatusView.isHidden = true
            self.messageTimeLabel.textAlignment = .left
        } else {
            self.messageStatusView.isHidden = false
            self.messageTimeLabel.textAlignment = .right
        }
        
        let reactionViewHeight = super.calculateReactionViewHeight(chatItem: chatItem)
        let reactionViewWidth: CGFloat = CHCustomStyles.locationMessageBubbleImageSize.width
        
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = self.locationContainerView.frame.origin.x
        self.reactionsContainerView.frame.origin.y = getViewEndOriginY(view: self.locationContainerView) - 15
        
        self.locationContainerView.backgroundColor = locationMessageModel.isIncoming ? CHUIConstant.incomingTextMessageBackGroundColor : CHUIConstant.outGoingTextMessageBackGroundColor
        
        self.locationNameLabel.attributedText = locationMessageModel.locationData?.locationNameAttributedString
        self.locationAddressLabel.attributedText = locationMessageModel.locationData?.locationAddressAttributedString
        
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
        
        if chatItem.isIncoming {
            self.messageStatusView.isHidden = true
            self.messageTimeLabel.textAlignment = .left
        } else {
            self.messageStatusView.isHidden = false
            self.messageTimeLabel.textAlignment = .right
        }
        
        if chatItem.showMessageStatusView {
            self.messageStatusViewContainer.isHidden = false
        } else {
            self.messageStatusViewContainer.isHidden = true
        }
        
        
        self.reactionsContainerView.assignReactions(reactions: locationMessageModel.reactions)
        let locationCoordinateString = "\(locationMessageModel.locationData?.locationLatitude ?? 0.0),\(locationMessageModel.locationData?.locationLongitude ?? 0.0)"
        let imageScale = UIScreen.main.scale
        let imageUrlString = "https://maps.googleapis.com/maps/api/staticmap?key=\(ChUI.instance.getMapKey())&center=\(locationCoordinateString)&zoom=14&size=400x400&scale=\(imageScale)&format=png"
        if let imageUrl = URL(string: imageUrlString) {
            self.locationImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.continueInBackground], completed: nil)
        }
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


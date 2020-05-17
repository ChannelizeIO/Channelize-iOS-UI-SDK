//
//  CHLocationMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

class CHLocationMessageCell: BaseChatItemCollectionCell {
    
    private var messageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
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
    
    var locationMessageModel: LocationMessageModel?
    var onReactionButtonPressed: ((_ model: CHLocationMessageCell?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(locationContainerView)
        self.bubbleContainerView.addSubview(self.reactionsContainerView)
        self.bubbleContainerView.addSubview(self.reactionButton)
        self.locationContainerView.addSubview(locationImageView)
        self.locationContainerView.addSubview(locationNameLabel)
        self.locationContainerView.addSubview(locationAddressLabel)
        self.reactionButton.addTarget(self, action: #selector(didTapOnReactionButton(sender:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: BaseMessageItemProtocol) {
        super.assignChatItem(chatItem: chatItem)
        guard let locationMessageModel = chatItem as? LocationMessageModel else {
            return
        }
        self.locationMessageModel = locationMessageModel
        
        let locationImageViewSize = CGSize(width: 280, height: 160)
        let locationNameLabelHeight: CGFloat = locationMessageModel.locationName == nil || locationMessageModel.locationName == "" ? 0 : 22.5
        
        let attributedAddress = locationMessageModel.locationAddressAttributedString ?? NSAttributedString()
        let height = getAttributedLabelHeight(attributedString: attributedAddress, maximumWidth: 265, numberOfLines: 2)
        
        let locationAddressHeight: CGFloat = height == 0 ? 0 : height
        
        
//        let nonZeroCountReactions = self.locationMessageModel?.reactionCountsInfo.filter({
//            $0.value > 0
//        })
        //let locationContainerHeight = locationImageViewSize.height + locationNameLabelHeight + locationAddressHeight + 10 + (nonZeroCountReactions?.count ?? 0 > 0 ? 15 : 0)
        
        let locationContainerHeight = locationImageViewSize.height + locationNameLabelHeight + locationAddressHeight + 10 + (chatItem.reactions.count > 0 ? 15 : 0)
        
        self.locationContainerView.frame.size = CGSize(width: 280, height: locationContainerHeight)
        self.locationContainerView.frame.origin.y = .zero
        self.locationContainerView.frame.origin.x = chatItem.isIncoming ? 15 : self.bubbleContainerView.frame.width - self.locationContainerView.frame.width - 15
        
        self.locationImageView.frame.size = locationImageViewSize
        self.locationImageView.frame.origin = .zero
        
        self.locationNameLabel.frame.size = CGSize(width: self.locationContainerView.frame.width - 15, height: locationNameLabelHeight)
        self.locationNameLabel.frame.origin.x = 7.5
        self.locationNameLabel.frame.origin.y = getViewOriginYEnd(view: self.locationImageView)
        
        self.locationAddressLabel.frame.size = CGSize(width: self.locationContainerView.frame.width - 15, height: locationAddressHeight)
        self.locationAddressLabel.frame.origin.x = 7.5
        self.locationAddressLabel.frame.origin.y = getViewOriginYEnd(view: self.locationNameLabel) + 5
        
        self.reactionButton.frame.size = CGSize(width: 22, height: 22)
        self.reactionButton.frame.origin.x = getViewOriginXEnd(view: self.locationContainerView) + 2.5
        self.reactionButton.frame.origin.y = self.locationContainerView.frame.origin.y
        
        if locationMessageModel.isIncoming {
            if CHCustomOptions.enableMessageReactions {
                self.reactionButton.isHidden = false
            } else {
                self.reactionButton.isHidden = true
            }
        } else {
            self.reactionButton.isHidden = true
        }
        
        let reactionViewHeight = super.calculateReactionViewHeight(chatItem: chatItem)
        let reactionViewWidth: CGFloat = 280
        
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = self.locationContainerView.frame.origin.x
        self.reactionsContainerView.frame.origin.y = getViewOriginYEnd(view: self.locationContainerView) - 15
        
        self.locationContainerView.backgroundColor = locationMessageModel.isIncoming ? CHUIConstants.incomingTextMessageBackgroundColor : CHUIConstants.outgoingTextMessageBackgroundColor
        
        self.locationNameLabel.attributedText = locationMessageModel.locationNameAttributedString
        self.locationAddressLabel.attributedText = locationMessageModel.locationAddressAttributedString
        
        self.reactionsContainerView.assignReactions(reactions: locationMessageModel.reactions)
        
        //self.reactionsContainerView.assignReactions(reactions: super.createReactionModels(chatItem: chatItem))
        
        if let image = SDImageCache.shared.imageFromCache(forKey: locationMessageModel.messageId) {
            self.locationImageView.image = image
        } else {
            let mapSnapshotOptions = MKMapSnapshotter.Options()
            let location = CLLocationCoordinate2DMake(locationMessageModel.locationLatitude ?? 0.0, locationMessageModel.locationLongitude ?? 0.0)
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapSnapshotOptions.mapType = .standard
            mapSnapshotOptions.region = region
            mapSnapshotOptions.scale = UIScreen.main.scale
            mapSnapshotOptions.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            mapSnapshotOptions.showsBuildings = true
            mapSnapshotOptions.showsPointsOfInterest = true
            let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
            snapShotter.start(completionHandler: {(snapShot,error) in
                if let image = snapShot?.image {
                    self.locationImageView.image = image
                    SDImageCache.shared.store(image, forKey: locationMessageModel.messageId, completion: nil)
                }
            })
        }
    }
    
    @objc private func didTapOnReactionButton(sender: UIButton) {
        self.onReactionButtonPressed?(self)
    }
    
    override func didTapOnBubble(tapGesture: UITapGestureRecognizer) {
        guard self.locationMessageModel?.messageStatus != .sending else {
            return
        }
        self.onBubbleTapped?(self)
    }
    
    override func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
        guard self.locationMessageModel?.messageStatus != .sending else {
            return
        }
        if longPressGesture.state == .began {
            self.onLongPressedBubble?(self)
        }
    }
    
    override func didSelectDeSelectCell(tapGesture: UITapGestureRecognizer) {
        guard self.locationMessageModel?.messageStatus != .sending else {
            return
        }
        self.onCellTapped?(self)
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

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
    
    var locationMessageModel: LocationMessageModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(locationContainerView)
        self.locationContainerView.addSubview(locationImageView)
        self.locationContainerView.addSubview(locationNameLabel)
        self.locationContainerView.addSubview(locationAddressLabel)
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
        self.locationContainerView.frame.size = CGSize(width: 280, height: self.bubbleContainerView.frame.height)
        self.locationContainerView.center.y = self.bubbleContainerView.frame.height/2
        self.locationContainerView.frame.origin.x = chatItem.isIncoming ? 15 : self.bubbleContainerView.frame.width - self.locationContainerView.frame.width - 15
        
        let locationImageViewSize = CGSize(width: self.locationContainerView.frame.width, height: 160)
        let locationNameLabelHeight: CGFloat = locationMessageModel.locationName == nil || locationMessageModel.locationName == "" ? 0 : 22.5
        
        let attributedAddress = locationMessageModel.locationAddressAttributedString ?? NSAttributedString()
        let height = getAttributedLabelHeight(attributedString: attributedAddress, maximumWidth: 265, numberOfLines: 2)
        
        let locationAddressHeight: CGFloat = height == 0 ? 0 : height + 10
        
        self.locationImageView.frame.size = locationImageViewSize
        self.locationImageView.frame.origin = .zero
        
        self.locationNameLabel.frame.size = CGSize(width: self.locationContainerView.frame.width - 15, height: locationNameLabelHeight)
        self.locationNameLabel.frame.origin.x = 7.5
        self.locationNameLabel.frame.origin.y = getViewOriginYEnd(view: self.locationImageView)
        
        self.locationAddressLabel.frame.size = CGSize(width: self.locationContainerView.frame.width - 15, height: locationAddressHeight)
        self.locationAddressLabel.frame.origin.x = 7.5
        self.locationAddressLabel.frame.origin.y = getViewOriginYEnd(view: self.locationNameLabel)
        
        self.locationContainerView.backgroundColor = locationMessageModel.isIncoming ? CHUIConstants.incomingTextMessageBackgroundColor : CHUIConstants.outgoingTextMessageBackgroundColor
        
        self.locationNameLabel.attributedText = locationMessageModel.locationNameAttributedString
        self.locationAddressLabel.attributedText = locationMessageModel.locationAddressAttributedString
        
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
    
}

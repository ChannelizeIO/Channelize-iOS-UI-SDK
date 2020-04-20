//
//  LocationMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

class UILocationMessageCell: UICollectionViewCell {
    
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
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
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
        imageView.tintColor = UIColor.customSystemBlue
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chSelectedCircleIcon")
        return imageView
    }()
    
    var bubbleContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.customSystemTeal
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        view.layer.borderColor = UIColor(hex: "#f1f1f1").cgColor
        view.layer.borderWidth = 1.0
        return view
    }()
    
    private var locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 0
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var locationAddressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var messageStatusContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    private var messageTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.backgroundColor = .clear
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabMedium, size: 13.0)
        return label
    }()
    
    private var messageStatusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        return imageView
    }()
    
    var locationMessageModel: LocationMessageModel? {
        didSet {
            self.setUpViewsFrames()
        }
    }
    
    var bubbleTapGesture: UITapGestureRecognizer!
    var longPressTapGesture: UILongPressGestureRecognizer!
    var cellTapGesture: UITapGestureRecognizer!
    
    var onBubbleTapped: ((_ cell: UILocationMessageCell) -> Void)?
    var onLongPressedBubble: ((_ cell: UILocationMessageCell) -> Void)?
    var onCellTapped: ((_ cell: UILocationMessageCell) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
        
        bubbleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnBubble(tapGesture:)))
        longPressTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressBubble(longPressGesture:)))
        cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectDeSelectCell(tapGesture:)))
        
        self.bubbleContainerView.addGestureRecognizer(
        longPressTapGesture)
        self.bubbleContainerView.addGestureRecognizer(bubbleTapGesture)
        self.addGestureRecognizer(cellTapGesture)
        self.cellTapGesture.isEnabled = false
        self.bubbleTapGesture.isEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(dateSeperatorLabel)
        self.addSubview(senderNameLabel)
        self.addSubview(selectedCirlceImageView)
        self.addSubview(unSelectedCircleImageView)
        self.addSubview(bubbleContainerView)
        self.bubbleContainerView.addSubview(locationImageView)
        self.bubbleContainerView.addSubview(locationLabel)
        self.bubbleContainerView.addSubview(
            locationAddressLabel)
        self.bubbleContainerView.addSubview(
            messageStatusContainerView)
        self.messageStatusContainerView.addSubview(messageTimeLabel)
        self.messageStatusContainerView.addSubview(
            messageStatusImageView)
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
    
    private func setUpViewsFrames() {
        guard let modelData = self.locationMessageModel else {
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
        
        let selectedCircleOriginX: CGFloat = modelData.isMessageSelectorOn ? 15 : -30
        let unselectedCircleOririginX: CGFloat = modelData.isMessageSelectorOn ? 15 : -30
        
        let selectedCircleWidthHeight: CGFloat = modelData.isMessageSelectorOn ? 30 : 0
        let unSelectedCircleWidthHeight: CGFloat = modelData.isMessageSelectorOn ? 30 : 0
        
        let dateSeperatorHeight: CGFloat = modelData.showDataSeperator ? 30 : 0
        let dateSeperatorWidth = self.frame.width
        
        let senderNameHeight: CGFloat = modelData.showSenderName ? 25 : 0
        let senderNameWidth = self.frame.width - 40
        
        let bubbleContainerWidth: CGFloat = 280
        let bubbleContainerHeight = self.frame.height - dateSeperatorHeight - senderNameHeight
        
        var messageBubbleOriginX: CGFloat = 0
        if modelData.isIncoming {
            messageBubbleOriginX = modelData.isMessageSelectorOn ? 60 : 15
        } else {
            messageBubbleOriginX = self.frame.width - bubbleContainerWidth - 15
        }
        
        self.dateSeperatorLabel.frame.origin = .zero
        self.dateSeperatorLabel.frame.size = CGSize(width: dateSeperatorWidth, height: dateSeperatorHeight)
        
        self.senderNameLabel.frame.size = CGSize(width: senderNameWidth, height: senderNameHeight)
        self.senderNameLabel.frame.origin.x = messageBubbleOriginX
        self.senderNameLabel.frame.origin.y = getViewOriginYEnd(view: self.dateSeperatorLabel)
        
        self.bubbleContainerView.frame.size = CGSize(width: bubbleContainerWidth, height: bubbleContainerHeight)
        self.bubbleContainerView.frame.origin.y = getViewOriginYEnd(view: self.senderNameLabel)
        self.bubbleContainerView.frame.origin.x = messageBubbleOriginX
        self.locationImageView.setLeftAnchor(relatedConstraint: self.bubbleContainerView.leftAnchor, constant: 0)
        self.locationImageView.setRightAnchor(relatedConstraint: self.bubbleContainerView.rightAnchor, constant: 0)
        self.locationImageView.setTopAnchor(relatedConstraint: self.bubbleContainerView.topAnchor, constant: 0)
        self.locationImageView.setHeightAnchor(constant: 150)
        
        self.locationLabel.setLeftAnchor(relatedConstraint: self.bubbleContainerView.leftAnchor, constant: 10)
        self.locationLabel.setRightAnchor(relatedConstraint: self.bubbleContainerView.rightAnchor, constant: -10)
        self.locationLabel.setTopAnchor(relatedConstraint: self.locationImageView.bottomAnchor, constant: 0)
        if modelData.locationName != nil && modelData.locationName != ""{
            self.locationLabel.setHeightAnchor(constant: 25)
        } else {
            self.locationLabel.setHeightAnchor(constant: 0)
        }
        
        self.locationAddressLabel.setLeftAnchor(
            relatedConstraint: self.bubbleContainerView.leftAnchor, constant: 10)
        self.locationAddressLabel.setRightAnchor(relatedConstraint: self.bubbleContainerView.rightAnchor, constant: -10)
        self.locationAddressLabel.setTopAnchor(relatedConstraint: self.locationLabel.bottomAnchor, constant: 0)
        self.locationAddressLabel.setBottomAnchor(relatedConstraint: self.bubbleContainerView.bottomAnchor, constant: 0)
        if modelData.isIncoming {
            self.bubbleContainerView.backgroundColor = UIColor(hex: "#f5fcf5")
        } else {
            self.bubbleContainerView.backgroundColor = CHUIConstants.appDefaultColor
        }
        
        self.selectedCirlceImageView.frame.size = CGSize(width: selectedCircleWidthHeight, height: selectedCircleWidthHeight)
        self.selectedCirlceImageView.frame.origin.x = selectedCircleOriginX
        self.selectedCirlceImageView.center.y = bubbleContainerView.center.y//selectedCircleCenterY
        self.selectedCirlceImageView.layer.cornerRadius = selectedCircleWidthHeight/2
        
        
        self.unSelectedCircleImageView.frame.size = CGSize(width: unSelectedCircleWidthHeight, height: unSelectedCircleWidthHeight)
        self.unSelectedCircleImageView.frame.origin.x = unselectedCircleOririginX
        self.unSelectedCircleImageView.center.y = bubbleContainerView.center.y//unselectedCircleCenterY
        self.unSelectedCircleImageView.layer.cornerRadius = unSelectedCircleWidthHeight/2
        
        let messageTime = modelData.messageDate
        self.messageTimeLabel.text = messageTime.toRelateTimeString()
        self.messageTimeLabel.sizeToFit()
        let messageTimeLabelWidth = self.messageTimeLabel.frame.width
        let messageTimeLabelHeight = self.messageTimeLabel.frame.height
        let messageStatusViewHeight: CGFloat = 15
        let messageStatusViewWidth = modelData.isIncoming ? 0 : messageStatusViewHeight
        
        let messageStatusContainerViewWidth = messageTimeLabelWidth + messageStatusViewWidth + 20
        let messageStatusContainerViewHeight = messageTimeLabelHeight + 5
        
        self.messageStatusContainerView.frame.size = CGSize(width: messageStatusContainerViewWidth, height: messageStatusContainerViewHeight)
        self.messageStatusContainerView.frame.origin.x = self.bubbleContainerView.frame.width - messageStatusContainerViewWidth - 10
        self.messageStatusContainerView.frame.origin.y = self.bubbleContainerView.frame.height - messageStatusContainerViewHeight - 10
        self.messageStatusContainerView.layer.cornerRadius = messageStatusContainerViewHeight/2
        self.messageStatusContainerView.layer.masksToBounds = true
        
        self.messageStatusImageView.frame.origin.x = self.messageStatusContainerView.frame.width - messageStatusViewWidth - 5
        self.messageStatusImageView.frame.size = CGSize(width: messageStatusViewWidth, height: messageStatusViewHeight)
        self.messageStatusImageView.center.y = self.messageStatusContainerView.frame.height/2
        
        self.messageTimeLabel.frame.origin.x = 10
        self.messageTimeLabel.frame.size = CGSize(width: messageTimeLabelWidth, height: messageTimeLabelHeight)
        self.messageTimeLabel.center.y = self.messageStatusContainerView.frame.height/2
        
        switch modelData.messageStatus {
        case .sending:
            self.messageStatusImageView.image = getImage("chSendingIcon")
            break
        case .sent:
            self.messageStatusImageView.image = getImage("chSingleTickIcon")
            break
        case .seen:
            self.messageStatusImageView.image = getImage("chDoubleTickIcon")
            break
        }
        
        self.messageTimeLabel.text = modelData.messageDate.toRelateTimeString()
        self.assignData(data: modelData)
    }
    
    private func assignData(data: LocationMessageModel) {
        self.locationImageView.image = nil
        self.dateSeperatorLabel.text = data.messageDate.toRelativeDateString()
        self.senderNameLabel.text = data.senderName.capitalized
        
        self.locationLabel.attributedText = data.locationNameAttributedString
        self.locationAddressLabel.attributedText = data.locationAddressAttributedString
        
        if let image = SDImageCache.shared.imageFromCache(forKey: data.messageId) {
            self.locationImageView.image = image
        } else {
            let mapSnapshotOptions = MKMapSnapshotter.Options()
            let location = CLLocationCoordinate2DMake(data.locationLatitude ?? 0.0, data.locationLongitude ?? 0.0)
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
                    SDImageCache.shared.store(image, forKey: data.messageId, completion: nil)
                }
            })
        }
    }
}


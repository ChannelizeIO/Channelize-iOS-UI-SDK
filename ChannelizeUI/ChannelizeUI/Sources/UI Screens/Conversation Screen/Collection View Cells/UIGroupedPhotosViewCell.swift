//
//  GroupedImageCollectionCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/15/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class UIGroupedImageCollectionCell: UICollectionViewCell {
    
    var dateSeperatorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont(fontStyle: .sourceSansProRegular, size: 16.0)
        return label
    }()
    
    var senderNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.font = UIFont(fontStyle: .sourceSansProRegular, size: 16.0)
        return label
    }()
    
    private var imageContainerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.lightGray//UIColor(hex: "#1c1c1c")
        //view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var firstImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var secondImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var thirdImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var fourthImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var overlayView: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(fontStyle: .sourceSansProSemiBold, size: 30.0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        return button
    }()
    
    var bubbleTapGesture: UITapGestureRecognizer!
    var longPressTapGesture: UILongPressGestureRecognizer!
    
    var onBubbleTapped: ((_ cell: UIGroupedImageCollectionCell) -> Void)?
    var onLongPressedBubble: ((_ cell: UIGroupedImageCollectionCell) -> Void)?
    
    var groupedImagesModel: GroupedImagesModel? {
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
        
        bubbleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnBubble(tapGesture:)))
        longPressTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(
            didLongPressBubble(longPressGesture:)))
        
        self.imageContainerView.addGestureRecognizer(
            longPressTapGesture)
        self.imageContainerView.addGestureRecognizer(
            bubbleTapGesture)
        
        self.addSubview(dateSeperatorLabel)
        self.addSubview(senderNameLabel)
        self.addSubview(imageContainerView)
        self.imageContainerView.addSubview(firstImageView)
        self.imageContainerView.addSubview(secondImageView)
        self.imageContainerView.addSubview(thirdImageView)
        self.imageContainerView.addSubview(fourthImageView)
        self.imageContainerView.addSubview(overlayView)
        
        overlayView.isEnabled = false
        
    }
    
    @objc func didTapOnBubble(tapGesture: UITapGestureRecognizer) {
        self.onBubbleTapped?(self)
    }
    
    @objc func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == .began {
            self.onLongPressedBubble?(self)
        }
    }
    
    private func setUpViewsFrames() {
        guard let modelData = self.groupedImagesModel else {
            return
        }
        guard let images = modelData.imagesModel as? [ImageMessageModel] else {
            return
        }
        let dateSeperatorHeight: CGFloat = modelData.showDataSeperator ? 30 : 0
        let senderNameLabelHeight: CGFloat = modelData.showSenderName ? 25 : 0
        
        self.dateSeperatorLabel.frame.size = CGSize(width: self.frame.width, height: dateSeperatorHeight)
        self.dateSeperatorLabel.frame.origin = .zero
        
        self.senderNameLabel.frame.origin.x = 15
        self.senderNameLabel.frame.origin.y = getViewOriginYEnd(view: self.dateSeperatorLabel)
        senderNameLabel.frame.size = CGSize(width: self.frame.width - 30, height: senderNameLabelHeight)
        
        let containerViewHeight = self.frame.height - self.dateSeperatorLabel.frame.height - self.senderNameLabel.frame.height
        self.imageContainerView.frame.size = CGSize(width: 270, height: containerViewHeight)
        self.imageContainerView.frame.origin.y = getViewOriginYEnd(view: self.senderNameLabel)
        
        
        if modelData.isIncoming {
            self.imageContainerView.frame.origin.x = 15
        } else {
            self.imageContainerView.frame.origin.x = self.frame.width - 270 - 15
        }
        
        switch images.count {
        case 1:
            self.firstImageView.frame.origin = CGPoint(x: 2.5, y: 2.5)
            self.firstImageView.frame.size.width = self.imageContainerView.frame.width - 5
            self.firstImageView.frame.size.height = self.imageContainerView.frame.height - 5
            
            self.firstImageView.isHidden = false
            self.secondImageView.isHidden = true
            self.thirdImageView.isHidden = true
            self.fourthImageView.isHidden = true
            self.overlayView.isHidden = true
            break
        case 2:
            
            self.firstImageView.frame.origin = CGPoint(x: 2.5, y: 2.5)
            self.firstImageView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.firstImageView.frame.size.height = self.imageContainerView.frame.height - 5
            
            self.secondImageView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 2.5, y: 2.5)
            self.secondImageView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.secondImageView.frame.size.height = self.imageContainerView.frame.height - 5
            
            self.firstImageView.isHidden = false
            self.secondImageView.isHidden = false
            self.thirdImageView.isHidden = true
            self.fourthImageView.isHidden = true
            self.overlayView.isHidden = true
            break
        case 3:
            
            self.firstImageView.frame.origin = CGPoint(x: 2.5, y: 2.5)
            self.firstImageView.frame.size.width = self.imageContainerView.frame.width - 5
            self.firstImageView.frame.size.height = 170
            
            self.secondImageView.frame.origin = CGPoint(x: 2.5, y: 175)
            self.secondImageView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.secondImageView.frame.size.height = self.imageContainerView.frame.height - 175 - 2.5
            
            self.thirdImageView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 2.5, y: 175)
            self.thirdImageView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.thirdImageView.frame.size.height = self.imageContainerView.frame.height - 175 - 2.5
            
            self.firstImageView.isHidden = false
            self.secondImageView.isHidden = false
            self.thirdImageView.isHidden = false
            self.fourthImageView.isHidden = true
            self.overlayView.isHidden = true
            break
        case 4:
            
            self.firstImageView.frame.origin = CGPoint(x: 2.5, y: 2.5)
            self.firstImageView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.firstImageView.frame.size.height = self.imageContainerView.frame.height/2 - 5
            
            self.secondImageView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 2.5, y: 2.5)
            self.secondImageView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.secondImageView.frame.size.height = self.imageContainerView.frame.height/2 - 5
            
            self.thirdImageView.frame.origin = CGPoint(x: 2.5, y: self.imageContainerView.frame.height/2 + 2.5)
            self.thirdImageView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.thirdImageView.frame.size.height = self.imageContainerView.frame.height/2 - 5
            
            self.fourthImageView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 2.5, y: self.imageContainerView.frame.height/2 + 2.5)
            self.fourthImageView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.fourthImageView.frame.size.height = self.imageContainerView.frame.height/2 - 5
            
            self.firstImageView.isHidden = false
            self.secondImageView.isHidden = false
            self.thirdImageView.isHidden = false
            self.fourthImageView.isHidden = false
            self.overlayView.isHidden = true
            break
        default:
            
            self.firstImageView.frame.origin = CGPoint(x: 2.5, y: 2.5)
            self.firstImageView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.firstImageView.frame.size.height = self.imageContainerView.frame.height/2 - 5
            
            self.secondImageView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 2.5, y: 2.5)
            self.secondImageView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.secondImageView.frame.size.height = self.imageContainerView.frame.height/2 - 5
            
            self.thirdImageView.frame.origin = CGPoint(x: 2.5, y: self.imageContainerView.frame.height/2 + 2.5)
            self.thirdImageView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.thirdImageView.frame.size.height = self.imageContainerView.frame.height/2 - 5
            
            self.fourthImageView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 2.5, y: self.imageContainerView.frame.height/2 + 2.5)
            self.fourthImageView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.fourthImageView.frame.size.height = self.imageContainerView.frame.height/2 - 5
            
            self.overlayView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 2.5, y: self.imageContainerView.frame.height/2 + 2.5)
            self.overlayView.frame.size.width = self.imageContainerView.frame.width/2 - 5
            self.overlayView.frame.size.height = self.imageContainerView.frame.height/2 - 5
            
            self.firstImageView.isHidden = false
            self.secondImageView.isHidden = false
            self.thirdImageView.isHidden = false
            self.fourthImageView.isHidden = false
            self.overlayView.isHidden = false
            break
        }
        self.assignImageData(data: modelData)
    }
    
    private func assignImageData(data: GroupedImagesModel) {
        
        self.imageContainerView.backgroundColor = data.isIncoming ? CHUIConstants.incomingTextMessageBackgroundColor : CHUIConstants.outgoingTextMessageBackgroundColor
        
        self.dateSeperatorLabel.text = data.messageDate.toRelativeDateString()
        self.senderNameLabel.text = data.senderName.capitalized
        
        self.overlayView.setTitle("+\(data.imagesModel.count - 4)", for: .normal)
        
        var firstImageUrlString: String?
        var secondImageUrlString: String?
        var thirdImageUrlString: String?
        var fourthImageUrlString: String?
        
        switch data.imagesModel.count {
        case 1:
            firstImageUrlString = (data.imagesModel[0] as? ImageMessageModel)?.imageUrl
        case 2:
            firstImageUrlString = (data.imagesModel[0] as? ImageMessageModel)?.imageUrl
            secondImageUrlString = (data.imagesModel[1] as? ImageMessageModel)?.imageUrl
            break
        case 3:
            firstImageUrlString = (data.imagesModel[0] as? ImageMessageModel)?.imageUrl
            secondImageUrlString = (data.imagesModel[1] as? ImageMessageModel)?.imageUrl
            thirdImageUrlString = (data.imagesModel[2] as? ImageMessageModel)?.imageUrl
            break
        case 4:
            firstImageUrlString = (data.imagesModel[0] as? ImageMessageModel)?.imageUrl
            secondImageUrlString = (data.imagesModel[1] as? ImageMessageModel)?.imageUrl
            thirdImageUrlString = (data.imagesModel[2] as? ImageMessageModel)?.imageUrl
            fourthImageUrlString = (data.imagesModel[3] as? ImageMessageModel)?.imageUrl
            break
        case let x where x > 4:
            firstImageUrlString = (data.imagesModel[0] as? ImageMessageModel)?.imageUrl
            secondImageUrlString = (data.imagesModel[1] as? ImageMessageModel)?.imageUrl
            thirdImageUrlString = (data.imagesModel[2] as? ImageMessageModel)?.imageUrl
            fourthImageUrlString = (data.imagesModel[3] as? ImageMessageModel)?.imageUrl
            break
        default:
            break
        }
        if let firstImageUrl = firstImageUrlString {
            self.firstImageView.sd_imageTransition = .fade
            self.firstImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.firstImageView.sd_setImage(with: URL(string: firstImageUrl), completed: nil)
        }
        if let secondImageUrl = secondImageUrlString {
            self.secondImageView.sd_imageTransition = .fade
            self.secondImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            
            self.secondImageView.sd_setImage(with: URL(string: secondImageUrl), completed: nil)
            
        }
        if let thirdImageUrl = thirdImageUrlString {
            self.thirdImageView.sd_imageTransition = .fade
            self.thirdImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.thirdImageView.sd_setImage(with: URL(string: thirdImageUrl), completed: nil)
            
        }
        if let fourthImageUrl = fourthImageUrlString {
            self.fourthImageView.sd_imageTransition = .fade
            self.fourthImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.fourthImageView.sd_setImage(with: URL(string: fourthImageUrl), completed: nil)
        }
        
    }
}


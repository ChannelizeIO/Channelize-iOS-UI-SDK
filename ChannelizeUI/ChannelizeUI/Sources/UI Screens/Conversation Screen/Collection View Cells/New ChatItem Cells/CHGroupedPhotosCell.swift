//
//  CHGroupedPhotosCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/29/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class CHGroupedPhotosCell: BaseChatItemCollectionCell {
    
    private var imageContainerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor.lightGray
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
    
    var groupedImagesModel: GroupedImagesModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(imageContainerView)
        self.imageContainerView.addSubview(firstImageView)
        self.imageContainerView.addSubview(secondImageView)
        self.imageContainerView.addSubview(thirdImageView)
        self.imageContainerView.addSubview(fourthImageView)
        self.imageContainerView.addSubview(overlayView)
        self.overlayView.isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: BaseMessageItemProtocol) {
        super.assignChatItem(chatItem: chatItem)
        guard let groupedImageModel = chatItem as? GroupedImagesModel else {
            return
        }
        self.groupedImagesModel = groupedImageModel
        let containerWidth: CGFloat = 280
        let containerHeight = self.bubbleContainerView.frame.height
        
        self.imageContainerView.frame.size = CGSize(width: containerWidth, height: containerHeight)
        self.imageContainerView.center.y = self.bubbleContainerView.frame.height/2
        if groupedImageModel.isIncoming {
            self.imageContainerView.frame.origin.x = 15
        } else {
            self.imageContainerView.frame.origin.x = self.frame.width - containerWidth - 15
        }
        
        switch groupedImageModel.imagesModel.count {
        case 1:
            self.firstImageView.frame.origin = CGPoint(x: 0, y: 0)
            self.firstImageView.frame.size.width = self.imageContainerView.frame.width
            self.firstImageView.frame.size.height = self.imageContainerView.frame.height
            
            self.firstImageView.isHidden = false
            self.secondImageView.isHidden = true
            self.thirdImageView.isHidden = true
            self.fourthImageView.isHidden = true
            self.overlayView.isHidden = true
            break
        case 2:
            
            self.firstImageView.frame.origin = CGPoint(x: 0, y: 0)
            self.firstImageView.frame.size.width = self.imageContainerView.frame.width/2 - 2.5
            self.firstImageView.frame.size.height = self.imageContainerView.frame.height
            
            self.secondImageView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 2.5, y: 0)
            self.secondImageView.frame.size.width = self.imageContainerView.frame.width/2 - 2.5
            self.secondImageView.frame.size.height = self.imageContainerView.frame.height
            
            self.firstImageView.isHidden = false
            self.secondImageView.isHidden = false
            self.thirdImageView.isHidden = true
            self.fourthImageView.isHidden = true
            self.overlayView.isHidden = true
            break
        case 3:
            
            self.firstImageView.frame.origin = CGPoint(x: 0, y: 0)
            self.firstImageView.frame.size.width = self.imageContainerView.frame.width
            self.firstImageView.frame.size.height = 170
            
            self.secondImageView.frame.origin = CGPoint(x: 0, y: 172.5)
            self.secondImageView.frame.size.width = self.imageContainerView.frame.width/2 - 1.25
            self.secondImageView.frame.size.height = self.imageContainerView.frame.height - 172.5
            
            self.thirdImageView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 2.5, y: 172.5)
            self.thirdImageView.frame.size.width = self.imageContainerView.frame.width/2 - 1.25
            self.thirdImageView.frame.size.height = self.imageContainerView.frame.height - 172.5
            
            self.firstImageView.isHidden = false
            self.secondImageView.isHidden = false
            self.thirdImageView.isHidden = false
            self.fourthImageView.isHidden = true
            self.overlayView.isHidden = true
            break
        case 4:
            
            self.firstImageView.frame.origin = CGPoint(x: 2.5, y: 2.5)
            self.firstImageView.frame.size.width = self.imageContainerView.frame.width/2 - 3.75
            self.firstImageView.frame.size.height = self.imageContainerView.frame.height/2 - 3.75
            
            self.secondImageView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 1.25, y: 2.5)
            self.secondImageView.frame.size.width = self.imageContainerView.frame.width/2 - 3.75
            self.secondImageView.frame.size.height = self.imageContainerView.frame.height/2 - 3.75
            
            self.thirdImageView.frame.origin = CGPoint(x: 2.5, y: self.imageContainerView.frame.height/2 + 1.25)
            self.thirdImageView.frame.size.width = self.imageContainerView.frame.width/2 - 3.75
            self.thirdImageView.frame.size.height = self.imageContainerView.frame.height/2 - 3.75
            
            self.fourthImageView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 1.25, y: self.imageContainerView.frame.height/2 + 1.25)
            self.fourthImageView.frame.size.width = self.imageContainerView.frame.width/2 - 3.75
            self.fourthImageView.frame.size.height = self.imageContainerView.frame.height/2 - 3.75
            
            self.firstImageView.isHidden = false
            self.secondImageView.isHidden = false
            self.thirdImageView.isHidden = false
            self.fourthImageView.isHidden = false
            self.overlayView.isHidden = true
            break
        default:
            
            self.firstImageView.frame.origin = CGPoint(x: 2.5, y: 2.5)
            self.firstImageView.frame.size.width = self.imageContainerView.frame.width/2 - 3.75
            self.firstImageView.frame.size.height = self.imageContainerView.frame.height/2 - 3.75
            
            self.secondImageView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 1.25, y: 2.5)
            self.secondImageView.frame.size.width = self.imageContainerView.frame.width/2 - 3.75
            self.secondImageView.frame.size.height = self.imageContainerView.frame.height/2 - 3.75
            
            self.thirdImageView.frame.origin = CGPoint(x: 2.5, y: self.imageContainerView.frame.height/2 + 1.25)
            self.thirdImageView.frame.size.width = self.imageContainerView.frame.width/2 - 3.75
            self.thirdImageView.frame.size.height = self.imageContainerView.frame.height/2 - 3.75
            
            self.fourthImageView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 1.25, y: self.imageContainerView.frame.height/2 + 1.25)
            self.fourthImageView.frame.size.width = self.imageContainerView.frame.width/2 - 3.75
            self.fourthImageView.frame.size.height = self.imageContainerView.frame.height/2 - 3.75
            
            self.overlayView.frame = self.fourthImageView.frame
            
//            self.overlayView.frame.origin = CGPoint(x: self.imageContainerView.frame.width/2 + 2.5, y: self.imageContainerView.frame.height/2 + 2.5)
//            self.overlayView.frame.size.width = self.imageContainerView.frame.width/2 - 5
//            self.overlayView.frame.size.height = self.imageContainerView.frame.height/2 - 5
            
            self.firstImageView.isHidden = false
            self.secondImageView.isHidden = false
            self.thirdImageView.isHidden = false
            self.fourthImageView.isHidden = false
            self.overlayView.isHidden = false
            break
        }
        
        self.imageContainerView.backgroundColor = groupedImageModel.isIncoming ? CHUIConstants.incomingTextMessageBackgroundColor : CHUIConstants.outgoingTextMessageBackgroundColor.lighter(by: 10)
        self.overlayView.setTitle("+\(groupedImageModel.imagesModel.count - 4)", for: .normal)
        
        var firstImageUrlString: String?
        var secondImageUrlString: String?
        var thirdImageUrlString: String?
        var fourthImageUrlString: String?
        
        switch groupedImageModel.imagesModel.count {
        case 1:
            firstImageUrlString = (groupedImageModel.imagesModel[0] as? ImageMessageModel)?.imageUrl
        case 2:
            firstImageUrlString = (groupedImageModel.imagesModel[0] as? ImageMessageModel)?.imageUrl
            secondImageUrlString = (groupedImageModel.imagesModel[1] as? ImageMessageModel)?.imageUrl
            break
        case 3:
            firstImageUrlString = (groupedImageModel.imagesModel[0] as? ImageMessageModel)?.imageUrl
            secondImageUrlString = (groupedImageModel.imagesModel[1] as? ImageMessageModel)?.imageUrl
            thirdImageUrlString = (groupedImageModel.imagesModel[2] as? ImageMessageModel)?.imageUrl
            break
        case 4:
            firstImageUrlString = (groupedImageModel.imagesModel[0] as? ImageMessageModel)?.imageUrl
            secondImageUrlString = (groupedImageModel.imagesModel[1] as? ImageMessageModel)?.imageUrl
            thirdImageUrlString = (groupedImageModel.imagesModel[2] as? ImageMessageModel)?.imageUrl
            fourthImageUrlString = (groupedImageModel.imagesModel[3] as? ImageMessageModel)?.imageUrl
            break
        case let x where x > 4:
            firstImageUrlString = (groupedImageModel.imagesModel[0] as? ImageMessageModel)?.imageUrl
            secondImageUrlString = (groupedImageModel.imagesModel[1] as? ImageMessageModel)?.imageUrl
            thirdImageUrlString = (groupedImageModel.imagesModel[2] as? ImageMessageModel)?.imageUrl
            fourthImageUrlString = (groupedImageModel.imagesModel[3] as? ImageMessageModel)?.imageUrl
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
    
    @objc override func didTapOnBubble(tapGesture: UITapGestureRecognizer) {
        self.onBubbleTapped?(self)
    }
    
    @objc override func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == .began {
            self.onLongPressedBubble?(self)
        }
    }
    
    @objc override func didSelectDeSelectCell(tapGesture: UITapGestureRecognizer) {
        self.onCellTapped?(self)
    }
}

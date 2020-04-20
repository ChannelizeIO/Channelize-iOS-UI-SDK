//
//  UIImageMessageCollectionCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/19/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage
import MaterialComponents.MaterialProgressView

class UIImageMessageCollectionCell: UICollectionViewCell {
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
        imageView.tintColor = CHUIConstants.appDefaultColor
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
    
    var gradientView: EZYGradientView = {
        let gradientView = EZYGradientView()
        gradientView.firstColor = UIColor.clear
        gradientView.secondColor = UIColor.black.withAlphaComponent(0.15)
        gradientView.angleº = 35
        gradientView.colorRatio = 0.20
        gradientView.fadeIntensity = 1.0
        gradientView.isBlur = false
        gradientView.blurOpacity = 0.5
        gradientView.layer.masksToBounds = true
        gradientView.layer.cornerRadius = 75
        return gradientView
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 7.5
        imageView.backgroundColor = .white
        imageView.isUserInteractionEnabled = false
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var messageStatusContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    private var messageTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .white
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoBold, size: CHUIConstants.smallFontSize)
        return label
    }()
    
    private var messageStatusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        return imageView
    }()
    
    private var progressView: MDCActivityIndicator = {
        let progressView = MDCActivityIndicator()
        //progressView.progress = 0
        progressView.radius = 25
        //progressView.indicatorMode = .determinate
        progressView.cycleColors = [CHUIConstants.appDefaultColor]
        progressView.strokeWidth = 5.0
        progressView.startAnimating()
        return progressView
    }()
    
    var imageMessageModel: ImageMessageModel? {
        didSet {
            self.setUpViewsFrames()
        }
    }
    
    var bubbleTapGesture: UITapGestureRecognizer!
    var longPressTapGesture: UILongPressGestureRecognizer!
    var cellTapGesture: UITapGestureRecognizer!
    
    var onBubbleTapped: ((_ cell: UIImageMessageCollectionCell) -> Void)?
    var onLongPressedBubble: ((_ cell: UIImageMessageCollectionCell) -> Void)?
    var onCellTapped: ((_ cell: UIImageMessageCollectionCell) -> Void)?
    
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(dateSeperatorLabel)
        self.addSubview(senderNameLabel)
        self.addSubview(bubbleContainerView)
        self.addSubview(unSelectedCircleImageView)
        self.addSubview(selectedCirlceImageView)
        self.bubbleContainerView.addSubview(imageView)
        self.bubbleContainerView.addSubview(gradientView)
        self.bubbleContainerView.addSubview(progressView)
        
        self.bubbleContainerView.addSubview(
            messageStatusContainerView)
        self.messageStatusContainerView.addSubview(messageTimeLabel)
        self.messageStatusContainerView.addSubview(
            messageStatusImageView)
        
        
        
    }
    
    private func setUpViewsFrames() {
        guard let modelData = self.imageMessageModel else {
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
        
        self.imageView.frame.origin = CGPoint(x: 5, y: 5)
        self.imageView.frame.size = CGSize(width: self.bubbleContainerView.frame.width - 10, height: self.bubbleContainerView.frame.height - 10)
        
        
        //gradientView.frame.origin = CGPoint(x: 5, y: 5)
        gradientView.frame.size = CGSize(width: 150, height: 150)
        gradientView.center = CGPoint(x: self.bubbleContainerView.frame.width, y: self.bubbleContainerView.frame.height)
        //self.gradientView.frame.size = CGSize(width: self.bubbleContainerView.frame.width - 10, height: self.bubbleContainerView.frame.height - 10)
        self.progressView.frame.size = CGSize(width: 150, height: 150)
        self.progressView.center = CGPoint(x: self.bubbleContainerView.frame.width/2, y: self.bubbleContainerView.frame.height/2)
//        self.progressView.frame.origin = CGPoint(x: 5, y: self.bubbleContainerView.frame.height - 35)
//        self.progressView.frame.size = CGSize(width: self.bubbleContainerView.frame.width - 10, height: 5)
        
        
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
        let messageStatusViewHeight: CGFloat = 20
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
        
        self.assignData(imageData: modelData)
        
    }
    
    private func assignData(imageData: ImageMessageModel) {
        
        if imageData.messageStatus == .sending {
            self.progressView.isHidden = false
        } else {
            self.progressView.isHidden = true
        }
        
        self.bubbleContainerView.backgroundColor = imageData.isIncoming ? UIColor(hex: "#f5f5f5") : CHUIConstants.appDefaultColor
        
        self.dateSeperatorLabel.text = imageData.messageDate.toRelativeDateString()
        self.senderNameLabel.text = imageData.senderName.capitalized
        
        if imageData.messageSource == .local {
            self.imageView.image = imageData.localImage
        } else {
            
            self.imageView.image = imageData.localImage
            if let imageUrlString = imageData.imageUrl {
                self.imageView.sd_imageTransition = imageData.localImage == nil ? .fade : .none
                self.imageView.sd_imageIndicator = imageData.localImage == nil ? SDWebImageActivityIndicator.gray : .none
                let imageUrl = URL(string: imageUrlString)
                self.imageView.sd_setImage(with: imageUrl, placeholderImage: imageData.localImage, options: [.refreshCached,.continueInBackground], completed: {(image,error,cache,url) in
                    if let _image = image {
                        imageData.localImage = nil
                    }
                })
            }
        }
    }
    
    func updateProgress(fromValue: Double, toValue: Double) {
        if toValue != 1.0 {
            progressView.setIndicatorMode(.determinate, animated: true)
            progressView.progress = Float(toValue)
            progressView.startAnimating()
            
        } else {
            self.progressView.stopAnimating()
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


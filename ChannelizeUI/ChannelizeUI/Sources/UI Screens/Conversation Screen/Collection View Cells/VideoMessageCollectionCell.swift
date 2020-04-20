//
//  VideoMessageCollectionCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage
import MaterialComponents.MaterialProgressView

class UIVideoMessageCollectionCell: UICollectionViewCell {
    
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
        view.backgroundColor = CHUIConstants.appDefaultColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        view.layer.borderColor = UIColor(hex: "#f1f1f1").cgColor
        view.layer.borderWidth = 1.0
        return view
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 0
        imageView.backgroundColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        progressView.cycleColors = [CHUIConstants.appDefaultColor]
        progressView.strokeWidth = 5.0
        progressView.radius = 25
        progressView.startAnimating()
        return progressView
    }()
    
    private var videoPlayButtonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = getImage("chPlayButton")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.tintColor = CHUIConstants.appDefaultColor
        imageView.backgroundColor = .white
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var overlayView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var videoMessageModel: VideoMessageModel? {
        didSet {
            self.setUpViewsFrames()
        }
    }
    
    var bubbleTapGesture: UITapGestureRecognizer!
    var longPressTapGesture: UILongPressGestureRecognizer!
    var cellTapGesture: UITapGestureRecognizer!
    
    var onBubbleTapped: ((_ cell: UIVideoMessageCollectionCell) -> Void)?
    var onLongPressedBubble: ((_ cell: UIVideoMessageCollectionCell) -> Void)?
    var onCellTapped: ((_ cell: UIVideoMessageCollectionCell) -> Void)?
    
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
        self.addSubview(bubbleContainerView)
        self.addSubview(unSelectedCircleImageView)
        self.addSubview(selectedCirlceImageView)
        self.bubbleContainerView.addSubview(imageView)
        self.bubbleContainerView.addSubview(gradientView)
        self.bubbleContainerView.addSubview(progressView)
        self.bubbleContainerView.addSubview(videoPlayButtonImageView)
        
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
        guard let modelData = self.videoMessageModel else {
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
        
        gradientView.frame.size = CGSize(width: 150, height: 150)
        gradientView.center = CGPoint(x: self.bubbleContainerView.frame.width, y: self.bubbleContainerView.frame.height)
        
        self.progressView.frame.size = CGSize(width: 150, height: 150)
        self.progressView.center = CGPoint(x: self.bubbleContainerView.frame.width/2, y: self.bubbleContainerView.frame.height/2)
        
        self.videoPlayButtonImageView.frame.size = CGSize(width: 50, height: 50)
        self.videoPlayButtonImageView.center = CGPoint(x: self.bubbleContainerView.frame.width/2, y: self.bubbleContainerView.frame.height/2)
        self.videoPlayButtonImageView.layer.cornerRadius = 25
        
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
        self.assignData(videoData: modelData)
    }
    
    private func assignData(videoData: VideoMessageModel) {
        
        if videoData.messageStatus == .sending {
            self.progressView.isHidden = false
            self.progressView.startAnimating()
            self.videoPlayButtonImageView.isHidden = true
        } else {
            self.progressView.stopAnimating()
            self.progressView.isHidden = true
            self.videoPlayButtonImageView.isHidden = false
        }
        
        self.dateSeperatorLabel.text = videoData.messageDate.toRelativeDateString()
        self.senderNameLabel.text = videoData.senderName.capitalized
        
        if videoData.messageSource == .local {
            self.imageView.image = videoData.localImage
        } else {
            self.imageView.image = videoData.localImage
            if let imageUrlString = videoData.thumbnailUrl {
                self.imageView.sd_imageTransition = videoData.localImage == nil ? .fade : .none
                self.imageView.sd_imageIndicator = videoData.localImage == nil ? SDWebImageActivityIndicator.gray : .none
                let imageUrl = URL(string: imageUrlString)
                self.imageView.sd_setImage(with: imageUrl, placeholderImage: videoData.localImage, options: [.refreshCached,.continueInBackground], completed: {(image,error,cache,url) in
                    if let _image = image {
                        videoData.localImage = nil
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
}


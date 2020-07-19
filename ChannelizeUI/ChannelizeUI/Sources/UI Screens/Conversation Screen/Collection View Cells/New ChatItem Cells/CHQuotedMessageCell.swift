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

class QuotedMessageContainerView: UIView {

    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    private var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 1.75
        return view
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.lightGray
        return imageView
    }()
    
    private var senderNameLabel: UILabel = {
        let label = UILabel()
        label.font = CHCustomStyles.mediumSizeRegularFont
        label.textColor = UIColor.customSystemBlue
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()
    
    private var typeOfMessageLabel: UILabel = {
        let label = UILabel()
        label.font = CHCustomStyles.smallSizeRegularFont
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
        self.dividerView.frame.origin.y = 2.5
        self.dividerView.frame.size.width = 3.5
        self.dividerView.frame.size.height = self.containerView.frame.height - 5
        
        self.imageView.frame.origin.x = getViewOriginXEnd(view: self.dividerView) + 5
        
        if quotedViewModel.imageUrl == nil {
            self.imageView.frame.origin.y = self.dividerView.frame.origin.y + 2.5
            if quotedViewModel.typeOfMessage == .text || quotedViewModel.typeOfMessage == .quotedMessage{
                self.imageView.frame.size = .zero
            } else {
                self.imageView.contentMode = .scaleAspectFit
                self.imageView.frame.size = CGSize(width: 33, height: 33)
            }
        } else {
            if quotedViewModel.typeOfMessage == .doc {
                self.imageView.frame.origin.y = self.dividerView.frame.origin.y + 2.5
                self.imageView.frame.size = CGSize(width: 33, height: 33)
                self.imageView.contentMode = .scaleAspectFit
            } else {
                self.imageView.frame.origin.y = self.dividerView.frame.origin.y + 2.5
                self.imageView.contentMode = .scaleAspectFill
                self.imageView.frame.size = CGSize(width: 33, height: 33)
            }
        }
        
        self.senderNameLabel.frame.origin.x = getViewOriginXEnd(view: self.imageView) + 5
        self.senderNameLabel.frame.origin.y = 5
        self.senderNameLabel.frame.size.height = 17.5
        self.senderNameLabel.frame.size.width = self.containerView.frame.width - self.senderNameLabel.frame.origin.x - 10
        
        self.typeOfMessageLabel.frame.origin.x = getViewOriginXEnd(view: self.imageView) + 5
        self.typeOfMessageLabel.frame.origin.y = getViewOriginYEnd(view: self.senderNameLabel)
        self.typeOfMessageLabel.frame.size.height = 17
        self.typeOfMessageLabel.frame.size.width = self.containerView.frame.width - self.typeOfMessageLabel.frame.origin.x - 10
        
        self.assignData(data: quotedViewModel)
    }
    
    private func assignData(data: QuotedViewModel) {
        self.senderNameLabel.text = data.senderId == Channelize.getCurrentUserId() ? "You" : data.senderName?.capitalized
        self.senderNameLabel.textColor = data.isIncoming ? CHUIConstant.incomingTextMessageColor : CHUIConstant.outGoingTextMessageColor
        self.dividerView.backgroundColor = data.isIncoming ? (CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor) : UIColor.white
        self.typeOfMessageLabel.textColor = data.isIncoming ? CHUIConstant.incomingTextMessageColor : CHUIConstant.outGoingTextMessageColor
        
        if data.imageUrl == nil {
            if data.typeOfMessage == .text || data.typeOfMessage == .quotedMessage{
                self.typeOfMessageLabel.text = data.textMessage?.string
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



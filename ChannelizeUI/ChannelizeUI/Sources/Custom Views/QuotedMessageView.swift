//
//  QuotedMessageView.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/11/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

protocol QuotedMessageViewDelegate {
    func didPressCloseQuotedViewButton()
}

class QuotedMessageView: UIView {

    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.customSystemIndigo
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var senderNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabMedium, size: 18.0)
        label.textColor = UIColor.customSystemBlue
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()
    
    private var typeOfMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()
    
    private var closeViewButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .clear
        button.imageView?.tintColor = UIColor.customSystemBlue
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(getImage("chCloseIcon"), for: .normal)
        return button
    }()
    
    var quotedViewModel: QuotedViewModel? {
        didSet {
            self.setUpViewsFrames()
        }
    }
    
    var delegate: QuotedMessageViewDelegate?
    
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
        self.containerView.addSubview(closeViewButton)
        
        self.closeViewButton.addTarget(self, action: #selector(didPressCloseButton(sender:)), for: .touchUpInside)
    }
    
    @objc private func didPressCloseButton(sender: UIButton) {
        self.delegate?.didPressCloseQuotedViewButton()
    }
    
    private func setUpViewsFrames() {
        guard let quotedViewModel = self.quotedViewModel else {
            return
        }
        self.containerView.pinEdgeToSuperView(superView: self)
        self.dividerView.setLeftAnchor(relatedConstraint: self.containerView.leftAnchor, constant: 10)
        self.dividerView.setTopAnchor(relatedConstraint: self.containerView.topAnchor, constant: 5)
        self.dividerView.setBottomAnchor(relatedConstraint: self.containerView.bottomAnchor, constant: -5)
        self.dividerView.setWidthAnchor(constant: 5)
        
        
        self.imageView.setLeftAnchor(relatedConstraint: self.dividerView.rightAnchor, constant: 5)
        self.imageView.setCenterYAnchor(relatedConstraint: self.containerView.centerYAnchor, constant: 0)
        if quotedViewModel.imageUrl == nil {
            self.imageView.setHeightAnchor(constant: 50)
            self.imageView.setWidthAnchor(constant: 0)
        } else {
            self.imageView.setViewsAsSquare(squareWidth: 50)
        }
        
        self.senderNameLabel.setLeftAnchor(relatedConstraint: self.imageView.rightAnchor, constant: 5)
        self.senderNameLabel.setTopAnchor(relatedConstraint: self.imageView.topAnchor, constant: 0)
        self.senderNameLabel.setHeightAnchor(constant: 25)
        self.senderNameLabel.setRightAnchor(relatedConstraint: self.closeViewButton.leftAnchor, constant: -5)
        
        self.typeOfMessageLabel.setLeftAnchor(relatedConstraint: self.imageView.rightAnchor, constant: 5)
        self.typeOfMessageLabel.setTopAnchor(relatedConstraint: self.senderNameLabel.bottomAnchor, constant: 2.5)
        self.typeOfMessageLabel.setHeightAnchor(constant: 22.5)
        self.typeOfMessageLabel.setRightAnchor(relatedConstraint: self.closeViewButton.leftAnchor, constant: -5)
        
        self.closeViewButton.setViewsAsSquare(squareWidth: 35)
        self.closeViewButton.setRightAnchor(relatedConstraint: self.containerView.rightAnchor, constant: -10)
        self.closeViewButton.setCenterYAnchor(relatedConstraint: self.containerView.centerYAnchor, constant: 0)
        
        self.assignData(data: quotedViewModel)
    }
    
    private func assignData(data: QuotedViewModel) {
        self.senderNameLabel.text = data.senderId == ChannelizeAPI.getCurrentUserId() ? "You" : data.senderName?.capitalized
        
        if data.imageUrl == nil {
            if data.typeOfMessage == .text || data.typeOfMessage == .quotedMessage {
                self.typeOfMessageLabel.text = data.textMessage?.string
            } else if data.typeOfMessage == .doc {
                self.typeOfMessageLabel.attributedText = data.textMessage
            } else {
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
                case .doc:
                    self.typeOfMessageLabel.text = ""
                    break
                default:
                    break
                }
            }
        } else {
            let imageUrl = URL(string: data.imageUrl ?? "")
            self.imageView.sd_imageTransition = .fade
            self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            let thumbnailSize = CGSize(width: getDeviceWiseAspectedWidth(constant: 45*UIScreen.main.scale*2), height: getDeviceWiseAspectedWidth(constant: 45*UIScreen.main.scale*2))
            self.imageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.continueInBackground], context: [.imageThumbnailPixelSize : thumbnailSize])
            
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
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


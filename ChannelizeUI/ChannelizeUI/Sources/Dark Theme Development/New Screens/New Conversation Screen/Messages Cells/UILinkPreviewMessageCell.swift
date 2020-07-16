//
//  UILinkPreviewMessageCell.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/11/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class UILinkPreviewMessageCell: CHBaseMessageCell {
    private var containerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    
    private var linkImagePreview : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        return imageView
    }()
    
    private var linkTitleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        label.backgroundColor = .clear
        return label
    }()
    
    private var linkDescriptionLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.backgroundColor = .clear
        label.numberOfLines = 3
        return label
    }()
    
    var messageStatusViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var messageTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .medium, size: 13.0)
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

    
    var linkMetaData: LinkMessageItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(self.containerView)
        self.bubbleContainerView.addSubview(self.messageStatusViewContainer)
        self.messageStatusViewContainer.addSubview(self.messageStatusView)
        self.messageStatusViewContainer.addSubview(self.messageTimeLabel)
        self.containerView.addSubview(linkImagePreview)
        self.containerView.addSubview(linkTitleLabel)
        self.containerView.addSubview(linkDescriptionLabel)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openLink(gesture:)))
        self.containerView.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: ChannelizeChatItem) {
        super.assignChatItem(chatItem: chatItem)
        guard let linkData = chatItem as? LinkMessageItem else {
            return
        }
        self.linkMetaData = linkData
        let linkContainerViewWidth : CGFloat = 270
        
        containerView.frame.size = CGSize(width: linkContainerViewWidth, height: self.bubbleContainerView.frame.height)
        if linkData.isIncoming == true {
            containerView.frame.origin = CGPoint(x: 15, y: 0)
            containerView.backgroundColor = CHUIConstant.incomingTextMessageBackGroundColor
            linkTitleLabel.textColor = UIColor(hex: "#1c1c1c")
            linkDescriptionLabel.textColor = UIColor(hex: "#1c1c1c")
        } else {
            containerView.frame.origin = CGPoint(x: self.frame.width - self.containerView.frame.width - 15, y: 0)
            containerView.backgroundColor = CHUIConstant.outGoingTextMessageBackGroundColor
            linkTitleLabel.textColor = .white
            linkDescriptionLabel.textColor = .white
        }
        
        self.messageStatusViewContainer.frame.size = CGSize(width: 80, height: 30)
        self.messageStatusViewContainer.frame.origin.y = getViewEndOriginY(view: self.containerView) - self.messageStatusViewContainer.frame.size.height - 2.5
        if linkData.isIncoming {
            self.messageStatusViewContainer.frame.origin.x = getViewEndOriginX(view: self.containerView) + 5
        } else {
            self.messageStatusViewContainer.frame.origin.x = self.containerView.frame.origin.x - self.messageStatusViewContainer.frame.width - 5
        }
        
        self.messageStatusView.frame.size = CGSize(width: 15, height: 15)
        self.messageStatusView.frame.origin.y = 0
        self.messageStatusView.frame.origin.x = linkData.isIncoming == true ? 0 : self.containerView.frame.width - self.messageStatusView.frame.width
        
        self.messageTimeLabel.frame.size = CGSize(width: 80, height: 15)
        self.messageTimeLabel.frame.origin.x = 0
        self.messageTimeLabel.frame.origin.y = getViewEndOriginY(view: self.messageStatusView)
        
        
        if chatItem.showMessageStatusView {
            self.messageStatusViewContainer.isHidden = false
        } else {
            self.messageStatusViewContainer.isHidden = true
        }
        
        if chatItem.isIncoming {
            self.messageStatusView.isHidden = true
            self.messageTimeLabel.textAlignment = .left
        } else {
            self.messageStatusView.isHidden = false
            self.messageTimeLabel.textAlignment = .right
        }
        
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
        
        
        let linkTitleAttributedString = linkData.linkTitleAttributedString ?? NSAttributedString()
        let descriptionAttributedString = linkData.linkDescriptionAttributedString ?? NSAttributedString()
        
        let labelHeight = getAttributedLabelHeight(attributedString: linkTitleAttributedString, maximumWidth: 240, numberOfLines: 2)
        
        let descriptionHeight = getAttributedLabelHeight(attributedString: descriptionAttributedString, maximumWidth: 240, numberOfLines: 3)
        
        linkImagePreview.frame.origin = CGPoint(x: 0, y: 0)
        if linkData.linkMetaData?.linkImageUrl != nil{
            linkImagePreview.frame.size = CGSize(width: linkContainerViewWidth, height: 150)
        } else{
            linkImagePreview.frame.size = CGSize(width: linkContainerViewWidth, height: 0)
        }
        
        linkTitleLabel.frame.origin = CGPoint(x: 7.5, y: getViewYOrigin(view: linkImagePreview)+5)
        linkTitleLabel.frame.size = CGSize(width: linkContainerViewWidth - 15, height: labelHeight+5)
        
        linkDescriptionLabel.frame.origin = CGPoint(x: 7.5, y: getViewYOrigin(view: linkTitleLabel))
        linkDescriptionLabel.frame.size = CGSize(width: linkContainerViewWidth - 15, height: descriptionHeight)
        
        self.linkTitleLabel.attributedText = linkTitleAttributedString
        self.linkDescriptionLabel.attributedText = descriptionAttributedString
        
        
        if let imageUrlString = linkData.linkMetaData?.linkImageUrl {
            if let imageUrl = URL(string: imageUrlString) {
                self.linkImagePreview.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.continueInBackground,.highPriority], completed: nil)
            }
        }
    }
    
    
    @objc func openLink(gesture:UITapGestureRecognizer){
        guard let model = self.linkMetaData else{
            return
        }
        if let urlString = model.linkMetaData?.mainUrl, let url = URL(string: urlString),UIApplication.shared.canOpenURL(url){
            if #available(iOS 10.0, *){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else{
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    private func getViewYOrigin(view:UIView)->CGFloat{
        return view.frame.origin.y+view.frame.height
    }
}


//
//  CHMissCallMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/30/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

class CHMissCallMessageCell: BaseChatItemCollectionCell {
    
    private var messageStringLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .robotoSlabMedium, size: 18.0)
        label.textColor = .white
        label.textAlignment = .left
        label.backgroundColor = .clear
        //label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var missCallIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.layer.masksToBounds = true
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var typeOfCallLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        label.textColor = .white
        label.textAlignment = .left
        label.backgroundColor = .clear
        //label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var callBackButton: UIButton = {
        let button = UIButton()
        button.setTitle("Call Back", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(fontStyle: .robotoSlabMedium, size: 18.0)
        button.backgroundColor = .clear
        //button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        view.layer.cornerRadius = 7.5
        view.layer.masksToBounds = true
        return view
    }()
    
    private var dividerLine: UIView = {
        let view = UIView()
        //view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var miscallMessageModel: MissCallMessageModel?
    
    var onCallBackButtonTapped: ((_ callType: CHCallScreen)-> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        
        self.bubbleContainerView.addSubview(containerView)
        self.containerView.addSubview(messageStringLabel)
        self.containerView.addSubview(missCallIcon)
        self.containerView.addSubview(typeOfCallLabel)
        self.containerView.addSubview(callBackButton)
        self.containerView.addSubview(dividerLine)
        
        self.callBackButton.addTarget(self, action: #selector(didTappOnCallBackButton(sender:)), for: .touchUpInside)
    }
    
    override func assignChatItem(chatItem: BaseMessageItemProtocol) {
        super.assignChatItem(chatItem: chatItem)
        guard let missCallModel = chatItem as? MissCallMessageModel else {
            return
        }
        self.miscallMessageModel = missCallModel
        
        let containerViewWidth: CGFloat = chatItem.isIncoming ? 170 : 190
        
        self.containerView.frame.size = CGSize(width: containerViewWidth, height: self.bubbleContainerView.frame.height)
        self.containerView.frame.origin.y = 0
        self.containerView.frame.origin.x = chatItem.isIncoming ? 15 : self.bubbleContainerView.frame.width - self.containerView.frame.width - 15
        
        self.messageStringLabel.frame.origin.x = 10
        self.messageStringLabel.frame.origin.y = 5
        self.messageStringLabel.frame.size.width = self.containerView.frame.width - 20
        self.messageStringLabel.frame.size.height = 25
        
        self.typeOfCallLabel.frame.origin.x = 40
        self.typeOfCallLabel.frame.origin.y = getViewOriginYEnd(view: self.messageStringLabel) + 0
        self.typeOfCallLabel.frame.size.width = self.containerView.frame.width - 40 - 5
        self.typeOfCallLabel.frame.size.height = 35
        
        self.missCallIcon.frame.size = CGSize(width: 25, height: 25)
        self.missCallIcon.frame.origin.x = 10
        self.missCallIcon.center.y = self.typeOfCallLabel.center.y
        
        self.dividerLine.frame.origin.x = 0
        self.dividerLine.frame.origin.y = getViewOriginYEnd(view: self.typeOfCallLabel) 
        self.dividerLine.frame.size.height = 1.0
        self.dividerLine.frame.size.width = self.containerView.frame.width
        
        self.callBackButton.frame.origin.x = 5
        self.callBackButton.frame.origin.y = getViewOriginYEnd(view: self.typeOfCallLabel)
        self.callBackButton.frame.size.width = self.containerView.frame.width - 10
        self.callBackButton.frame.size.height = self.containerView.frame.height - self.callBackButton.frame.origin.y
        
        if missCallModel.isIncoming {
            self.dividerLine.backgroundColor = CHUIConstants.conversationTitleColor
            self.containerView.backgroundColor = CHUIConstants.incomingTextMessageBackgroundColor
            self.messageStringLabel.textColor = UIColor.customSystemRed
            self.typeOfCallLabel.textColor = CHUIConstants.conversationMessageColor
            self.callBackButton.setTitleColor(
                CHUIConstants.conversationTitleColor, for: .normal)
            self.missCallIcon.tintColor = UIColor.customSystemRed
        } else {
            self.dividerLine.backgroundColor = UIColor(hex: "#ffffff")
            self.containerView.backgroundColor = CHUIConstants.appDefaultColor
            self.messageStringLabel.textColor = UIColor(hex: "#ffffff")
            self.typeOfCallLabel.textColor = UIColor(hex: "#ffffff")
            self.callBackButton.setTitleColor(UIColor(hex: "#ffffff"), for: .normal)
            self.missCallIcon.tintColor = .white
        }
        
        if missCallModel.callType == .voice {
            self.typeOfCallLabel.text = "Voice Call"
            self.missCallIcon.image = getImage("miss_call")
        } else {
            self.typeOfCallLabel.text = "Video Call"
            self.missCallIcon.image = getImage("missed_video_call")
        }
        
        if missCallModel.senderId ==
            Channelize.getCurrentUserId() {
            let recieverName = missCallModel.recieverName?.trim ?? ""
            let firstName = recieverName.components(separatedBy: " ").first ?? ""
            let formattedString = String(format: "%@ Missed", firstName)
            self.messageStringLabel.text = formattedString
        } else {
            self.messageStringLabel.text = "You Missed"
        }
    }
    
    @objc func didTappOnCallBackButton(sender: UIButton) {
        self.onCallBackButtonTapped?(self.miscallMessageModel?.callType ?? .voice)
    }
}

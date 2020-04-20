//
//  DetailedCallLogHeaderView.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import SDWebImage
import ChannelizeAPI

class DetailedCallLogHeaderView: UIView {
    
    var onBackButtonTapped: ((_ sender: UIButton) -> Void)?
    
    private var headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var backButton: UIButton = {
        let button = CHCallButton()
        button.backgroundColor = .clear
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(getImage("chBackButton"), for: .normal)
        return button
    }()
    
    
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(hex: "#f8f8f8")
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var callPartnerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        return label
    }()
    
    private var voiceCallButton: CHCallButton = {
        let button = CHCallButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(getImage("chVoiceCallIcon"), for: .normal)
        return button
    }()
    
    private var videoCallButton: CHCallButton = {
        let button = CHCallButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(getImage("chVideoCallIcon"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpHeaderView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpHeaderView() {
        self.addSubview(headerContainerView)
        self.headerContainerView.pinEdgeToSuperView(superView: self)
        
        self.headerContainerView.addSubview(backButton)
        self.headerContainerView.addSubview(profileImageView)
        self.headerContainerView.addSubview(callPartnerNameLabel)
        self.headerContainerView.addSubview(videoCallButton)
        self.headerContainerView.addSubview(voiceCallButton)
        
        self.backButton.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        
        self.backButton.setViewsAsSquare(squareWidth: 40)
        self.backButton.setLeftAnchor(relatedConstraint: self.headerContainerView.leftAnchor, constant: 5)
        self.backButton.setCenterYAnchor(relatedConstraint: self.headerContainerView.centerYAnchor, constant: 0)
        
        self.profileImageView.setViewAsCircle(circleWidth: 35)
        self.profileImageView.setLeftAnchor(relatedConstraint: self.backButton.rightAnchor, constant: 5)
        self.profileImageView.setCenterYAnchor(relatedConstraint: self.headerContainerView.centerYAnchor, constant: 0)
        
        self.callPartnerNameLabel.setLeftAnchor(relatedConstraint: self.profileImageView.rightAnchor, constant: 12.5)
        self.callPartnerNameLabel.setCenterYAnchor(relatedConstraint: self.headerContainerView.centerYAnchor, constant: 0)
        self.callPartnerNameLabel.setHeightAnchor(constant: 25)
        self.callPartnerNameLabel.setWidthAnchor(constant: 150)
        
        self.videoCallButton.setViewsAsSquare(squareWidth: 40)
        self.videoCallButton.setCenterYAnchor(relatedConstraint: self.headerContainerView.centerYAnchor, constant: 0)
        self.videoCallButton.setRightAnchor(relatedConstraint: self.headerContainerView.rightAnchor, constant: -10)
        
        self.voiceCallButton.setViewsAsSquare(squareWidth: 40)
        self.voiceCallButton.setCenterYAnchor(relatedConstraint: self.headerContainerView.centerYAnchor, constant: 0)
        self.voiceCallButton.setRightAnchor(relatedConstraint: self.videoCallButton.leftAnchor, constant: 0)
        
    }
    
    @objc private func backButtonPressed(sender: UIButton) {
        self.onBackButtonTapped?(sender)
    }
    
    func assignHeaderViewData(callPartner: CHCallMember?) {
        let callPartnerName = callPartner?.user?.displayName?.capitalized
        let profileImageUrl = callPartner?.user?.profileImageUrl
        self.callPartnerNameLabel.text = callPartnerName
        if let imageUrl = URL(string: profileImageUrl ?? "") {
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.profileImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: callPartnerName ?? "", imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 60), height: getDeviceWiseAspectedWidth(constant: 60)))
            let image = imageGenerator.generateImage()
            self.profileImageView.image = image
        }
    }
    
    override var intrinsicContentSize: CGSize {
      return UIView.layoutFittingExpandedSize
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

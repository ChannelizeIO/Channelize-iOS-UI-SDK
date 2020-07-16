//
//  SelectedChatModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/29/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import SDWebImage
import ChannelizeAPI

class SelectedChatModelCell: UICollectionViewCell {
    
    private var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor(hex: "#F5F5F5")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var userDisplayName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = CHUIConstants.contactNameColor
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 13.0)
        return label
    }()
    
    var removeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.setImage(getImage("blankCloseIcon"), for: .normal)
        button.imageView?.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        button.backgroundColor = CHUIConstants.appDefaultColor
        return button
    }()
    
    var onRemoveButtonPressed: ((_ model: SelecteChatModel?, _ user: CHUser?) ->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    var selectedModel: SelecteChatModel?
    
    var selectedUserModel: CHUser?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        self.addSubview(userImageView)
        self.addSubview(userDisplayName)
        self.addSubview(removeButton)
        
        self.userImageView.setViewAsCircle(circleWidth: 50)
        self.userImageView.setTopAnchor(relatedConstraint: self.topAnchor, constant: 10)
        self.userImageView.setCenterXAnchor(relatedConstraint: self.centerXAnchor, constant: 0)
        
        self.userDisplayName.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 5)
        self.userDisplayName.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -5)
        self.userDisplayName.setHeightAnchor(constant: 30)
        self.userDisplayName.setTopAnchor(relatedConstraint: self.userImageView.bottomAnchor, constant: 10)
        
        //self.removeButton.setViewsAsSquare(squareWidth: 20)
        self.removeButton.setViewAsCircle(circleWidth: 20)
        self.removeButton.setCenterYAnchor(relatedConstraint: self.userImageView.topAnchor, constant: 6)
        self.removeButton.setRightAnchor(relatedConstraint: self.userImageView.rightAnchor, constant: -1)
        
        self.removeButton.addTarget(self, action: #selector(removeButtonPressed(sender:)), for: .touchUpInside)
    }
    
    @objc func removeButtonPressed(sender: UIButton) {
        self.onRemoveButtonPressed?(self.selectedModel, self.selectedUserModel)
    }
    
    func assignData(model: SelecteChatModel) {
        self.selectedModel = model
        let displayName = model.type == .user ? model.title.capitalized : model.title
        let profileImageUrl = model.profileImageUrl
        self.userImageView.image = nil
        self.userDisplayName.text = displayName
        if let imageUrl = URL(string: profileImageUrl) {
            //self.userImageView.sd_imageTransition = .fade
            self.userImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.userImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.highPriority,.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: displayName, imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 50), height: getDeviceWiseAspectedWidth(constant: 50)))
            let image = imageGenerator.generateImage()
            self.userImageView.image = image
        }
    }
    
    func assignUser(user: CHUser) {
        self.selectedUserModel = user
        let profileImageUrl = user.profileImageUrl ?? ""
        let displayName = user.displayName?.capitalized ?? ""
        self.userImageView.image = nil
        self.userDisplayName.text = user.displayName?.capitalized
        if let imageUrl = URL(string: profileImageUrl) {
            //self.userImageView.sd_imageTransition = .fade
            self.userImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.userImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.highPriority,.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: displayName, imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 50), height: getDeviceWiseAspectedWidth(constant: 50)))
            let image = imageGenerator.generateImage()
            self.userImageView.image = image
        }
    }
}


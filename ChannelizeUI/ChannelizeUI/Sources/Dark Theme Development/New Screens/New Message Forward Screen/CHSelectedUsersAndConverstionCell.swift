//
//  CHSelectedUsersAndConverstionCell.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/13/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import ChannelizeAPI
import DifferenceKit

class CHSelectedUsersAndConverstionCell: UICollectionViewCell {
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
        label.textColor = CHUIConstant.recentConversationTitleColor
        label.font = CHCustomStyles.smallSizeRegularFont
        return label
    }()
    
    var removeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.setImage(getImage("blankCloseIcon"), for: .normal)
        button.imageView?.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        return button
    }()
    
    var onRemoveButtonPressed: ((_ user: SelecteChatModel?) ->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var selectedUserModel: SelecteChatModel?
    
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
        
        self.removeButton.setViewAsCircle(circleWidth: 20)
        self.removeButton.setCenterYAnchor(relatedConstraint: self.userImageView.topAnchor, constant: 6)
        self.removeButton.setRightAnchor(relatedConstraint: self.userImageView.rightAnchor, constant: -1)
        
        self.removeButton.addTarget(self, action: #selector(removeButtonPressed(sender:)), for: .touchUpInside)
    }
    
    @objc func removeButtonPressed(sender: UIButton) {
        self.onRemoveButtonPressed?(self.selectedUserModel)
    }
    
    func assignData(model: SelecteChatModel) {
        self.selectedUserModel = model
        let profileImageUrl = model.profileImageUrl
        let displayName = model.title
        self.userImageView.image = nil
        self.userDisplayName.text = self.initialsFromString(string: displayName)
        if let imageUrl = URL(string: profileImageUrl) {
            //self.userImageView.sd_imageTransition = .fade
            self.userImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.userImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.highPriority,.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: displayName, imageSize: CGSize(width: 50, height: 50))
            let image = imageGenerator.generateImage()
            self.userImageView.image = image
        }
    }
    
    private func initialsFromString(string: String) -> String {
        
        let trimmedString = string.trimmingCharacters(in: .whitespaces)
        return trimmedString.components(separatedBy: " ").first ?? ""
    }
}

enum SelectedChatModelType {
    case user
    case conversation
}

class SelecteChatModel: NSCopying, Differentiable {
    func copy(with zone: NSZone? = nil) -> Any {
        let copiedItem = SelecteChatModel(id: self.id, type: self.type, title: self.title, profileImageUrl: self.profileImageUrl)
        return copiedItem
    }
    
    
    func isContentEqual(to source: SelecteChatModel) -> Bool {
        return self.id == source.id &&
            self.type == source.type &&
            self.title == source.title &&
            self.profileImageUrl == source.profileImageUrl
    }
    
    var differenceIdentifier: String {
        return id
    }
    
    var id: String
    var type: SelectedChatModelType
    var title: String
    var profileImageUrl: String
    
    init(id: String, type: SelectedChatModelType, title: String, profileImageUrl: String) {
        self.id = id
        self.type = type
        self.title = title
        self.profileImageUrl = profileImageUrl
    }
}



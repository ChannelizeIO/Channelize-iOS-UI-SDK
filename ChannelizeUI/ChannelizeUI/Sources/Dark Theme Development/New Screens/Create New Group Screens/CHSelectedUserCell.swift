//
//  SelectedChatModelCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/3/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import ChannelizeAPI

class CHSelectedUserCell: UICollectionViewCell {
    
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
        label.font = UIFont(fontStyle: .regular, size: 14.0)
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
    
    var onRemoveButtonPressed: ((_ user: CHUser?) ->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
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
        
        self.removeButton.setViewAsCircle(circleWidth: 22)
        self.removeButton.setCenterYAnchor(relatedConstraint: self.userImageView.topAnchor, constant: 6)
        self.removeButton.setRightAnchor(relatedConstraint: self.userImageView.rightAnchor, constant: -1)
        
        self.removeButton.addTarget(self, action: #selector(removeButtonPressed(sender:)), for: .touchUpInside)
    }
    
    @objc func removeButtonPressed(sender: UIButton) {
        self.onRemoveButtonPressed?(self.selectedUserModel)
    }
    
    func assignUser(user: CHUser) {
        self.selectedUserModel = user
        let profileImageUrl = user.profileImageUrl ?? ""
        let displayName = user.displayName?.capitalized ?? ""
        self.userImageView.image = nil
        self.userDisplayName.text = self.initialsFromString(string: user.displayName?.capitalized ?? "")
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


//
//  UIContactTableCell2.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/20/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class UIContactTableCell: UITableViewCell {
    
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
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.textColor = CHUIConstants.contactNameColor
        label.font = CHUIConstants.contactNameFont
        return label
    }()
    
    private var onlineStatusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = CHUIConstants.onlineStatusColor
        view.layer.borderWidth = 2.0
        return view
    }()
    
    var userModel: CHUser? {
        didSet {
            self.assignData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.white//CHConstants.contactsTableCellBackGroundColor
        self.selectionStyle = .none
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    private func setUpViews() {
        self.contentView.addSubview(userImageView)
        self.contentView.addSubview(userDisplayName)
        self.contentView.addSubview(onlineStatusView)
    }
    
    private func setUpViewsFrames() {
        self.userImageView.setViewAsCircle(circleWidth: 50)
        self.userImageView.setLeftAnchor(relatedConstraint: self.contentView.leftAnchor, constant: 12.5)
        self.userImageView.setCenterYAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        
        self.userDisplayName.setLeftAnchor(relatedConstraint: self.userImageView.rightAnchor, constant: 12.5)
        self.userDisplayName.setCenterYAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        self.userDisplayName.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -5)
        self.userDisplayName.setHeightAnchor(constant: 30)
        
        self.onlineStatusView.setViewAsCircle(circleWidth: 15)
        self.onlineStatusView.setRightAnchor(relatedConstraint: self.userImageView.rightAnchor, constant: -1.5)
        self.onlineStatusView.setBottomAnchor(relatedConstraint: self.userImageView.bottomAnchor, constant: -2.5)
        
        self.separatorInset.left = 75
        self.separatorInset.right = 5
    }
    
    private func assignData() {
        guard let userData = self.userModel else {
            return
        }
        if userData.isOnline == true {
            self.onlineStatusView.isHidden = false
        } else {
            self.onlineStatusView.isHidden = true
        }
        
        self.userImageView.image = nil
        self.userDisplayName.text = userData.displayName?.capitalized
        if let imageUrlString = userData.profileImageUrl {
            let imageUrl = URL(string: imageUrlString)
            self.userImageView.sd_imageTransition = .fade
            self.userImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.userImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.highPriority,.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: userData.displayName?.capitalized ?? "", imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 50), height: getDeviceWiseAspectedWidth(constant: 50)))
            let image = imageGenerator.generateImage()
            self.userImageView.image = image
        }
    }
    
    func assignExtraData(imageUrl: String?, title: String?) {
        self.imageView?.image = nil
        let diplayTitle = title ?? ""
        self.userDisplayName.text = diplayTitle
        self.onlineStatusView.isHidden = true
        if let imageUrlString = imageUrl {
            let imageUrl = URL(string: imageUrlString)
            self.userImageView.sd_imageTransition = .fade
            self.userImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.userImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.highPriority,.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: diplayTitle, imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 50), height: getDeviceWiseAspectedWidth(constant: 50)))
            let image = imageGenerator.generateImage()
            self.userImageView.image = image
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


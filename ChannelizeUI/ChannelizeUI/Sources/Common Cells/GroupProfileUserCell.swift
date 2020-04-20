//
//  GroupProfileUserCell.swift
//  Channelize-API-SDK
//
//  Created by Ashish-BigStep on 2/15/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class GroupProfileUserCell: UITableViewCell {
    
    private var userImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var userNameLabel: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.textColor = CHUIConstants.contactNameColor
        label.font = CHUIConstants.contactNameFont
        return label
    }()
    
    var extraInfoLabel: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .clear
        label.textColor = UIColor.lightGray
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)
        return label
    }()
    
    var rightArrowIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = getImage("chRightArrowIcon")
        imageView.tintColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    var member: CHMember? {
        didSet {
            self.setUpViewsFrames()
            self.assignData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.contentView.addSubview(userImageView)
        self.contentView.addSubview(userNameLabel)
        self.contentView.addSubview(extraInfoLabel)
        self.contentView.addSubview(rightArrowIcon)
    }
    
    private func setUpViewsFrames() {
        self.userImageView.frame.size = CGSize(width: 50, height: 50)
        self.userImageView.layer.cornerRadius = 25
        self.userImageView.frame.origin.x = 10
        self.userImageView.center.y = self.contentView.frame.height/2
       
        
        self.extraInfoLabel.frame.size = CGSize(width: 60, height: 20)
        self.extraInfoLabel.center.y = self.contentView.frame.height/2
        if self.member?.user?.id == ChannelizeAPI.getCurrentUserId() {
            self.rightArrowIcon.frame.size = .zero
            self.rightArrowIcon.isHidden = true
            self.extraInfoLabel.frame.origin.x = self.contentView.frame.width - 100
        } else {
            self.rightArrowIcon.isHidden = false
            self.rightArrowIcon.frame.size = CGSize(width: 25, height: 25)
            self.extraInfoLabel.frame.origin.x = self.contentView.frame.width - 100
        }
        
        self.rightArrowIcon.frame.origin.x = self.contentView.frame.width - 35
        self.rightArrowIcon.center.y = self.userImageView.center.y
        
        self.userNameLabel.frame.size = CGSize(width: self.contentView.frame.width - 160, height: 35)
        self.userNameLabel.center.y = self.contentView.frame.height/2
        self.userNameLabel.frame.origin.x = 67.5
        
        
        
        self.separatorInset.left = getDeviceWiseAspectedWidth(constant: 67.5)
    }
    
    private func assignData() {
        guard let memberData = self.member else {
            return
        }
        
        let userName = memberData.user?.displayName?.capitalized ?? ""
        self.userNameLabel.text = userName
        
        if memberData.isAdmin == true {
            self.extraInfoLabel.text = "Admin"
            self.extraInfoLabel.isHidden = false
        } else {
            self.extraInfoLabel.isHidden = true
        }
        
        if let profileImage = memberData.user?.profileImageUrl {
            if let url = URL(string: profileImage) {
                let imageWidth = getDeviceWiseAspectedWidth(constant: 60)
                let scale = UIScreen.main.scale
                let imageSize = CGSize(width: imageWidth*scale*2, height: imageWidth*scale*2)
                
                self.userImageView.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground], context: [.imageThumbnailPixelSize : imageSize])
                
            } else {
                
                let imageWidth = getDeviceWiseAspectedWidth(constant: 60)
                let scale = UIScreen.main.scale
                let imageSize = CGSize(width: imageWidth*scale*2, height: imageWidth*scale*2)
                
                let imageGenerator = ImageFromStringProvider(name: memberData.user?.displayName?.capitalized ?? "", imageSize: imageSize)
                let image = imageGenerator.generateImage(with: 18.0 * scale * 2)
                self.userImageView.image = image
            }
        } else {
            // Create Image Using Generator
            let imageWidth = getDeviceWiseAspectedWidth(constant: 60)
            let scale = UIScreen.main.scale
            let imageSize = CGSize(width: imageWidth*scale*2, height: imageWidth*scale*2)
            
            let imageGenerator = ImageFromStringProvider(name: memberData.user?.displayName?.capitalized ?? "", imageSize: imageSize)
            let image = imageGenerator.generateImage(with: 18.0 * scale * 2)
            self.userImageView.image = image
            //self.conversationImageView.kf.setImage(with: provider)
        }
        
    }
    
}



//
//  ContactActionTableCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/2/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class ContactActionTableCell: UITableViewCell {

    var removeButton: UIButton = {
        let button = UIButton()
        button.setImage(getImage("chRemoveSign"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = UIColor.white
        button.backgroundColor = UIColor.customSystemRed
        button.layer.masksToBounds = true
        return button
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var contactNameLabel: UILabel = {
        let label = UILabel()
        label.font = CHCustomStyles.normalSizeRegularFont
        label.backgroundColor = .clear
        return label
    }()
    
    var seperatorLineView: UIView = {
        let view = UIView()
        return view
    }()
    
    var isAdminLabel: UILabel = {
        let label = UILabel()
        label.font = CHCustomStyles.mediumSizeRegularFont
        label.text = CHLocalized(key: "pmAdminText").capitalized
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        return label
    }()
    
    var discloseIndicatorView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = CHUIConstant.settingsSceenDiscloseIndicatorColor
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.image = getImage("chRightArrowIcon")
        return imageView
    }()
    
    var onRemoveButtonPressed: ((_ userId: String) ->Void)?
    
    var member: CHMember?
    var user: CHUser?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        self.addSubview(removeButton)
        self.addSubview(profileImageView)
        self.addSubview(contactNameLabel)
        self.addSubview(discloseIndicatorView)
        self.addSubview(isAdminLabel)
        self.removeButton.addTarget(self, action: #selector(removeUserButtonPressed(sender:)), for: .touchUpInside)
    }
    
    func setUpViewsFrames(hideRemoveButton: Bool = false) {
        
        if hideRemoveButton {
            self.removeButton.frame.size = .zero
            self.removeButton.frame.origin.x = 0
            self.discloseIndicatorView.isHidden = false
            self.isAdminLabel.frame.size = CGSize(width: 60, height: 25)
        } else {
            self.removeButton.frame.size = CGSize(width: 25, height: 25)
            self.removeButton.frame.origin.x = 12.5
            self.discloseIndicatorView.isHidden = true
            self.isAdminLabel.frame.size = .zero
        }
        self.removeButton.center.y = self.frame.height/2
        self.removeButton.setViewCircular()
        
        self.discloseIndicatorView.frame.size = CGSize(width: 25, height: 25)
        self.discloseIndicatorView.frame.origin.x = self.frame.width - 35
        self.discloseIndicatorView.center.y = self.frame.height/2
        
        
        self.isAdminLabel.frame.origin.x = self.discloseIndicatorView.frame.origin.x - self.isAdminLabel.frame.width - 5
        self.isAdminLabel.center.y = self.frame.height/2
        
        self.profileImageView.frame.size = CGSize(width: 50, height: 50)
        self.profileImageView.frame.origin.x = getViewEndOriginX(view: self.removeButton) + 12.5
        self.profileImageView.center.y = self.frame.height/2
        self.profileImageView.setViewCircular()
        
        self.contactNameLabel.frame.size.height = 30
        self.contactNameLabel.frame.origin.x = getViewEndOriginX(view: self.profileImageView) + 12.5
        self.contactNameLabel.frame.size.width = self.isAdminLabel.frame.origin.x - self.contactNameLabel.frame.origin.x - 5
        self.contactNameLabel.center.y = self.profileImageView.center.y
        
        self.seperatorLineView.frame.size.height = 0.7
        self.seperatorLineView.frame.size.width = self.contactNameLabel.frame.width
        self.seperatorLineView.frame.origin.x = self.contactNameLabel.frame.origin.x
        self.seperatorLineView.frame.origin.y = self.frame.height - self.seperatorLineView.frame.height
        self.separatorInset.left = self.contactNameLabel.frame.origin.x
    }
    
    func setUpUIProperties() {
        self.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.profileImageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#3c3c3c") : UIColor(hex: "#acacac")
        self.contactNameLabel.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor
        self.seperatorLineView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor
        self.isAdminLabel.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.secondaryColor : CHLightThemeColors.secondaryColor
    }
    
    func assignData() {
        guard let userData = self.member?.user else {
            return
        }
        self.contactNameLabel.text = userData.displayName?.capitalized
        if self.member?.isAdmin == true {
            self.isAdminLabel.isHidden = false
        } else {
            self.isAdminLabel.isHidden = true
        }
        
        if member?.user?.id == Channelize.getCurrentUserId() {
            self.discloseIndicatorView.isHidden = true
        } else {
            self.discloseIndicatorView.isHidden = false
        }
        
        
        if let profileImageUrl = URL(string: userData.profileImageUrl ?? "") {
            self.profileImageView.sd_imageIndicator = CHAppConstant.themeStyle == .dark ? SDWebImageActivityIndicator.white : SDWebImageActivityIndicator.gray
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil, options: [.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: userData.displayName?.capitalized ?? "", imageSize: self.profileImageView.frame.size)
            let image = imageGenerator.generateImage(with: 20.0)
            self.profileImageView.image = image
        }
    }
    
    func assignUser() {
        guard let userData = self.user else {
            return
        }
        self.contactNameLabel.text = userData.displayName?.capitalized
        self.isAdminLabel.isHidden = true
        
        if let profileImageUrl = URL(string: userData.profileImageUrl ?? "") {
            self.profileImageView.sd_imageIndicator = CHAppConstant.themeStyle == .dark ? SDWebImageActivityIndicator.white : SDWebImageActivityIndicator.gray
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil, options: [.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: userData.displayName?.capitalized ?? "", imageSize: self.profileImageView.frame.size)
            let image = imageGenerator.generateImage(with: 20.0)
            self.profileImageView.image = image
        }
    }
    
    @objc private func removeUserButtonPressed(sender: UIButton) {
        self.onRemoveButtonPressed?(self.user?.id ?? "")
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


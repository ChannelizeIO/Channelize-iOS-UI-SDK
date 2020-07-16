//
//  CHContactSelectTableCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/3/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class CHContactSelectTableCell: UITableViewCell {

    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var contactNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .regular, size: 17.0)
        label.backgroundColor = .clear
        return label
    }()
    
    var unSelectedCircleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chUnSelectedCircelcon")
        return imageView
    }()
    
    var selectedCirlceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : UIColor(hex: "#8b8b8b")
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chSelectedCircleIcon")
        return imageView
    }()
    
    var user: CHUser?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        self.addSubview(profileImageView)
        self.addSubview(contactNameLabel)
        self.addSubview(unSelectedCircleImageView)
        self.addSubview(selectedCirlceImageView)
    }
    
    func setUpViewsFrames() {
        
        self.profileImageView.frame.size = CGSize(width: 50, height: 50)
        self.profileImageView.frame.origin.x =  12.5
        self.profileImageView.center.y = self.frame.height/2
        self.profileImageView.setViewCircular()
        
        self.contactNameLabel.frame.size.height = 30
        self.contactNameLabel.frame.origin.x = getViewEndOriginX(view: self.profileImageView) + 12.5
        self.contactNameLabel.frame.size.width = self.frame.width - self.contactNameLabel.frame.origin.x - 35
        self.contactNameLabel.center.y = self.profileImageView.center.y
        
        self.selectedCirlceImageView.frame.size = CGSize(width: 25, height: 25)
        self.selectedCirlceImageView.frame.origin.x = self.frame.width - 40
        self.selectedCirlceImageView.center.y = self.frame.height/2
        self.selectedCirlceImageView.setViewCircular()
        
        self.unSelectedCircleImageView.frame.size = CGSize(width: 25, height: 25)
        self.unSelectedCircleImageView.frame.origin.x = self.frame.width - 40
        self.unSelectedCircleImageView.center.y = self.frame.height/2
        self.unSelectedCircleImageView.setViewCircular()
        
        self.selectedCirlceImageView.isHidden = true
        
        self.separatorInset.left = self.contactNameLabel.frame.origin.x
    }
    
    func setUpUIProperties() {
        self.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.profileImageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#3c3c3c") : UIColor(hex: "#acacac")
        self.contactNameLabel.textColor = CHUIConstant.recentConversationTitleColor
    }
    
    func assignData() {
        guard let userData = self.user else {
            return
        }
        self.contactNameLabel.text = userData.displayName?.capitalized
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
    
    func setCellSelected() {
        self.selectedCirlceImageView.isHidden = false
        self.unSelectedCircleImageView.isHidden = true
    }
    
    func setCellUnselected() {
        self.selectedCirlceImageView.isHidden = true
        self.unSelectedCircleImageView.isHidden = false
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



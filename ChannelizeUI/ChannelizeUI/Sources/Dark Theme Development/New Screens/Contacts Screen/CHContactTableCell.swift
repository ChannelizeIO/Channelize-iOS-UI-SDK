//
//  CHContactTableCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/27/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class CHContactTableCell: UITableViewCell {

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
        label.numberOfLines = 1
        return label
    }()
    
    var onlineIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen
        return view
    }()
    
    var seperatorLineView: UIView = {
        let view = UIView()
        return view
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
        self.addSubview(onlineIndicatorView)
        self.addSubview(seperatorLineView)
    }
    
    func setUpViewsFrames() {
        self.profileImageView.frame.size = CGSize(width: 50, height: 50)
        self.profileImageView.frame.origin.x = 15
        self.profileImageView.center.y = self.frame.height/2
        self.profileImageView.setViewCircular()
        
        self.contactNameLabel.frame.size.height = self.frame.height - 10
        self.contactNameLabel.frame.origin.x = getViewEndOriginX(view: self.profileImageView) + 12.5
        self.contactNameLabel.frame.size.width = self.frame.width - self.contactNameLabel.frame.origin.x - 5
        self.contactNameLabel.center.y = self.profileImageView.center.y
        
        self.onlineIndicatorView.frame.size = CGSize(width: 15, height: 15)
        let xTheta = CGFloat(cos(315*Double.pi/180))
        let yTheta = CGFloat(sin(315*Double.pi/180))
        
        let xPoint = self.profileImageView.center.x+((self.profileImageView.frame.height/2)*xTheta)
        let yPoint = self.profileImageView.center.y-((self.profileImageView.frame.height/2)*yTheta)
        self.onlineIndicatorView.center = CGPoint(x: xPoint, y: yPoint)
        self.onlineIndicatorView.setViewCircular()
        
        self.seperatorLineView.frame.size.height = 0.7
        self.seperatorLineView.frame.size.width = self.contactNameLabel.frame.width
        self.seperatorLineView.frame.origin.x = self.contactNameLabel.frame.origin.x
        self.seperatorLineView.frame.origin.y = self.frame.height - self.seperatorLineView.frame.height
        
        self.separatorInset.left = self.contactNameLabel.frame.origin.x
    }
    
    func setUpUIProperties() {
        self.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.profileImageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#3c3c3c") : UIColor(hex: "#acacac")
        self.contactNameLabel.textColor = CHUIConstant.contactNameColor
        self.onlineIndicatorView.layer.borderWidth = 2.0
        self.onlineIndicatorView.layer.borderColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c").cgColor : UIColor.white.cgColor
        self.seperatorLineView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.seperatorColor : CHLightThemeColors.instance.seperatorColor
    }
    
    func assignData() {
        guard let userData = self.user else {
            return
        }
        self.contactNameLabel.text = userData.displayName?.capitalized
        self.onlineIndicatorView.isHidden = !(userData.isOnline ?? false)
        if let profileImageUrl = URL(string: userData.profileImageUrl ?? "") {
            self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.profileImageView.sd_imageTransition = .fade
            self.profileImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil, options: [.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: userData.displayName?.capitalized ?? "", imageSize: self.profileImageView.frame.size)
            let image = imageGenerator.generateImage(with: 20.0)
            self.profileImageView.image = image
        }
        
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


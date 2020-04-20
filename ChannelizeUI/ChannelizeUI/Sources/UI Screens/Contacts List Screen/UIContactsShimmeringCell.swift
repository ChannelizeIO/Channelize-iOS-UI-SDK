//
//  ContactsShimmeringCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class UIContactsShimmeringCell: UITableViewCell {

    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private var displayNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.layer.cornerRadius = 7.5
        label.layer.masksToBounds = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(displayNameLabel)
    }
    
    func setUpViewsFrames() {
        
        self.profileImageView.frame.size = CGSize(width: getDeviceWiseAspectedWidth(constant: 50), height: getDeviceWiseAspectedWidth(constant: 50))
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.frame.origin.x = getDeviceWiseAspectedWidth(constant: 12.5)
        self.profileImageView.frame.origin.y = (self.frame.height - getDeviceWiseAspectedWidth(constant: 50))/2
        
        self.displayNameLabel.frame.size = CGSize(width: self.frame.width - 110, height: 30)
        self.displayNameLabel.frame.origin.x = getViewOriginXEnd(view: self.profileImageView) + getDeviceWiseAspectedWidth(constant: 12.5)
        self.displayNameLabel.frame.origin.y = self.frame.height/2 - self.displayNameLabel.frame.height/2
        
        self.separatorInset.left = getDeviceWiseAspectedWidth(constant: 75)
    }
    
    func startShimmering() {
        ABLoader().startShining(profileImageView)
        ABLoader().startShining(displayNameLabel)
    }
    
    private func stopShimmering() {
        for subView in self.subviews {
            ABLoader().stopShining(subView)
        }
    }
    
}


//
//  GroupsListShimmeringCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/1/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class GroupsListShimmeringCell: UICollectionViewCell {
    
    private var groupProfileImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .white
        label.layer.cornerRadius = 7.5
        label.font = UIFont(fontStyle: .robotoSlabSemiBold, size: 18.0)
        return label
    }()
    
    private var activeStatusLabel: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .white
        label.layer.cornerRadius = 7.5
        label.font = UIFont(fontStyle: .robotoSlabSemiBold, size: 16.0)
        return label
    }()
    
    private var dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        //view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var memberCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .white
        label.layer.cornerRadius = 7.5
        label.font = UIFont(fontStyle: .sourceSansProRegular, size: 16.0)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.contentView.addSubview(groupProfileImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(activeStatusLabel)
        self.contentView.addSubview(dividerLine)
        self.contentView.addSubview(memberCountLabel)
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 2.5
        layer.cornerRadius = 2.5
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    private func setUpViewsFrames() {
        
        let profileImageWidth = getDeviceWiseAspectedWidth(constant: 70)
        self.groupProfileImageView.frame.size = CGSize(width: profileImageWidth, height: profileImageWidth)
        self.groupProfileImageView.layer.cornerRadius = self.groupProfileImageView.frame.height/2
        self.groupProfileImageView.center.x = self.frame.width/2
        self.groupProfileImageView.frame.origin.y = getDeviceWiseAspectedHeight(constant: 20)
        
        self.titleLabel.frame.size = CGSize(width: self.frame.width - 10, height: getDeviceWiseAspectedHeight(constant: 20))
        self.titleLabel.frame.origin.x = getDeviceWiseAspectedWidth(constant: 5)
        self.titleLabel.frame.origin.y = getViewOriginYEnd(view: self.groupProfileImageView) + getDeviceWiseAspectedHeight(constant: 30)
        
        self.activeStatusLabel.frame.size = CGSize(width: self.frame.width - 40, height: 15)
        self.activeStatusLabel.frame.origin.x = getDeviceWiseAspectedWidth(constant: 20)
        self.activeStatusLabel.frame.origin.y = getViewOriginYEnd(view: self.titleLabel) + getDeviceWiseAspectedHeight(constant: 15)
        
        
        self.dividerLine.frame.size = CGSize(width: self.frame.width, height: 1.0)
        self.dividerLine.frame.origin.x = 0
        self.dividerLine.frame.origin.y = getViewOriginYEnd(view: self.activeStatusLabel) + getDeviceWiseAspectedHeight(constant: 10)
        
        self.memberCountLabel.frame.size = CGSize(width: self.frame.width - 60, height: getDeviceWiseAspectedHeight(constant: 15))
        self.memberCountLabel.frame.origin.x = 30
        self.memberCountLabel.frame.origin.y = getViewOriginYEnd(view: self.dividerLine) + getDeviceWiseAspectedHeight(constant: 15)
    }
    
    func startShimmering() {
        ABLoader().startShining(groupProfileImageView)
        ABLoader().startShining(titleLabel)
        ABLoader().startShining(activeStatusLabel)
        ABLoader().startShining(dividerLine)
        ABLoader().startShining(memberCountLabel)
    }
    
    private func stopShimmering() {
        for subView in self.subviews {
            ABLoader().stopShining(subView)
        }
    }
}


//
//  RecentConversationShimmeringCell.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class RecentConversationShimmeringCell: UITableViewCell {

    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .medium, size: 17.0)
        label.backgroundColor = .clear
        return label
    }()
    
    var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .regular, size: 15.0)
        label.backgroundColor = .clear
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .white// CHConstants.recentScreencellBackGroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        self.addSubview(profileImageView)
        self.addSubview(titleLabel)
        self.addSubview(messageLabel)
    }
    
    private func getViewOriginXEnd(view: UIView) -> CGFloat {
        return view.frame.width + view.frame.origin.x
    }
    
    private func getViewOriginYEnd(view: UIView) -> CGFloat {
        return view.frame.height + view.frame.origin.y
    }
    
    func setUpViewsFrames() {
        
        self.addSubview(profileImageView)
        self.addSubview(titleLabel)
        self.addSubview(messageLabel)
        
        self.profileImageView.frame.size = CGSize(width: 50, height: 50)
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.frame.origin.x = 12.5
        self.profileImageView.center.y = self.frame.height/2
        
        
        self.titleLabel.frame.origin.y = self.profileImageView.frame.origin.y + 2.5
        self.titleLabel.frame.origin.x = getViewEndOriginX(view: self.profileImageView) + 12.5
        self.titleLabel.frame.size.height = 20
        self.titleLabel.frame.size.width = self.frame.width - self.titleLabel.frame.origin.x - 80
        self.titleLabel.layer.cornerRadius = 5
        
        self.messageLabel.frame.origin.y = getViewEndOriginY(view: self.titleLabel) + 7.5
        self.messageLabel.frame.origin.x = getViewEndOriginX(view: self.profileImageView) + 12.5
        self.messageLabel.frame.size.height = 22.5
        self.messageLabel.frame.size.width = self.frame.width - self.messageLabel.frame.origin.x - 50
        self.messageLabel.layer.cornerRadius = 5
        
        self.separatorInset.left = self.titleLabel.frame.origin.x
        self.setUpUIProperties()
    }
    
    func setUpUIProperties() {
        self.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.profileImageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#7c7c7c") : UIColor(hex: "#acacac")
        self.titleLabel.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#7c7c7c") : UIColor(hex: "#acacac")
        self.messageLabel.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#7c7c7c") : UIColor(hex: "#acacac")
        self.startShimmering()
    }
    
    func startShimmering() {
        ABLoader().startShining(profileImageView)
        ABLoader().startShining(titleLabel)
        ABLoader().startShining(messageLabel)
    }
    
    private func stopShimmering() {
        for subView in self.subviews {
            ABLoader().stopShining(subView)
        }
    }

}

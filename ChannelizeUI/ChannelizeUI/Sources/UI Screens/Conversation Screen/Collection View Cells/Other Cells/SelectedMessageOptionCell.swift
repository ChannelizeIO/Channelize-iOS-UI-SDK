//
//  SelectedMessageOptionCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/10/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class SelectedMessageOptionCell: UITableViewCell {

    private var visualEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: effect)
        visualEffectView.backgroundColor = UIColor(hex: "#dadada")
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    
    private var optionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoRegular, size: CHUIConstants.normalFontSize)
        label.textColor = CHUIConstants.conversationTitleColor
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.text = "Option Name"
        return label
    }()
    
    private var optionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.image = getImage("chDeleteButton")
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(hex: "#dadada")
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(visualEffectView)
        self.visualEffectView.contentView.addSubview(optionImageView)
        self.visualEffectView.contentView.addSubview(optionLabel)
    }
    
    private func setUpViewsFrames() {
        self.visualEffectView.pinEdgeToSuperView(superView: self)
        
        self.optionImageView.setViewsAsSquare(squareWidth: 20)
        self.optionImageView.setLeftAnchor(relatedConstraint: self.visualEffectView.contentView.leftAnchor, constant: 15)
        self.optionImageView.setCenterYAnchor(relatedConstraint: self.visualEffectView.contentView.centerYAnchor, constant: 0)
        
        self.optionLabel.setLeftAnchor(relatedConstraint: self.optionImageView.rightAnchor, constant: 15)
        self.optionLabel.setTopAnchor(relatedConstraint: self.visualEffectView.contentView.topAnchor, constant: 0)
        self.optionLabel.setBottomAnchor(relatedConstraint: self.visualEffectView.contentView.bottomAnchor, constant: 0)
        self.optionLabel.setRightAnchor(relatedConstraint: self.visualEffectView.contentView.rightAnchor, constant: -5)
    }
    
    func assignData(optionName: String?, icon: String?, tintColor: UIColor) {
        self.optionImageView.image = getImage(icon ?? "")
        self.optionLabel.text = optionName
        self.optionImageView.tintColor = tintColor
        self.optionLabel.textColor = tintColor
    }
}


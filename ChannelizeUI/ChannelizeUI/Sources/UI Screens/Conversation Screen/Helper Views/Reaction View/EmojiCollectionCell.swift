//
//  EmojiCollectionCell.swift
//  ChannelizeUI
//
//  Created by bigstep on 5/3/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class EmojiCollectionCell: UICollectionViewCell {
    
    private var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        return label
    }()
    
    private var isSelectedDotView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.customSystemTeal
        view.layer.cornerRadius = 2.5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var model: EmojiReactionModel? {
        didSet {
            self.assignData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(textLabel)
        self.addSubview(isSelectedDotView)
    }
    
    private func setUpViewsFrames() {
        self.textLabel.setViewsAsSquare(squareWidth: 40)
        self.textLabel.setCenterXAnchor(relatedConstraint: self.centerXAnchor, constant: 0)
        self.textLabel.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
//        self.textLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        self.textLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
//        self.textLabel.bottomAnchor.constraint(equalTo: self., constant: <#T##CGFloat#>)
//        self.textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
//        self.textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
//
//        self.isSelectedDotView.heightAnchor.constraint(equalToConstant: 5).isActive = true
//        self.isSelectedDotView.widthAnchor.constraint(equalToConstant: 5).isActive = true
//        self.isSelectedDotView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
//        self.isSelectedDotView.topAnchor.constraint(equalTo: self.textLabel.bottomAnchor, constant: 5).isActive = true
    }
    
    private func assignData() {
        self.textLabel.text = model?.emojiCode
        self.textLabel.backgroundColor = model?.isSelected == true ? (CHAppConstant.themeStyle == .dark ? UIColor(hex: "#3c3c3c") : UIColor(hex: "#cacaca")) : .clear
        self.isSelectedDotView.isHidden = model?.isSelected == true ? false : true
    }
}

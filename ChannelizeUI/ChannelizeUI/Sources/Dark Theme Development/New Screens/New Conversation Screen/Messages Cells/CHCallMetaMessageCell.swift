//
//  CHCallMetaMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 8/13/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class CHCallMetaMessageCell: UICollectionViewCell {

    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private var callTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.secondaryColor : CHLightThemeColors.secondaryColor
        label.font = CHCustomStyles.metaMessageFont!
        return label
    }()
    
    private var metaMessageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.backgroundColor = .clear
        return label
    }()
    
    var metaMessageModel: CHCallMetaMessageModel? {
        didSet {
            self.setUpViewsFrames()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.containerView.removeFromSuperview()
        self.metaMessageLabel.removeFromSuperview()
        self.callTimeLabel.removeFromSuperview()
        self.addSubview(containerView)
        self.containerView.addSubview(callTimeLabel)
        self.containerView.addSubview(metaMessageLabel)
    }
    
    private func setUpViewsFrames() {
        guard let modelData = self.metaMessageModel else {
            return
        }
        self.containerView.frame.origin = .zero
        self.containerView.frame.size = self.frame.size
        
        self.callTimeLabel.frame.origin = .zero
        self.callTimeLabel.frame.size = CGSize(width: self.frame.width, height: 20)
        
        self.metaMessageLabel.frame.origin = CGPoint(x: 0, y: 20)
        self.metaMessageLabel.frame.size = CGSize(width: self.frame.width, height: 25)
        
        self.metaMessageLabel.attributedText = modelData.callMetaMessageAttributedString
        self.callTimeLabel.text = modelData.messageDate.toRelateTimeString()
    }
    

}


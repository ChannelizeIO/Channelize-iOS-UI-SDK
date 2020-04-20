//
//  MetaMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class UIMetaMessageCell: UICollectionViewCell {
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        //view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var metaMessageLabel: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.backgroundColor = .clear//UIColor(hex: "#1c1c1c")
        return label
    }()
    
    var metaMessageModel: MetaMessageModel? {
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
        self.addSubview(containerView)
        self.containerView.addSubview(metaMessageLabel)
    }
    
    private func setUpViewsFrames() {
        guard let modelData = self.metaMessageModel else {
            return
        }
        self.containerView.frame.origin = .zero
        self.containerView.frame.size = self.frame.size
        
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 280, withText: modelData.metaMessageAttributedString ?? NSAttributedString())
        self.metaMessageLabel.frame.size.height = self.containerView.frame.height
        self.metaMessageLabel.frame.size.width = frameSizeInfo.frameSize.width + 10
        self.metaMessageLabel.frame.origin.y = 0
        self.metaMessageLabel.center.x = self.containerView.frame.width/2
        
        self.metaMessageLabel.attributedText = modelData.metaMessageAttributedString
    }
}



//
//  CHMetaMessageCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/3/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit

class CHMetaMessageCell: UICollectionViewCell {
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
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
    
    var metaMessageModel: MetaMessageItem? {
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



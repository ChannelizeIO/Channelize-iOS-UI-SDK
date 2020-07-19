//
//  UnReadMessageHeaderCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/22/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class UnReadMessageHeaderCell: UICollectionViewCell {
    private var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "---------- Unread Messages ----------"
        label.textColor = CHUIConstants.appDefaultColor
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(label)
        self.label.pinEdgeToSuperView(superView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



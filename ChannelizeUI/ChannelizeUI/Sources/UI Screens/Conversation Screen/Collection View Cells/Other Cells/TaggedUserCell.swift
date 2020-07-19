//
//  TaggedUserCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/5/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class TaggedUserCell: UITableViewCell {

    var userImage : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        imageView.frame.size = CGSize(width: 40, height: 40)
        return imageView
    }()
    
    var userName : UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .regular, size: 17.0)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpSubViews()
    }
    
    func setUpSubViews(){
        self.addSubview(userImage)
        self.addSubview(userName)
        
        self.userImage.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 5)
        self.userImage.setViewAsCircle(circleWidth: 40)
        self.userImage.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        self.userName.setLeftAnchor(relatedConstraint: self.userImage.rightAnchor, constant: 10)
        self.userName.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -10)
        self.userName.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        self.userName.setHeightAnchor(constant: 30)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



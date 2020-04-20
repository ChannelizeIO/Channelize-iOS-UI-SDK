//
//  GroupedPhotosViewCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/16/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class GroupedPhotosViewCell: UICollectionViewCell {
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var unSelectedCircleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .gray
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chUnSelectedCircelcon")
        return imageView
    }()
    
    private var selectedCirlceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = CHUIConstants.appDefaultColor
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .white
        imageView.image = getImage("chSelectedCircleIcon")
        return imageView
    }()
    
    var imageModel: ImageMessageModel? {
        didSet {
            self.assignData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(imageView)
        self.addSubview(unSelectedCircleImageView)
        self.addSubview(selectedCirlceImageView)
    }
    
    private func setUpViewsFrames() {
        self.imageView.pinEdgeToSuperView(superView: self)
        
        self.unSelectedCircleImageView.setViewsAsSquare(squareWidth: 30)
        self.unSelectedCircleImageView.setLeftAnchor(
            relatedConstraint: self.leftAnchor, constant: 15)
        self.unSelectedCircleImageView.setTopAnchor(
            relatedConstraint: self.topAnchor, constant: 15)
        
        //self.selectedCirlceImageView.setViewsAsSquare(squareWidth: 30)
        self.selectedCirlceImageView.setViewAsCircle(circleWidth: 30)
        self.selectedCirlceImageView.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 15)
        self.selectedCirlceImageView.setTopAnchor(relatedConstraint: self.topAnchor, constant: 15)
    }
    
    func hideSelectorView() {
        self.selectedCirlceImageView.isHidden = true
        self.unSelectedCircleImageView.isHidden = true
    }
    
    func showSelectorView() {
        self.unSelectedCircleImageView.isHidden = false
        self.selectedCirlceImageView.isHidden = true
    }
    
    func setSelected() {
        self.unSelectedCircleImageView.isHidden = true
        self.selectedCirlceImageView.isHidden = false
    }
    
    func setUnSelected() {
        self.unSelectedCircleImageView.isHidden = false
        self.selectedCirlceImageView.isHidden = true
    }
    
    private func assignData() {
        guard let modelData = self.imageModel else {
            return
        }
        if let firstImageUrl = modelData.imageUrl {
            self.imageView.sd_imageTransition = .fade
            self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imageView.sd_setImage(with: URL(string: firstImageUrl), placeholderImage: nil, options: [.continueInBackground], completed: nil)
        }
    }
    
}


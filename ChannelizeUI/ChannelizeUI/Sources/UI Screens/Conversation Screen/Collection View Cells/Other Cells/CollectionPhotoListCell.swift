//
//  CollectionPhotoListCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/1/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import Photos

class CollectionPhotoListCell: UICollectionViewCell {
    
    var spinnerView : UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .gray
        view.startAnimating()
        return view
    }()
    
    var cellImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor(white: 0.99, alpha: 0.5)
        //imageView.isHidden = true
        return imageView
    }()
    
    var selectedView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    
    var selectedImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = CHUIConstants.appDefaultColor
        imageView.layer.cornerRadius = 15
        imageView.tintColor = .white
        imageView.image = getImage("checkMark")
        return imageView
    }()
    
    var progressView : CircularProgressBar = {
        let progressBar = CircularProgressBar()
        progressBar.isHidden = true
        progressBar.setProgress(to: 1, withAnimation: true)
        progressBar.safePercent = 100
        progressBar.labelSize = 1
        progressBar.lineWidth = 5
        return progressBar
    }()
    
    var selectedLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = CHUIConstants.appDefaultColor
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    
    var photoIdentifier : String!
    var requestId : Int!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cellAsset : PHAsset? {
        didSet{
            //self.assignData()
        }
    }
    
    var manager = PHImageManager.default()
    var cachingManager = PHCachingImageManager.default()
    
    func setUpView(){
        
        self.addSubview(cellImageView)
        self.addSubview(selectedView)
        self.addSubview(selectedImageView)
        self.addSubview(progressView)
        self.addSubview(selectedLabel)
        //self.addSubview(spinnerView)
        
        selectedView.isHidden = true
        selectedImageView.isHidden = true
        progressView.isHidden = true
        selectedLabel.isHidden = true
        
        
        self.addConstraintsWithFormat(format: "H:|-10-[v0(25)]", views: progressView)
        self.addConstraintsWithFormat(format: "V:[v0(25)]-10-|", views: progressView)
        
        self.addConstraintsWithFormat(format: "H:|[v0]|", views: cellImageView)
        self.addConstraintsWithFormat(format: "V:|[v0]|", views: cellImageView)
        
        self.addConstraintsWithFormat(format: "H:|[v0]|", views: selectedView)
        self.addConstraintsWithFormat(format: "V:|[v0]|", views: selectedView)
        
        self.addConstraintsWithFormat(format: "H:[v0(30)]-5-|", views: selectedImageView)
        self.addConstraintsWithFormat(format: "V:[v0(30)]-5-|", views: selectedImageView)
        
        self.addConstraintsWithFormat(format: "H:[v0(30)]|", views: selectedLabel)
        self.addConstraintsWithFormat(format: "V:[v0(30)]|", views: selectedLabel)
    }
}



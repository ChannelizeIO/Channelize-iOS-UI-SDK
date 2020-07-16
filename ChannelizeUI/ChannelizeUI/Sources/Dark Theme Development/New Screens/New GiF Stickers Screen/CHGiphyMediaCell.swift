//
//  GiphyMediaCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/7/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import SDWebImage
import SDWebImageFLPlugin

class CHGiphyMediaCell: UICollectionViewCell {
    
    private var imageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.runLoopMode = RunLoop.Mode.default.rawValue
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#4c4c4c") : UIColor(hex: "#e6e6e6")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var onTapGiphySticker: ((_ model: CHGiphImageModel) -> Void)?
    
    var mediaModel: CHGiphImageModel? {
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
        self.contentView.addSubview(imageView)
    }
    
    private func setUpViewsFrames() {
        self.imageView.setLeftAnchor(relatedConstraint: self.contentView.leftAnchor, constant: 3)
        self.imageView.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -3)
        self.imageView.setTopAnchor(relatedConstraint: self.contentView.topAnchor, constant: 3)
        self.imageView.setBottomAnchor(relatedConstraint: self.contentView.bottomAnchor, constant: -3)
        
        //self.imageView.addGestureRecognizer(
            //UITapGestureRecognizer(target: self, action: #selector(didTapOnCell(gesture:))))
    }
    
    @objc func didTapOnCell(gesture: UITapGestureRecognizer) {
        guard let model = self.mediaModel else {
            return
        }
        self.onTapGiphySticker?(model)
    }
    
    private func assignData() {
        guard let mediaData = self.mediaModel else {
            return
        }
        if let downSampledUrl = mediaData.downSampledUrl {
            if let gifUrl = URL(string: downSampledUrl) {
                self.imageView.sd_imageIndicator = CHAppConstant.themeStyle == .dark ? SDWebImageActivityIndicator.white  : SDWebImageActivityIndicator.gray
                self.imageView.sd_imageTransition = .fade
                self.imageView.sd_setImage(with: gifUrl, completed: nil)
            }
        }
        
    }
    
}





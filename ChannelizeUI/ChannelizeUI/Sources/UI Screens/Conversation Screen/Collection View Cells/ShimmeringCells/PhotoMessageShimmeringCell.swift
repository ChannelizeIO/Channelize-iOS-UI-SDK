//
//  PhotoMessageShimmeringCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/30/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class PhotoMessageShimmeringCell: UICollectionViewCell {
    
    private var photoShimmeringView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 7.5
        view.layer.masksToBounds = true
        return view
    }()
    
    private var videoShimmeringView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 7.5
        view.layer.masksToBounds = true
        return view
    }()
    
    private var textMessageShimmeringView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 7.5
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(photoShimmeringView)
        self.contentView.addSubview(videoShimmeringView)
        self.contentView.addSubview(textMessageShimmeringView)
    }
    
    func setUpViewsFrames(isIncoming: Bool) {
        if isIncoming {
            self.photoShimmeringView.frame.origin = CGPoint(x: 15, y: 5)
            self.photoShimmeringView.frame.size = CGSize(width: 160, height: self.frame.height - 10)
            
            self.videoShimmeringView.frame.origin = CGPoint(x: 15, y: 5)
            self.videoShimmeringView.frame.size = CGSize(width: 190, height: self.frame.height - 10)
            
            self.textMessageShimmeringView.frame.origin = CGPoint(x: 15, y: 5)
            self.textMessageShimmeringView.frame.size = CGSize(width: 190, height: self.frame.height - 10)
            
        } else {
            self.photoShimmeringView.frame.origin = CGPoint(x: self.frame.width - 175, y: 5)
            self.photoShimmeringView.frame.size = CGSize(width: 160, height: self.frame.height - 10)
            
            self.videoShimmeringView.frame.origin = CGPoint(x: self.frame.width - 205, y: 5)
            self.videoShimmeringView.frame.size = CGSize(width: 190, height: self.frame.height - 10)
            
            self.textMessageShimmeringView.frame.origin = CGPoint(x: self.frame.width - 205, y: 5)
            self.textMessageShimmeringView.frame.size = CGSize(width: 190, height: self.frame.height - 10)
        }
    }
    
    
    func showPhotoShimmer() {
        self.photoShimmeringView.isHidden = false
        self.videoShimmeringView.isHidden = true
        self.textMessageShimmeringView.isHidden = true
        ABLoader().startShining(photoShimmeringView)
    }
    
    func showVideoShimmer() {
        self.photoShimmeringView.isHidden = true
        self.videoShimmeringView.isHidden = false
        self.textMessageShimmeringView.isHidden = true
        ABLoader().startShining(videoShimmeringView)
    }
    
    func showTextMessageShimmer() {
        self.photoShimmeringView.isHidden = true
        self.videoShimmeringView.isHidden = true
        self.textMessageShimmeringView.isHidden = false
        ABLoader().startShining(textMessageShimmeringView)
    }
    
    private func stopShimmering() {
        for subView in self.subviews {
            ABLoader().stopShining(subView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

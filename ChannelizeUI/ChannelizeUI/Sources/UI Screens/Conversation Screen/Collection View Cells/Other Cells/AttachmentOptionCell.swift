//
//  AttachmentOptionCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/13/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class AttachmentOptionCell: UICollectionViewCell {
    
    private var containerVisualEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = UIColor(hex: "#1c1c1c")
        return view
    }()
    
    private var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = CHUIConstants.appDefaultColor
        imageView.contentMode = .scaleAspectFit
        imageView.image = getImage("chPhotoIcon")
        return imageView
    }()
    
    private var optionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = CHUIConstants.appDefaultColor
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: CHUIConstants.mediumFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var model: AttachmentModel? {
        didSet {
            self.assignData()
        }
    }
    
    var onSelfTapped: ((_ cell: AttachmentOptionCell) ->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(containerView)
        self.containerView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didPressOnItem(gesture:))))
        self.containerView.addSubview(imageView)
        self.containerView.addSubview(optionLabel)
    }
    
    @objc func didPressOnItem(gesture: UITapGestureRecognizer) {
        self.onSelfTapped?(self)
    }
    
    private func setUpViewsFrames() {
        
        self.containerView.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 5)
        self.containerView.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -5)
        self.containerView.setTopAnchor(relatedConstraint: self.topAnchor, constant: 5)
        self.containerView.setBottomAnchor(relatedConstraint: self.bottomAnchor, constant: -5)
        
        self.imageView.setViewsAsSquare(squareWidth: 30)
        self.imageView.setCenterXAnchor(relatedConstraint: self.containerView.centerXAnchor, constant: 0)
        self.imageView.setBottomAnchor(relatedConstraint: self.containerView.centerYAnchor, constant: -5)
        
        self.optionLabel.setLeftAnchor(relatedConstraint: self.containerView.leftAnchor, constant: 10)
        self.optionLabel.setRightAnchor(relatedConstraint: self.containerView.rightAnchor, constant: -10)
        self.optionLabel.setTopAnchor(relatedConstraint: self.containerView.centerYAnchor, constant: 5)
        self.optionLabel.setHeightAnchor(constant: 25)
    }
    
    private func assignData() {
        guard let modelData = self.model else {
            return
        }
        self.optionLabel.text = modelData.label
        self.imageView.image = getImage(modelData.icon ?? "")
    }
    
}



//
//  LinkPreviewCollectionCell.swift
//  Channelize-API-SDK
//
//  Created by Ashish-BigStep on 2/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import SDWebImage

class LinkPreviewCollectionCell: UICollectionViewCell {
    
    private var containerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    
    private var linkImagePreview : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        return imageView
    }()
    
    private var linkTitleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        label.backgroundColor = .clear
        return label
    }()
    
    private var linkDescriptionLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.backgroundColor = .clear
        label.numberOfLines = 3
        return label
    }()
    
    var linkDataModel : LinkPreviewModel? {
        didSet{
            arrangeFrames()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews(){
        containerView.removeFromSuperview()
        self.addSubview(containerView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openLink(gesture:)))
        self.containerView.addGestureRecognizer(tapGesture)
        
        self.containerView.addSubview(linkImagePreview)
        self.containerView.addSubview(linkTitleLabel)
        self.containerView.addSubview(linkDescriptionLabel)
    }
    
    @objc func openLink(gesture:UITapGestureRecognizer){
        guard let model = self.linkDataModel else{
            return
        }
        if let urlString = model.linkData?.mainUrl, let url = URL(string: urlString),UIApplication.shared.canOpenURL(url){
            if #available(iOS 10.0, *){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else{
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    private func arrangeFrames(){
        guard let model = linkDataModel else{
            return
        }
        
        let cellWidth = self.frame.width
        let cellHeight = self.frame.height
        
        let linkContainerViewWidth : CGFloat = 270
        
        containerView.frame.size = CGSize(width: linkContainerViewWidth, height: cellHeight)
        if model.isIncoming == true {
            containerView.frame.origin = CGPoint(x: 15, y: 0)
            containerView.backgroundColor = .white
            linkTitleLabel.textColor = UIColor(hex: "#1c1c1c")
            linkDescriptionLabel.textColor = UIColor(hex: "#1c1c1c")
        } else {
            containerView.frame.origin = CGPoint(x: self.frame.width - self.containerView.frame.width - 15, y: 0)
            containerView.backgroundColor = UIColor(hex: "#1c1c1c")
            linkTitleLabel.textColor = .white
            linkDescriptionLabel.textColor = .white
        }
        
        let linkTitleAttributedString = model.linkTitleAttributedString ?? NSAttributedString()
        let descriptionAttributedString = model.linkDescriptionAttributedString ?? NSAttributedString()
        
        let labelHeight = getAttributedLabelHeight(attributedString: linkTitleAttributedString, maximumWidth: 240, numberOfLines: 2)
        
        let descriptionHeight = getAttributedLabelHeight(attributedString: descriptionAttributedString, maximumWidth: 240, numberOfLines: 3)
        
        linkImagePreview.frame.origin = CGPoint(x: 0, y: 0)
        if model.linkData?.linkImageUrl != nil{
            linkImagePreview.frame.size = CGSize(width: linkContainerViewWidth, height: 150)
        } else{
            linkImagePreview.frame.size = CGSize(width: linkContainerViewWidth, height: 0)
        }
        
        linkTitleLabel.frame.origin = CGPoint(x: 15, y: getViewYOrigin(view: linkImagePreview)+5)
        linkTitleLabel.frame.size = CGSize(width: linkContainerViewWidth-30, height: labelHeight+5)
        
        linkDescriptionLabel.frame.origin = CGPoint(x: 15, y: getViewYOrigin(view: linkTitleLabel)+5)
        linkDescriptionLabel.frame.size = CGSize(width: linkContainerViewWidth-30, height: descriptionHeight)
        
        self.linkTitleLabel.attributedText = linkTitleAttributedString
        self.linkDescriptionLabel.attributedText = descriptionAttributedString
        
        
        if let imageUrlString = model.linkData?.linkImageUrl {
            if let imageUrl = URL(string: imageUrlString) {
                self.linkImagePreview.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.continueInBackground,.highPriority], completed: nil)
            }
        }
    }
    
    private func getViewYOrigin(view:UIView)->CGFloat{
        return view.frame.origin.y+view.frame.height
    }
    
}

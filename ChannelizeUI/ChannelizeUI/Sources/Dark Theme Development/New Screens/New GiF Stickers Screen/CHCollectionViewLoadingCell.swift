//
//  CollectionViewLoadingCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/1/20.
//  Copyright © 2020 Channelize. All rights reserved.
//
import Foundation
import UIKit

class CHCollectionViewLoadingCell: UICollectionViewCell {
    private var indicatorView: UIActivityIndicatorView = {
        var view = CHAppConstant.themeStyle == .dark ? UIActivityIndicatorView(style: .white) : UIActivityIndicatorView(style: .gray)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var noResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .medium, size: 18.0)
        label.textColor = .black
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.text = "No More Results"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        indicatorView.startAnimating()
        
        self.addSubview(indicatorView)
        self.addSubview(noResultLabel)
        
        self.noResultLabel.isHidden = true
    }
    
    private func setUpViewsFrames() {
        indicatorView.setViewsAsSquare(squareWidth: 45)
        indicatorView.setCenterXAnchor(relatedConstraint: self.centerXAnchor, constant: 0)
        indicatorView.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        noResultLabel.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 5)
        noResultLabel.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -5)
        noResultLabel.setTopAnchor(relatedConstraint: self.topAnchor, constant: 5)
        noResultLabel.setBottomAnchor(relatedConstraint: self.bottomAnchor, constant: -5)
    }
    
    func showSpinnerView() {
        self.indicatorView.startAnimating()
        self.indicatorView.isHidden = false
        self.noResultLabel.isHidden = true
    }
    
    func showNoMoreResultLabel() {
        self.indicatorView.stopAnimating()
        self.indicatorView.isHidden = true
        self.noResultLabel.isHidden = true
    }
}




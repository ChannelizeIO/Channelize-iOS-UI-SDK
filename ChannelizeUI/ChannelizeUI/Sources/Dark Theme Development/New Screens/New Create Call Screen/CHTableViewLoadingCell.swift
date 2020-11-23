//
//  CHTableViewLoadingCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/2/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit

class CHTableViewLoadingCell: UITableViewCell {

    private var indicatorView: UIActivityIndicatorView = {
        let view = CHAppConstant.themeStyle == .dark ? UIActivityIndicatorView(style: .white) : UIActivityIndicatorView(style: .gray)
        return view
    }()
    
    private var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor
        label.font = CHCustomStyles.normalSizeRegularFont
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : .white
        //self.setUpViews()
        //self.setUpViewsFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        indicatorView.startAnimating()
        self.addSubview(indicatorView)
        self.addSubview(infoLabel)
    }
    
    func setUpViewsFrames() {
        indicatorView.frame.size = CGSize(width: 45, height: 45)
        indicatorView.center.y = self.frame.height/2
        indicatorView.center.x = self.frame.width/2
        
        self.infoLabel.frame.size = CGSize(width: self.frame.width - 20, height: self.frame.height)
        self.infoLabel.frame.origin.x = 10
        self.infoLabel.frame.origin.y = 0
        
        self.infoLabel.isHidden = true
        
        self.separatorInset.left = 0
        //indicatorView.setViewsAsSquare(squareWidth: 45)
        //indicatorView.setCenterXAnchor(relatedConstraint: self.centerXAnchor, constant: 0)
        //indicatorView.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
    }
    
    func hideIndicatorView() {
        self.indicatorView.stopAnimating()
    }
    
    func showIndicatorView() {
        self.indicatorView.startAnimating()
        self.infoLabel.isHidden = true
        self.indicatorView.isHidden = false
    }
    
    func showInfoLabel(withText: String?) {
        self.infoLabel.text = withText
        self.infoLabel.isHidden = false
        self.indicatorView.isHidden = true
        self.indicatorView.stopAnimating()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}




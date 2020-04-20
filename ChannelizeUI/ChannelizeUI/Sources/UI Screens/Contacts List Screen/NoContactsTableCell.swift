//
//  NoContactsTableCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/25/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class NoContactsTableCell: UITableViewCell {

    private var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var noConversationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.image = getImage("noContacts.png")
        return imageView
    }()
    
    private var noConversationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(hex: "#3b3c4c")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        label.text = "No contacts found. To enjoy messaging, get connected with community members."
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .white
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(containerView)
        self.containerView.addSubview(noConversationImageView)
        self.containerView.addSubview(noConversationLabel)
    }
    
    private func setUpViewsFrames() {
        self.containerView.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        self.containerView.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 0)
        self.containerView.setRightAnchor(relatedConstraint: self.rightAnchor, constant: 0)
        self.containerView.setHeightAnchor(constant: 225)
        
        self.noConversationImageView.setViewsAsSquare(squareWidth: 120)
        self.noConversationImageView.setCenterXAnchor(relatedConstraint: self.containerView.centerXAnchor, constant: 0)
        self.noConversationImageView.setTopAnchor(relatedConstraint: self.containerView.topAnchor, constant: 30)
        //self.noConversationImageView.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        self.noConversationLabel.setLeftAnchor(relatedConstraint: self.containerView.leftAnchor, constant: 15)
        self.noConversationLabel.setRightAnchor(relatedConstraint: self.containerView.rightAnchor, constant: -15)
        self.noConversationLabel.setTopAnchor(relatedConstraint: self.noConversationImageView.bottomAnchor, constant: 10)
        self.noConversationLabel.setHeightAnchor(constant: 45)
    }
    
    func assignCustomData(image: String, message: String) {
        self.noConversationLabel.text = message
        self.noConversationImageView.image = getImage(image)
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

//
//  NoConversationMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/25/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class NoConversationMessageCell: UITableViewCell {

    private var noConversationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.image = getImage("noConversations.png")
        return imageView
    }()
    
    private var noConversationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(hex: "#3b3c4c")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        label.text = "No conversations yet. Start a new one by tapping on '+' icon."
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
        self.addSubview(noConversationImageView)
        self.addSubview(noConversationLabel)
    }
    
    private func setUpViewsFrames() {
        self.noConversationImageView.setViewsAsSquare(squareWidth: 120)
        self.noConversationImageView.setCenterXAnchor(relatedConstraint: self.centerXAnchor, constant: 0)
        self.noConversationImageView.setBottomAnchor(relatedConstraint: self.centerYAnchor, constant: -5)
        
        self.noConversationLabel.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 15)
        self.noConversationLabel.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -15)
        self.noConversationLabel.setTopAnchor(relatedConstraint: self.centerYAnchor, constant: 5)
        self.noConversationLabel.setHeightAnchor(constant: 45)
    }
    
    func assignCustomData(image: String, title: String) {
        self.noConversationLabel.text = title
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

//
//  BlockStatusView.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/15/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class BlockStatusView: UIView {

    private var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var removedFromGroupLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.text = "You can't reply to this Conversation."
        label.numberOfLines = 2
        return label
    }()
    
    private var userIsBlockedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.text = "User is blocked. Unblock user to send Messages and create calls."
        return label
    }()
    
    private var userHasBlockedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.text = "You can't reply to this Conversation"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
        self.setUpViewFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(containerView)
        self.containerView.addSubview(removedFromGroupLabel)
        self.containerView.addSubview(userIsBlockedLabel)
        self.containerView.addSubview(userHasBlockedLabel)
    }
    
    private func setUpViewFrames() {
        self.containerView.pinEdgeToSuperView(superView: self)
        
        self.removedFromGroupLabel.setLeftAnchor(relatedConstraint: self.containerView.leftAnchor, constant: 15)
        self.removedFromGroupLabel.setRightAnchor(relatedConstraint: self.containerView.rightAnchor, constant: -15)
        self.removedFromGroupLabel.setTopAnchor(relatedConstraint: self.containerView.topAnchor, constant: 0)
        self.removedFromGroupLabel.setBottomAnchor(relatedConstraint: self.containerView.bottomAnchor, constant: 0)
        
        self.userIsBlockedLabel.setLeftAnchor(relatedConstraint: self.containerView.leftAnchor, constant: 15)
        self.userIsBlockedLabel.setRightAnchor(relatedConstraint: self.containerView.rightAnchor, constant: -15)
        self.userIsBlockedLabel.setTopAnchor(relatedConstraint: self.containerView.topAnchor, constant: 0)
        self.userIsBlockedLabel.setBottomAnchor(relatedConstraint: self.containerView.bottomAnchor, constant: 0)
        
        self.userHasBlockedLabel.setLeftAnchor(relatedConstraint: self.containerView.leftAnchor, constant: 15)
        self.userHasBlockedLabel.setRightAnchor(relatedConstraint: self.containerView.rightAnchor, constant: -15)
        self.userHasBlockedLabel.setTopAnchor(relatedConstraint: self.containerView.topAnchor, constant: 0)
        self.userHasBlockedLabel.setBottomAnchor(relatedConstraint: self.containerView.bottomAnchor, constant: 0)
    }
    
    func showGroupConversationStatusView() {
        self.removedFromGroupLabel.isHidden = false
        self.userIsBlockedLabel.isHidden = true
        self.userHasBlockedLabel.isHidden = true
    }
    
    func showUserIsBlockedStatusView() {
        self.removedFromGroupLabel.isHidden = true
        self.userIsBlockedLabel.isHidden = false
        self.userHasBlockedLabel.isHidden = true
    }
    
    func showUserHasBlockedStatusView() {
        self.removedFromGroupLabel.isHidden = true
        self.userIsBlockedLabel.isHidden = true
        self.userHasBlockedLabel.isHidden = false
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


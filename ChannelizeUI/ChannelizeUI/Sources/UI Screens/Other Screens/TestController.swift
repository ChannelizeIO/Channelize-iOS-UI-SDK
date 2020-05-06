//
//  TestController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 4/3/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit


class TestControllerHeaderView: UIView {
    
    var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(getImage("chBackButton"), for: .normal)
        return button
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var infoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 14.0)
        label.textColor = .white
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.text = "Conversations"
        return label
    }()
    
    var extraInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 12.5)
        label.textColor = .white
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.text = "Conversation Info"
        return label
    }()
    
    var voiceCallButton: CHCallButton = {
        let button = CHCallButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(getImage("chVoiceCallIcon"), for: .normal)
        return button
    }()
    
    var videoCallButton: CHCallButton = {
        let button = CHCallButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.tintColor = UIColor.white
        button.setImage(getImage("chVideoCallIcon"), for: .normal)
        return button
    }()
    
    var menuOptionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.tintColor = UIColor.white
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(getImage("chVerticalDotsIcon"), for: .normal)
        return button
    }()
    
    var voiceCallButtonWidthConstraint: NSLayoutConstraint!
    var videoCallButtonWidthConstraint: NSLayoutConstraint!
    var voiceCallButtonHeightConstraint: NSLayoutConstraint!
    var videoCallButtonHeightConstraint: NSLayoutConstraint!
    var conversationTitleHeightConstraint: NSLayoutConstraint!
    var conversationInfoHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(backButton)
        self.addSubview(profileImageView)
        self.addSubview(infoContainerView)
        self.addSubview(menuOptionButton)
        self.addSubview(videoCallButton)
        self.addSubview(voiceCallButton)
        
        self.infoContainerView.addSubview(titleLabel)
        self.infoContainerView.addSubview(extraInfoLabel)
        
        //setUpViewsFrames()
    }
    
    func setUpViewsFrames(callButtonHidden: Bool) {
        
        self.backButton.setViewsAsSquare(squareWidth: 35)
        self.backButton.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 0)
        self.backButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        self.profileImageView.setViewAsCircle(circleWidth: 38)
        self.profileImageView.setLeftAnchor(relatedConstraint: self.backButton.rightAnchor, constant: 2.5)
        self.profileImageView.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        self.menuOptionButton.setViewsAsSquare(squareWidth: 35)
        self.menuOptionButton.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -2.5)
        self.menuOptionButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        self.videoCallButton.setRightAnchor(relatedConstraint: self.menuOptionButton.leftAnchor, constant: -5)
        self.videoCallButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        self.videoCallButtonWidthConstraint = NSLayoutConstraint(item: self.videoCallButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: callButtonHidden ? 0 : 35)
        self.videoCallButtonHeightConstraint = NSLayoutConstraint(item: self.videoCallButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: callButtonHidden ? 0 : 35)
        self.videoCallButtonWidthConstraint.isActive = true
        self.videoCallButtonHeightConstraint.isActive = true
        
        self.voiceCallButton.setRightAnchor(relatedConstraint: self.videoCallButton.leftAnchor, constant: -5)
        self.voiceCallButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        self.voiceCallButtonWidthConstraint = NSLayoutConstraint(item: self.voiceCallButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: callButtonHidden ? 0 : 35)
        self.voiceCallButtonHeightConstraint = NSLayoutConstraint(item: self.voiceCallButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: callButtonHidden ? 0 : 35)
        self.voiceCallButtonHeightConstraint.isActive = true
        self.voiceCallButtonWidthConstraint.isActive = true
        
        self.addConstraints([
            self.videoCallButtonWidthConstraint, self.videoCallButtonHeightConstraint, self.voiceCallButtonHeightConstraint, self.voiceCallButtonWidthConstraint])
        
        self.infoContainerView.setLeftAnchor(relatedConstraint: self.profileImageView.rightAnchor, constant: 5)
        self.infoContainerView.setRightAnchor(relatedConstraint: self.voiceCallButton.leftAnchor, constant: -2.5)
        self.infoContainerView.setHeightAnchor(constant: 40)
        self.infoContainerView.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        self.titleLabel.setLeftAnchor(relatedConstraint: self.infoContainerView.leftAnchor, constant: 0)
        self.titleLabel.setRightAnchor(relatedConstraint: self.infoContainerView.rightAnchor, constant: 0)
        self.titleLabel.setTopAnchor(relatedConstraint: self.infoContainerView.topAnchor, constant: 0)
        self.conversationTitleHeightConstraint = NSLayoutConstraint(item: self.titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20.0)
        self.conversationTitleHeightConstraint.isActive = true
        self.addConstraint(conversationTitleHeightConstraint)
        //self.conversationTitleLabel.setHeightAnchor(constant: 20.0)
        
        self.extraInfoLabel.setLeftAnchor(relatedConstraint: self.infoContainerView.leftAnchor, constant: 0)
        self.extraInfoLabel.setTopAnchor(relatedConstraint: self.titleLabel.bottomAnchor, constant: 0)
        self.extraInfoLabel.setRightAnchor(relatedConstraint: self.infoContainerView.rightAnchor, constant: 0)
        self.conversationInfoHeightConstraint = NSLayoutConstraint(item: self.extraInfoLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 17.0)
        self.conversationInfoHeightConstraint.isActive = true
        self.addConstraint(conversationInfoHeightConstraint)
        
        
        /*
        self.backButton.frame.size = CGSize(width: 40, height: 40)
        self.backButton.frame.origin.x = 15
        self.backButton.center.y = self.frame.height/2
        
        self.profileImageView.frame.size = CGSize(width: 35, height: 35)
        self.profileImageView.layer.cornerRadius = 17.5
        self.profileImageView.frame.origin.x = getViewOriginXEnd(view: self.backButton) + 5
        self.profileImageView.center.y = self.frame.height/2
        
        self.menuOptionButton.frame.size = CGSize(width: 40, height: 40)
        self.menuOptionButton.frame.origin.x = self.frame.width - 55
        self.menuOptionButton.center.y = self.frame.height/2
        
        self.videoCallButton.frame.size = CGSize(width: 40, height: 40)
        self.videoCallButton.frame.origin.x = self.menuOptionButton.frame.origin.x - 45
        self.videoCallButton.center.y = self.frame.height/2
        
        self.voiceCallButton.frame.size = CGSize(width: 40, height: 40)
        self.videoCallButton.frame.origin.x = self.videoCallButton.frame.origin.x - 45
        self.videoCallButton.center.y = self.frame.height/2
        
        self.infoContainerView.frame.origin.x = getViewOriginXEnd(view: self.profileImageView) + 5
        self.infoContainerView.center.y = self.frame.height/2
        self.infoContainerView.frame.size.height = 40
        self.infoContainerView.frame.size.width = self.voiceCallButton.frame.origin.x - self.infoContainerView.frame.origin.x
         */
    }
    
    func hideCallButtons() {
        self.videoCallButtonHeightConstraint.constant = 0
        self.videoCallButtonWidthConstraint.constant = 0
        
        self.voiceCallButtonWidthConstraint.constant = 0
        self.voiceCallButtonHeightConstraint.constant = 0
        self.updateConstraintsIfNeeded()
        self.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //self.setUpViewsFrames()
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
}

class TestController: UIViewController, UISearchBarDelegate {
    
    var headerView: TestControllerHeaderView = {
        let view = TestControllerHeaderView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.titleView = headerView
        self.headerView.setUpViewsFrames(callButtonHidden: false)
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressNavButton))
        self.navigationItem.rightBarButtonItem = rightBarButton
        //self.headerView.hideCallButtons()
        // Do any additional setup after loading the view.
    }
    
    @objc func didPressNavButton() {
        let alertController = UIAlertController(title: "Select Attachment Type", message: "What would you like to send?", preferredStyle: .actionSheet)
        let gifStickerAction = UIAlertAction(title: "Send GIFs and Sticker", style: .default, handler: {(action) in
            let loadingVC = GiphStickerViewController()
            //loadingVC.searchBar.delegate = self
            self.addChild(loadingVC)
            self.view.addSubview(loadingVC.view)
            loadingVC.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 0)
            loadingVC.didMove(toParent: self)
            UIView.transition(with: loadingVC.view, duration: 0.33, options: [.transitionCrossDissolve,.curveEaseOut], animations: {
                loadingVC.view.frame.size.height = 330
                loadingVC.view.frame.origin.y = self.view.frame.height - 330
            }, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(gifStickerAction)
        alertController.addAction(cancelAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            alertController.overrideUserInterfaceStyle = .light
        }
        #endif
        self.present(alertController,animated: true, completion: nil)
        
        
        
        
        
        
        //self.add(self.loadingVC, frame: CGRect(x: 0, y: self.view.frame.height - 300, width: self.view.frame.width, height: 300))
//        UIView.transition(with: self.loadingVC.view, duration: 0.5, options: [.curveLinear], animations: {
//
//        }, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

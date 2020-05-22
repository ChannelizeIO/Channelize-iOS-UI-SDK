//
//  UserProfileViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/5/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage
import ChannelizeCall

class UserProfileViewController: ChannelizeController, UITableViewDelegate, UITableViewDataSource {

    private var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private var userDisplayName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = CHUIConstants.contactNameColor
        label.font = CHUIConstants.contactNameFont
        return label
    }()
    
    private var messageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: "#f5f5f5")
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.setImage(getImage("messageIcon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    
    private var voiceCallButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: "#f5f5f5")
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.imageEdgeInsets = UIEdgeInsets(top: 12.5, left: 12.5, bottom: 12.5, right: 12.5)
        button.setImage(getImage("chVoiceCallIcon"), for: .normal)
        return button
    }()
    
    private var videoCallButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: "#f5f5f5")
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 12.5, left: 12.5, bottom: 12.5, right: 12.5)
        button.setImage(getImage("chVideoCallIcon"), for: .normal)
        return button
    }()
    
    private var userHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#fdfdfd")
        return view
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    private var muteUnMuteSwitch: UISwitch = UISwitch()
    
    var user: CHUser? {
        didSet {
            self.assignUserProfileData()
        }
    }
    
    var conversation: CHConversation?
    
    private var screenIdentifier: UUID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.screenIdentifier = UUID()
        Channelize.addUserEventDelegate(delegate: self, identifier: screenIdentifier)
        Channelize.addConversationEventDelegate(delegate: self, identifier: screenIdentifier)
        self.setUpViews()
        self.tableView.backgroundColor = UIColor(hex: "#f5f5f5")
        self.configureTableHeaderView()
        self.setUpUserHeaderViewFrames()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "userProfileActionCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.userHeaderView.frame.size.height = getDeviceWiseAspectedHeight(constant: 300)
        self.tableView.tableHeaderView = self.userHeaderView
        self.tableView.tableFooterView = UIView()
        self.tableView.contentInset.bottom = 70
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        Channelize.removeConversationDelegate(identifier: self.screenIdentifier)
        Channelize.removeUserEventDelegate(identifier: self.screenIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = self.user?.displayName?.capitalized
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setUpViews() {
        self.view.addSubview(tableView)
        
        self.tableView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.tableView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.tableView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
        self.tableView.setBottomAnchor(relatedConstraint: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
    }
    
    private func configureTableHeaderView() {
        self.userHeaderView.addSubview(userImageView)
        self.userHeaderView.addSubview(userDisplayName)
        self.userHeaderView.addSubview(voiceCallButton)
        self.userHeaderView.addSubview(messageButton)
        self.userHeaderView.addSubview(videoCallButton)
        
        if self.user?.isBlocked == true {
            self.videoCallButton.isEnabled = false
            self.voiceCallButton.isEnabled = false
            self.messageButton.isEnabled = false
        } else {
            self.videoCallButton.isEnabled = true
            self.voiceCallButton.isEnabled = true
            self.messageButton.isEnabled = true
        }
        
        self.messageButton.addTarget(self, action: #selector(didPressMessageButton(sender:)), for: .touchUpInside)
        self.voiceCallButton.addTarget(self, action: #selector(didPressVoiceCallButton(sender:)), for: .touchUpInside)
        self.videoCallButton.addTarget(self, action: #selector(didPressVideoCallButton(sender:)), for: .touchUpInside)
    }
    
    private func setUpUserHeaderViewFrames() {
        self.userImageView.setViewAsCircle(circleWidth: 120)
        self.userImageView.setCenterXAnchor(relatedConstraint: self.userHeaderView.centerXAnchor, constant: 0)
        self.userImageView.setTopAnchor(relatedConstraint: self.userHeaderView.topAnchor, constant: 25)
        
        self.userDisplayName.setTopAnchor(relatedConstraint: self.userImageView.bottomAnchor, constant: 15)
        self.userDisplayName.setLeftAnchor(relatedConstraint: self.userHeaderView.leftAnchor, constant: 50)
        self.userDisplayName.setRightAnchor(relatedConstraint: self.userHeaderView.rightAnchor, constant: -50)
        self.userDisplayName.setHeightAnchor(constant: 50)
        
        self.voiceCallButton.setViewAsCircle(circleWidth: CHConstants.isChannelizeCallAvailable == true ? 50 : 0)
        self.voiceCallButton.setTopAnchor(relatedConstraint: self.userDisplayName.bottomAnchor, constant: 10)
        self.voiceCallButton.setCenterXAnchor(relatedConstraint: self.userHeaderView.centerXAnchor, constant: 0)
        
        self.videoCallButton.setViewAsCircle(circleWidth: CHConstants.isChannelizeCallAvailable == true ? 50 : 0)
        self.videoCallButton.setTopAnchor(relatedConstraint: self.userDisplayName.bottomAnchor, constant: 10)
        self.videoCallButton.setLeftAnchor(relatedConstraint: self.voiceCallButton.rightAnchor, constant: 10)
        
        self.messageButton.setViewAsCircle(circleWidth: 50)
        self.messageButton.setTopAnchor(relatedConstraint: self.userDisplayName.bottomAnchor, constant: 10)
        if CHConstants.isChannelizeCallAvailable {
            self.messageButton.setRightAnchor(relatedConstraint: self.voiceCallButton.leftAnchor, constant: -10)
        } else {
            self.messageButton.setCenterXAnchor(relatedConstraint: self.userHeaderView.centerXAnchor, constant: 0)
        }
        
    }
    
    private func assignUserProfileData() {
        guard let userData = self.user else {
            return
        }
        let userName = userData.displayName?.capitalized ?? ""
        self.userDisplayName.text = userName
        
        if let profileImageUrl = URL(string: userData.profileImageUrl ?? "") {
            let imageWidth = getDeviceWiseAspectedWidth(constant: 120)
            let imageSize = CGSize(width: imageWidth, height: imageWidth)
            
            self.userImageView.sd_imageTransition = .fade
            let thumbnailSize = CGSize(width: getDeviceWiseAspectedWidth(constant: 120*UIScreen.main.scale*2), height: getDeviceWiseAspectedWidth(constant: 120*UIScreen.main.scale*2))
            self.userImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil, options: [.continueInBackground], context: [.imageThumbnailPixelSize : thumbnailSize])
        } else {
            
            let imageGenerator = ImageFromStringProvider(name: userData.displayName?.capitalized ?? "", imageSize: CGSize(width: getDeviceWiseAspectedWidth(constant: 120), height: getDeviceWiseAspectedWidth(constant: 120)))
            let image = imageGenerator.generateImage()
            self.userImageView.image = image
        }
    }
    

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userProfileActionCell", for: indexPath)
            cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 18.0)
            cell.selectionStyle = .none
            cell.textLabel?.textColor = UIColor.customSystemBlue
            cell.backgroundColor = UIColor(hex: "#ffffff")
            if self.user?.isBlocked == true {
                cell.textLabel?.text = "Unblock Contact"
            } else {
                cell.textLabel?.text = "Block Contact"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userProfileActionCell", for: indexPath)
            cell.textLabel?.text = "Groups in Common"
            cell.textLabel?.textColor = CHUIConstants.contactNameColor
            cell.backgroundColor = UIColor(hex: "#ffffff")
            cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 18.0)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if self.user?.isBlocked == true {
                self.callUnblockContactApi()
            } else {
                self.callBlockContactApi()
            }
        } else {
            let controller = CommonGroupesViewController(collectionViewLayout: UICollectionViewFlowLayout())
            controller.user = self.user
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - Button Targets
    @objc private func didPressVoiceCallButton(sender: UIButton) {
        let bundleUrl = Bundle.url(forResource: "ChannelizeCall", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
        let bundle = Bundle(url: bundleUrl!)
        bundle?.load()
        let aClass : AnyClass? = NSClassFromString("ChannelizeCall.CHCall")
        if let callMainClass = aClass as? CallSDKDelegates.Type{
            if let unwrappedUser = self.user {
                callMainClass.launchCallViewController(
                    navigationController: self.navigationController, user: unwrappedUser, type: CHCallScreen.voice.rawValue)
            }
        }
    }
    
    @objc private func didPressVideoCallButton(sender: UIButton) {
        let bundleUrl = Bundle.url(forResource: "ChannelizeCall", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
        let bundle = Bundle(url: bundleUrl!)
        bundle?.load()
        let aClass : AnyClass? = NSClassFromString("ChannelizeCall.CHCall")
        if let callMainClass = aClass as? CallSDKDelegates.Type{
            if let unwrappedUser = self.user {
                callMainClass.launchCallViewController(
                    navigationController: self.navigationController, user: unwrappedUser, type: CHCallScreen.video.rawValue)
            }
        }
    }
    
    @objc private func didPressMessageButton(sender: UIButton) {
        if self.conversation != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            let controller = UIConversationViewController()
            controller.user = self.user
            controller.conversation = nil
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - API Functions
    
    private func callBlockContactApi() {
        guard let userId = self.user?.id else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.blockUser(userId: userId, completion: {[weak self](status,errorString) in
            if status {
                showProgressSuccessView(superView: self?.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self?.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    private func callUnblockContactApi() {
        guard let userId = self.user?.id else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.unblockUser(userId: userId, completion: {[weak self](status,errorString) in
            if status {
                showProgressSuccessView(superView: self?.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self?.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    private func performMuteUnMuteConversation() {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.view, string: nil)
        let isConversationMute = self.conversation?.isMute ?? false
        ChannelizeAPIService.muteConversation(conversationId: conversationId, isMute: !isConversationMute, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
}

extension UserProfileViewController: CHConversationEventDelegate, CHUserEventDelegates {
    func didUserBlocked(model: CHUserBlockModel?) {
        guard model?.blockedUser?.id == self.user?.id else {
            return
        }
        self.user?.isBlocked = true
        self.videoCallButton.isEnabled = false
        self.voiceCallButton.isEnabled = false
        self.messageButton.isEnabled = false
        self.tableView.reloadData()
    }
    
    func didUserUnBlocked(model: CHUserUnblockModel?) {
        guard model?.unblockedUser?.id == self.user?.id else {
            return
        }
        self.user?.isBlocked = false
        self.videoCallButton.isEnabled = true
        self.voiceCallButton.isEnabled = true
        self.messageButton.isEnabled = true
        self.tableView.reloadData()
    }
    
    
    // Conversation Related
    func didUpdateConversationMuteStatus(model: CHConversationMuteStatusModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.conversation?.isMute = model?.conversation?.isMute
        self.tableView.reloadData()
    }
    
}


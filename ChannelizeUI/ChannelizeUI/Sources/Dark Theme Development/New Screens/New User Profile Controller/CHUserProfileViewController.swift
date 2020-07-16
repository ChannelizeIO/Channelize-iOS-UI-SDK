//
//  CHUserProfileViewController.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/3/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

enum UserBlockStatus: String {
    case none = "none"
    case isBlocked = "isBlocked"
    case hasBlocked = "hasBlocked"
    case isNotBlocked = "isNotBlocked"
    case hasNotBlocked = "hasNotBlocked"
}

class CHUserProfileViewController: UITableViewController, CHConversationEventDelegate, CHUserEventDelegates {

    private var userProfileHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        //view.addTopBorder(with: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor, andWidth: 0.5)
        return view
    }()
    
    private var userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#3c3c3c") : UIColor(hex: "#e6e6e6")
        return imageView
    }()
    
    private var userNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = CHCustomStyles.normalSizeRegularFont
        label.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor  : CHLightThemeColors.primaryColor
        label.backgroundColor = .clear
        return label
    }()
    
    private var messageButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#2c2c2c") : UIColor(hex: "#e6e6e6")
        button.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        button.setImage(getImage("messageIcon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    
    private var voiceCallButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#2c2c2c") : UIColor(hex: "#e6e6e6")
        button.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        button.setImage(getImage("chVoiceCallIcon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 12.5, left: 12.5, bottom: 12.5, right: 12.5)
        return button
    }()
    
    private var videoCallButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#2c2c2c") : UIColor(hex: "#e6e6e6")
        button.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        button.setImage(getImage("chVideoCallIcon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 12.5, left: 12.5, bottom: 12.5, right: 12.5)
        return button
    }()
    
    var user: CHUser?
    var conversation: CHConversation?
    private var screenIdentifier: UUID!
    
    private var userIsBlockedStatus = UserBlockStatus.none
    private var userHasBlockedStatus = UserBlockStatus.none
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.user?.displayName?.capitalized
        
        self.screenIdentifier = UUID()
        Channelize.addUserEventDelegate(delegate: self, identifier: screenIdentifier)
        Channelize.addConversationEventDelegate(delegate: self, identifier: screenIdentifier)
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.tableView.indicatorStyle = CHAppConstant.themeStyle == .dark ? .white : .black
        self.userProfileHeaderView.frame.size.height = 300
        self.tableView.tableHeaderView = self.userProfileHeaderView
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "userProfileActionCell")
        self.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor
        self.configureHeaderView()
        self.assignData()
    }
    
    private func configureHeaderView() {
        self.userProfileHeaderView.addSubview(userProfileImageView)
        self.userProfileHeaderView.addSubview(userNameLabel)
        self.userProfileHeaderView.addSubview(messageButton)
        if CHConstants.isChannelizeCallAvailable {
            self.userProfileHeaderView.addSubview(voiceCallButton)
            self.userProfileHeaderView.addSubview(videoCallButton)
        }
        
        self.messageButton.addTarget(self, action: #selector(didPressMessageButton(sender:)), for: .touchUpInside)
        self.voiceCallButton.addTarget(self, action: #selector(didPressVoiceCallButton(sender:)), for: .touchUpInside)
        self.videoCallButton.addTarget(self, action: #selector(didPressVideoCallButton(sender:)), for: .touchUpInside)
        
        
        ChannelizeAPIService.getRelationshipStatus(userId: self.user?.id ?? "", completion: {(statusModel,errorString) in
            guard errorString == nil else {
                return
            }
            if let recievedStatus = statusModel {
                self.userIsBlockedStatus = recievedStatus.isBlocked == true ? UserBlockStatus.isBlocked : UserBlockStatus.isNotBlocked
                self.userHasBlockedStatus = recievedStatus.hasBlocked == true ? UserBlockStatus.hasBlocked : UserBlockStatus.hasNotBlocked
                self.checkBlockStatusAndSetButtons()
                self.tableView.reloadData()
            }
        })
        self.userProfileImageView.frame.size = CGSize(width: 120, height: 120)
        self.userProfileImageView.frame.origin.y = 25
        self.userProfileImageView.center.x = self.tableView.frame.width/2
        self.userProfileImageView.setViewCircular()
        
        self.userNameLabel.frame.size = CGSize(width: self.tableView.frame.width - 30, height: 30)
        self.userNameLabel.frame.origin.x = 15
        self.userNameLabel.frame.origin.y = getViewEndOriginY(view: self.userProfileImageView) + 25
        
        if CHConstants.isChannelizeCallAvailable {
            
            self.voiceCallButton.frame.size = CGSize(width: 50, height: 50)
            self.voiceCallButton.frame.origin.y = getViewEndOriginY(view: self.userNameLabel) + 15
            self.voiceCallButton.center.x = self.userNameLabel.center.x
            self.voiceCallButton.setViewCircular()
            
            self.videoCallButton.frame.size = CGSize(width: 50, height: 50)
            self.videoCallButton.frame.origin.y = getViewEndOriginY(view: self.userNameLabel) + 15
            self.videoCallButton.frame.origin.x = getViewEndOriginX(view: self.voiceCallButton) + 10
            self.videoCallButton.setViewCircular()
            
            self.messageButton.frame.size = CGSize(width: 50, height: 50)
            self.messageButton.frame.origin.y = getViewEndOriginY(view: self.userNameLabel) + 15
            self.messageButton.frame.origin.x = self.voiceCallButton.frame.origin.x - self.messageButton.frame.width - 10
            self.messageButton.setViewCircular()
        } else {
            self.messageButton.frame.size = CGSize(width: 50, height: 50)
            self.messageButton.frame.origin.y = getViewEndOriginY(view: self.userNameLabel) + 15
            self.messageButton.center.x = self.userNameLabel.center.x
            self.messageButton.setViewCircular()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userProfileActionCell", for: indexPath)
            cell.textLabel?.font = CHCustomStyles.normalSizeRegularFont
            cell.selectionStyle = .none
            cell.textLabel?.textColor = UIColor.customSystemBlue
            cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor(hex: "#ffffff")
            if self.userHasBlockedStatus == .hasBlocked {
                cell.textLabel?.text = CHLocalized(key: "pmUnblock")
            } else {
                cell.textLabel?.text = CHLocalized(key: "pmBlockUser")
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userProfileActionCell", for: indexPath)
            cell.textLabel?.text = CHLocalized(key: "pmGroupsInCommon")
            cell.textLabel?.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor
            cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor(hex: "#ffffff")
            cell.textLabel?.font = CHCustomStyles.normalSizeRegularFont
            
            let accessoryImageView = UIImageView(image: getImage("chRightArrowIcon"))
            accessoryImageView.contentMode = .scaleAspectFit
            accessoryImageView.tintColor = CHUIConstant.settingsSceenDiscloseIndicatorColor
            cell.accessoryView = accessoryImageView
            cell.accessoryType = .none
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if self.userHasBlockedStatus == .hasBlocked {
                self.callUnblockContactApi()
            } else {
                self.callBlockContactApi()
            }
        } else {
            let controller = CHCommonGroupsViewController()
            controller.userId = self.user?.id ?? ""
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func checkUserBlockStatus() -> UserBlockStatus{
        if self.conversation?.members?.count == 2 {
            return .none
        } else {
            if self.conversation?.members?.contains(where: {
                $0.user?.id == Channelize.getCurrentUserId()
            }) == true {
                return .hasBlocked
            } else {
                return .isBlocked
            }
        }
    }
    
    func checkBlockStatusAndSetButtons() {
        if self.userIsBlockedStatus == .isBlocked || self.userHasBlockedStatus == .hasBlocked {
            self.videoCallButton.isEnabled = false
            self.voiceCallButton.isEnabled = false
            self.messageButton.isEnabled = false
        } else {
            self.videoCallButton.isEnabled = true
            self.voiceCallButton.isEnabled = true
            self.messageButton.isEnabled = true
        }
    }
    
    // MARK: - Assign Data
    private func assignData() {
        guard let userModel = self.user else {
            return
        }
        let userDisplayName = userModel.displayName?.capitalized ?? ""
        let profileImageUrlString = userModel.profileImageUrl ?? ""
        
        self.userNameLabel.text = userDisplayName
        
        if let profileImageUrl = URL(string: profileImageUrlString) {
            self.userProfileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.userProfileImageView.sd_imageTransition = .fade
            self.userProfileImageView.sd_setImage(with: profileImageUrl, placeholderImage: nil, options: [.continueInBackground], completed: nil)
        } else {
            let imageGenerator = ImageFromStringProvider(name: userDisplayName, imageSize: self.userProfileImageView.frame.size)
            let image = imageGenerator.generateImage(with: 20.0)
            self.userProfileImageView.image = image
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
            let controller = CHConversationViewController()
            //controller.user = self.user
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
    
    func getConversationMembers() {
        guard let conversationId = self.conversation?.id else {
            print("Invalid Conversation Id")
            return
        }
        ChannelizeAPIService.getConversationsMembers(conversationId: conversationId, completion: {(members,errorString) in
            guard errorString == nil else {
                print("Fail to get Members")
                print("Errors: \(errorString ?? "")")
                return
            }
            self.conversation?.members = members
            self.checkBlockStatusAndSetButtons()
            self.tableView.reloadData()
        })
    }

    // MARK: - Channelize MQTT Events Functions
    
    func didUserBlocked(model: CHUserBlockModel?) {
        if model?.blockedUser?.id == self.user?.id && model?.blockerUser?.id == Channelize.getCurrentUserId() {
            self.userHasBlockedStatus = .hasBlocked
            self.checkBlockStatusAndSetButtons()
            self.tableView.reloadData()
        } else if model?.blockerUser?.id == self.user?.id && model?.blockedUser?.id == Channelize.getCurrentUserId() {
            self.userIsBlockedStatus = .isBlocked
            self.checkBlockStatusAndSetButtons()
            self.tableView.reloadData()
        }
    }
    
    func didUserUnBlocked(model: CHUserUnblockModel?) {
        if model?.unblockedUser?.id == self.user?.id && model?.unblockerUser?.id == Channelize.getCurrentUserId() {
            self.userHasBlockedStatus = .hasNotBlocked
            self.checkBlockStatusAndSetButtons()
            self.tableView.reloadData()
        } else if model?.unblockerUser?.id == self.user?.id && model?.unblockedUser?.id == Channelize.getCurrentUserId() {
            self.userIsBlockedStatus = .isNotBlocked
            self.checkBlockStatusAndSetButtons()
            self.tableView.reloadData()
        }
    }
    
    
    // Conversation Related
    func didUpdateConversationMuteStatus(model: CHConversationMuteStatusModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.conversation?.isMute = model?.conversation?.isMute
        self.tableView.reloadData()
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



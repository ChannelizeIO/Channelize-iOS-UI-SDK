//
//  GroupProfileViewController.swift
//  Channelize-API-SDK
//
//  Created by Ashish-BigStep on 2/15/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage
import AVFoundation

class GroupProfileViewController: ChannelizeController, AddMembersToGroupControllerDelegate {
    
    var topHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#000000")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .clear
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(getImage("chBoldBackButton"), for: .normal)
        return button
    }()
    
    var titleView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabSemiBold, size: 22.0)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.text = "Group Profile"
        return label
    }()
    
    private var tableHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var groupImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor(hex: "#FAFAFA")
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var galleryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1.0
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.setImage(getImage("chCameraIcon"), for: .normal)
        return button
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.allowsMultipleSelection = false
        return tableView
    }()
    
    private var editGroupTitleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = CHUIConstants.conversationTitleColor
        button.setImage(getImage("chPencilEditIcon"), for: .normal)
        return button
    }()
    
    private var screenIdentifier: UUID!
    var conversation: CHConversation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.title = "Group Profile"
        self.view.backgroundColor = UIColor(hex: "#f2f2f7")
        self.screenIdentifier = UUID()
        Channelize.addConversationEventDelegate(delegate: self, identifier: self.screenIdentifier)
        //AWSMqttService.addConversationDelegate(self, identifier: self.screenIdentifier)
        self.setUpViews()
        self.setUpViewsFrames()
        self.assignData()
        // Do any additional setup after loading the view.
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        Channelize.removeConversationDelegate(identifier: self.screenIdentifier)
        Channelize.removeUserEventDelegate(identifier: self.screenIdentifier)
    }
    
    private func configureTopHeaderView() {
        self.topHeaderView.addSubview(backButton)
        self.topHeaderView.addSubview(titleView)
        
        self.backButton.addTarget(self, action: #selector(backButtonPressed(sender:)), for: .touchUpInside)
        
        self.backButton.setViewsAsSquare(squareWidth: 35)
        self.backButton.setLeftAnchor(relatedConstraint: self.topHeaderView.leftAnchor, constant: 15)
        self.backButton.setCenterYAnchor(relatedConstraint: self.topHeaderView.centerYAnchor, constant: 0)
        
        self.titleView.setCenterXAnchor(relatedConstraint: self.topHeaderView.centerXAnchor, constant: 0)
        self.titleView.setCenterYAnchor(relatedConstraint: self.topHeaderView.centerYAnchor, constant: 0)
        self.titleView.setWidthAnchor(constant: 200)
        self.titleView.setHeightAnchor(constant: 40)
    }
    
    private func setUpViews() {
        self.view.addSubview(tableView)
        self.view.addSubview(groupImageView)
        self.view.addSubview(galleryButton)
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        let tableHeaderView = UIView()
        tableHeaderView.frame.size.height = 300
        tableHeaderView.backgroundColor = .clear
        self.tableView.tableHeaderView = tableHeaderView
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "actionCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "groupTitleCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "addMemberCell")
        self.tableView.register(GroupProfileUserCell.self, forCellReuseIdentifier: "memberCell")
        self.tableView.contentInset.bottom = 60
        
        self.editGroupTitleButton.frame.size = CGSize(width: 40, height: 40)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true;
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingToParent {
            self.tabBarController?.tabBar.isHidden = false
        }
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc private func backButtonPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func galleryButtonPressed(sender: UIButton) {
        let photoActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {[weak self](action) in
            self?.openPhotoPicker(sourceType: .camera)
        })
        let galleryAction = UIAlertAction(title: "Gallery", style: .default, handler: {[weak self](action) in
            self?.openPhotoPicker(sourceType: .photoLibrary)
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        photoActionSheet.addAction(cameraAction)
        photoActionSheet.addAction(galleryAction)
        photoActionSheet.addAction(cancelAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            photoActionSheet.overrideUserInterfaceStyle = .light
        }
        #endif
        if let popoverController = photoActionSheet.popoverPresentationController {
            showIpadActionSheet(sourceView: self.view, popoverController: popoverController)
        }
        self.present(photoActionSheet, animated: true, completion: nil)
    }
    
    private var profileImageHeightAnchor: NSLayoutConstraint!
    
    private func setUpViewsFrames() {
        self.groupImageView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.groupImageView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.groupImageView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
        self.profileImageHeightAnchor = NSLayoutConstraint(item: self.groupImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 300)
        self.profileImageHeightAnchor.isActive = true
        self.view.addConstraint(profileImageHeightAnchor)
        
        self.galleryButton.setViewAsCircle(circleWidth: 45)
        self.galleryButton.setRightAnchor(relatedConstraint: self.groupImageView.rightAnchor, constant: -10)
        self.galleryButton.setBottomAnchor(relatedConstraint: self.groupImageView.bottomAnchor, constant: -10)
        
        self.tableView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.tableView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.tableView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
        self.tableView.setBottomAnchor(relatedConstraint: self.view.bottomAnchor, constant: 0)
        
        if self.conversation?.isCurrentUserAdmin == true {
            self.galleryButton.isHidden = false
        } else {
            self.galleryButton.isHidden = true
        }
        
        self.galleryButton.addTarget(self, action: #selector(galleryButtonPressed(sender:)), for: .touchUpInside)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 300 - (scrollView.contentOffset.y)
        let height = max(min(y,300),0)
        //let height = min(max(y, 0), 300)
        self.profileImageHeightAnchor.constant = height
        self.view.layoutIfNeeded()
    }
    
    private func assignData() {
        if let profileImageUrl = self.conversation?.profileImageUrl {
            if let url = URL(string: profileImageUrl) {
                
                self.groupImageView.sd_imageTransition = .fade
                self.groupImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.groupImageView.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground], completed: nil)
            } else {
                
                let thumbnailSize = CGSize(width: self.view.frame.width * UIScreen.main.scale * 2, height: getDeviceWiseAspectedWidth(constant: 300 * UIScreen.main.scale * 2))
                
                let imageGenerator = ImageFromStringProvider(name: self.conversation?.title?.capitalized ?? "", imageSize: thumbnailSize)
                let image = imageGenerator.generateImage(with: 35.0 * UIScreen.main.scale * 2)
                self.groupImageView.image = image
            }
        } else {
            let thumbnailSize = CGSize(width: self.view.frame.width * UIScreen.main.scale * 2, height: getDeviceWiseAspectedWidth(constant: 300 * UIScreen.main.scale * 2))
            
            let imageGenerator = ImageFromStringProvider(name: self.conversation?.title?.capitalized ?? "", imageSize: thumbnailSize)
            let image = imageGenerator.generateImage(with: 35.0 * UIScreen.main.scale * 2)
            self.groupImageView.image = image
        }
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

extension GroupProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.conversation?.isCurrentUserAdmin == true ? 1 : 0
        } else if section == 2 {
            return self.conversation?.members?.count ?? 0
        } else if section == 3 {
            if self.conversation?.canReplyToConversation == true {
                return 3
            } else {
                return 2
            }
            
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return getDeviceWiseAspectedHeight(constant: 60)
        } else if indexPath.section == 1 {
            return getDeviceWiseAspectedHeight(constant: 50)
        } else if indexPath.section == 2 {
            return getDeviceWiseAspectedHeight(constant: 70)
        } else {
            return getDeviceWiseAspectedHeight(constant: 50)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupTitleCell", for: indexPath)
            cell.textLabel?.text = self.conversation?.title
            cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)
            cell.backgroundColor = .white
            cell.textLabel?.textColor = CHUIConstants.conversationTitleColor
            cell.selectionStyle = .none
            if self.conversation?.isCurrentUserAdmin == true {
                cell.accessoryView = self.editGroupTitleButton
                self.editGroupTitleButton.isEnabled = false
            } else {
                cell.accessoryView = nil
                self.editGroupTitleButton.isEnabled = false
            }
            cell.textLabel?.isUserInteractionEnabled = false
            return cell
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "addMemberCell", for: indexPath)
            cell.backgroundColor = .white
            cell.textLabel?.textColor = UIColor.customSystemBlue
            cell.textLabel?.text = "Add Members"
            cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)
            cell.selectionStyle = .none
            return cell
            
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! GroupProfileUserCell
            let member = self.conversation?.members![indexPath.row]
            cell.member = member
            cell.backgroundColor = .white
            return cell
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
                cell.textLabel?.textColor = CHUIConstants.conversationTitleColor
                cell.backgroundColor = .white
                cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)
                if self.conversation?.isMute == true {
                    cell.textLabel?.text = "UnMute Conversation"
                } else {
                    cell.textLabel?.text = "Mute Conversation"
                }
                cell.accessoryType = .disclosureIndicator
                cell.accessibilityHint = "muteActionCell"
                cell.selectionStyle = .none
                return cell
            } else if indexPath.row == 1 {
                if self.conversation?.canReplyToConversation == true {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
                    cell.textLabel?.text = "Leave Conversation"
                    cell.backgroundColor = .white
                    cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)
                    cell.textLabel?.textColor = UIColor.customSystemBlue
                    cell.accessoryType = .disclosureIndicator
                    cell.accessibilityHint = "leaveConversationActionCell"
                    cell.selectionStyle = .none
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
                    cell.textLabel?.textColor = UIColor.customSystemRed
                    cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)
                    cell.backgroundColor = .white
                    cell.textLabel?.text = "Delete Conversation"
                    cell.accessoryType = .disclosureIndicator
                    cell.accessibilityHint = "deleteConversationActionCell"
                    cell.selectionStyle = .none
                    return cell
                }
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
                cell.textLabel?.textColor = UIColor.customSystemRed
                cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)
                cell.backgroundColor = .white
                cell.textLabel?.text = "Delete Conversation"
                cell.accessoryType = .disclosureIndicator
                cell.accessibilityHint = "deleteConversationActionCell"
                cell.selectionStyle = .none
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if self.conversation?.isCurrentUserAdmin == true {
                    self.showGroupTitleEditAlert()
                }
            }
        } else if indexPath.section == 1 {
            let allLoadedUsers = CHAllContacts.contactsList
            var nonMemberUsers = [CHUser]()
            var currentUserIds = [String]()
            self.conversation?.members?.forEach({
                currentUserIds.append($0.user?.id ?? "")
            })
            nonMemberUsers = allLoadedUsers.filter({
                !currentUserIds.contains($0.id ?? "")
            })
            
            let controller = AddMembersToGroupViewController()
            controller.delegate = self
            //controller.allUsers = nonMemberUsers
            controller.currentMembers = self.conversation?.members ?? []
            self.navigationController?.pushViewController(
                controller, animated: true)
        } else if indexPath.section == 2 {
            if let member = self.conversation?.members?[indexPath.row] {
                self.showUserOptionsAlert(for: member)
            }
        } else if indexPath.section == 3 {
            let cell = tableView.cellForRow(at: indexPath)
            switch cell?.accessibilityHint ?? "" {
            case "muteActionCell":
                self.performMuteUnMuteConversation()
                break
            case "leaveConversationActionCell":
                if (self.conversation?.members?.first(where: {
                    $0.isAdmin == true && $0.user?.id != Channelize.getCurrentUserId()
                })) != nil {
                    self.performGroupLeaveConversation()
                } else {
                    self.showErrorAlert(message: "You're only admin. Choose someone else as admin.", title: nil)
                }
                break
            case "deleteConversationActionCell":
                self.performGroupDeleteConversation()
                break
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return " "
        } else if section == 2 {
            return "Members"
        } else {
            return " "
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 40
        } else if section == 0 {
            return 0
        } else {
            return 10
        }
    }
    
    private func showUserOptionsAlert(for user: CHMember) {
        
        guard user.userId != Channelize.getCurrentUserId() else {
            return
        }
        
        let optionsController = UIAlertController(title: nil, message: user.user?.displayName?.capitalized, preferredStyle: .actionSheet)
        let infoAction = UIAlertAction(title: "Info", style: .default, handler: {[weak self](action) in
            let controller = UserProfileViewController()
            controller.user = user.user
            controller.conversation = nil
            controller.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(
                controller, animated: true)
        })
        let messageAction = UIAlertAction(title: "Send Message", style: .default, handler: {[weak self](action) in
            let controller = UIConversationViewController()
            controller.user = user.user
            controller.conversation = nil
            controller.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(
                controller, animated: true)
        })
        let voiceCallAction = UIAlertAction(title: "Voice Call", style: .default, handler: {[weak self](action) in
            self?.showVoiceCallController(user: user.user)
        })
        let videoCallAction = UIAlertAction(title: "Video Call", style: .default, handler: {[weak self](action) in
            self?.showVideoCallController(user: user.user)
        })
        optionsController.addAction(infoAction)
        optionsController.addAction(messageAction)
        optionsController.addAction(voiceCallAction)
        optionsController.addAction(videoCallAction)
        if self.conversation?.isCurrentUserAdmin == true {
            let makeAdminAction = UIAlertAction(title: "Make Group Admin", style: .default, handler: {[weak self](action) in
                let userId = user.userId ?? ""
                self?.makeMemberAdmin(userId: userId)
            })
            let removeMemberAction = UIAlertAction(title: "Remove From Group", style: .destructive, handler: {[weak self](action) in
                let userId = user.userId ?? ""
                self?.removeMembers(userId: userId)
            })
            
            if user.isAdmin == false {
                optionsController.addAction(makeAdminAction)
            }
            optionsController.addAction(removeMemberAction)
        }
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        optionsController.addAction(cancelAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            optionsController.overrideUserInterfaceStyle = .light
        }
        #endif
        if let popoverController = optionsController.popoverPresentationController {
            showIpadActionSheet(sourceView: self.view, popoverController: popoverController)
        }
        self.present(optionsController, animated: true, completion: nil)
    }
    
    private func setUpGroupNameSection() {
        
    }
    
    private func showErrorAlert(message: String?, title: String?) {
        let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        errorAlert.addAction(okAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            errorAlert.overrideUserInterfaceStyle = .light
        }
        #endif
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    private func showGroupTitleEditAlert() {
        let changeTitleAlert = UIAlertController(title: "Edit Group Title", message: self.conversation?.title, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: {[weak self](action) in
            let textField = changeTitleAlert.textFields?.first
            self?.updateConversationTitle(newTitle: textField?.text)
        })
        changeTitleAlert.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.text = self.conversation?.title
        })
        changeTitleAlert.addAction(doneAction)
        changeTitleAlert.addAction(cancelAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            changeTitleAlert.overrideUserInterfaceStyle = .light
        }
        #endif
        self.present(changeTitleAlert, animated: true, completion: nil)
    }
    
    // MARK: - Button Targets
    func showVoiceCallController(user: CHUser?) {
        let bundleUrl = Bundle.url(forResource: "ChannelizeCall", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
        let bundle = Bundle(url: bundleUrl!)
        bundle?.load()
        let aClass : AnyClass? = NSClassFromString("ChannelizeCall.CHCall")
        if let callMainClass = aClass as? CallSDKDelegates.Type {
            if let unwrappedUser = user {
                callMainClass.launchCallViewController(
                    navigationController: self.navigationController, user: unwrappedUser, type: CHCallScreen.voice.rawValue)
            }
        }
    }
    
    func showVideoCallController(user: CHUser?) {
        let bundleUrl = Bundle.url(forResource: "ChannelizeCall", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
        let bundle = Bundle(url: bundleUrl!)
        bundle?.load()
        let aClass : AnyClass? = NSClassFromString("ChannelizeCall.CHCall")
        if let callMainClass = aClass as? CallSDKDelegates.Type {
            if let unwrappedUser = user {
                callMainClass.launchCallViewController(
                    navigationController: self.navigationController, user: unwrappedUser, type: CHCallScreen.video.rawValue)
            }
        }
    }
}

// MARK: - API Functions
extension GroupProfileViewController {
    
    private func performGroupDeleteConversation() {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.deleteConversation(conversationId: conversationId, completion: {(status,errorSting) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorSting)
            }
        })
    }
    
    private func performGroupLeaveConversation() {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.leaveConversation(conversatinoId: conversationId, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
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
    
    private func updateConversationTitle(newTitle: String?) {
        guard let conversationId = self.conversation?.id else {
            return
        }
        guard let updatedTitle = newTitle, updatedTitle != "" else {
            return
        }
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.updateConversationTitle(conversationId: conversationId, newTitle: updatedTitle, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
    
    private func removeMembers(userId: String) {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.removeMemberFromConversation(conversationId: conversationId, userIds: [userId], completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
    
    private func makeMemberAdmin(userId: String) {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.addAdminToConversation(conversationId: conversationId, userId: userId, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
    
    private func addMembersToGroup(userIds: [String]) {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.addMembersToConversation(conversationId: conversationId, userIds: userIds, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
}


/*
extension GroupProfileViewController: CHConversationDelegate {
    func didCurrentMemberRemovedFromConversation(conversationId: String?, updatedAt: Date?, newMemberCount: Int?) {
        guard conversationId == self.conversation?.id else {
            return
        }
        self.conversation?.lastUpDatedAt = updatedAt
        self.conversation?.membersCount = newMemberCount
        self.navigationController?.popViewController(animated: false)
    }
    
    func didNewAdminAdded(conversationId: String?, isAdmin: Bool, userId: String?) {
        if let firstMember = self.conversation?.members?.first(where: {
            $0.userId == userId
        }) {
            firstMember.isAdmin = isAdmin
            self.tableView.reloadData()
        }
    }
    
    func didReceiveNewMessage(message: CHMessage2?) {
        
    }
    
    func didGetUpdatedConversationInfo(conversationInfo: CHUpdatedConversationInfo?) {
        self.conversation?.title = conversationInfo?.title
        self.conversation?.profileImageUrl = conversationInfo?.profileImageUrl
        self.conversation?.lastUpDatedAt = conversationInfo?.updatedAt
        self.assignData()
        self.tableView.reloadData()
    }
    
    func didConversationDeleted(conversationId: String?) {
        guard conversationId == self.conversation?.id else {
            return
        }
        if let recentChatController = self.navigationController?.viewControllers.first(where: {
            $0.isKind(of: RecentChatController.self)
        }) {
            self.navigationController?.popToViewController(recentChatController, animated: false)
        }
    }
    
    func didConversationCleared(conversationId: String?) {
        
    }
    
    func didOtherMembersRemovedFromGroup(conversationId: String?, updatedAt: Date?, newMemberCount: Int?, removedMemberIds: [String]?) {
        guard conversationId == self.conversation?.id else {
            return
        }
        self.conversation?.membersCount = newMemberCount
        self.conversation?.lastUpDatedAt = updatedAt
        if let removedIds = removedMemberIds {
            removedIds.forEach({
                let userId = $0
                self.conversation?.members?.removeAll(where: {
                    $0.userId == userId
                })
            })
        }
        self.tableView.reloadData()
    }
    
    func didOtherMembersAddedToGroup(conversationId: String?, updatedAt: Date?, newMemberCount: Int?, addedMembers: [CHMember2]?) {
        guard conversationId == self.conversation?.id else {
            return
        }
        self.conversation?.membersCount = newMemberCount
        self.conversation?.lastUpDatedAt = updatedAt
        if let addedusers = addedMembers {
            self.conversation?.members?.append(contentsOf: addedusers)
        }
        self.tableView.reloadData()
    }
    
    func didMessagesDeleted(conversationId: String?, messageIds: [String]?, updatedAt: Date?, lastMesageObject: CHMessage2?) {
        
    }
    
    func didChangeTypingStatus(conversationId: String?, userId: String?, isTyping: Bool?) {
        
    }
    
    func didMuteUnMuteConversation(conversationId: String?, userId: String?, isMute: Bool?) {
        guard self.conversation?.id == conversationId else {
            return
        }
        self.conversation?.isMute = isMute
        self.tableView.reloadData()
    }
    
    
}
*/
extension GroupProfileViewController {
    private func reloadTable(withDeletedIndexPaths: [IndexPath]?, insertedIndexPaths: [IndexPath]?, reloadedIndexPaths: [IndexPath]?) {
        self.tableView.performBatchUpdates({
            if withDeletedIndexPaths != nil {
                self.tableView.deleteRows(at: withDeletedIndexPaths!, with: .automatic)
            }
            if insertedIndexPaths != nil {
                self.tableView.insertRows(at: insertedIndexPaths!, with: .automatic)
            }
            if reloadedIndexPaths != nil {
                self.tableView.reloadRows(at: reloadedIndexPaths!, with: .automatic)
            }
            
        }, completion: nil)
    }
}

// MARK: - Functions Gallery Related
extension GroupProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            presentCameraSettings()
        case .restricted:
            print("Restricted, device owner must approve")
        case .authorized:
            self.openCamera()
            print("Authorized, proceed")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    DispatchQueue.main.async {
                        self.openCamera()
                    }
                    print("Permission granted, proceed")
                } else {
                    DispatchQueue.main.async {
                        self.presentCameraSettings()
                    }
                    print("Permission denied")
                }
            }
        }
    }
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Camera access is denied",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            alertController.overrideUserInterfaceStyle = .light
        }
        #endif
        present(alertController, animated: true)
    }
    
    private func openCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        //vc.allowsEditing = true
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    private func openPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        if sourceType == .camera {
            self.checkCameraAccess()
//            let vc = UIImagePickerController()
//            vc.sourceType = .camera
//            vc.allowsEditing = true
//            vc.delegate = self
//            self.present(vc, animated: true)
        } else {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = sourceType
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
        
        
        
        
//        if sourceType == .camera {
//            controller.showsCameraControls = true
//            controller.takePicture()
//        } else {
//
//        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var profileImage:UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            profileImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profileImage = originalImage
        }
        
        if let imageData = profileImage?.jpegData(compressionQuality: 0.5) {
            showProgressView(superView: self.view, string: nil)
            ChannelizeAPIService.updateConversationProfileImage(conversationId: self.conversation?.id ?? "", profileImageUrl: nil, imageData: imageData, completion: {(status,errorString) in
                if status {
                    showProgressSuccessView(superView: self.view, withStatusString: nil)
                } else {
                    showProgressErrorView(superView: self.view, errorString: errorString)
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension GroupProfileViewController: CHConversationEventDelegate {
    func didConversationDeleted(model: CHConversationDeleteModel?) {
        
    }
    
    func didConversationCleared(model: CHConversationClearModel?) {
        
    }
    
    func didConversationInfoUpdated(model: CHConversationUpdatedModel?) {
        
        guard model?.conversationID == self.conversation?.id else {
            return
        }
        self.conversation?.title = model?.title
        self.conversation?.profileImageUrl = model?.profileImageUrl
        self.conversation?.lastUpDatedAt = model?.timeStamp
        self.conversation?.membersCount = model?.memberCount
        self.assignData()
        self.tableView.reloadData()
    }
    
    func didCurrentUserRemovedFromConversation(model: CHCurrentUserRemovedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    
    func didUpdateConversationMuteStatus(model: CHConversationMuteStatusModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.conversation?.isMute = model?.conversation?.isMute
        self.tableView.reloadData()
    }
    
    
    func didNewAdminAddedToConversation(model: CHNewAdminAddedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        if let adminUser = model?.adminUser {
            
            if let firstUser = self.conversation?.members?.first(where: {
                $0.user?.id == adminUser.id
            }) {
                firstUser.isAdmin = true
            }
            if adminUser.id == Channelize.getCurrentUserId() {
                self.conversation?.isCurrentUserAdmin = true
                self.galleryButton.isHidden = false
            }
        }
        self.tableView.reloadData()
    }
    
    func didMembersRemovedFromConversation(model: CHMembersRemovedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        guard var conversationMembers = self.conversation?.members else {
            return
        }
        if let removedUsers = model?.removedUsers {
            removedUsers.forEach({
                let userId = $0.id
                conversationMembers.removeAll(where: {
                    $0.user?.id == userId
                })
            })
        }
        self.conversation?.members = conversationMembers
        //self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
        self.tableView.reloadData()
    }
    
    func didNewMembersAddedToConversation(model: CHNewMemberAddedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        if let addedMembers = model?.addedMembers {
            addedMembers.forEach({
                let member = $0
                if self.conversation?.members?.contains(where: {
                    $0.user?.id == member.user?.id
                }) == false {
                    self.conversation?.members?.append($0)
                }
            })
        }
        //self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
        self.tableView.reloadData()
    }
    func didSelectMembersToAdd(users: [CHUser]) {
        var addedUserIds = [String]()
        users.forEach({
            if let userId = $0.id {
                addedUserIds.append(userId)
            }
        })
        self.addMembersToGroup(userIds: addedUserIds)
    }
}
/*
extension GroupProfileViewController: AddMembersToGroupControllerDelegate {
    func didSelectMembersToAdd(users: [CHUser]) {
        var addedUserIds = [String]()
        users.forEach({
            if let userId = $0.id {
                addedUserIds.append(userId)
            }
        })
        self.addMembersToGroup(userIds: addedUserIds)
    }
}
 */


//
//  CHGroupProfileViewController.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/3/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage
import AVFoundation

protocol AddMembersToGroupControllerDelegate {
    func didSelectMembersToAdd(users: [CHUser])
}

class CHGroupProfileViewController: UITableViewController, CHConversationEventDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, AddMembersToGroupControllerDelegate {
    
    private var groupHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var groupImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#3c3c3c") : UIColor(hex: "#FAFAFA")
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var galleryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.imageView?.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.setImage(getImage("chCameraIcon"), for: .normal)
        return button
    }()
    
    private var editGroupTitleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = CHAppConstant.themeStyle == .dark ? UIColor.white : CHUIConstant.recentConversationTitleColor
        button.setImage(getImage("chPencilEditIcon"), for: .normal)
        return button
    }()
    
    var conversation: CHConversation?
    var screenIdentifier: UUID!
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenIdentifier = UUID()
        Channelize.addConversationEventDelegate(delegate: self, identifier: self.screenIdentifier)
        
        if self.conversation?.members == nil {
            self.getConversationMembers()
        }
        
        self.title = self.conversation?.title
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.groupedTableBackGroundColor : CHLightThemeColors.groupedTableBackGroundColor
        self.tableView.indicatorStyle = CHAppConstant.themeStyle == .dark ? .white : .black
        self.configureHeaderView()
        self.assignData()
        self.groupHeaderView.frame.size.height = 300
        self.tableView.tableHeaderView = self.groupHeaderView
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "groupTitleCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "addMemberCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "actionCell")
        self.tableView.register(ContactActionTableCell.self, forCellReuseIdentifier: "membersCell")
        self.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor
        self.editGroupTitleButton.frame.size = CGSize(width: 40, height: 40)
        self.conversation?.members?.sort(by: { $0.user?.displayName?.capitalized ?? "" < $1.user?.displayName?.capitalized ?? ""})
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func configureHeaderView() {
        self.groupHeaderView.addSubview(groupImageView)
        self.groupHeaderView.addSubview(galleryButton)
        
        // Set Frames
        self.groupImageView.pinEdgeToSuperView(superView: self.groupHeaderView)
        
        self.galleryButton.setViewAsCircle(circleWidth: 50)
        self.galleryButton.setRightAnchor(relatedConstraint: self.groupHeaderView.rightAnchor, constant: -15)
        self.galleryButton.setBottomAnchor(relatedConstraint: self.groupHeaderView.bottomAnchor, constant: -15)
        
        if self.conversation?.members?.first(where: {
            $0.user?.id == Channelize.getCurrentUserId()
        })?.isAdmin == true {
            self.galleryButton.isHidden = false
        } else {
            self.galleryButton.isHidden = true
        }
        self.galleryButton.addTarget(self, action: #selector(galleyButtonPressed(sender:)), for: .touchUpInside)
    }
    
    private func assignData() {
        if let profileImageUrl = self.conversation?.profileImageUrl {
            if let url = URL(string: profileImageUrl) {
                self.groupImageView.sd_imageTransition = .fade
                self.groupImageView.sd_imageIndicator = CHAppConstant.themeStyle == .dark ? SDWebImageActivityIndicator.white :  SDWebImageActivityIndicator.gray
                self.groupImageView.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground], completed: nil)
            } else {
                let thumbnailSize = CGSize(width: self.view.frame.width * 2, height: 600)
                let imageGenerator = ImageFromStringProvider(name: self.conversation?.title?.capitalized ?? "", imageSize: thumbnailSize)
                let image = imageGenerator.generateImage(with: 35.0 * 2)
                self.groupImageView.image = image
            }
        } else {
            let thumbnailSize = CGSize(width: self.view.frame.width * 2, height: 600)
            let imageGenerator = ImageFromStringProvider(name: self.conversation?.title?.capitalized ?? "", imageSize: thumbnailSize)
            let image = imageGenerator.generateImage(with: 35.0 * 2)
            self.groupImageView.image = image
        }
    }
    
    @objc private func galleyButtonPressed(sender: UIButton) {
        let cameraAction = CHActionSheetAction(title: CHLocalized(key: "pmCamera"), image: nil, actionType: .default, handler: {(action) in
            self.openPhotoPicker(sourceType: .camera)
        })
        
        let galleryAction = CHActionSheetAction(title: CHLocalized(key: "pmGallery"), image: nil, actionType: .default, handler: {(action) in
            self.openPhotoPicker(sourceType: .photoLibrary)
        })
        let actionSheetController = CHActionSheetController()
        actionSheetController.actions = [cameraAction,galleryAction]
        actionSheetController.modalPresentationStyle = .overCurrentContext
        actionSheetController.modalTransitionStyle = .crossDissolve
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func didSelectMembersToAdd(users: [CHUser]) {
        
    }
    
    // MARK: - UITableView Functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if let myMember = self.conversation?.members?.first(where: {
                $0.user?.id == Channelize.getCurrentUserId()
            }) {
                if myMember.isAdmin == true {
                    return 1
                } else {
                    return 0
                }
            } else {
                return 0
            }
        } else if section == 2 {
            return self.conversation?.members?.count ?? 0
        } else if section == 3 {
            if self.conversation?.isActive == true {
                return 2
            } else {
                return 1
            }
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupTitleCell", for: indexPath)
            cell.textLabel?.text = self.conversation?.title
            cell.textLabel?.font = CHCustomStyles.normalSizeRegularFont
            cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
            cell.textLabel?.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor
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
            cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
            cell.textLabel?.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
            cell.textLabel?.text = CHLocalized(key: "pmAddMembers")
            cell.textLabel?.font = CHCustomStyles.normalSizeRegularFont
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 3{
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
                cell.textLabel?.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
                cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
                cell.textLabel?.font = CHCustomStyles.normalSizeRegularFont
                if self.conversation?.isMute == true {
                    cell.textLabel?.text = CHLocalized(key: "pmUnmuteConversation")
                } else {
                    cell.textLabel?.text = CHLocalized(key: "pmMuteConversation")
                }
                cell.accessibilityHint = "muteActionCell"
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
                cell.textLabel?.text = CHLocalized(key: "pmLeaveConversation")
                cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
                cell.textLabel?.font = CHCustomStyles.normalSizeRegularFont
                cell.textLabel?.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
                cell.accessibilityHint = "leaveConversationActionCell"
                cell.selectionStyle = .none
                return cell
            }
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
            cell.textLabel?.textColor = UIColor.customSystemRed
            cell.textLabel?.font = CHCustomStyles.normalSizeRegularFont
            cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
            cell.textLabel?.text = CHLocalized(key: "pmDeleteConversation")
            cell.accessibilityHint = "deleteConversationActionCell"
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "membersCell", for: indexPath) as! ContactActionTableCell
            cell.setUpViews()
            cell.setUpViewsFrames(hideRemoveButton: true)
            cell.member = (self.conversation?.members ?? [])[indexPath.row]
            cell.user = (self.conversation?.members ?? [])[indexPath.row].user
            cell.assignData()
            cell.setUpUIProperties()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 65
        } else {
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return CHLocalized(key: "pmMembers")
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let controller = CHAlertViewController()
            controller.addTextField(configuration: {(textField) in
                textField.text = self.conversation?.title
                textField.accessibilityHint = "editGroupTitle"
            })
            let doneAction = CHActionSheetAction(title: CHLocalized(key: "pmDone"), image: nil, actionType: .default, handler: {(action) in
                let textfield = controller.textFields.first(where: {
                    $0.accessibilityHint == "editGroupTitle"
                })
                self.updateConversationTitle(newTitle: textfield?.text)
            })
            
            let cancelAction = CHActionSheetAction(title: CHLocalized(key: "pmCancel"), image: nil, actionType: .cancel, handler: {(action) in
                
            })
            controller.alertTitle = CHLocalized(key: "pmEditGroupTitle")
            controller.actions = [doneAction,cancelAction]
            controller.modalPresentationStyle = .overCurrentContext
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        } else if indexPath.section == 1 {
            let controller = CHAddMembersToGroupController()
            controller.skipUserIds = self.conversation?.members?.compactMap({ $0.user?.id ?? ""}) ?? []
            controller.onDoneButtonPressed = {[weak self](selectedUsers) in
                let userIds = selectedUsers.compactMap({ $0.id ?? ""})
                self?.addMembersToGroup(userIds: userIds)
            }
            self.navigationController?.pushViewController(controller, animated: true)
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
                    self.showErrorAlert(message: CHLocalized(key: "pmAddGroupAdminAlertText"), title: nil)
                }
                break
            default:
                break
            }
        } else if indexPath.section == 4 {
            self.performGroupDeleteConversation()
        }
    }
    
    // MARK: - Other Functions
    private func showErrorAlert(message: String?, title: String?) {
        let alertController = CHAlertViewController()
        alertController.alertTitle = CHLocalized(key: "pmError")
        alertController.alertDescription = message
        let okAction = CHActionSheetAction(title: CHLocalized(key: "pmOk"), image: nil, actionType: .default, handler: nil)
        alertController.actions.append(okAction)
        alertController.modalTransitionStyle = .crossDissolve
        alertController.modalPresentationStyle = .overCurrentContext
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func showUserOptionsAlert(for user: CHMember) {
        
        guard user.userId != Channelize.getCurrentUserId() else {
            return
        }
        
        let InfoAction = CHActionSheetAction(title: CHLocalized(key: "pmViewProfile"), image: nil, actionType: .default, handler: {(action) in
            let userProfileViewController = CHUserProfileViewController()
            let conversation = CHConversation()
            userProfileViewController.user = user.user
            userProfileViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(userProfileViewController, animated: true)
        })
        let sendMessageAction = CHActionSheetAction(title: CHLocalized(key: "pmMessage"), image: nil, actionType: .default, handler: {(action) in
            let controller = CHConversationViewController()
            let conversation = CHConversation()
            conversation.conversationPartner = user.user
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        })
        let voiceCallAction = CHActionSheetAction(title: CHLocalized(key: "pmVoiceCall"), image: nil, actionType: .default, handler: {[weak self](action) in
            self?.showVoiceCallController(user: user.user)
        })
        let videoCallAction = CHActionSheetAction(title: CHLocalized(key: "pmVideoCall"), image: nil, actionType: .default, handler: {[weak self](action) in
            self?.showVideoCallController(user: user.user)
        })
        
        let makeAdminAction = CHActionSheetAction(title: CHLocalized(key: "pmMakeGroupAdminText"), image: nil, actionType: .default, handler: {[weak self](action) in
            let userId = user.userId ?? ""
            self?.makeMemberAdmin(userId: userId)
        })
        let removeMemberAction = CHActionSheetAction(title: CHLocalized(key: "pmRemoveUser"), image: nil, actionType: .destructive, handler: {[weak self](action) in
            let userId = user.userId ?? ""
            self?.removeMembers(userId: userId)
        })
        
        let controller = CHActionSheetController()
        controller.actions.append(InfoAction)
        if CHConstants.isChannelizeCallAvailable {
            controller.actions.append(voiceCallAction)
            controller.actions.append(videoCallAction)
        }
        if self.conversation?.isCurrentUserAdmin == true {
            if user.isAdmin == false {
                controller.actions.append(makeAdminAction)
            }
            controller.actions.append(removeMemberAction)
        }
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
    }
    
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
    
    // MARK: - Gallery Related Functions
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
        let alertController = UIAlertController(title: CHLocalized(key: "pmError"),
                                                message: CHLocalized(key: "pmAllowCameraPermission"),
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .default))
        alertController.addAction(UIAlertAction(title: CHLocalized(key: "pmSettings"), style: .cancel) { _ in
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
        vc.delegate = self
        self.present(vc, animated: true)
    }
        
    private func openPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        if sourceType == .camera {
            self.checkCameraAccess()
        } else {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = sourceType
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
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
        showProgressView(superView: self.navigationController?.view, string: nil)
        if let imageData = profileImage?.jpegData(compressionQuality: 0.5) {
            ChannelizeAPIService.updateConversationProfileImage(conversationId: self.conversation?.id ?? "", profileImageUrl: nil, imageData: imageData, completion: {(status,errorString) in
                if status {
                    showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
                } else {
                    showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - MQTT Functions
    func didMembersRemovedFromConversation(model: CHMembersRemovedModel?) {
        guard self.conversation?.isGroup == true else {
            return
        }
        guard self.conversation?.id == model?.conversation?.id else {
            return
        }
        guard let removedUsers = model?.removedUsers else {
            return
        }
        
        removedUsers.forEach({
            let userId = $0.id
            self.conversation?.members?.removeAll(where: {
                $0.user?.id == userId
            })
        })
        self.conversation?.members?.sort(by: { $0.user?.displayName?.capitalized ?? "" < $1.user?.displayName?.capitalized ?? ""})
        self.conversation?.membersCount = self.conversation?.members?.count
        self.tableView.reloadData()
    }
    
    func didNewMembersAddedToConversation(model: CHNewMemberAddedModel?) {
        guard self.conversation?.isGroup == true else {
            return
        }
        guard self.conversation?.id == model?.conversation?.id else {
            return
        }
        guard let addedMembers = model?.addedMembers else {
            return
        }
        
        addedMembers.forEach({
            let member = $0
            if self.conversation?.members?.filter({
                $0.user?.id == member.user?.id
            }).count == 0 {
                self.conversation?.members?.append(member)
            }
        })
        self.conversation?.members?.sort(by: { $0.user?.displayName?.capitalized ?? "" < $1.user?.displayName?.capitalized ?? ""})
        self.conversation?.membersCount = self.conversation?.members?.count
        self.tableView.reloadData()
        
    }
    
    func didCurrentUserRemovedFromConversation(model: CHCurrentUserRemovedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.conversation?.members?.removeAll(where: {
            $0.user?.id == Channelize.getCurrentUserId()
        })
        self.conversation?.members?.sort(by: { $0.user?.displayName?.capitalized ?? "" < $1.user?.displayName?.capitalized ?? ""})
        self.conversation?.membersCount = self.conversation?.members?.count
        self.conversation?.isActive = false
        self.galleryButton.isHidden = true
        self.tableView.reloadData()
    }
    
    func didCurrentUserJoinedConversation(model: CHCurrentUserJoinConversationModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.conversation?.members?.sort(by: { $0.user?.displayName?.capitalized ?? "" < $1.user?.displayName?.capitalized ?? ""})
        self.conversation?.isActive = true
        self.getConversationMembers()
        //self.tableView.reloadData()
    }
    
    func didNewAdminAddedToConversation(model: CHNewAdminAddedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        if let addedAdmin = model?.adminUser {
            if let adminMember = self.conversation?.members?.first(where: {
                $0.user?.id == addedAdmin.id
            }) {
                adminMember.isAdmin = true
            }
            if addedAdmin.id == Channelize.getCurrentUserId() {
                self.galleryButton.isHidden = false
            }
        }
        self.tableView.reloadData()
    }
    
    func didConversationInfoUpdated(model: CHConversationUpdatedModel?) {
        guard model?.conversationID == self.conversation?.id else {
            return
        }
        self.conversation?.membersCount = model?.memberCount
        self.conversation?.profileImageUrl = model?.profileImageUrl
        self.conversation?.title = model?.title
        self.conversation?.createdAt = model?.createdAt
        self.conversation?.isGroup = model?.isGroup
        self.conversation?.lastUpDatedAt = model?.timeStamp
        self.title = self.conversation?.title
        self.tableView.reloadData()
        //self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        self.assignData()
    }
    
    func didUpdateConversationMuteStatus(model: CHConversationMuteStatusModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.conversation?.isMute = model?.conversation?.isMute
        self.tableView.reloadData()
    }
    
    func didConversationDeleted(model: CHConversationDeleteModel?) {
        if let allControllers = self.navigationController?.viewControllers {
            if allControllers.count == 3 {
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                guard allControllers.count > 3 else {
                    return
                }
                let jumpToController = allControllers[allControllers.count - 2]
                self.navigationController?.popToViewController(jumpToController, animated: false)
            }
        }
    }
    
    
    // MARK: - API Functions
    private func getConversationMembers() {
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
            self.conversation?.membersCount = self.conversation?.members?.count
            self.conversation?.members?.sort(by: { $0.user?.displayName?.capitalized ?? "" < $1.user?.displayName?.capitalized ?? ""})
            self.tableView.reloadData()
        })
    }
    
    private func updateConversationTitle(newTitle: String?) {
        guard let conversationId = self.conversation?.id else {
            return
        }
        guard let updatedTitle = newTitle, updatedTitle != "" else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.updateConversationTitle(conversationId: conversationId, newTitle: updatedTitle, completion: {(status,errorString) in
            if status {
                self.conversation?.title = newTitle
                self.title = newTitle
                self.tableView.reloadData()
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    private func makeMemberAdmin(userId: String) {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.addAdminToConversation(conversationId: conversationId, userId: userId, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    private func addMembersToGroup(userIds: [String]) {
        guard let conversationId = self.conversation?.id else {
            return
        }
        guard userIds.count > 0 else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.addMembersToConversation(conversationId: conversationId, userIds: userIds, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    private func removeMembers(userId: String) {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.removeMemberFromConversation(conversationId: conversationId, userIds: [userId], completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    private func performGroupDeleteConversation() {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.deleteConversation(conversationId: conversationId, completion: {(status,errorSting) in
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorSting)
            }
        })
    }
    
    private func performGroupLeaveConversation() {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.leaveConversation(conversatinoId: conversationId, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    private func performMuteUnMuteConversation() {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        let isConversationMute = self.conversation?.isMute ?? false
        ChannelizeAPIService.muteConversation(conversationId: conversationId, isMute: !isConversationMute, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
}

/*
class CHGroupProfileViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var groupHeaderView: UIView = {
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
        button.imageView?.tintColor = CHAppConstant.themeStyle == .dark ? UIColor.customSystemBlue : CHUIConstant.appTintColor
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
        button.imageView?.tintColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#4a505a")
        button.setImage(getImage("chPencilEditIcon"), for: .normal)
        return button
    }()
    
    var conversation: CHConversation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func configureHeaderView() {
        self.groupHeaderView.addSubview(groupImageView)
        self.groupHeaderView.addSubview(galleryButton)
        
        // Set Frames
        self.groupImageView.frame.size = CGSize(width: <#T##CGFloat#>, height: <#T##CGFloat#>)
        self.groupImageView.pinEdgeToSuperView(superView: self.groupHeaderView)
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
        self.tableView.register(ContactActionTableCell.self, forCellReuseIdentifier: "memberCell")
        self.tableView.contentInset.bottom = 60
        
        self.editGroupTitleButton.frame.size = CGSize(width: 40, height: 40)
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
    
    // MARK: - UITableView Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
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
*/



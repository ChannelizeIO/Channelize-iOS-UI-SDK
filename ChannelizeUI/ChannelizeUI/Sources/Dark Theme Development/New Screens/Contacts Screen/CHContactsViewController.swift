//
//  CHContactsViewController.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import ObjectMapper

class CHContactViewController: NewCHTableViewController, CHUserEventDelegates {
    
    var screenIdentifier: UUID!
    var onlineContacts = [CHUser]()
    var allContacts = [CHUser]()
    
    var isAllOnlineContactsLoaded = false
    var isAllOfflineContactsLoaded = false
    
    var isLoadingOnlineContacts = false
    var isLoadingOfflineContacts = false
    
    var currentOnlineOffset = 0
    var currentOfflineOffset = 0
    var apiCallLimit = 100
    
    var headerView: CHNavHeaderView = {
        let headerView = CHNavHeaderView()
        return headerView
    }()
    
    private var noContactsView: NoContactsView = {
        let view = NoContactsView()
        return view
    }()
    
    var tableLoaderFooterView: UIActivityIndicatorView = {
        let loaderView = CHAppConstant.themeStyle == .dark ? UIActivityIndicatorView(style: .white) : UIActivityIndicatorView(style: .gray)
        loaderView.startAnimating()
        return loaderView
    }()
    
    init() {
        super.init(tableStyle: .grouped)
        self.getOnlineContacts()
        self.setNavigationColor(animated: false)
        self.headerView.updateViewsColors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenIdentifier = UUID()
        Channelize.addUserEventDelegate(delegate: self, identifier: self.screenIdentifier)
        
        
        self.headerView.assignTitle(text: CHLocalized(key: "pmContacts"))
        self.headerView.chatPlusButtonPressed = {
            let newGroupOption = CHActionSheetAction(title: CHLocalized(key: "pmNewGroup"), image: nil, actionType: .default, handler: {(action) in
                let controller = CHSelectMembersForGroup()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            let newMessageOption = CHActionSheetAction(title: "New Message", image: nil, actionType: .default, handler: {(action) in
                let controller = CHNewMessageController()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            let newCallOption = CHActionSheetAction(title: "Start a Call", image: nil, actionType: .default, handler: {(action) in
                let controller = CHNewCallViewController()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            
            var controllerActions = [CHActionSheetAction]()
            controllerActions.append(newGroupOption)
            controllerActions.append(newMessageOption)
            if CHCustomOptions.callModuleEnabled {
                controllerActions.append(newCallOption)
            }
            
            let controller = CHActionSheetController()
            controller.actions = controllerActions
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        }
        self.headerView.onSearchButtonPressed = {
            let controller = CHSearchViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        self.headerView.onBackButtonPressed = {
            if CHCustomOptions.showLogoutButton {
                let alertController = UIAlertController(title: nil, message: "Logout?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: CHLocalized(key: "pmLogout"), style: .destructive, handler: {(action) in
                    self.logout()
                })
                let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                if #available(iOS 13.0, *) {
                    // Always adopt a light interface style.
                    if CHAppConstant.themeStyle == .dark {
                        alertController.overrideUserInterfaceStyle = .dark
                    } else {
                        alertController.overrideUserInterfaceStyle = .light
                    }
                }
                self.present(alertController, animated: true, completion: nil)
            } else {
                ChUI.instance.isCHOpen = false
                ChUserCache.instance.users.removeAll()
                self.navigationController?.parent?.navigationController?.popViewController(animated: true)
            }
        }
        
        self.navigationItem.titleView = headerView
        NotificationCenter.default.addObserver(self, selector: #selector(processStatusBarChangeNotification), name: NSNotification.Name(rawValue: "changeBarStyle"), object: nil)
        self.tableView.tableHeaderView = UIView()
        self.tableView.register(CHContactTableCell.self, forCellReuseIdentifier: "contactCell")
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.plainTableBackGroundColor : CHLightThemeColors.instance.plainTableBackGroundColor
        self.headerView.updateViewsColors()
        self.setNavigationColor(animated: false)
        
        self.tableLoaderFooterView.frame.size.height = 50
        self.tableView.tableFooterView = self.tableLoaderFooterView
        //self.getOnlineContacts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            Channelize.removeUserEventDelegate(identifier: self.screenIdentifier)
            Channelize.removeConversationDelegate(identifier: self.screenIdentifier)
        }
    }
    
    // MARK: - API Functions
    func logout() {
        showProgressView(superView: self.navigationController?.view, string: nil)
        Channelize.logout(completion: {(status,errorString) in
            disMissProgressView()
            if status {
                ChUI.instance.isCHOpen = false
                ChUserCache.instance.users.removeAll()
                self.navigationController?
                    .parent?.navigationController?.popViewController(
                        animated: true)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    private func getOnlineContacts() {
        let onlineContactsQueryBuilder = CHFriendQueryBuilder()
        onlineContactsQueryBuilder.limit = self.apiCallLimit
        onlineContactsQueryBuilder.isOnline = true
        onlineContactsQueryBuilder.skip = self.currentOnlineOffset
        onlineContactsQueryBuilder.includeBlocked = false
        ChannelizeAPIService.getFriendsList(queryBuilder: onlineContactsQueryBuilder, completion: {(users,errorString) in
            self.isLoadingOnlineContacts = false
            guard errorString == nil else {
                return
            }
            if let recievedUsers = users {
                self.currentOnlineOffset += recievedUsers.count
                recievedUsers.forEach({
                    self.onlineContacts.append($0)
                })
                ChUserCache.instance.appendUsers(newUsers: recievedUsers)
            }
            self.tableView.reloadData()
            if users?.count ?? 0 < self.apiCallLimit {
                self.isAllOnlineContactsLoaded = true
                self.getOfflineContacts()
            }
        })
    }
    
    private func getOfflineContacts() {
        let onlineContactsQueryBuilder = CHFriendQueryBuilder()
        onlineContactsQueryBuilder.limit = self.apiCallLimit
        onlineContactsQueryBuilder.isOnline = false
        onlineContactsQueryBuilder.skip = self.currentOfflineOffset
        onlineContactsQueryBuilder.includeBlocked = false
        ChannelizeAPIService.getFriendsList(queryBuilder: onlineContactsQueryBuilder, completion: {(users,errorString) in
            self.isLoadingOfflineContacts = false
            guard errorString == nil else {
                return
            }
            if let recievedUsers = users {
                self.currentOfflineOffset += recievedUsers.count
                recievedUsers.forEach({
                    self.allContacts.append($0)
                })
                ChUserCache.instance.appendUsers(newUsers: recievedUsers)
            }
            self.tableView.reloadData()
            if users?.count ?? 0 < self.apiCallLimit {
                self.isAllOfflineContactsLoaded = true
            }
            self.checkAndSetNoContactView()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.onlineContacts.count
        } else {
            return self.allContacts.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! CHContactTableCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            cell.setUpUIProperties()
            cell.user = self.onlineContacts[indexPath.row]
            cell.assignData()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! CHContactTableCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            cell.setUpUIProperties()
            cell.user = self.allContacts[indexPath.row]
            cell.assignData()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return self.onlineContacts.count == 0 ? CGFloat.leastNormalMagnitude : 45
        } else {
            return self.allContacts.count == 0 ? CGFloat.leastNormalMagnitude : 45
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard self.onlineContacts.count > 0, indexPath.row == self.onlineContacts.count - 3 else {
                return
            }
            if self.isAllOnlineContactsLoaded == false {
                if self.isLoadingOnlineContacts == false {
                    self.isLoadingOnlineContacts = true
                    self.tableLoaderFooterView.startAnimating()
                    self.getOnlineContacts()
                }
            } else {
                self.tableLoaderFooterView.stopAnimating()
            }
        } else {
            guard self.allContacts.count > 0, indexPath.row == self.allContacts.count - 3 else {
                return
            }
            if self.isAllOfflineContactsLoaded == false {
                if self.isLoadingOfflineContacts == false {
                    self.isLoadingOfflineContacts = true
                    self.tableLoaderFooterView.startAnimating()
                    self.getOfflineContacts()
                }
            } else {
                self.tableLoaderFooterView.stopAnimating()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let user = self.onlineContacts[indexPath.row]
            let controller = CHConversationViewController()
            var params = [String:Any]()
            params.updateValue(false, forKey: "isGroup")
            if let conversation = Mapper<CHConversation>().map(JSON: params) {
                conversation.conversationPartner = user
                conversation.isGroup = false
                controller.conversation = conversation
            }
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
            
        } else {
            let user = self.allContacts[indexPath.row]
            let controller = CHConversationViewController()
            var params = [String:Any]()
            params.updateValue(false, forKey: "isGroup")
            if let conversation = Mapper<CHConversation>().map(JSON: params) {
                conversation.conversationPartner = user
                conversation.isGroup = false
                controller.conversation = conversation
            }
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard self.onlineContacts.count > 0 else {
                return nil
            }
            let backGroundView = UIView()
            backGroundView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : .white
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Online"
            label.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor
            label.font = CHCustomStyles.mediumSizeMediumFont
            backGroundView.addSubview(label)
            label.setTopAnchor(relatedConstraint: backGroundView.topAnchor, constant: 10)
            label.setBottomAnchor(relatedConstraint: backGroundView.bottomAnchor, constant: 0)
            label.setRightAnchor(relatedConstraint: backGroundView.rightAnchor, constant: -10)
            label.setLeftAnchor(relatedConstraint: backGroundView.leftAnchor, constant: 15)
            return backGroundView
        } else {
            guard self.allContacts.count > 0 else {
                return nil
            }
            let backGroundView = UIView()
            backGroundView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : .white
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Offline"
            label.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor
            label.font = CHCustomStyles.mediumSizeMediumFont
            backGroundView.addSubview(label)
            label.setTopAnchor(relatedConstraint: backGroundView.topAnchor, constant: 10)
            label.setBottomAnchor(relatedConstraint: backGroundView.bottomAnchor, constant: 0)
            label.setRightAnchor(relatedConstraint: backGroundView.rightAnchor, constant: -10)
            label.setLeftAnchor(relatedConstraint: backGroundView.leftAnchor, constant: 15)
            return backGroundView
        }
    }
    
    
    // MARK: - Notification Function
    @objc func processStatusBarChangeNotification() {
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.setNavigationColor(animated: false)
        self.headerView.updateViewsColors()
    }
    
    // MARK: - Other UIView Related Functions
    override func setNavigationColor(animated: Bool = false) {
        self.setNeedsStatusBarAppearanceUpdate()
        self.tableView.addTopBorder(with: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.seperatorColor : CHLightThemeColors.instance.seperatorColor, andWidth: 0.3)
        var tintColor: UIColor?
        var imageColor: UIColor = UIColor(hex: "#1c1c1c")
        if CHAppConstant.themeStyle == .dark {
            tintColor = CHDarkThemeColors.tintColor
            imageColor = UIColor(hex: "#1c1c1c")
        } else {
            tintColor = CHLightThemeColors.tintColor
            imageColor = UIColor(hex: "#ffffff")
        }
        
        let animation = CATransition()
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.type = CATransitionType.fade

        if animated {
            navigationController?.navigationBar.layer.add(animation, forKey: nil)
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: {
                self.navigationController?.navigationBar.setBackgroundImage(imageColor.imageWithColor(width: self.view.frame.width, height: self.navigationController?.navigationBar.frame.size.height ?? 0), for: .default)
                getKeyWindow()?.tintColor = tintColor
            }, completion: nil)
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(imageColor.imageWithColor(width: self.view.frame.width, height: self.navigationController?.navigationBar.frame.size.height ?? 0), for: .default)
            getKeyWindow()?.tintColor = tintColor
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#4a505a")]
        self.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.seperatorColor : CHLightThemeColors.instance.seperatorColor
        self.tableView.separatorStyle = .none
        self.tableView.indicatorStyle = CHAppConstant.themeStyle == .dark ? .white : .black
        self.tableView.reloadData()
        
        self.tabBarController?.tabBar.barTintColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.tabBarController?.tabBar.tintColor = UIColor.systemBlue
    }
    
    private func checkAndSetNoContactView() {
        if self.allContacts.count == 0 && self.onlineContacts.count == 0 {
            self.view.addSubview(self.noContactsView)
            self.noContactsView.translatesAutoresizingMaskIntoConstraints = false
            self.noContactsView.pinEdgeToSuperView(superView: self.view)
        } else {
            self.noContactsView.removeFromSuperview()
        }
        self.tableView.reloadData()
    }
    
    // MARK: - MQTT Events Functions
    func didUserBlocked(model: CHUserBlockModel?) {
        let blockerUser = model?.blockerUser
        let blockedUser = model?.blockedUser
        
        if blockedUser?.id == Channelize.getCurrentUserId() {
            self.onlineContacts.removeAll(where: {
                $0.id == blockerUser?.id
            })
            self.allContacts.removeAll(where: {
                $0.id == blockerUser?.id
            })
            self.checkAndSetNoContactView()
        } else {
            self.onlineContacts.removeAll(where: {
                $0.id == blockedUser?.id
            })
            self.allContacts.removeAll(where: {
                $0.id == blockedUser?.id
            })
            self.checkAndSetNoContactView()
        }
    }
    
    func didUserUnBlocked(model: CHUserUnblockModel?) {
        guard let unBlockerUser = model?.unblockerUser, let unBlockedUser = model?.unblockedUser else {
            return
        }
        if unBlockedUser.id == Channelize.getCurrentUserId() {
            if unBlockerUser.isOnline == true {
                if self.onlineContacts.filter({
                    $0.id == unBlockerUser.id
                }).count == 0 {
                    self.onlineContacts.append(unBlockerUser)
                }
            } else {
                if self.allContacts.filter({
                    $0.id == unBlockerUser.id
                }).count == 0 {
                    self.allContacts.append(unBlockerUser)
                }
            }
            self.checkAndSetNoContactView()
        } else {
            if unBlockedUser.isOnline == true {
                if self.onlineContacts.filter({
                    $0.id == unBlockedUser.id
                }).count == 0 {
                    self.onlineContacts.append(unBlockedUser)
                }
            } else {
                if self.allContacts.filter({
                    $0.id == unBlockedUser.id
                }).count == 0 {
                    self.allContacts.append(unBlockedUser)
                }
            }
            self.checkAndSetNoContactView()
        }
    }
    
    func didUserStatusUpdated(model: CHUserStatusUpdatedModel?) {
        guard let updatedUser = model?.updatedUser else {
            return
        }
        guard updatedUser.id != Channelize.getCurrentUserId() else {
            return
        }
        if updatedUser.isOnline == true {
            if self.onlineContacts.filter({
                $0.id == updatedUser.id
            }).count == 0 {
                self.onlineContacts.append(updatedUser)
            }
            self.allContacts.removeAll(where: {
                $0.id == updatedUser.id
            })
        } else {
            self.onlineContacts.removeAll(where: {
                $0.id == updatedUser.id
            })
            if self.allContacts.filter({
                $0.id == updatedUser.id
            }).count == 0 {
                self.allContacts.append(updatedUser)
            }
        }
        self.checkAndSetNoContactView()
    }
    
    func didUserAddedAsFriend(model: CHUserAddedFriendModel?) {
        guard let addedFriend = model?.addedUser else {
            return
        }
        if addedFriend.isOnline == true {
            if self.onlineContacts.filter({
                $0.id == addedFriend.id
            }).count == 0 {
                self.onlineContacts.append(addedFriend)
            }
        } else {
            if self.allContacts.filter({
                $0.id == addedFriend.id
            }).count == 0 {
                self.allContacts.append(addedFriend)
            }
        }
        self.checkAndSetNoContactView()
    }
    
    func didUserRemovedAsFriend(model: CHUserRemovedFriendModel?) {
        guard let removedFriend = model?.removedUser else {
            return
        }
        self.onlineContacts.removeAll(where: {
            $0.id == removedFriend.id
        })
        self.allContacts.removeAll(where: {
            $0.id == removedFriend.id
        })
        self.checkAndSetNoContactView()
    }
}

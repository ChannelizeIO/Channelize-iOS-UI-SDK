//
//  UIRecentConversationController2.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/23/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire
import ObjectMapper

class UIRecentConversationController: CHTableViewController, CHAllConversationsDelegate, CHUserEventDelegates {
    
    var conversations = [CHConversation]()
    var screenIdentifier: UUID!
    
    private var isShimmeringModeOn = true
    
    init() {
        super.init(style: .plain)
        self.screenIdentifier = UUID()
        ChannelizeAPI.addUserEventDelegate(delegate: self, identifier: self.screenIdentifier)
        CHAllConversations.addConversationDelegates(delegate: self, identifier: self.screenIdentifier)
        CHAllConversations.getAllConversations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Conversations"
        self.edgesForExtendedLayout = .all
        //self.extendedLayoutIncludesOpaqueBars = true
        self.tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        self.tableView.register(UITableViewLoadingCell.self, forCellReuseIdentifier: "conversationLoadingCell")
        self.tableView.register(UIRecentConversationCell.self, forCellReuseIdentifier: "conversationCell")
        self.tableView.register(RecentConversationShimmerCell.self, forCellReuseIdentifier: "shimmeringCell")
        self.tableView.register(NoConversationMessageCell.self, forCellReuseIdentifier: "noConversationCell")
        self.tableView.tableHeaderView = UIView()
        self.tableView.tableFooterView = UIView()
        
        if(ChannelizeUI.instance.getData() != nil) {
            handleNotification(userInfo: ChannelizeUI.instance.getData()!)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showNotification(notification:)), name: NSNotification.Name(rawValue: "channelizeNotification"), object: nil)
        
        //self.tableView.contentInset.top = 0
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func showNotification(notification: NSNotification) {
        if let notificationData = notification.userInfo {
            if let conversationId = notificationData["conversationId"] as? String {
                if conversationId != ChannelizeUI.instance.chCurrentChatId {
                    if(self.tabBarController?.selectedIndex != 0){
                        self.tabBarController?.selectedIndex = 0
                    }
                    self.navigationController?.popToRootViewController(
                        animated: false)
                    if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
                        let conversation = self.conversations[conversationIndex]
                        let controller = UIConversationViewController()
                        controller.conversation = conversation
                        controller.user = conversation.conversationPartner
                        controller.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(
                            controller, animated: true)
                    } else {
                        let controller = UIConversationViewController()
                        controller.conversationId = conversationId
                        controller.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(
                            controller, animated: true)
                    }
                }
                
            }
        }
    }
    
    func handleNotification(userInfo:[AnyHashable:Any]){
        if let conversationId = userInfo["conversationId"] as? String{
            if conversationId != ChannelizeUI.instance.chCurrentChatId {
                if(self.tabBarController?.selectedIndex != 0){
                    self.tabBarController?.selectedIndex = 0
                }
                if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
                    let conversation = self.conversations[conversationIndex]
                    let controller = UIConversationViewController()
                    controller.conversation = conversation
                    controller.user = conversation.conversationPartner
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(
                        controller, animated: true)
                } else {
                    let controller = UIConversationViewController()
                    controller.conversationId = conversationId
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(
                        controller, animated: true)
                }
            }
            
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.isShimmeringModeOn == true {
            return 10
        } else {
            if self.conversations.count == 0 {
                return 1
            } else {
                return self.conversations.count + 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isShimmeringModeOn == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shimmeringCell", for: indexPath) as! RecentConversationShimmerCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            cell.startShimmering()
            return cell
        } else {
            if self.conversations.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noConversationCell", for: indexPath)
                return cell
            } else {
                if indexPath.row == self.conversations.count {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "conversationLoadingCell", for: indexPath) as! UITableViewLoadingCell
                    if CHAllConversations.isAllConversationsLoaded {
                        cell.showNoMoreResultLabel()
                    } else {
                        cell.showSpinnerView()
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath) as! UIRecentConversationCell
                    cell.conversation = self.conversations[indexPath.row]
                    cell.onLongPressedBubble = {[weak self] (cell) in
                        self?.showLongPressOptions(for: cell.conversation)
                    }
                    return cell
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.conversations.count == 0 {
            tableView.isScrollEnabled = false
            if self.isShimmeringModeOn == true {
                return 75
            } else {
                return UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height ?? 0.0) - (self.tabBarController?.tabBar.frame.height ?? 0.0)
            }
            //return tableView.frame.height
        } else {
            tableView.isScrollEnabled = true
            return 75
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.conversations.count > 0 else {
            return
        }
        guard CHAllConversations.isAllConversationsLoaded == false else {
            return
        }
        if indexPath.row == self.conversations.count - 3 {
            CHAllConversations.getAllConversations()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.isShimmeringModeOn == false else {
            return
        }
        guard self.conversations.count > 0 else {
            return
        }
        guard indexPath.row != self.conversations.count else {
            return
        }
        let conversation = self.conversations[indexPath.row]
        let controller = UIConversationViewController()
        controller.conversation = conversation
        controller.user = conversation.conversationPartner
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Other Functions
    func showLongPressOptions(for conversation: CHConversation?) {
        guard let conversationId = conversation?.id else {
            return
        }
        let optionsSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteConversation = UIAlertAction(title: "Delete Conversation", style: .destructive, handler: {(action) in
            let alertController = UIAlertController(title: "Delete Conversation", message: "Are you sure you want to delete this conversation? Once deleted, it cannot be undone.", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
                self.deleteConversation(conversationId: conversationId)
            })
            let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                // Always adopt a light interface style.
                alertController.overrideUserInterfaceStyle = .light
            }
            #endif
            if let popoverController = alertController.popoverPresentationController {
                showIpadActionSheet(sourceView: self.view, popoverController: popoverController)
            }
            self.present(alertController, animated: true, completion: nil)
        })
        let clearConversation = UIAlertAction(title: "Clear Conversation", style: .default, handler: {(action) in
            let alertController = UIAlertController(title: "Clear Conversation", message: "Are you sure you want to clear this conversation? Once cleared, it cannot be undone.", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Clear", style: .destructive, handler: {(action) in
                self.clearConversation(conversationId: conversationId)
            })
            let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                // Always adopt a light interface style.
                alertController.overrideUserInterfaceStyle = .light
            }
            #endif
            self.present(alertController, animated: true, completion: nil)
        })
        let blockUserAction = UIAlertAction(title: "Block User", style: .default, handler: {(action) in
            self.blockUser(userId: conversation?.conversationPartner?.id ?? "")
            //self.blockUser()
        })
        let unblockUserAction = UIAlertAction(title: "Unblock User", style: .default, handler: {(action) in
            self.unblockUser(userId: conversation?.conversationPartner?.id ?? "")
            //self.unblockUser()
        })
        let muteConversationAction = UIAlertAction(title: "Mute Conversation", style: .default, handler: {(action) in
            self.muteUnMuteConversation(conversationId: conversationId, isMute: true)
            //self.muteUnMuteConversation()
        })
        let unMuteConversation = UIAlertAction(title: "UnMute Conversation", style: .default, handler: {(action) in
            self.muteUnMuteConversation(conversationId: conversationId, isMute: false)
            //self.muteUnMuteConversation()
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        
        optionsSheet.addAction(deleteConversation)
        optionsSheet.addAction(clearConversation)
        if conversation?.isGroup == false {
            if conversation?.isPartnerIsBlocked == true {
                optionsSheet.addAction(unblockUserAction)
            } else {
                optionsSheet.addAction(blockUserAction)
            }
        }
        if conversation?.isMute == true {
            optionsSheet.addAction(unMuteConversation)
        } else {
            optionsSheet.addAction(muteConversationAction)
        }
        optionsSheet.addAction(cancelAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            optionsSheet.overrideUserInterfaceStyle = .light
        }
        #endif
        self.present(optionsSheet, animated: true, completion: nil)
    }
    
    // MARK:- API Functions
    func deleteConversation(conversationId: String) {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        showProgressView(superView: self.superView, string: nil)
        ChannelizeAPIService.deleteConversation(conversationId: conversationId, completion: {(status,errorSting) in
            if status {
                showProgressSuccessView(superView: self.superView, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.superView, errorString: errorSting)
            }
        })
    }
    
    func clearConversation(conversationId: String) {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        showProgressView(superView: superView, string: nil)
        ChannelizeAPIService.clearConversation(conversationId: conversationId, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.superView, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.superView, errorString: errorString)
            }
        })
    }
    
    func muteUnMuteConversation(conversationId: String, isMute: Bool) {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        showProgressView(superView: self.superView, string: nil)
        let isConversationMute = isMute
        ChannelizeAPIService.muteConversation(conversationId: conversationId, isMute: !isConversationMute, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.superView, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.superView, errorString: errorString)
            }
        })
    }
    
    func blockUser(userId: String) {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.blockUser(userId: userId, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.superView, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.superView, errorString: errorString)
            }
        })
    }
    
    func unblockUser(userId: String) {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        showProgressView(superView: self.superView, string: nil)
        ChannelizeAPIService.unblockUser(userId: userId, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.superView, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.superView, errorString: errorString)
            }
        })
    }
    
    // MARK: - Conversations Delegates

    
    func didLoadNewConversations(conversations: [CHConversation]) {
        conversations.forEach({
            let conversationObject = $0
            if self.conversations.filter({
                $0.id == conversationObject.id
            }).count == 0 {
                self.conversations.append(conversationObject)
            }
        })
        self.isShimmeringModeOn = false
        if self.conversations.count - conversations.count == 0 {
            self.tableView.reloadData()
        } else {
            let indexPathsToBeInserted = self.calculateIndexPathsToInsert(from: conversations)
            self.reloadTable(withNewIndexPaths: indexPathsToBeInserted)
        }
    }
    
    func didRecieveNewMessage(message: CHMessage?) {
        guard let recievedMessage = message else {
            return
        }
        guard let conversationId = recievedMessage.conversationId else {
            return
        }
        
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.conversations[conversationIndex]
            if recievedMessage.owner?.id == ChannelizeAPI.getCurrentUserId() {
                
                let dateTransformer = ISODateTransform()
                if let messageDateString = dateTransformer.transformToJSON(recievedMessage.createdAt) {
                    conversation.lastReadByMe = recievedMessage.createdAt
                    conversation.lastReadDictionary?.updateValue(
                        messageDateString, forKey: ChannelizeAPI.getCurrentUserId())
                }
            }
            conversation.lastMessage = recievedMessage
            conversation.unreadMessageCount = (conversation.unreadMessageCount ?? 0) + 1
            self.conversations.remove(at: conversationIndex)
            self.conversations.insert(conversation, at: 0)
            self.tableView.performBatchUpdates({
                self.tableView.deleteRows(at: [IndexPath(row: conversationIndex, section: 0)], with: .none)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }, completion: nil)
            //self.tableView.reloadData()
        } else {
            ChannelizeAPIService.getConversationWithId(conversationId: conversationId, completion: {(conversation,errorString) in
                if let recievedConversation = conversation {
                    self.conversations.insert(recievedConversation, at: 0)
                    if self.conversations.count == 1 {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.performBatchUpdates({
                            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                        }, completion: nil)
                    }
                    //self.tableView.reloadData()
                }
            })
        }
    }
    
    func didConversationCleared(conversationId: String?) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId ?? "") {
            let conversation = self.conversations[conversationIndex]
            conversation.lastMessage = nil
            conversation.unreadMessageCount = 0
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [IndexPath(row: conversationIndex, section: 0)], with: .none)
            }, completion: nil)
        }
    }
    
    func didConversationDeleted(conversationId: String?) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId ?? "") {
            self.conversations.remove(at: conversationIndex)
            if self.conversations.count == 0 {
                self.tableView.reloadData()
            } else {
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: [IndexPath(row: conversationIndex, section: 0)], with: .right)
                }, completion: nil)
            }
        }
    }
    
    func didConversationMessagesDeleted(conversationId: String?, deletedMessagesIds: [String]) {
        if let conversationIndex = getConversationIndex(conversationId: conversationId ?? "") {
            let conversation = self.conversations[conversationIndex]
            var doFetchConversation = false
            deletedMessagesIds.forEach({
                let messageId = $0
                if conversation.lastMessage?.id == messageId {
                    doFetchConversation = true
                }
            })
            
            if doFetchConversation == true {
                ChannelizeAPIService.getConversationWithId(conversationId: conversationId ?? "", completion: {(conversation,errorString) in
                    if let recievedConversation = conversation {
                        self.conversations.remove(at: conversationIndex)
                        self.conversations.insert(recievedConversation, at: 0)
                        self.conversations.sort(by: { $0.lastUpDatedAt ?? Date() > $1.lastUpDatedAt ?? Date()})
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func didConversationMessagesDeletedForEveryOne(conversationId: String?, deletedMessagesIds: [String]) {
        if let conversationIndex = getConversationIndex(conversationId: conversationId ?? "") {
            let conversation = self.conversations[conversationIndex]
            var doUpdateMessage = false
            deletedMessagesIds.forEach({
                let messageId = $0
                if conversation.lastMessage?.id == messageId {
                    doUpdateMessage = true
                }
            })
            
            if doUpdateMessage == true {
                conversation.lastMessage?.isDeleted = true
                self.tableView.reloadData()
            }
        }
    }
    
    func didTypingStatusChanged(conversationId: String?, typingUserName: String?, isTyping: Bool) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId ?? "") {
            let conversation = self.conversations[conversationIndex]
            conversation.isTyping = isTyping
            conversation.typingUserName = typingUserName
            self.conversations.remove(at: conversationIndex)
            self.conversations.insert(conversation, at: conversationIndex)
            self.tableView.performBatchUpdates({
                self.tableView.deleteRows(at: [IndexPath(item: conversationIndex, section: 0)], with: .none)
                self.tableView.insertRows(at: [IndexPath(item: conversationIndex, section: 0)], with: .none)
            }, completion: nil)
            
        }
    }
    
    func didNewAdminAddedToConversation(conversationId: String, adminUserId: String) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.conversations[conversationIndex]
            if let firstUser = conversation.members?.first(where: {
                $0.user?.id == adminUserId
            }) {
                firstUser.isAdmin = true
            }
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [IndexPath(row: conversationIndex, section: 0)], with: .none)
            }, completion: nil)
        }
    }
    
    func didConversationMarkAsRead(conversationId: String, readerId: String, readedAt: Date?) {
        let dateTransformer = ISODateTransform()
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.conversations[conversationIndex]
            if readerId == ChannelizeAPI.getCurrentUserId() {
                conversation.unreadMessageCount = 0
                conversation.lastReadByMe = readedAt
            }
            let dateString = dateTransformer.transformToJSON(
                readedAt)
            conversation.lastReadDictionary?.updateValue(
                dateString ?? "", forKey: readerId)
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [IndexPath(row: conversationIndex, section: 0)], with: .none)
            }, completion: nil)
        }
    }
    
    func didMembersRemovedFromConversation(conversationId: String, removedMemberIds: [String]) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.conversations[conversationIndex]
            guard var conversationMembers = conversation.members else {
                return
            }
            removedMemberIds.forEach({
                let userId = $0
                conversationMembers.removeAll(where: {
                    $0.user?.id == userId
                })
            })
            conversation.members = conversationMembers
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [IndexPath(row: conversationIndex, section: 0)], with: .none)
            }, completion: nil)
        }
    }
    
    func didNewMembersAddedToConversation(conversationId: String, addedMembers: [CHMember]) {
        
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.conversations[conversationIndex]
            addedMembers.forEach({
                let memberObject = $0
                if conversation.members?.filter({
                    $0.user?.id == memberObject.user?.id
                }).count == 0 {
                    conversation.members?.append(memberObject)
                }
            })
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [IndexPath(row: conversationIndex, section: 0)], with: .none)
            }, completion: nil)
        }
    }
    
    func didCurrentUserRemovedFromConversation(conversationId: String) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.conversations[conversationIndex]
            conversation.canReplyToConversation = false
            conversation.members?.removeAll(where: {
                $0.user?.id == ChannelizeAPI.getCurrentUserId()
            })
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [IndexPath(row: conversationIndex, section: 0)], with: .none)
            }, completion: nil)
        }
    }
    
    func didCurrentUserAddedToConversation(conversationId: String) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.conversations[conversationIndex]
            conversation.canReplyToConversation = true
            var params = [String:Any]()
            params.updateValue(UUID().uuidString, forKey: "id")
            params.updateValue(ChannelizeAPI.getCurrentUserId(), forKey: "userId")
            params.updateValue(false, forKey: "isAdmin")
            if let member = Mapper<CHMember>().map(JSON: params) {
                
                var userParams = [String:Any]()
                userParams.updateValue(ChannelizeAPI.getCurrentUserId(), forKey: "id")
                userParams.updateValue(ChannelizeAPI.getCurrentUserDisplayName(), forKey: "displayName")
                if ChannelizeAPI.getCurrentUserProfileImageUrl() != nil {
                    userParams.updateValue(
                        ChannelizeAPI.getCurrentUserProfileImageUrl()!, forKey: "profileImageUrl")
                }
                let userObject = Mapper<CHUser>().map(JSON: userParams)
                member.user = userObject
                conversation.members?.append(member)
            }
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [IndexPath(row: conversationIndex, section: 0)], with: .none)
            }, completion: nil)
        }
    }
    
    func didConversationMuteStatusUpdated(conversationId: String, isMuted: Bool) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.conversations[conversationIndex]
            conversation.isMute = isMuted
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [IndexPath(row: conversationIndex, section: 0)], with: .none)
            }, completion: nil)
        }
    }
    
    func didConversationInfoUpdated(updatedInfo: CHConversationUpdatedModel) {
        if let conversationIndex = self.getConversationIndex(conversationId: updatedInfo.conversationID ?? "") {
            let conversation = self.conversations[conversationIndex]
            conversation.coversationTitle = updatedInfo.title
            conversation.conversationProfileImage = updatedInfo.profileImageUrl
            conversation.lastUpDatedAt = updatedInfo.timeStamp
            conversation.membersCount = updatedInfo.memberCount
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [IndexPath(row: conversationIndex, section: 0)], with: .none)
            }, completion: nil)
        }
    }
    
    
    
    // MARK:- IndexPath Calculator
    func getConversationIndex(conversationId: String) -> Int? {
        let firstIndex = self.conversations.firstIndex(where: {
            $0.id == conversationId
        })
        return firstIndex
    }
    private func calculateIndexPathsToInsert(from newConversations: [CHConversation]) -> [IndexPath] {
        let startIndex = self.conversations.count - newConversations.count
        let endIndex = self.conversations.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0)}
    }
    
    private func reloadTable(withNewIndexPaths: [IndexPath]) {
        self.tableView.performBatchUpdates({
            self.tableView.insertRows(at: withNewIndexPaths, with: .bottom)
        }, completion: nil)
    }
    
    // MARK:- User Events Delegates
    func didUserStatusUpdated(model: CHUserStatusUpdatedModel?) {
        guard let updatedUser = model?.updatedUser else {
            return
        }
        guard updatedUser.id != ChannelizeAPI.getCurrentUserId() else {
            return
        }
        
        if let firstConversationIndex = self.conversations.firstIndex(where: {
            $0.isGroup == false && $0.conversationPartner?.id == updatedUser.id
        }) {
            let conversation = self.conversations[firstConversationIndex]
            conversation.conversationPartner?.isOnline = updatedUser.isOnline
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [IndexPath(row: firstConversationIndex, section: 0)], with: .none)
            }, completion: {(completed) in
                print(completed)
            })
        }
    }
    
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


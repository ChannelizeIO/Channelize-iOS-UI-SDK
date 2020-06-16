//
//  CHRecentConversationsController.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/23/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import ObjectMapper

class CHRecentConversationsController: NewCHTableViewController, UITableViewDataSourcePrefetching, CHConversationEventDelegate {
    
    var backBarButton: UIBarButtonItem!
    var searchBarButton: UIBarButtonItem!
    var chatPlusBarButton: UIBarButtonItem!
    var isInitialLoadingOn = true
    var conversationsList = [CHConversation]()
    
    var currentAPIOffset = 0
    var isAllConversationLoaded = false
    var apiCallLimit = 30
    var isLoadingConversation = false
    
    var screenIdentifier = UUID()
    
    var headerView: CHNavHeaderView = {
        let headerView = CHNavHeaderView()
        return headerView
    }()
    
    var noConversationView: NoRecentConversationView = {
        let view = NoRecentConversationView()
        return view
    }()
    
    var tableLoaderFooterView: UIActivityIndicatorView = {
        let loaderView = CHAppConstant.themeStyle == .dark ? UIActivityIndicatorView(style: .white) : UIActivityIndicatorView(style: .gray)
        loaderView.startAnimating()
        return loaderView
    }()
    
    init() {
        super.init(tableStyle: .plain)
        self.getRecentConversations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Conversations"
        Channelize.addConversationEventDelegate(delegate: self, identifier: self.screenIdentifier)
        self.navigationItem.titleView = headerView
        self.navigationItem.setHidesBackButton(true, animated: false)
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
        
        
        
        self.tableView.prefetchDataSource = self
        //self.navigationItem.setLeftBarButtonItems([backBarButton,leftSideSpacer], animated: true)
        //self.navigationItem.leftItemsSupplementBackButton = false
        //self.navigationItem.rightBarButtonItems = [chatPlusBarButton]
        
        NotificationCenter.default.addObserver(self, selector: #selector(processStatusBarChangeNotification), name: NSNotification.Name(rawValue: "changeBarStyle"), object: nil)
        
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.tableView.register(CHRecentConversationCell.self, forCellReuseIdentifier: "recentConversationCell")
        self.tableView.register(RecentConversationShimmeringCell.self, forCellReuseIdentifier: "shimmeringCell")
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gesture:)))
        self.tableView.addGestureRecognizer(longPressGesture)
        self.setNavigationColor()
        self.headerView.updateViewsColors()
        
        self.tableLoaderFooterView.frame.size.height = 50
        self.tableView.tableFooterView = self.tableLoaderFooterView
        //self.getRecentConversations()
        // Do any additional setup after loading the view.
        
        
        if(ChUI.instance.getData() != nil) {
            handleNotification(userInfo: ChUI.instance.getData()!)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showNotification(notification:)), name: NSNotification.Name(rawValue: "channelizeNotification"), object: nil)
    }
    
    @objc func showNotification(notification: NSNotification) {
        if let notificationData = notification.userInfo {
            if let conversationId = notificationData["conversationId"] as? String {
                if conversationId != ChUI.instance.chCurrentChatId {
                    if(self.tabBarController?.selectedIndex != 0){
                        self.tabBarController?.selectedIndex = 0
                    }
                    self.navigationController?.popToRootViewController(
                        animated: false)
                    if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
                        let conversation = self.conversationsList[conversationIndex]
                        let controller = CHConversationViewController()
                        controller.conversation = conversation
                        controller.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
                
            }
        }
    }
    
    func handleNotification(userInfo:[AnyHashable:Any]){
        if let conversationId = userInfo["conversationId"] as? String{
            if conversationId != ChUI.instance.chCurrentChatId {
                if(self.tabBarController?.selectedIndex != 0){
                    self.tabBarController?.selectedIndex = 0
                }
                if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
                    let conversation = self.conversationsList[conversationIndex]
                    let controller = CHConversationViewController()
                    controller.conversation = conversation
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        } else if let userId = userInfo["userId"] {
            ChannelizeAPIService.getUserInfo(userId: String(describing: userId), completion: {(user,errorString) in
                let controller = CHConversationViewController()
                let conversation = CHConversation()
                conversation.conversationPartner = user
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: false)
            })
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isMovingToParent {
            self.setNavigationColor()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            Channelize.removeUserEventDelegate(identifier: self.screenIdentifier)
            Channelize.removeConversationDelegate(identifier: self.screenIdentifier)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "channelizeNotification"), object: nil)
        }
    }
    
    @objc private func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let touchPoint = gesture.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                self.showConversationOptionAlert(conversation: self.conversationsList[indexPath.row])
            }
        }
    }
    
    private func showConversationOptionAlert(conversation: CHConversation?) {
        let muteConversationAction = CHActionSheetAction(title: CHLocalized(key: "pmMuteConversation"), image: nil, actionType: .default, handler: {(action) in
            self.muteUnMuteConversation(conversationId: conversation?.id ?? "", isMute: true)
        })
        let unMuteConversationAction = CHActionSheetAction(title: CHLocalized(key: "pmUnmuteConversation"), image: nil, actionType: .default, handler: {(action) in
            self.muteUnMuteConversation(conversationId: conversation?.id ?? "", isMute: false)
        })
        let clearConversationAction = CHActionSheetAction(title: CHLocalized(key: "pmClearConversation"), image: nil, actionType: .default, handler: {(action) in
            self.clearConversation(conversationId: conversation?.id ?? "")
        })
        let deleteConversationAction = CHActionSheetAction(title: CHLocalized(key: "pmDeleteConversation"), image: nil, actionType: .destructive, handler: {(action) in
            self.deleteConversation(conversationId: conversation?.id ?? "")
        })
        
        var controllerActions = [CHActionSheetAction]()
        if conversation?.isMute == true {
            controllerActions.append(unMuteConversationAction)
        } else {
            controllerActions.append(muteConversationAction)
        }
        controllerActions.append(clearConversationAction)
        controllerActions.append(deleteConversationAction)
        
        let controller = CHActionSheetController()
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.actions = controllerActions
        self.present(controller, animated: true, completion: nil)
    }

    
    // MARK: - API Functions
    func getRecentConversations() {
        let conversationQueryBuilder = CHListConversationsQueryBuilder()
        conversationQueryBuilder.limit = self.apiCallLimit
        conversationQueryBuilder.skip = self.currentAPIOffset
        self.isLoadingConversation = true
        //conversationQueryBuilder.includeMembers = true
        ChannelizeAPIService.getConversationList(queryBuilder: conversationQueryBuilder, completion: {(conversations,errorString) in
            self.isInitialLoadingOn = false
            self.isLoadingConversation = false
            guard errorString == nil else {
                return
            }
            if let recievedConversations = conversations {
                recievedConversations.forEach({
                    let conversation = $0
                    if self.conversationsList.filter({
                        $0.id == conversation.id
                    }).count == 0 {
                        self.conversationsList.append(conversation)
                    }
                })
                if recievedConversations.count < self.apiCallLimit {
                    self.isAllConversationLoaded = true
                }
                self.currentAPIOffset += recievedConversations.count
            }
            self.checkAndSetNoContentView()
        })
    }
    
    // MARK:- API Functions
    func deleteConversation(conversationId: String) {
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.deleteConversation(conversationId: conversationId, completion: {(status,errorSting) in
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorSting)
            }
        })
    }
    
    func clearConversation(conversationId: String) {
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.clearConversation(conversationId: conversationId, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    func muteUnMuteConversation(conversationId: String, isMute: Bool) {
        showProgressView(superView: self.navigationController?.view, string: nil)
        let isConversationMute = isMute
        ChannelizeAPIService.muteConversation(conversationId: conversationId, isMute: isConversationMute, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
    
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
    
    // MARK: - Table View Delegates And Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isInitialLoadingOn {
            return 10
        } else {
            return self.conversationsList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Cell for row at \(indexPath.row)")
        if self.isInitialLoadingOn {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shimmeringCell", for: indexPath) as! RecentConversationShimmeringCell
            cell.setUpViewsFrames()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recentConversationCell", for: indexPath) as! CHRecentConversationCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            cell.conversation = self.conversationsList[indexPath.row]
            cell.setUpUIProperties()
            cell.assignData()
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.isInitialLoadingOn == false else {
            return
        }
        
        let conversation = self.conversationsList[indexPath.row]
        let controller = CHConversationViewController()
        controller.conversation = Mapper<CHConversation>().map(JSON: conversation.toJSON())
        controller.hidesBottomBarWhenPushed = true
        controller.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.conversationsList.count > 0, indexPath.row == self.conversationsList.count - 3 else {
            return
        }
        if self.isAllConversationLoaded == false {
            if self.isLoadingConversation == false {
                self.isLoadingConversation = true
                self.tableLoaderFooterView.startAnimating()
                self.getRecentConversations()
            }
        } else {
            self.tableLoaderFooterView.stopAnimating()
        }
    }
    
    // MARK: - Notification Function
    @objc func processStatusBarChangeNotification() {
        self.conversationsList.forEach({
            $0.lastMessage?.setMessageAttributedString(attributedString: nil)
        })
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.headerView.updateViewsColors()
        self.setNavigationColor(animated: true)
    }
    
    @objc func backButtonPressed(sender: UIBarButtonItem) {
        
    }
    
    @objc func searchButtonPressed(sender: UIBarButtonItem) {
        
    }
    
    @objc func chatPlusButton(sender: UIBarButtonItem) {
        
    }
    
    // MARK: - MQTT Functions
    func didConversationDeleted(model: CHConversationDeleteModel?) {
        self.conversationsList.removeAll(where: {
            $0.id == model?.conversation?.id
        })
        self.checkAndSetNoContentView()
    }
    
    func didConversationCleared(model: CHConversationClearModel?) {
        if let conversationIndex = self.conversationsList.firstIndex(where: {
            $0.id == model?.conversation?.id
        }) {
            let conversation = self.conversationsList[conversationIndex]
            conversation.lastMessage = nil
            self.tableView.reloadData()
        }
    }
    
    func didConversationMessageDeletedForEveryOne(model: CHMessageDeletedModel?) {
        guard let deletedMessages = model?.deletedMessages else {
            return
        }
        let deletedMessageIds = deletedMessages.compactMap({ $0.id ?? ""})
        if let conversationIndex = self.conversationsList.firstIndex(where: {
            $0.id == model?.conversation?.id
        }) {
            let conversation = conversationsList[conversationIndex]
            if deletedMessageIds.contains(conversation.lastMessage?.id ?? "") {
                conversation.lastMessage?.isDeleted = true
            }
            self.tableView.reloadData()
        }
        
    }
    
    func didConversationMessageDeleted(model: CHMessageDeletedModel?) {
        guard let deletedMessages = model?.deletedMessages else {
            return
        }
        let deletedMessageIds = deletedMessages.compactMap({ $0.id ?? ""})
        if let conversationIndex = self.conversationsList.firstIndex(where: {
            $0.id == model?.conversation?.id
        }) {
            let conversation = conversationsList[conversationIndex]
            if deletedMessageIds.contains(conversation.lastMessage?.id ?? "") {
                ChannelizeAPIService.getConversationWithId(conversationId: model?.conversation?.id ?? "", completion: {(conversation,errorString) in
                    if let recievedConversation = conversation {
                        self.conversationsList.remove(at: conversationIndex)
                        self.conversationsList.insert(recievedConversation, at: 0)
                        self.conversationsList.sort(by: { $0.lastUpDatedAt ?? Date() > $1.lastUpDatedAt ?? Date()})
                    }
                })
            }
            self.tableView.reloadData()
        }
    }
    
    func didRecieveNewMessage(model: CHNewMessageRecievedModel?) {
        if let conversationIndex = self.conversationsList.firstIndex(where: {
            $0.id == model?.message?.conversationId
        }) {
            let conversation = self.conversationsList[conversationIndex]
            if model?.message?.owner?.id == Channelize.getCurrentUserId() {
                let dateTransformer = ISODateTransform()
                if let messageDateString = dateTransformer.transformToJSON(model?.message?.createdAt) {
                    conversation.lastReadDictionary?.updateValue(
                        messageDateString, forKey: Channelize.getCurrentUserId())
                }
            }
            
            conversation.lastMessage = model?.message
            conversation.lastUpDatedAt = model?.message?.createdAt
            if model?.message?.ownerId != Channelize.getCurrentUserId() {
                conversation.unreadMessageCount = (conversation.unreadMessageCount ?? 0) + 1
            }
            
            self.conversationsList.remove(at: conversationIndex)
            self.conversationsList.insert(conversation, at: 0)
            self.tableView.reloadData()
        } else {
            ChannelizeAPIService.getConversationWithId(conversationId: model?.message?.conversationId ?? "", completion: {(conversation,errorString) in
                guard errorString == nil else {
                    return
                }
                if let recievedConversation = conversation {
                    self.conversationsList.insert(recievedConversation, at: 0)
                }
                self.checkAndSetNoContentView()
            })
        }
    }
    
    func didTypingUserStatusUpdated(model: CHUserTypingStatusModel?) {
        guard model?.user?.id != Channelize.getCurrentUserId() else {
            return
        }
        print(model?.isTyping ?? false)
        guard let typingUser = model?.user else {
            return
        }
        if let conversationIndex = self.conversationsList.firstIndex(where: {
            $0.id == model?.conversation?.id
        }) {
            let conversation = self.conversationsList[conversationIndex]
            conversation.isTyping = model?.isTyping
            conversation.typingUserName = typingUser.displayName
            self.tableView.reloadData()
        }
    }
    
    func didNewAdminAddedToConversation(model: CHNewAdminAddedModel?) {
        if let conversation = self.conversationsList.first(where: {
            $0.id == model?.conversation?.id
        }) {
            conversation.members?.first(where: {
                $0.user?.id == model?.adminUser?.id
            })?.isAdmin = true
            self.tableView.reloadData()
        }
    }
    
    func didConversationInfoUpdated(model: CHConversationUpdatedModel?) {
        if let conversation = self.conversationsList.first(where: {
            $0.id == model?.conversationID
        }) {
            conversation.membersCount = model?.memberCount
            conversation.profileImageUrl = model?.profileImageUrl
            conversation.title = model?.title
            conversation.createdAt = model?.createdAt
            conversation.isGroup = model?.isGroup
            conversation.lastUpDatedAt = model?.timeStamp
            self.tableView.reloadData()
        }
    }
    
    func didNewMembersAddedToConversation(model: CHNewMemberAddedModel?) {
        self.conversationsList.first(where: {
            $0.id == model?.conversation?.id
        })?.membersCount = model?.conversation?.membersCount
        self.tableView.reloadData()
    }
    
    func didMembersRemovedFromConversation(model: CHMembersRemovedModel?) {
        self.conversationsList.first(where: {
            $0.id == model?.conversation?.id
        })?.membersCount = model?.conversation?.membersCount
        self.tableView.reloadData()
    }
    
    func didUpdateConversationMuteStatus(model: CHConversationMuteStatusModel?) {
        self.conversationsList.first(where: {
            $0.id == model?.conversation?.id
        })?.isMute = model?.conversation?.isMute
        self.tableView.reloadData()
    }
    
    func didCurrentUserRemovedFromConversation(model: CHCurrentUserRemovedModel?) {
        self.conversationsList.first(where: {
            $0.id == model?.conversation?.id
        })?.isActive = false
        self.conversationsList.first(where: {
            $0.id == model?.conversation?.id
        })?.membersCount = model?.conversation?.membersCount
        self.tableView.reloadData()
    }
    
    func didCurrentUserJoinedConversation(model: CHCurrentUserJoinConversationModel?) {
        self.conversationsList.first(where: {
            $0.id == model?.conversation?.id
            })?.isActive = true
        self.conversationsList.first(where: {
            $0.id == model?.conversation?.id
        })?.membersCount = model?.conversation?.membersCount
        self.tableView.reloadData()
    }
    
    func didConversationMarkAsRead(model: CHConversationMarkReadModel?) {
        if let updatedConversation = self.conversationsList.first(where: {
            $0.id == model?.conversation?.id
        }) {
            if let readTimeDateString = ISODateTransform().transformToJSON(model?.timeStamp) {
                updatedConversation.lastReadDictionary?.updateValue(readTimeDateString, forKey: model?.user?.id ?? "")
                updatedConversation.updateLastMessageOldestRead()
            }
            if model?.user?.id == Channelize.getCurrentUserId() {
                updatedConversation.unreadMessageCount = 0
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Other UIViews Functions
    private func checkAndSetNoContentView() {
        if self.conversationsList.count == 0 {
            self.view.addSubview(noConversationView)
            self.noConversationView.translatesAutoresizingMaskIntoConstraints = false
            self.noConversationView.pinEdgeToSuperView(superView: self.view)
        } else {
            self.noConversationView.removeFromSuperview()
        }
        self.tableView.reloadData()
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard self.conversationsList.count > 0 else {
            return
        }
        
//        indexPaths.forEach({
//            let conversation = self.conversationsList[$0.row]
//            if conversation.lastReadDateDictionary == nil {
//                print("Prefetching row at \(indexPaths.map({ $0.row}))")
//                conversation.prepareLastReadDateDictionary()
//            }
//        })
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func getConversationIndex(conversationId: String) -> Int? {
        let firstIndex = self.conversationsList.firstIndex(where: {
            $0.id == conversationId
        })
        return firstIndex
    }

}



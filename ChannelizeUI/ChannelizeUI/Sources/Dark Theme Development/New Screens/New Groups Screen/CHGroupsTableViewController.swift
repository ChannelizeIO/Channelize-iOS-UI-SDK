//
//  CHGroupsTableViewController.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

class CHGroupsTableViewController: NewCHTableViewController, CHConversationEventDelegate {

    var groupConversations = [CHConversation]()
    var isAllConversationsLoaded = false
    var isLoadingGroupConversations = false
    var currentApiOffset = 0
    
    var headerView: CHNavHeaderView = {
        let headerView = CHNavHeaderView()
        return headerView
    }()
    
    var noGroupsView: NoGroupsView = {
        let view = NoGroupsView()
        return view
    }()
    
    var tableLoaderFooterView: UIActivityIndicatorView = {
        let loaderView = CHAppConstant.themeStyle == .dark ? UIActivityIndicatorView(style: .white) : UIActivityIndicatorView(style: .gray)
        loaderView.startAnimating()
        return loaderView
    }()
    
    init() {
        super.init(tableStyle: .plain)
        self.getGroupsConversations()
        self.screenIdentifier = UUID()
        Channelize.addConversationEventDelegate(delegate: self, identifier: self.screenIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var screenIdentifier: UUID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerView.assignTitle(text: CHLocalized(key: "pmGroups"))
        self.headerView.updateViewsColors()
        self.navigationItem.titleView = headerView
        NotificationCenter.default.addObserver(self, selector: #selector(processStatusBarChangeNotification), name: NSNotification.Name(rawValue: "changeBarStyle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processLocaleChangeNotification(notification:)), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
        
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.tableView.register(CHGroupConversationCell.self, forCellReuseIdentifier: "groupInfoCell")
        self.headerView.chatPlusButtonPressed = {
            let newGroupOption = CHActionSheetAction(title: CHLocalized(key: "pmNewGroup"), image: nil, actionType: .default, handler: {(action) in
                let controller = CHSelectMembersForGroup()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            let newMessageOption = CHActionSheetAction(title: CHLocalized(key: "pmNewMessage"), image: nil, actionType: .default, handler: {(action) in
                let controller = CHNewMessageController()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            let newCallOption = CHActionSheetAction(title: CHLocalized(key: "pmStartNewCall"), image: nil, actionType: .default, handler: {(action) in
                let controller = CHNewCallViewController()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            
            var controllerActions = [CHActionSheetAction]()
            controllerActions.append(newGroupOption)
            controllerActions.append(newMessageOption)
            if CHConstants.isChannelizeCallAvailable {
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
                let okAction = UIAlertAction(title: "Logout", style: .destructive, handler: {(action) in
                    self.logout()
                })
                let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                ChUI.instance.isCHOpen = false
                ChUserCache.instance.users.removeAll()
                self.navigationController?.parent?.navigationController?.popViewController(animated: true)
            }
        }
        self.tableLoaderFooterView.frame.size.height = 50
        self.tableView.tableFooterView = self.tableLoaderFooterView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            Channelize.removeConversationDelegate(identifier: self.screenIdentifier)
            Channelize.removeUserEventDelegate(identifier: self.screenIdentifier)
        }
    }
    
    // MARK: - API Functions
    func getGroupsConversations() {
        let conversationQueryBuilder = CHListConversationsQueryBuilder()
        conversationQueryBuilder.limit = 25
        conversationQueryBuilder.skip = self.currentApiOffset
        conversationQueryBuilder.isGroup = true
        ChannelizeAPIService.getConversationList(queryBuilder: conversationQueryBuilder, completion: {(conversations,errorString) in
            self.isLoadingGroupConversations = false
            guard errorString == nil else {
                return
            }
            if let recievedConversations = conversations {
                self.currentApiOffset += recievedConversations.count
                recievedConversations.forEach({
                    self.groupConversations.append($0)
                })
                if recievedConversations.count < 25 {
                    self.isAllConversationsLoaded = true
                }
            }
            self.checkAndSetNoContentView()
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

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupConversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupInfoCell", for: indexPath) as! CHGroupConversationCell
        cell.setUpViews()
        cell.setUpViewsFrames()
        cell.conversation = self.groupConversations[indexPath.row]
        cell.setUpUIProperties()
        cell.assignData()
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.groupConversations.count > 0, indexPath.row == self.groupConversations.count - 3 else {
            self.tableLoaderFooterView.stopAnimating()
            return
        }
        if self.isAllConversationsLoaded == false {
            if self.isLoadingGroupConversations == false {
                self.isLoadingGroupConversations = true
                self.tableLoaderFooterView.startAnimating()
                self.getGroupsConversations()
            }
        } else {
            self.tableLoaderFooterView.stopAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = self.groupConversations[indexPath.row]
        let controller = CHConversationViewController()
        controller.conversation = conversation
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Other UIViews Functions
    private func checkAndSetNoContentView() {
        if self.groupConversations.count == 0 {
            self.view.addSubview(noGroupsView)
            self.noGroupsView.translatesAutoresizingMaskIntoConstraints = false
            self.noGroupsView.pinEdgeToSuperView(superView: self.view)
        } else {
            self.noGroupsView.removeFromSuperview()
        }
        self.tableView.reloadData()
    }

    // MARK: - Notification Function
    @objc func processStatusBarChangeNotification() {
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.headerView.updateViewsColors()
        self.setNavigationColor(animated: true)
        self.noGroupsView.updateColors()
    }
    
    @objc func processLocaleChangeNotification(notification: NSNotification) {
        self.tableView.reloadData()
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.checkAndSetNoContentView()
        //self.tableView.reloadData()
    }
    
    // MARK: - MQTT Events Delegates
    func didMembersRemovedFromConversation(model: CHMembersRemovedModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        self.groupConversations.first(where: {
            $0.id == conversationId
        })?.membersCount = model?.conversation?.membersCount
        self.tableView.reloadData()
    }
    
    func didNewMembersAddedToConversation(model: CHNewMemberAddedModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        self.groupConversations.first(where: {
            $0.id == conversationId
        })?.membersCount = model?.conversation?.membersCount
        self.tableView.reloadData()
    }
    
    func didCurrentUserRemovedFromConversation(model: CHCurrentUserRemovedModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        self.groupConversations.first(where: {
            $0.id == conversationId
        })?.membersCount = model?.conversation?.membersCount
        self.tableView.reloadData()
    }
    
    func didCurrentUserJoinedConversation(model: CHCurrentUserJoinConversationModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        self.groupConversations.first(where: {
            $0.id == conversationId
        })?.membersCount = model?.conversation?.membersCount
        self.tableView.reloadData()
    }
    
    func didConversationInfoUpdated(model: CHConversationUpdatedModel?) {
        if let updatedConversation = self.groupConversations.first(where: {
            $0.id == model?.conversationID
        }) {
            updatedConversation.profileImageUrl = model?.profileImageUrl
            updatedConversation.title = model?.title
            updatedConversation.membersCount = model?.memberCount
        }
        self.tableView.reloadData()
    }
    func didConversationDeleted(model: CHConversationDeleteModel?) {
        self.groupConversations.removeAll(where: {
            $0.id == model?.conversation?.id
        })
        self.checkAndSetNoContentView()
    }
    
    func didRecieveNewMessage(model: CHNewMessageRecievedModel?) {
        guard let conversationId = model?.message?.conversationId else {
            return
        }
        if let conversationIndex = self.groupConversations.firstIndex(where: {
            $0.id == conversationId
        }) {
            let conversation = self.groupConversations[conversationIndex]
            conversation.lastMessage = model?.message
            conversation.lastUpDatedAt = model?.message?.createdAt
            
            self.groupConversations.remove(at: conversationIndex)
            self.groupConversations.insert(conversation, at: 0)
            self.checkAndSetNoContentView()
        } else {
            ChannelizeAPIService.getConversationWithId(conversationId: conversationId, completion: {(conversation,errorString) in
                guard errorString == nil else {
                    return
                }
                if let recievedConversation = conversation {
                    self.groupConversations.insert(recievedConversation, at: 0)
                }
                self.checkAndSetNoContentView()
            })
        }
    }
    
    // MARK: - Other Functions
    private func getConversationIndex(conversationId: String?) -> Int? {
        let index = self.groupConversations.firstIndex(where: {
            $0.id == conversationId
        })
        return index
    }
}


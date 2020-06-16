//
//  CHMessageForwardScreenController.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/11/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire
import ObjectMapper
import InputBarAccessoryView
import DifferenceKit

class CHMessageForwardScreenController: NewCHTableViewController, UISearchBarDelegate {

    var allContacts = [CHUser]()
    var allGroupsConversations = [CHConversation]()
    
    var searchedContacts = [CHUser]()
    var searchedGroupsConversation = [CHConversation]()
    
    var isSearching = true
    
    var isSearchingContact = false
    var isSearchingConversation = false
    
    var contactsSearchTask: DispatchWorkItem?
    
    var keyBoardManger: KeyboardManager?
    
    var selectedUsers = [CHUser]()
    var selectedConversations = [CHConversation]()
    var messageIds = [String]()
    
    var selectedUserChatView: CHSelectedUsersAndConverstionView = {
        let view = CHSelectedUsersAndConverstionView()
        return view
    }()
    
    var forwardToolBarButton: UIBarButtonItem!
    
    init() {
        super.init(tableStyle: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.keyboardAppearance = CHAppConstant.themeStyle == .dark ? .dark : .light
        searchBar.textField?.tintColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor.black
        searchBar.textField?.borderStyle = .roundedRect
        searchBar.textField?.layer.borderWidth = 0.0
        searchBar.textField?.font = CHCustomStyles.normalSizeRegularFont
        searchBar.textField?.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor.black
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: UIBarMetrics.default)
        searchBar.setTextFieldBackgroundColor(color: CHAppConstant.themeStyle == .dark ? UIColor(hex: "#2c2c2c") : UIColor(hex: "#e6e6e6"))
        let closeIconImage = getImage("chCloseIcon")?.selfResize(targetSize: CGSize(width: 17.5, height: 17.5))
        searchBar.setImage(closeIconImage?.imageWithColor(tintColor: CHAppConstant.themeStyle == .dark ? UIColor(hex: "#E6E6E6") : UIColor(hex: "#8b8b8b")), for: .clear, state: .normal)
        searchBar.setImage(getImage("chSearchIcon")?.imageWithColor(tintColor: CHAppConstant.themeStyle == .dark ? UIColor(hex: "#E6E6E6") : UIColor(hex: "#8b8b8b")), for: .search, state: .normal)
        searchBar.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        searchBar.addBottomBorder(with: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.seperatorColor : CHLightThemeColors.instance.seperatorColor, andWidth: 0.5)
        return searchBar
    }()
    
    var doneBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.titleView = self.searchBar
        self.searchBar.delegate = self
        self.keyBoardManger = KeyboardManager()
        self.keyBoardManger?.on(event: .willShow, do: { notification in
            self.tableView.contentInset.bottom = notification.endFrame.height
        }).on(event: .willHide, do: { _ in
            self.tableView.contentInset.bottom = 0
        })
        self.tableView.tableHeaderView = UIView()
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.groupedTableBackGroundColor : CHLightThemeColors.instance.groupedTableBackGroundColor
        self.tableView.indicatorStyle = CHAppConstant.themeStyle == .dark ? .white : .black
        self.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.seperatorColor : CHLightThemeColors.instance.seperatorColor
        self.tableView.register(CHContactSelectTableCell.self, forCellReuseIdentifier: "selectContactTable")
        self.tableView.register(CHTableViewLoadingCell.self, forCellReuseIdentifier: "searchLoadingCell")
        self.tableView.register(CHSelectGroupTableCell.self, forCellReuseIdentifier: "selectGroupCell")
        self.tableView.allowsMultipleSelection = true
        self.tableView.keyboardDismissMode = .onDrag
        self.getContactLists()
        self.getConversationsList()
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarButtonPressed(sender:)))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(forwardButtonPressed(sender:)))
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
        doneBarButtonItem.isEnabled = false
        
        self.selectedUserChatView.onSelectedModelRemoved = {(model) in
            if model?.type == .user {
                if let firstIndex = self.selectedUsers.firstIndex(where: {
                    $0.id == model?.id
                }) {
                    self.selectedUsers.removeAll(where: {
                        $0.id == model?.id
                    })
                    self.tableView.performBatchUpdates({
                        self.tableView.reloadRows(at: [IndexPath(row: firstIndex, section: 0)], with: .none)
                    }, completion: nil)
                }
            } else {
                if let firstIndex = self.selectedConversations.firstIndex(where: {
                    $0.id == model?.id
                }) {
                    self.selectedConversations.removeAll(where: {
                        $0.id == model?.id
                    })
                    self.tableView.performBatchUpdates({
                        self.tableView.reloadRows(at: [IndexPath(row: firstIndex, section: 1)], with: .none)
                    }, completion: nil)
                }
            }
            self.updateSelectedCells()
            self.updateSelectedContainerView(with: nil, modelId: model?.id, actionType: .remove)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc private func cancelBarButtonPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func forwardButtonPressed(sender: UIBarButtonItem) {
        var selectedUserIds = self.selectedUsers.compactMap({ $0.id ?? ""})
        selectedUserIds.removeAll(where: {
            $0 == ""
        })
        var selectedConversationIds = self.selectedConversations.compactMap({ $0.id ?? ""})
        selectedConversationIds.removeAll(where: {
            $0 == ""
        })
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.forwardMessages(messageIds: self.messageIds, userIds: selectedUserIds, conversationIds: selectedConversationIds, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.titleView = self.searchBar
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.titleView = nil
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.isSearching {
            return 1
        } else {
            if self.searchedContacts.count == 0 && self.searchedGroupsConversation.count == 0 {
                return 1
            } else {
                return 2
            }
            
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.isSearching {
            return 1
        } else {
            if self.searchedContacts.count == 0 && self.searchedGroupsConversation.count == 0 {
                return 1
            } else {
                if section == 0 {
                    return self.searchedContacts.count
                } else {
                    return self.searchedGroupsConversation.count
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isSearching {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchLoadingCell", for: indexPath) as! CHTableViewLoadingCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            return cell
        } else {
            if self.searchedContacts.count == 0 && self.searchedGroupsConversation.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchLoadingCell", for: indexPath) as! CHTableViewLoadingCell
                cell.setUpViews()
                cell.setUpViewsFrames()
                cell.showInfoLabel(withText: "No Results Found.")
                return cell
            } else {
                if indexPath.section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "selectContactTable", for: indexPath) as! CHContactSelectTableCell
                    cell.setUpViews()
                    cell.setUpViewsFrames()
                    cell.user = self.searchedContacts[indexPath.row]
                    cell.assignData()
                    cell.setUpUIProperties()
                    
                    if self.selectedUsers.contains(where: {
                        $0.id == self.searchedContacts[indexPath.row].id
                    }) {
                        cell.setCellSelected()
                    } else {
                        cell.setCellUnselected()
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "selectGroupCell", for: indexPath) as! CHSelectGroupTableCell
                    cell.setUpViews()
                    cell.setUpViewsFrames()
                    cell.conversation = self.searchedGroupsConversation[indexPath.row]
                    cell.assignData()
                    cell.setUpUIProperties()
                    if self.selectedConversations.contains(where: {
                        $0.id == self.searchedGroupsConversation[indexPath.row].id
                    }) {
                        cell.setCellSelected()
                    } else {
                        cell.setCellUnselected()
                    }
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.isSearching {
            return 0
        } else {
            if self.searchedContacts.count == 0 && self.searchedGroupsConversation.count == 0 {
                return 10
            } else {
                if section == 0 {
                    if self.searchedContacts.count == 0 {
                        return 0
                    } else {
                        return 60
                    }
                } else {
                    if self.searchedGroupsConversation.count == 0 {
                        return 0
                    } else {
                        return 40
                    }
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard self.isSearching == false else {
            return nil
        }
        guard self.searchedContacts.count >= 0 && self.searchedGroupsConversation.count >= 0 else {
            return nil
        }
            
        if section == 0 {
            guard self.searchedContacts.count > 0 else {
                return nil
            }
            let backGroundView = UIView()
            backGroundView.backgroundColor = .clear
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = CHLocalized(key: "pmContacts")
            label.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor
            label.font = CHCustomStyles.mediumSizeMediumFont
            backGroundView.addSubview(label)
            label.setTopAnchor(relatedConstraint: backGroundView.topAnchor, constant: 10)
            label.setBottomAnchor(relatedConstraint: backGroundView.bottomAnchor, constant: 0)
            label.setRightAnchor(relatedConstraint: backGroundView.rightAnchor, constant: -10)
            label.setLeftAnchor(relatedConstraint: backGroundView.leftAnchor, constant: 15)
            return backGroundView
        } else {
            guard self.allGroupsConversations.count > 0 else {
                return nil
            }
            let backGroundView = UIView()
            backGroundView.backgroundColor = .clear
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = CHLocalized(key: "pmGroups")
            label.textColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor
            label.font = CHCustomStyles.mediumSizeMediumFont
            backGroundView.addSubview(label)
            label.setTopAnchor(relatedConstraint: backGroundView.topAnchor, constant: 0)
            label.setBottomAnchor(relatedConstraint: backGroundView.bottomAnchor, constant: 0)
            label.setRightAnchor(relatedConstraint: backGroundView.rightAnchor, constant: -10)
            label.setLeftAnchor(relatedConstraint: backGroundView.leftAnchor, constant: 15)
            return backGroundView
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if let cell = tableView.cellForRow(at: indexPath) as? CHSelectGroupTableCell {
            if let conversation = cell.conversation {
                self.selectedConversations.append(conversation)
                if let newModel = self.createSelectedChatModel(with: nil, with: conversation) {
                    self.updateSelectedContainerView(with: newModel, modelId: nil, actionType: .add)
                }
            }
            cell.isSelected = true
            cell.setCellSelected()
        }
        if let cell = tableView.cellForRow(at: indexPath) as? CHContactSelectTableCell {
            if let cellUser = cell.user{
                self.selectedUsers.append(cellUser)
                if let newModel = self.createSelectedChatModel(with: cellUser, with: nil) {
                    self.updateSelectedContainerView(with: newModel, modelId: nil, actionType: .add)
                }
            }
            cell.isSelected = true
            cell.setCellSelected()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CHContactSelectTableCell {
            
            if let cellUser = cell.user{
                self.selectedUsers.removeAll(where: {
                    $0.id == cellUser.id
                })
                self.updateSelectedContainerView(with: nil, modelId: cellUser.id, actionType: .remove)
            }
            cell.isSelected = false
            cell.setCellUnselected()
        } else if let conversationCell = tableView.cellForRow(at: indexPath) as? CHSelectGroupTableCell {
            if let cellConversation = conversationCell.conversation {
                self.selectedConversations.removeAll(where: {
                    $0.id == cellConversation.id
                })
                self.updateSelectedContainerView(with: nil, modelId: cellConversation.id, actionType: .remove)
            }
            conversationCell.isSelected = false
            conversationCell.setCellUnselected()
        }
    }
    
    func createSelectedChatModel(with user: CHUser?, with conversation: CHConversation?) -> SelecteChatModel? {
        if user != nil {
            let model = SelecteChatModel(id: user?.id ?? "", type: .user, title: user?.displayName?.capitalized ?? "", profileImageUrl: user?.profileImageUrl ?? "")
            return model
        } else if conversation != nil {
            let model = SelecteChatModel(id: conversation?.id ?? "", type: .conversation, title: conversation?.title ?? "", profileImageUrl: conversation?.profileImageUrl ?? "")
            return model
        } else {
            return nil
        }
    }
    
    func updateSelectedContainerView(with model: SelecteChatModel? = nil, modelId: String? = nil, actionType: SelectedContainerViewActionType) {
        
        if self.selectedUsers.count > 0 || self.selectedConversations.count > 0 {
            self.doneBarButtonItem.isEnabled = true
            if self.selectedUserChatView.viewWithTag(101010) == nil {
                self.selectedUserChatView.addBottomBorder(with: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor, andWidth: 1.0)
            }
            self.extraInfoContainerViewHeight = 120
            if !self.extraInfoContainerView.subviews.contains(self.selectedUserChatView) {
                self.extraInfoContainerView.addSubview(self.selectedUserChatView)
                self.selectedUserChatView.translatesAutoresizingMaskIntoConstraints = false
                self.selectedUserChatView.pinEdgeToSuperView(superView: self.extraInfoContainerView)
            }
        } else {
            self.doneBarButtonItem.isEnabled = false
            self.selectedUserChatView.viewWithTag(101010)?.removeFromSuperview()
            self.extraInfoContainerViewHeight = 0
        }
        
        let oldItems = self.selectedUserChatView.selectedModels.copy()
        if actionType == .add {
            if let addedModel = model {
                self.selectedUserChatView.selectedModels.append(addedModel)
            }
        } else {
            self.selectedUserChatView.selectedModels.removeAll(where: {
                $0.id == modelId
            })
        }
        let changeSet = StagedChangeset(source: oldItems, target: self.selectedUserChatView.selectedModels)
        
        self.selectedUserChatView.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
            self.selectedUserChatView.selectedModels = data
        }, completion: {
            if actionType == .add {
                self.selectedUserChatView.collectionView.scrollToLast(animated: true, position: .centeredHorizontally)
            }
        })
    }
    
    
    
    func updateSelectedContainerView(with user: CHUser?,with conversation: CHConversation? ) {
        if self.selectedUsers.count > 0 || self.selectedConversations.count > 0 {
            self.extraInfoContainerViewHeight = 110
        } else {
            self.extraInfoContainerViewHeight = 0
        }
    }
    
    // MARK: - UISearchbar Delegates
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //var searchTask: DispatchWorkItem?
        if searchText == "" {
            self.contactsSearchTask?.cancel()
            self.cancelPreviousRequest()
            self.isSearching = false
            self.searchedContacts = self.allContacts
            self.searchedGroupsConversation = self.allGroupsConversations
            self.tableView.reloadData()
            self.updateSelectedCells()
        } else {
            self.contactsSearchTask?.cancel()
            let task = DispatchWorkItem { [weak self] in
                self?.cancelPreviousRequest()
                self?.isSearching = true
                self?.searchedContacts.removeAll()
                self?.searchedGroupsConversation.removeAll()
                self?.tableView.reloadData()
                self?.performUserSearch(searchQuery: searchText)
                self?.perfromGroupSearch(searchQuery: searchText)
            }
            self.contactsSearchTask = task
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.50, execute: task)
        }
    }
    
    
    // MARK: - API Functions
    private func getContactLists() {
        let onlineContactsQueryBuilder = CHFriendQueryBuilder()
        onlineContactsQueryBuilder.limit = 100
        onlineContactsQueryBuilder.skip = 0
        onlineContactsQueryBuilder.includeBlocked = false
        ChannelizeAPIService.getFriendsList(queryBuilder: onlineContactsQueryBuilder, completion: {(users,errorString) in
            self.isSearching = false
            guard errorString == nil else {
                return
            }
            if let recievedUsers = users {
                recievedUsers.forEach({
                    self.allContacts.append($0)
                })
                ChUserCache.instance.appendUsers(newUsers: recievedUsers)
            }
            self.searchedContacts = self.allContacts
            self.tableView.reloadData()
        })
    }
    
    private func getConversationsList() {
        let groupConversationBuilder = CHListConversationsQueryBuilder()
        groupConversationBuilder.isGroup = true
        groupConversationBuilder.limit = 100
        groupConversationBuilder.skip = 0
        ChannelizeAPIService.getConversationList(queryBuilder: groupConversationBuilder, completion: {(conversations,errorString) in
            self.isSearching = false
            guard errorString == nil else {
                return
            }
            if let recievedConversations = conversations {
                recievedConversations.forEach({
                    self.allGroupsConversations.append($0)
                })
            }
            self.searchedGroupsConversation = self.allGroupsConversations
            self.tableView.reloadData()
        })
    }
    
    
    private func performUserSearch(searchQuery: String) {
        let onlineContactsQueryBuilder = CHFriendQueryBuilder()
        onlineContactsQueryBuilder.limit = 100
        onlineContactsQueryBuilder.skip = 0
        onlineContactsQueryBuilder.includeBlocked = false
        onlineContactsQueryBuilder.searchQuery = searchQuery
        ChannelizeAPIService.getFriendsList(queryBuilder: onlineContactsQueryBuilder, completion: {(users,errorString) in
            guard errorString == nil else {
                return
            }
            if let recievedUsers = users {
                self.isSearching = false
                self.searchedContacts.removeAll()
                self.searchedContacts = recievedUsers
                ChUserCache.instance.appendUsers(newUsers: recievedUsers)
            }
            self.tableView.reloadData()
            self.updateSelectedCells()
        })
    }
    
    private func perfromGroupSearch(searchQuery: String) {
        let groupConversationBuilder = CHListConversationsQueryBuilder()
        groupConversationBuilder.isGroup = true
        groupConversationBuilder.searchQuery = searchQuery
        groupConversationBuilder.limit = 100
        groupConversationBuilder.skip = 0
        ChannelizeAPIService.getConversationList(queryBuilder: groupConversationBuilder, completion: {(conversations,errorString) in
            guard errorString == nil else {
                return
            }
            if let recievedConversations = conversations {
                self.isSearching = false
                self.searchedGroupsConversation.removeAll()
                self.searchedGroupsConversation = recievedConversations
            }
            self.tableView.reloadData()
            self.updateSelectedCells()
        })
    }
    
    private func cancelPreviousRequest() {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach {
                print("Cancelling -> \($0.originalRequest?.url?.absoluteURL.path ?? "")")
                if ($0.originalRequest?.url?.absoluteURL.path == "/users/friends") {
                    $0.cancel()
                }
                if ($0.originalRequest?.url?.absoluteURL.path == "/conversations") {
                    $0.cancel()
                }
            }
        }
    }
    
    func updateSelectedCells() {
        self.selectedUsers.forEach({
            let user = $0
            if let indexPath = self.searchedContacts.firstIndex(where: {
                $0.id == user.id
            }) {
                self.tableView.selectRow(at: IndexPath(row: indexPath, section: 0), animated: false, scrollPosition: .none)
            }
        })
        self.selectedConversations.forEach({
            let conversation = $0
            if let indexPath = self.searchedGroupsConversation.firstIndex(where: {
                $0.id == conversation.id
            }) {
                self.tableView.selectRow(at: IndexPath(row: indexPath, section: 1), animated: false, scrollPosition: .none)
            }
        })
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

enum SelectedContainerViewActionType {
    case add
    case remove
}

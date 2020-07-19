//
//  CHNewMessageController.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/2/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire
import InputBarAccessoryView

class CHNewMessageController: NewCHTableViewController, UISearchBarDelegate {

    var allContacts = [CHUser]()
    var searchedContacts = [CHUser]()
    
    var isLoadingContacts = false
    var currentOffset = 0
    var apiCallLimit = 100
    var isAllContactsLoaded = false
    var isSearchingContact = false
    
    var searchTask: DispatchWorkItem?
    var keyBoardManager: KeyboardManager?
    
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
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
        searchBar.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.buttonsTintColor : CHLightThemeColors.buttonsTintColor
        searchBar.addBottomBorder(with: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor, andWidth: 0.5)
        return searchBar
    }()
    
    init() {
        super.init(tableStyle: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.tableView.register(CHNewCallTableCell.self, forCellReuseIdentifier: "createCallContactCell")
        self.tableView.register(CHTableViewLoadingCell.self, forCellReuseIdentifier: "searchLoadingCell")
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.plainTableBackGroundColor : CHLightThemeColors.plainTableBackGroundColor
        self.tableView.indicatorStyle = CHAppConstant.themeStyle == .dark ? .white : .black
        if ChUserCache.instance.users.count == 0 {
            self.getContactLists()
        } else {
            self.allContacts = ChUserCache.instance.users.sorted(by: {$0.displayName ?? "" < $1.displayName ?? ""})
            self.searchedContacts = ChUserCache.instance.users.sorted(by: {$0.displayName ?? "" < $1.displayName ?? ""})
        }
        
        self.keyBoardManager = KeyboardManager()
        self.keyBoardManager?.on(event: .willShow, do: { notification in
            self.tableView.contentInset.bottom = notification.endFrame.height
        }).on(event: .willHide, do: { _ in
            self.tableView.contentInset.bottom = 0
        })
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.titleView = self.searchBar
        self.navigationItem.titleView?.clipsToBounds = true
        self.searchBar.delegate = self
        self.searchBar.becomeFirstResponder()
        self.tableView.contentInset.top = 10
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.titleView = nil
        if self.isMovingFromParent {
            self.keyBoardManager = nil
        }
    }
    
    // MARK: - API Functions
    private func getContactLists() {
        let onlineContactsQueryBuilder = CHFriendQueryBuilder()
        onlineContactsQueryBuilder.limit = self.apiCallLimit
        onlineContactsQueryBuilder.skip = self.currentOffset
        onlineContactsQueryBuilder.includeBlocked = false
        ChannelizeAPIService.getFriendsList(queryBuilder: onlineContactsQueryBuilder, completion: {(users,errorString) in
            self.isLoadingContacts = false
            guard errorString == nil else {
                return
            }
            if let recievedUsers = users {
                self.currentOffset += recievedUsers.count
                recievedUsers.forEach({
                    self.allContacts.append($0)
                })
                ChUserCache.instance.appendUsers(newUsers: recievedUsers)
            }
            self.searchedContacts = self.allContacts
            self.tableView.reloadData()
            if users?.count ?? 0 < self.apiCallLimit {
                self.isAllContactsLoaded = true
            }
        })
    }
    
    private func performUserSearch(searchQuery: String) {
        if CHCustomOptions.isAllUserSearchEnabled {
            let usersSearchQuery = CHUserQueryBuilder()
            usersSearchQuery.limit = 100
            usersSearchQuery.skip = 0
            usersSearchQuery.searchQuery = searchQuery
            ChannelizeAPIService.getUsersList(queryBuilder: usersSearchQuery, completion: {(users,errorString) in
                guard errorString == nil else {
                    return
                }
                if let recievedUsers = users {
                    self.isSearchingContact = false
                    self.searchedContacts.removeAll()
                    self.searchedContacts = recievedUsers
                    self.tableView.reloadData()
                    //ChUserCache.instance.appendUsers(newUsers: recievedUsers)
                }
            })
        } else {
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
                    self.isSearchingContact = false
                    self.searchedContacts.removeAll()
                    self.searchedContacts = recievedUsers
                    ChUserCache.instance.appendUsers(newUsers: recievedUsers)
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    private func cancelPreviousRequest() {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach {
                print("Cancelling -> \($0.originalRequest?.url?.absoluteURL.path ?? "")")
                if ($0.originalRequest?.url?.absoluteURL.path == "/users/friends") {
                    $0.cancel()
                }
                if ($0.originalRequest?.url?.absoluteURL.path == "/users") {
                    $0.cancel()
                }
            }
        }
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.isSearchingContact {
            return 1
        } else {
            if self.searchedContacts.count == 0 {
                return 1
            } else {
                return self.searchedContacts.count
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isSearchingContact {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchLoadingCell", for: indexPath) as! CHTableViewLoadingCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            return cell
        } else {
            if self.searchedContacts.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchLoadingCell", for: indexPath) as! CHTableViewLoadingCell
                cell.setUpViews()
                cell.setUpViewsFrames()
                cell.showInfoLabel(withText: "No Result Found.")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "createCallContactCell", for: indexPath) as! CHNewCallTableCell
                cell.setUpViews()
                cell.setUpViewsFrames()
                cell.user = self.searchedContacts[indexPath.row]
                cell.assignData()
                cell.setUpUIProperties()
                cell.hideCallButtons()
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.isLoadingContacts == false, self.isSearchingContact == false, self.searchedContacts.count > 0 else {
            return
        }
        let selectedUser = self.searchedContacts[indexPath.row]
        let conversation = CHConversation()
        conversation.conversationPartner = selectedUser
        let conversationController = CHConversationViewController()
        conversationController.conversation = conversation
        conversationController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(conversationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    // MARK: - Searchbar Delegates
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //var searchTask: DispatchWorkItem?
        if searchText == "" {
            self.searchTask?.cancel()
            self.cancelPreviousRequest()
            self.isSearchingContact = false
            self.searchedContacts = self.allContacts
            self.tableView.reloadData()
        } else {
            self.searchTask?.cancel()
            let task = DispatchWorkItem { [weak self] in
                self?.cancelPreviousRequest()
                self?.isSearchingContact = true
                self?.searchedContacts.removeAll()
                self?.tableView.reloadData()
                self?.performUserSearch(searchQuery: searchText)
            }
            self.searchTask = task
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: task)
        }
    }
    
    // MARK: - Other Functions
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.tableView.reloadData()
    }
}



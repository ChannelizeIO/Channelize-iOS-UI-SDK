//
//  CHSearchViewController.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/11/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire
import ObjectMapper

class CHSearchViewController: UITableViewController, UISearchBarDelegate {

    var allContacts = [CHUser]()
    var allGroupsConversations = [CHConversation]()
    
    var searchedContacts = [CHUser]()
    var searchedGroupsConversation = [CHConversation]()
    
    var isSearching = true
    
    var isSearchingContact = false
    var isSearchingConversation = false
    
    var contactsSearchTask: DispatchWorkItem?
    
    init() {
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.keyboardAppearance = CHAppConstant.themeStyle == .dark ? .dark : .light
        searchBar.textField?.tintColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor.black
        searchBar.textField?.borderStyle = .roundedRect
        searchBar.textField?.layer.borderWidth = 0.0
        searchBar.textField?.font = UIFont(fontStyle: .regular, size: 17.0)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.titleView = self.searchBar
        self.searchBar.delegate = self
        self.searchBar.becomeFirstResponder()
        self.tableView.tableHeaderView = UIView()
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.groupedTableBackGroundColor : CHLightThemeColors.instance.groupedTableBackGroundColor
        self.tableView.indicatorStyle = CHAppConstant.themeStyle == .dark ? .white : .black
        self.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.seperatorColor : CHLightThemeColors.instance.seperatorColor
        self.tableView.register(CHNewCallTableCell.self, forCellReuseIdentifier: "createCallContactCell")
        self.tableView.register(CHTableViewLoadingCell.self, forCellReuseIdentifier: "searchLoadingCell")
        self.tableView.register(CHGroupConversationCell.self, forCellReuseIdentifier: "groupInfoCell")
        
        self.getContactLists()
        self.getConversationsList()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

    override func numberOfSections(in tableView: UITableView) -> Int {
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
                    let cell = tableView.dequeueReusableCell(withIdentifier: "createCallContactCell", for: indexPath) as! CHNewCallTableCell
                    cell.setUpViews()
                    cell.setUpViewsFrames()
                    cell.user = self.searchedContacts[indexPath.row]
                    cell.assignData()
                    cell.setUpUIProperties()
                    cell.hideCallButtons()
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "groupInfoCell", for: indexPath) as! CHGroupConversationCell
                    cell.setUpViews()
                    cell.setUpViewsFrames()
                    cell.conversation = self.searchedGroupsConversation[indexPath.row]
                    cell.assignData()
                    cell.setUpUIProperties()
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
                        return 45
                    }
                }
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
            backGroundView.backgroundColor = .clear//CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : .white
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Contacts"
            label.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#4a505a")
            label.font = UIFont(fontStyle: .medium, size: 16)
            backGroundView.addSubview(label)
            label.setTopAnchor(relatedConstraint: backGroundView.topAnchor, constant: 15)
            label.setBottomAnchor(relatedConstraint: backGroundView.bottomAnchor, constant: 0)
            label.setRightAnchor(relatedConstraint: backGroundView.rightAnchor, constant: -10)
            label.setLeftAnchor(relatedConstraint: backGroundView.leftAnchor, constant: 15)
            return backGroundView
        } else {
            guard self.allGroupsConversations.count > 0 else {
                return nil
            }
            let backGroundView = UIView()
            backGroundView.backgroundColor = .clear//CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : .white
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Groups"
            label.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#4a505a")
            label.font = UIFont(fontStyle: .medium, size: 16)
            backGroundView.addSubview(label)
            label.setTopAnchor(relatedConstraint: backGroundView.topAnchor, constant: 10)
            label.setBottomAnchor(relatedConstraint: backGroundView.bottomAnchor, constant: 0)
            label.setRightAnchor(relatedConstraint: backGroundView.rightAnchor, constant: -10)
            label.setLeftAnchor(relatedConstraint: backGroundView.leftAnchor, constant: 15)
            return backGroundView
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.isSearching == false else {
            return
        }
        guard self.searchedContacts.count >= 0 && self.searchedGroupsConversation.count >= 0 else {
            return
        }
        if indexPath.section == 0 {
            let user = self.searchedContacts[indexPath.row]
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
            let conversationController = CHConversationViewController()
            conversationController.hidesBottomBarWhenPushed = true
            conversationController.conversation = self.searchedGroupsConversation[indexPath.row]
            self.navigationController?.pushViewController(conversationController, animated: true)
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
        } else {
            self.contactsSearchTask?.cancel()
            let task = DispatchWorkItem { [weak self] in
                self?.cancelPreviousRequest()
                self?.isSearching = true
                self?.searchedContacts.removeAll()
                self?.searchedGroupsConversation.removeAll()
                self?.tableView.reloadData()
                self?.performUserSearch(searchQuery: searchText)
                //self?.perfromGroupSearch(searchQuery: searchText)
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
            self.isSearchingContact = false
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
            self.isSearchingConversation = false
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
                    self.searchedContacts.removeAll()
                    self.searchedContacts = recievedUsers
                    //ChUserCache.instance.appendUsers(newUsers: recievedUsers)
                }
                self.perfromGroupSearch(searchQuery: searchQuery)
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
                    self.searchedContacts.removeAll()
                    self.searchedContacts = recievedUsers
                    ChUserCache.instance.appendUsers(newUsers: recievedUsers)
                }
                self.perfromGroupSearch(searchQuery: searchQuery)
            })
        }
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
                self.searchedGroupsConversation.removeAll()
                self.searchedGroupsConversation = recievedConversations
            }
            self.isSearching = false
            self.tableView.reloadData()
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
                if ($0.originalRequest?.url?.absoluteURL.path == "/users") {
                    $0.cancel()
                }
            }
        }
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


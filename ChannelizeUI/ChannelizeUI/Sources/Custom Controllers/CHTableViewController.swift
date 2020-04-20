//
//  CHTableViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/22/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire

class CHTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating{
    
    var currentSearchType: UISearchType = .contacts
    var superView: UIView?
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.superView = self.navigationController?.view
        self.configureSearchController()
        self.setUpHomeButton()
        self.setUpCreateButton()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func configureSearchController() {
        
        let searchResultController = UISearchResultTableViewController()
        searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.scopeButtonTitles = [CHLocalized(key: "pmContacts"),CHLocalized(key: "pmGroups")]
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.setTextFieldBackgroundColor(color: .white)
        searchController.searchBar.tintColor = .white
        
        searchController.searchBar.textField?.tintColor = .black
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        
        definesPresentationContext = true
        searchController.searchBar.setScopeBarButtonBackgroundImage(
            UIImage.imageWithColor(color: UIColor.white), for: .selected)
        searchController.searchBar.setScopeBarButtonTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: CHUIConstants.appDefaultColor,
            NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabSemiBold, size: 17.0)!
            ], for: .selected)
        
        searchController.searchBar.setScopeBarButtonTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabSemiBold, size: 17.0)!
            ], for: .normal)
    }
    
    // MARK: - UISearchController Functions
    
    func updateSearchResults(for searchController: UISearchController) {
        if let resultsController = searchController.searchResultsController as? UISearchResultTableViewController {
            
            resultsController.onTappedCell = {[weak self](conversation,user) in
                for view in self?.searchController.searchBar.subviews ?? [] {
                    if view.isKind(of: UIButton.self) {
                        let cancelButton = view as? UIButton
                        cancelButton?.sendActions(for: .touchUpInside)
                    }
                }
//                self?.navigationItem.searchController?.isActive = false
                self?.dismiss(animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.4, execute: {
                    if conversation != nil {
                        let controller = UIConversationViewController()
                        controller.conversation = conversation
                        //controller.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(
                            controller, animated: true)
                    } else {
                        let controller = UIConversationViewController()
                        controller.user = user
                        //controller.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(
                            controller, animated: true)
                    }
                })
//                self?.dismiss(animated: true, completion: {
//                    if conversation != nil {
//                        let controller = UIConversationViewController()
//                        controller.conversation = conversation
//                        //controller.hidesBottomBarWhenPushed = true
//                        self?.navigationController?.pushViewController(
//                            controller, animated: true)
//                    } else {
//                        let controller = UIConversationViewController()
//                        controller.user = user
//                        //controller.hidesBottomBarWhenPushed = true
//                        self?.navigationController?.pushViewController(
//                            controller, animated: true)
//                    }
//                })
            }
            
            let searchText = searchController.searchBar.text ?? ""
            if searchText == "" {
                self.cancelPreviousRequest()
                resultsController.isLoadingApi = false
                resultsController.searchType = self.currentSearchType
                if self.currentSearchType == .contacts {
                    
                    resultsController.users = CHAllContacts.contactsList
                    resultsController.tableView.reloadData()
                    resultsController.view.isHidden = false
                } else {
                    resultsController.conversations = CHAllConversations.allConversations.filter({
                        $0.isGroup == true
                    })
                    resultsController.tableView.reloadData()
                    resultsController.view.isHidden = false
                }
            } else {
                self.cancelPreviousRequest()
                resultsController.isLoadingApi = true
                resultsController.tableView.reloadData()
                
                if self.currentSearchType == .contacts {
                    self.getSearchResult(with: searchText, completion: {(users,error) in
                        if let recievedUsers = users {
                            resultsController.searchType = self.currentSearchType
                            resultsController.isLoadingApi = false
                            let onlineUsers = recievedUsers.filter({
                                $0.isOnline == true
                            })
                            let offlineUsers = recievedUsers.filter({
                                $0.isOnline == false
                            })
                            var mergedUsers = onlineUsers
                            mergedUsers.append(contentsOf: offlineUsers)
                            resultsController.users = mergedUsers
                            resultsController.tableView.reloadData()
                        }
                    })
                } else if self.currentSearchType == .conversations {
                    self.getSearchedConversations(with: searchText, completion: {(converstions,error) in
                        if let recievedConversations = converstions {
                            resultsController.searchType = self.currentSearchType
                            resultsController.isLoadingApi = false
                            resultsController.conversations = recievedConversations
                            resultsController.tableView.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 0 {
            self.currentSearchType = .contacts
        } else {
            self.currentSearchType = .conversations
        }
        self.updateSearchResults(for: self.searchController)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    
    // MARK:- API Functions
    private func getSearchResult(with searchText: String, completion: @escaping ([CHUser]?,String?) -> ()) {
        var params = [String:Any]()
        params.updateValue(50, forKey: "limit")
        params.updateValue(0, forKey: "skip")
        params.updateValue(searchText, forKey: "search")
        
        ChannelizeAPIService.getFriendsList(params: params, completion: {(users,errorString) in
            if let recievedUsers = users {
                completion(recievedUsers,nil)
            }
        })
    }
    
    private func getSearchedConversations(with searchText: String, completion: @escaping ([CHConversation]?,String?) -> ()) {
        
        var params = [String:Any]()
        params.updateValue(searchText, forKey: "search")
        params.updateValue(true, forKey: "isGroup")
        params.updateValue(50, forKey: "limit")
        params.updateValue(0, forKey: "skip")
        params.updateValue("members", forKey: "include")
        
        ChannelizeAPIService.getConversationList(params: params, completion: {(conversations,errorString) in
            if let error = errorString{
                completion(nil,error)
                print("Api failed with error \(error)")
            } else{
                print("Response Comes")
                if let recievedConversations = conversations {
                    completion(recievedConversations,nil)
                }
            }
        })
    }
    
    func cancelPreviousRequest() {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach {
                print("Cancelling -> \($0.originalRequest?.url?.absoluteURL.path ?? "")")
                if ($0.originalRequest?.url?.absoluteURL.path == "/v2/users/friends")
                {
                    $0.cancel()
                } else if ($0.originalRequest?.url?.absoluteURL.path == "/v2/conversations") {
                    $0.cancel()
                }
            }
        }
    }
    
    func setUpHomeButton(){
        let homeButton = UIBarButtonItem(image: getImage("chHomeIcon"), style: .plain, target: self, action: #selector(homeButtonPressed(sender:)))
        self.navigationItem.leftBarButtonItem = homeButton
        /*
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 44, height: 44)
        menuBtn.setImage(getImage("chHomeIcon"), for: .normal)
        menuBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        menuBtn.addTarget(self, action: #selector(homeButtonPressed(sender:)), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 44)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
 */
    }
    
    func setUpCreateButton() {
        let createButton = UIBarButtonItem(image: getImage("chPlusIcon"), style: .plain, target: self, action: #selector(createButtonPressed(sender:)))
        self.navigationItem.rightBarButtonItem = createButton
        /*
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 44, height: 44)
        menuBtn.setImage(getImage("chPlusIcon"), for: .normal)
        menuBtn.addTarget(self, action: #selector(createButtonPressed(sender:)), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 44)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
    */
    }
    
//    func configureTableView() {
//        tableView = UITableView(frame: .zero, style: tableStyle)
//        tableView.tableFooterView = UIView()
//        tableView.tableHeaderView = UIView()
//        tableView.delegate = self
//        tableView.dataSource = self
//        self.view.addSubview(tableView)
//        self.tableView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
//        self.tableView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
//        self.tableView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
//        self.tableView.setBottomAnchor(relatedConstraint: self.view.bottomAnchor, constant: 0)
//    }
    
    @objc func homeButtonPressed(sender: Any) {
        
//        ChannelizeAPI.removeUserEventDelegate(identifier: CHAllContacts.identifier)
//        ChannelizeAPI.removeConversationDelegate(identifier: CHAllContacts.identifier)
//        CHAllConversations.allConversations.removeAll()
//        CHAllConversations.allGroupsConversations.removeAll()
//        CHAllConversations.allConversationCurrentOffset = 0
//        CHAllConversations.groupsConversationCurrentOffset = 0
//        CHAllConversations.isAllConversationsLoaded = false
//        CHAllConversations.isAllGroupsConversationLoaded = false
//        CHAllConversations.removeConversationEventDelegates()
//        CHAllContacts.contactsList.removeAll()
//        CHAllContacts.currentOffset = 0
//        CHAllContacts.isAllContactsLoaded = false
//        ChannelizeUI.instance.isCHOpen = false
//        self.navigationController?
//            .parent?.navigationController?.popViewController(
//                animated: true)
        
        
        
        
        let alertController = UIAlertController(title: nil, message: "Logout?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Logout", style: .destructive, handler: {(action) in
            self.logout()
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func createButtonPressed(sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let newChatOption = UIAlertAction(title: "Create New Conversation", style: .default, handler: {(action) in
            self.openOneToOneSearchController()
        })
        let newGroupOption = UIAlertAction(title: "Create New Group", style: .default, handler: {(action) in
            self.openCreateGroupController()
        })
        let newCallAction = UIAlertAction(title: "Make a Call", style: .default, handler: {(action) in
            self.openCallSelectController()
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        alertController.addAction(newChatOption)
        alertController.addAction(newGroupOption)
        if CHConstants.isChannelizeCallAvailable {
            alertController.addAction(newCallAction)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func openCreateGroupController() {
        let controller = CreateGroupController()
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openOneToOneSearchController() {
        let controller = NewConversationController()
        controller.allUsers = CHAllContacts.contactsList
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openCallSelectController() {
        let controller = NewCallSelectController()
        controller.allUsers = CHAllContacts.contactsList
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func logout() {
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPI.logout(completion: {(status,errorString) in
            disMissProgressView()
            if status {
                ChannelizeAPI.removeUserEventDelegate(identifier: CHAllContacts.identifier)
                ChannelizeAPI.removeConversationDelegate(identifier: CHAllContacts.identifier)
                CHAllConversations.allConversations.removeAll()
                CHAllConversations.allGroupsConversations.removeAll()
                CHAllConversations.allConversationCurrentOffset = 0
                CHAllConversations.groupsConversationCurrentOffset = 0
                CHAllConversations.isAllConversationsLoaded = false
                CHAllConversations.isAllGroupsConversationLoaded = false
                CHAllConversations.removeConversationEventDelegates()
                CHAllContacts.contactsList.removeAll()
                CHAllContacts.currentOffset = 0
                CHAllContacts.isAllContactsLoaded = false
                ChannelizeUI.instance.isCHOpen = false
                self.navigationController?
                    .parent?.navigationController?.popViewController(
                        animated: true)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    /*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }*/
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


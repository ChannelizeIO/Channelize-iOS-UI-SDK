//
//  UIGroupsViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/15/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire

private let reuseIdentifier = "Cell"

class UIGroupsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, CHConversationEventDelegate, CHAllConversationsDelegate {

    var allConversation = [CHConversation]()
    private var isApiLoading = true
    private var isAllConversationLoaded = false
    private var isShimmeringModeOn = true
    private var currentOffset = 0
    
    var screenIdentifier: UUID!
    
    var currentSearchType: UISearchType = .contacts
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        self.screenIdentifier = UUID()
        CHAllConversations.addConversationDelegates(delegate: self, identifier: self.screenIdentifier)
        CHAllConversations.getAllGroupsConversations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Groups"
        //self.screenIdentifier = UUID()
        //ChannelizeAPI.addConversationEventDelegate(delegate: self, identifier: self.screenIdentifier)
        
        self.setUpHomeButton()
        self.setUpCreateButton()
        if CHCustomOptions.enableSearching {
            self.configureSearchController()
        }
        self.collectionView.backgroundColor = UIColor(hex: "#f2f2f7") //CHConstants.groupScreenBackGroundColor
        self.collectionView.register(UIGroupCollectionViewCell.self, forCellWithReuseIdentifier: "groupListCell")
        self.collectionView.register(GroupsListShimmeringCell.self, forCellWithReuseIdentifier: "groupShimmeringCell")
        self.collectionView.register(CollectionViewLoadingCell.self, forCellWithReuseIdentifier: "loadingCell")
        self.collectionView.register(NoGroupConversationCell.self, forCellWithReuseIdentifier: "noGroupConversationCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        //self.getGroupConversations(offet: self.currentOffset)

        // Do any additional setup after loading the view.
    }
    
    private func configureSearchController() {
        
        let searchResultController = UISearchResultTableViewController()
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.scopeButtonTitles = ["Contacts","Groups"]
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.setTextFieldBackgroundColor(color: CHCustomStyles.searchBarBackgroundColor)
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
                searchController.isActive = false
                if conversation != nil {
                    //let controller = UIConversationViewScreen()
                    //controller.conversation = conversation
                    //controller.hidesBottomBarWhenPushed = true
                    //self?.navigationController?.pushViewController(
                        //controller, animated: true)
                } else {
                    
                }
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
                            resultsController.users = recievedUsers
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
    
    
    
    // MARK:- UIView Functions
    private func setUpHomeButton(){
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 25, height: 25)
        menuBtn.setImage(getImage("chHomeIcon"), for: .normal)
        menuBtn.addTarget(self, action: #selector(homeButtonPressed(sender:)), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 25)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 25)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    private func setUpCreateButton() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 25, height: 25)
        menuBtn.setImage(getImage("chPlusIcon"), for: .normal)
        menuBtn.addTarget(self, action: #selector(createButtonPressed(sender:)), for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 25)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 25)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
    }
    
    // MARK: - Button Targets Functions
    @objc func homeButtonPressed(sender: UIButton) {
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
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            alertController.overrideUserInterfaceStyle = .light
        }
        #endif
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func createButtonPressed(sender: UIButton) {
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
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            alertController.overrideUserInterfaceStyle = .light
        }
        #endif
        if let popoverController = alertController.popoverPresentationController {
            showIpadActionSheet(sourceView: self.collectionView, popoverController: popoverController)
        }
        self.present(alertController, animated: true, completion: nil)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if section == 0 {
            if self.isShimmeringModeOn == true {
                return 10
            } else {
                if self.allConversation.count == 0 {
                    return 1
                } else {
                    return self.allConversation.count
                }
            }
        } else {
            if self.allConversation.count == 0 {
                collectionView.isScrollEnabled = false
                return 0
            } else {
                collectionView.isScrollEnabled = true
                return 1
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if self.isShimmeringModeOn == true {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupShimmeringCell", for: indexPath) as! GroupsListShimmeringCell
                cell.startShimmering()
                return cell
            } else {
                if self.allConversation.count == 0 {
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: "noGroupConversationCell", for: indexPath)
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: "groupListCell", for: indexPath) as! UIGroupCollectionViewCell
                    cell.conversation = self.allConversation[indexPath.item]
                    return cell
                }
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath) as! CollectionViewLoadingCell
            if CHAllConversations.isAllGroupsConversationLoaded == true {
                cell.showNoMoreResultLabel()
            } else {
                cell.showSpinnerView()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            if self.isShimmeringModeOn == true {
                let width = self.view.frame.width / 2 - 15
                return CGSize(width: width, height: getDeviceWiseAspectedHeight(constant: 220))
            } else {
                if self.allConversation.count == 0 {
                    let screenHeight = UIScreen.main.bounds.height
                    let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
                    let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0.0
                    return CGSize(width: self.view.frame.width, height: screenHeight - navBarHeight - tabBarHeight)
                    //return screenHeight - navBarHeight - tabBarHeight
                } else {
                    let width = self.view.frame.width / 2 - 10
                    return CGSize(width: width, height: getDeviceWiseAspectedHeight(constant: 220))
                }
            }
        } else {
            return CGSize(width: self.view.frame.width, height: 100)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else {
            return
        }
        if self.isShimmeringModeOn == false {
            if self.isAllConversationLoaded == false {
                if self.isApiLoading == false {
                    self.isApiLoading = true
                    self.getGroupConversations(offet: self.currentOffset)
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 6.5, bottom: 5, right: 6.5)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.isShimmeringModeOn == false else {
            return
        }
        guard indexPath.item != self.allConversation.count else {
            return
        }
        let conversation = self.allConversation[indexPath.item]
        let controller = UIConversationViewController()
        controller.conversation = conversation
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
        //let controller = UIConversationViewScreen()
        //controller.conversation = conversation
        //controller.hidesBottomBarWhenPushed = true
        //self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    // MARK:- API Functions
    private func getGroupConversations(offet: Int) {
        var params = [String : Any]()
        params.updateValue(30, forKey: "limit")
        params.updateValue(offet, forKey: "skip")
        params.updateValue("members", forKey: "include")
        params.updateValue(true, forKey: "isGroup")
        ChannelizeAPIService.getConversationList(params: params, completion: {(conversations,errorString) in
            self.isShimmeringModeOn = false
            self.isApiLoading = false
            if let fetchedConversations = conversations {
                self.currentOffset += fetchedConversations.count
                if fetchedConversations.count < 30 {
                    self.isAllConversationLoaded = true
                }
                self.allConversation.append(contentsOf: fetchedConversations)
            }
            self.collectionView.reloadData()
        })
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        //let controller = UISearchViewController()
        //controller.loadedUsers = AllFriends.allFriends
        //controller.loadedConversation = AllConversations.allConversations
        //controller.hidesBottomBarWhenPushed = true
        //self.navigationController?.pushViewController(controller, animated: true)
        return true
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
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
    
    func openCreateGroupController() {
        let controller = CreateGroupController()
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func logout() {
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPI.logout(completion: {(status,errorString) in
            disMissProgressView()
            if status {
                self.navigationController?
                    .parent?.navigationController?.popViewController(
                        animated: true)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }

}

extension UIGroupsViewController {
    
    func didRecieveNewMessage(message: CHMessage?) {
        guard let recievedMessage = message else {
            return
        }
        guard let conversationId = recievedMessage.conversationId else {
            return
        }
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.allConversation[conversationIndex]
            conversation.lastMessage = recievedMessage
            conversation.unreadMessageCount = (conversation.unreadMessageCount ?? 0) + 1
            self.allConversation.remove(at: conversationIndex)
            self.allConversation.insert(conversation, at: 0)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [IndexPath(item: conversationIndex, section: 0)])
                self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            }, completion: nil)
        } else {
            ChannelizeAPIService.getConversationWithId(conversationId: conversationId, completion: {(conversation,errorString) in
                if let recievedConversation = conversation, recievedConversation.isGroup == true {
                    self.allConversation.insert(recievedConversation, at: 0)
                    if self.allConversation.count == 1 {
                        self.collectionView.reloadData()
                    } else {
                        self.collectionView.performBatchUpdates({
                            self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                        }, completion: nil)
                    }
                }
            })
        }
    }
    
    func didConversationCleared(conversationId: String?) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId ?? "") {
            let conversation = self.allConversation[conversationIndex]
            conversation.lastMessage = nil
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
            }, completion: nil)
        }
    }
    
    func didConversationDeleted(conversationId: String?) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId ?? "") {
            self.allConversation.remove(at: conversationIndex)
            if self.allConversation.count == 0 {
                self.collectionView.reloadData()
            } else {
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: [IndexPath(item: conversationIndex, section: 0)])
                }, completion: nil)
            }
            
        }
    }
    
    func didConversationMessagesDeleted(conversationId: String?, deletedMessagesIds: [String]) {
        if let conversationIndex = getConversationIndex(conversationId: conversationId ?? "") {
            let conversation = self.allConversation[conversationIndex]
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
                        self.allConversation.remove(at: conversationIndex)
                        self.allConversation.insert(
                            recievedConversation, at: 0)
                        self.allConversation.sort(by: { $0.lastUpDatedAt ?? Date() > $1.lastUpDatedAt ?? Date()})
                        self.collectionView.reloadData()
                    }
                })
            }
        }
    }
    
    func didConversationMessagesDeletedForEveryOne(conversationId: String?, deletedMessagesIds: [String]) {
        if let conversationIndex = getConversationIndex(conversationId: conversationId ?? "") {
            let conversation = self.allConversation[conversationIndex]
            var doUpdateMessage = false
            deletedMessagesIds.forEach({
                let messageId = $0
                if conversation.lastMessage?.id == messageId {
                    doUpdateMessage = true
                }
            })
            
            if doUpdateMessage == true {
                conversation.lastMessage?.isDeleted = true
                self.collectionView.reloadData()
            }
        }
    }
    
    func didTypingStatusChanged(conversationId: String?, typingUserName: String?, isTyping: Bool) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId ?? "") {
            let conversation = self.allConversation[conversationIndex]
            conversation.isTyping = isTyping
            conversation.typingUserName = typingUserName
            self.allConversation.remove(at: conversationIndex)
            self.allConversation.insert(conversation, at: conversationIndex)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [IndexPath(item: conversationIndex, section: 0)])
                self.collectionView.insertItems(at: [IndexPath(item: conversationIndex, section: 0)])
            }, completion: nil)
            
        }
    }
    
    func didNewAdminAddedToConversation(conversationId: String, adminUserId: String) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.allConversation[conversationIndex]
            if let firstUser = conversation.members?.first(where: {
                $0.user?.id == adminUserId
            }) {
                firstUser.isAdmin = true
            }
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
            }, completion: nil)
        }
    }
    
    func didConversationMarkAsRead(conversationId: String, readerId: String, readedAt: Date?) {
        let dateTransformer = ISODateTransform()
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.allConversation[conversationIndex]
            if conversation.isGroup == true {
                if readerId == ChannelizeAPI.getCurrentUserId() {
                    conversation.unreadMessageCount = 0
                } else {
                    let dateString = dateTransformer.transformToJSON(
                        readedAt)
                    conversation.lastReadDictionary?.updateValue(
                        dateString ?? "", forKey: readerId)
                }
            } else {
                if readerId == ChannelizeAPI.getCurrentUserId() {
                    conversation.unreadMessageCount = 0
                } else {
                    let dateString = dateTransformer.transformToJSON(
                        readedAt)
                    conversation.lastReadDictionary?.updateValue(
                        dateString ?? "", forKey: readerId)
                }
            }
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
            }, completion: nil)
        }
    }
    
    func didMembersRemovedFromConversation(conversationId: String, removedMemberIds: [String]) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.allConversation[conversationIndex]
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
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
            }, completion: nil)
        }
    }
    
    func didNewMembersAddedToConversation(conversationId: String, addedMembers: [CHMember]) {
        
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.allConversation[conversationIndex]
            addedMembers.forEach({
                let memberObject = $0
                if conversation.members?.filter({
                    $0.user?.id == memberObject.user?.id
                }).count == 0 {
                    conversation.members?.append(memberObject)
                }
            })
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
            }, completion: nil)
        }
    }
    
    func didCurrentUserRemovedFromConversation(conversationId: String) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.allConversation[conversationIndex]
            conversation.canReplyToConversation = false
            conversation.members?.removeAll(where: {
                $0.user?.id == ChannelizeAPI.getCurrentUserId()
            })
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
            }, completion: nil)
        }
    }
    
    func didConversationMuteStatusUpdated(conversationId: String, isMuted: Bool) {
        if let conversationIndex = self.getConversationIndex(conversationId: conversationId) {
            let conversation = self.allConversation[conversationIndex]
            conversation.isMute = isMuted
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [IndexPath(item: conversationIndex, section: 0)])
            }, completion: nil)
        }
    }
    
    func getConversationIndex(conversationId: String) -> Int? {
        let firstIndex = self.allConversation.firstIndex(where: {
            $0.id == conversationId
        })
        return firstIndex
    }
    
    // MARK: - Conversations Events Functions
    func didLoadNewGroupConversations(conversations: [CHConversation]) {
        conversations.forEach({
            let conversationObject = $0
            if self.allConversation.filter({
                $0.id == conversationObject.id
            }).count == 0 {
                self.allConversation.append(conversationObject)
            }
        })
        self.isShimmeringModeOn = false
        self.collectionView.reloadData()
//        let indexPathsToBeInserted = self.calculateIndexPathsToInsert(from: conversations)
//        self.reloadTable(withNewIndexPaths: indexPathsToBeInserted)
    }
    
    
    
    
    
    private func calculateIndexPathsToInsert(from newConversations: [CHConversation]) -> [IndexPath] {
        let startIndex = self.allConversation.count - newConversations.count
        let endIndex = startIndex + newConversations.count
        return (startIndex..<endIndex).map { IndexPath(item: $0, section: 0)}
    }
    
    private func reloadTable(withNewIndexPaths: [IndexPath]) {
        self.collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: withNewIndexPaths)
        }, completion: nil)
    }
}


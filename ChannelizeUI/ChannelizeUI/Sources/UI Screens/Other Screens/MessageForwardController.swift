//
//  MessageForwardController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage
import Alamofire

class MessageForwardController: ChannelizeController, UITableViewDelegate, UITableViewDataSource, ForwardScreenChatViewDelegates, UISearchBarDelegate {
    
    var allUsers = [CHUser]()
    private var searchedUsers = [CHUser]()
    var allConversations = [CHConversation]()
    private var searchedConversations = [CHConversation]()
    
    var messageIds = [String]()
    
    private var selectedUsers = [CHUser]()
    private var selectedConversations = [CHConversation]()
    
    private var selectedConversationsView: ForwardScreenSelectedChatView = {
        let view = ForwardScreenSelectedChatView()
        view.backgroundColor = UIColor.white
        view.addTopBorder(with: CHUIConstants.appDefaultColor, andWidth: 2.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var locationSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.tintColor = .white
        searchBar.textField?.tintColor = .black
        searchBar.setTextFieldBackgroundColor(color: .white)
        return searchBar
    }()
    
    private var searchSegmentControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.layer.cornerRadius = 10
        control.layer.masksToBounds = true
        control.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *){
            control.backgroundColor = .clear
            control.setBackgroundImage(UIImage.imageWithColor(color: UIColor.white), for: .selected, barMetrics: .defaultPrompt)
            control.setTitleTextAttributes(
                [NSAttributedString.Key.foregroundColor: CHUIConstants.appDefaultColor,
                 NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)!], for: .selected)
            control.setTitleTextAttributes(
                [NSAttributedString.Key.foregroundColor: UIColor.white,
                 NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)!], for: .normal)
        } else {
            control.setBackgroundImage(UIImage.imageWithColor(color: .white), for: .selected, barMetrics: .default)
            control.setBackgroundImage(UIImage.imageWithColor(color: CHUIConstants.appDefaultColor), for: .normal, barMetrics: .default)
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: CHUIConstants.appDefaultColor,
                NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)!
                ], for: .selected)
            control.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)!]
                , for: .normal)
        }
        
        control.insertSegment(withTitle: "Contacts", at: 0, animated: false)
        control.insertSegment(withTitle: "Groups", at: 1, animated: false)
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        tableView.separatorStyle = .singleLine
        tableView.tag = 1001
        tableView.allowsMultipleSelection = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var forwardButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = CHUIConstants.appDefaultColor
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageEdgeInsets = UIEdgeInsets(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5)
        button.setImage(getImage("chMessageSendButton"), for: .normal)
        button.layer.masksToBounds = true
        return button
    }()
    
    private var selectedChatsViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = CHUIConstants.appDefaultColor
        self.navigationItem.titleView = self.locationSearchBar
        self.locationSearchBar.delegate = self
        self.view.addSubview(searchSegmentControl)
        self.view.addSubview(tableView)
        self.view.addSubview(selectedConversationsView)
        self.view.addSubview(forwardButton)
        self.tableView.tableFooterView = UIView()
        
        self.searchSegmentControl.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 30)
        self.searchSegmentControl.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: -30)
        self.searchSegmentControl.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 20)
        self.searchSegmentControl.setHeightAnchor(constant: 35)
        
        self.selectedConversationsView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.selectedConversationsView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.selectedConversationsView.setBottomAnchor(relatedConstraint: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        self.selectedChatsViewHeightConstraint = NSLayoutConstraint(item: self.selectedConversationsView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0)
        self.selectedChatsViewHeightConstraint.constant = 0
        self.view.addConstraint(self.selectedChatsViewHeightConstraint)
        self.selectedConversationsView.delegate = self
        
        self.forwardButton.setViewAsCircle(circleWidth: 50)
        self.forwardButton.setCenterYAnchor(relatedConstraint: self.selectedConversationsView.topAnchor, constant: 0)
        self.forwardButton.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: -15)
        self.forwardButton.isHidden = true
        
        self.forwardButton.addTarget(self, action: #selector(forwardButtonPressed(sender:)), for: .touchUpInside)
        
        self.tableView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.tableView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.tableView.setTopAnchor(relatedConstraint: self.searchSegmentControl.bottomAnchor, constant: 10)
        self.tableView.setBottomAnchor(relatedConstraint: self.selectedConversationsView.topAnchor, constant: 0)
        
        self.searchSegmentControl.addTarget(self, action: #selector(segmentControlIndexChanged(sender:)), for: .valueChanged)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(CreateGroupUserSelectCell.self, forCellReuseIdentifier: "userSelectCell")
        self.searchedUsers = self.allUsers
        self.searchedConversations = self.allConversations
        
        
        //self.locationSearchBar.frame.size.height = 70
        //self.tableView.tableHeaderView = self.locationSearchBar
        //self.searchSegmentControl.frame.size.height = 50
        //self.tableView.tableHeaderView = self.searchSegmentControl
        //self.navigationItem.titleView = self.locationSearchBar
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.layoutIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    var selectedUsersIndexPaths = [IndexPath]()
    var selectedConversationIndexPaths = [IndexPath]()
    
    @objc func segmentControlIndexChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            self.selectedUsersIndexPaths = self.tableView.indexPathsForSelectedRows ?? []
        } else {
            self.selectedConversationIndexPaths = self.tableView.indexPathsForSelectedRows ?? []
        }
        self.tableView.reloadData()
        if sender.selectedSegmentIndex == 1 {
            for row in self.selectedConversationIndexPaths {
                self.tableView.selectRow(at: row, animated: false, scrollPosition: .none)
            }
        } else {
            for row in self.selectedUsersIndexPaths {
                self.tableView.selectRow(at: row, animated: false, scrollPosition: .none)
            }
        }
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.searchSegmentControl.selectedSegmentIndex == 0 {
            if self.locationSearchBar.text == "" || self.locationSearchBar.text == nil {
                return searchedUsers.count + 1
            } else {
                return searchedUsers.count + 1
            }
        } else {
            if self.locationSearchBar.text == "" || self.locationSearchBar.text == nil {
                return self.searchedConversations.count
            } else {
                return self.searchedConversations.count + 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.searchSegmentControl.selectedSegmentIndex == 0 {
            if indexPath.row != self.searchedUsers.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "userSelectCell", for: indexPath) as! CreateGroupUserSelectCell
                cell.backgroundColor = .white
                let user = self.searchedUsers[indexPath.row]
                cell.userModel = user
                cell.activateSelectionMode()
                if self.selectedUsers.contains(where: {
                    $0.id == user.id
                }) == true {
                    cell.selectedCirlceImageView.isHidden = false
                    cell.unSelectedCircleImageView.isHidden = true
                } else {
                    cell.selectedCirlceImageView.isHidden = true
                    cell.unSelectedCircleImageView.isHidden = false
                }
                return cell
            } else {
                return UITableViewCell()
            }
        } else {
            if indexPath.row != self.searchedConversations.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "userSelectCell", for: indexPath) as! CreateGroupUserSelectCell
                cell.backgroundColor = .white
                let conversation = self.searchedConversations[indexPath.row]
                cell.assignExtraData(imageUrl: conversation.profileImageUrl, title: conversation.title)
                cell.activateSelectionMode()
                if self.selectedConversations.contains(where: {
                    $0.id == conversation.id
                }) == true {
                    cell.selectedCirlceImageView.isHidden = false
                    cell.unSelectedCircleImageView.isHidden = true
                } else {
                    cell.selectedCirlceImageView.isHidden = true
                    cell.unSelectedCircleImageView.isHidden = false
                }
                return cell
            } else {
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if let cell = tableView.cellForRow(at: indexPath) as? CreateGroupUserSelectCell{
            if self.searchSegmentControl.selectedSegmentIndex == 0 {
                if let cellUser = cell.userModel{
                    self.selectedUsers.append(cellUser)
                   let selectedModel = SelecteChatModel(id: cellUser.id ?? "", type: .user, title: cellUser.displayName ?? "", profileImageUrl: cellUser.profileImageUrl ?? "")
                    self.selectedConversationsView.addNewItemToCollectionView(item: selectedModel)
                }
                
            } else {
                let conversation = self.searchedConversations[indexPath.row]
                self.selectedConversations.append(conversation)
                let selectedModel = SelecteChatModel(id: conversation.id ?? "", type: .conversation, title: conversation.title ?? "", profileImageUrl: conversation.profileImageUrl ?? "")
                self.selectedConversationsView.addNewItemToCollectionView(item: selectedModel)
            }
            
            cell.isSelected = true
            cell.unSelectedCircleImageView.isHidden = true
            cell.selectedCirlceImageView.isHidden = false
            self.updateSelectedContainerView()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CreateGroupUserSelectCell{
            if self.searchSegmentControl.selectedSegmentIndex == 0 {
                if let cellUser = cell.userModel{
                    self.selectedUsers.removeAll(where: {
                        $0.id == cellUser.id
                    })
                    self.selectedConversationsView.removeItemFromCollectionView(
                    itemId: cellUser.id ?? "")
                }
            } else {
                let conversation = self.searchedConversations[indexPath.row]
                self.selectedConversations.removeAll(where: {
                    $0.id == conversation.id
                })
                self.selectedConversationsView.removeItemFromCollectionView(
                    itemId: conversation.id ?? "")
            }
            
            cell.isSelected = false
            cell.unSelectedCircleImageView.isHidden = false
            cell.selectedCirlceImageView.isHidden = true
            self.updateSelectedContainerView()
        }
    }
    
    func updateSelectedContainerView() {
        var showSelectedView = false
        if self.selectedConversations.count > 0 {
            showSelectedView = true
        }
        if self.selectedUsers.count > 0 {
            showSelectedView = true
        }
        var selectedModels = [SelecteChatModel]()
        self.selectedUsers.forEach({
            let model = $0
            let selectedModel = SelecteChatModel(id: model.id ?? "", type: .user, title: model.displayName ?? "", profileImageUrl: model.profileImageUrl ?? "")
            selectedModels.append(selectedModel)
        })
        self.selectedConversations.forEach({
            let model = $0
            let selectedModel = SelecteChatModel(id: model.id ?? "", type: .conversation, title: model.title ?? "", profileImageUrl: model.profileImageUrl ?? "")
            selectedModels.append(selectedModel)
        })
        selectedConversationsView.selectedChatModels = selectedModels
        UIView.animate(withDuration: 0.00, animations: {
            self.selectedChatsViewHeightConstraint.constant = showSelectedView ? 140 : 0
            self.view.layoutIfNeeded()
        }, completion: {(completed) in
            self.forwardButton.isHidden = !showSelectedView
            self.selectedConversationsView.collectionView.reloadData()
            self.selectedConversationsView.collectionView.scrollToLast(
                animated: false, position: .centeredHorizontally)
        })
    }
    
    func didPressRemovedButton(for model: SelecteChatModel?) {
        if model?.type == .user {
            self.selectedUsers.removeAll(where: {
                $0.id == model?.id
            })
            if let firstIndex = self.searchedUsers.firstIndex(where: {
                $0.id == model?.id
            }) {
                self.tableView.reloadRows(at: [IndexPath(row: firstIndex, section: 0)], with: .none)
            }
        } else {
            self.selectedConversations.removeAll(where: {
                $0.id == model?.id
            })
            if let firstIndex = self.searchedConversations.firstIndex(where: {
                $0.id == model?.id
            }) {
                self.tableView.reloadRows(at: [IndexPath(row: firstIndex, section: 0)], with: .none)
            }
        }
        self.updateSelectedContainerView()
    }
    
    // MARK:- SearchBar Delegates
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.locationSearchBar.setShowsCancelButton(true, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.tableView.reloadData()
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        self.locationSearchBar.setShowsCancelButton(false, animated: true)
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.searchedUsers = self.allUsers
        self.searchedConversations = self.allConversations
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.searchSegmentControl.selectedSegmentIndex == 0 {
            if searchBar.text == "" || searchBar.text == nil {
                self.cancelPreviousRequest()
                self.searchedUsers = self.allUsers
                self.tableView.reloadData()
            } else {
                self.cancelPreviousRequest()
                self.tableView.reloadData()
                self.getSearchResult(with: searchText, completion: {(users,error) in
                    self.searchedUsers = users ?? []
                    self.tableView.reloadData()
                })
            }
        } else {
            if searchBar.text == "" || searchBar.text == nil {
                self.cancelPreviousRequest()
                self.searchedConversations = self.allConversations
                self.tableView.reloadData()
            }
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
    
    @objc func forwardButtonPressed(sender: UIButton) {
        let messageIds = self.messageIds
        var conversationIds = [String]()
        self.selectedConversations.forEach({
            if let chatId = $0.id {
                conversationIds.append(chatId)
            }
        })
        
        var userIds = [String]()
        self.selectedUsers.forEach({
            if let userId = $0.id {
                userIds.append(userId)
            }
        })
        let superView = self.navigationController?.view
        showProgressView(superView: superView, string: nil)
        ChannelizeAPIService.forwardMessages(messageIds: messageIds, userIds: userIds, conversationIds: conversationIds, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: superView, withStatusString: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {[weak self] in
                    self?.navigationController?.popViewController(
                        animated: true)
                })
            } else {
                showProgressErrorView(superView: superView, errorString: errorString)
            }
        })
        
        
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

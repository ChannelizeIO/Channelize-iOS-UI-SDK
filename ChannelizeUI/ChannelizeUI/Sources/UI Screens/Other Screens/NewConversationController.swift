//
//  NewConversationController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/2/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire

class NewConversationController: UITableViewController, UISearchBarDelegate, CHAllContactsDelegates {

    var allUsers = [CHUser]()
    var searchedUsers = [CHUser]()
    private var isApiLoading = false
    
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.tintColor = .white
        searchBar.textField?.tintColor = .black
        searchBar.setTextFieldBackgroundColor(color: .white)
        return searchBar
    }()
    
    var screenIdentifier: UUID!
    init() {
        super.init(style: .plain)
        self.screenIdentifier = UUID()
        CHAllContacts.addContactsLoadDelegates(delegate: self, identifier: self.screenIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.navigationItem.titleView = self.searchBar
        self.tableView.tableFooterView = UIView()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        self.tableView.register(CreateGroupUserSelectCell.self, forCellReuseIdentifier: "userSelectCell")
        self.tableView.register(UITableViewLoadingCell.self, forCellReuseIdentifier: "loadingCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
         self.searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.searchBar.resignFirstResponder()
        if self.isMovingFromParent {
            CHAllContacts.removeContactsLoadDelegates(identifier: self.screenIdentifier)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Contact Events Functions
    func didLoadContacts(contacts: [CHUser]) {
        self.isApiLoading = false
        self.allUsers.append(contentsOf: contacts)
        self.tableView.reloadData()
    }
    
    func didUserAddedInContactList(user: CHUser) {
        
    }
    
    func didUserRemovedFromContactList(user: CHUser) {
        
    }
    
    func didUserStatusUpdated(updatedUser: CHUser) {
        
    }
    
    
    // MARK: - Search Bar Delegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.performSearchQuery(withText: searchText)
    }
    
    // MARK: - API Functions
    private func performSearchQuery(withText: String) {
        self.cancelPreviousRequest()
        self.searchedUsers.removeAll()
        self.isApiLoading = true
        self.tableView.reloadData()
        self.getFriendsList(searchQuery: withText)
    }
    
    private func getFriendsList(searchQuery: String) {
        var params = [String:Any]()
        params.updateValue(50, forKey: "limit")
        params.updateValue(0, forKey: "skip")
        params.updateValue(searchQuery, forKey: "search")
        params.updateValue(true, forKey: "includeBlocked")
        ChannelizeAPIService.getFriendsList(params: params, completion: {(users,errorString) in
            guard errorString == nil else {
                return
            }
            if let recievedUsers = users {
                self.searchedUsers = recievedUsers
                self.isApiLoading = false
                self.tableView.reloadData()
            }
        })
    }
    
    private func cancelPreviousRequest() {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach {
                print("Cancelling -> \($0.originalRequest?.url?.absoluteURL.path ?? "")")
                if ($0.originalRequest?.url?.absoluteURL.path == "/users/friends")
                {
                    $0.cancel()
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
        if self.searchBar.text == "" {
            return allUsers.count
        } else {
            return searchedUsers.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.searchBar.text == "" || self.searchBar.text == nil{
            let cell = tableView.dequeueReusableCell(withIdentifier: "userSelectCell", for: indexPath) as! CreateGroupUserSelectCell
            let userModel = self.allUsers[indexPath.row]
            cell.backgroundColor = .white
            cell.userModel = userModel
            cell.hideAllButtons()
            return cell
        } else {
            if indexPath.row != self.searchedUsers.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "userSelectCell", for: indexPath) as! CreateGroupUserSelectCell
                let userModel = self.searchedUsers[indexPath.row]
                cell.userModel = userModel
                cell.backgroundColor = .white
                cell.hideAllButtons()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! UITableViewLoadingCell
                cell.backgroundColor = .white
                if self.isApiLoading == true {
                    cell.showSpinnerView()
                } else {
                    if self.searchedUsers.count == 0 {
                        cell.showNoResultFound()
                    } else {
                        cell.showEndOfResult()
                    }
                }
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isApiLoading == false else {
            return
        }
        if self.searchBar.text == "" {
            let user = self.allUsers[indexPath.row]
            let controller = UIConversationViewController()
            controller.user = user
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(
                controller, animated: true)
        } else {
            let user = self.searchedUsers[indexPath.row]
            let controller = UIConversationViewController()
            controller.user = user
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(
                controller, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.searchBar.text == "" {
            if indexPath.row == self.allUsers.count - 3 && self.allUsers.count > 0 {
                if CHAllContacts.isAllContactsLoaded == false {
                    self.isApiLoading = true
                    CHAllContacts.getContacts()
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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


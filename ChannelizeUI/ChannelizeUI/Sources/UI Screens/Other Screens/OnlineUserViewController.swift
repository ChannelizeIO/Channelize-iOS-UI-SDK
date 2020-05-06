//
//  OnlineUserViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/30/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

class OnlineUserViewController: UITableViewController, CHAllContactsDelegates {

    var onlineContactsList = [CHUser]()
    var isShimmeringModeOn = true
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
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        #endif
        self.title = "Online Contacts"
        self.tableView.tableHeaderView = UIView()
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        self.tableView.register(UIContactsShimmeringCell.self, forCellReuseIdentifier: "contactShimmeringCell")
        self.tableView.register(UIContactTableCell.self, forCellReuseIdentifier: "contactsListCell")
        self.tableView.register(UITableViewLoadingCell.self, forCellReuseIdentifier: "contactLoadingCell")
        self.tableView.register(NoContactsTableCell.self, forCellReuseIdentifier: "noContactViewCell")
        self.getOnlineContacts()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - API Functions
    private func getOnlineContacts() {
        var params = [String:Any]()
        params.updateValue(50, forKey: "limit")
        params.updateValue(0, forKey: "skip")
        params.updateValue(false, forKey: "includeBlocked")
        params.updateValue(true, forKey: "online")
        ChannelizeAPIService.getFriendsList(params: params, completion: {(users,errorString) in
            self.isShimmeringModeOn = false
            guard errorString == nil else {
                print("Error in getting Online Users")
                print(errorString ?? "")
                return
            }
            if let recievedUsers = users {
                self.onlineContactsList = recievedUsers
                self.tableView.performBatchUpdates({
                    self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                }, completion: nil)
            }
        })
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
            if self.onlineContactsList.count == 0 {
                return 1
            } else {
                return self.onlineContactsList.count + 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isShimmeringModeOn == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactShimmeringCell", for: indexPath) as! UIContactsShimmeringCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            cell.startShimmering()
            return cell
        } else {
            if self.onlineContactsList.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noContactViewCell", for: indexPath)
                return cell
            } else {
                if indexPath.row != self.onlineContactsList.count {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "contactsListCell", for: indexPath) as! UIContactTableCell
                    cell.userModel = self.onlineContactsList[indexPath.row]
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "contactLoadingCell", for: indexPath) as! UITableViewLoadingCell
                    cell.showNoMoreResultLabel()
                    return cell
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isShimmeringModeOn == true {
            return 75
        } else {
            if self.onlineContactsList.count == 0 {
                return 230
            } else {
                return 75
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.isShimmeringModeOn == false else {
            return
        }
        guard indexPath.row != self.onlineContactsList.count else {
            return
        }
        let controller = UIConversationViewController()
        controller.user = self.onlineContactsList[indexPath.row]
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(
            controller, animated: true)
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
    
    // MARK: - Contacts Delegates
    func didLoadContacts(contacts: [CHUser]) {
        
    }
    
    func didUserAddedInContactList(user: CHUser) {
        if user.isOnline == true {
            if !self.onlineContactsList.contains(where: {
                $0.id == user.id
            }) {
                self.onlineContactsList.insert(user, at: 0)
                if self.onlineContactsList.count == 1 {
                    self.tableView.reloadData()
                } else {
                    self.tableView.performBatchUpdates({
                        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
                    }, completion: nil)
                }
            }
        }
    }
    
    func didUserRemovedFromContactList(user: CHUser) {
        if let firstIndex = self.onlineContactsList.firstIndex(where: {
            $0.id == user.id
        }) {
            self.onlineContactsList.remove(at: firstIndex)
            if self.onlineContactsList.count == 0 {
                self.tableView.reloadData()
            } else {
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: [IndexPath(row: firstIndex, section: 0)], with: .left)
                }, completion: nil)
            }
            
        }
    }
    
    func didUserStatusUpdated(updatedUser: CHUser) {
        guard updatedUser.id != ChannelizeAPI.getCurrentUserId() else {
            return
        }
        if updatedUser.isOnline == false {
            if let userIndex = self.onlineContactsList.firstIndex(where: {
                $0.id == updatedUser.id
            }) {
                self.onlineContactsList.remove(at: userIndex)
                self.tableView.performBatchUpdates({
                    self.tableView.reloadSections(
                        IndexSet(integer: 0), with: .none)
                }, completion: {(completed) in
                    print(completed)
                })
            }
        } else {
            ChannelizeAPIService.getRelationshipStatus(userId: updatedUser.id ?? "", completion: {(status,errorString) in
                guard errorString == nil else {
                    return
                }
                if let statusModel = status {
                    if statusModel.isFollowed == true {
                        // Check for Online
                        if updatedUser.isOnline == true {
                            if !self.onlineContactsList.contains(where: {
                                $0.id == updatedUser.id
                            }) {
                                self.onlineContactsList.insert(
                                    updatedUser, at: 0)
                                self.tableView.performBatchUpdates({
                                    self.tableView.reloadSections(
                                        IndexSet(integer: 0), with: .none)
                                }, completion: {(completed) in
                                    print(completed)
                                })
                            }
                        }
                    }
                }
            })
        }
    }

}

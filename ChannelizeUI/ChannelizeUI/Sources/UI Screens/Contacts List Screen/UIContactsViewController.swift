//
//  UIContactsViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/20/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire

class UIContactsViewController: CHTableViewController, CHAllContactsDelegates{
    
    var contactsList = [CHUser]()
    var onlineContactsList = [CHUser]()
    
    var isShimmeringModeOn = true
    //var currentSearchType: UISearchType = .contacts
    var screenIdentifier: UUID!
    init() {
        super.init(style: .grouped)
        self.screenIdentifier = UUID()
        CHAllContacts.addContactsLoadDelegates(delegate: self, identifier: self.screenIdentifier)
        CHAllContacts.getContacts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        self.tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        //self.configureSearchController()
        self.tableView.tableHeaderView = UIView()
        self.tableView.tableFooterView = UIView()
        self.tableView.contentInset.top = 0
        self.tableView.register(UIContactsShimmeringCell.self, forCellReuseIdentifier: "contactShimmeringCell")
        self.tableView.register(UIContactTableCell.self, forCellReuseIdentifier: "contactsListCell")
        self.tableView.register(UITableViewLoadingCell.self, forCellReuseIdentifier: "contactLoadingCell")
        self.tableView.register(NoContactsTableCell.self, forCellReuseIdentifier: "noContactViewCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "showOnlineContactCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isMovingToParent {
            self.getOnlineContacts()
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            if self.onlineContactsList.count <= 5 {
                return self.onlineContactsList.count
            } else {
                return 6
            }
        } else {
            if self.isShimmeringModeOn == true {
                return 10
            } else {
                if self.contactsList.count == 0 {
                    return 1
                } else {
                    return self.contactsList.count + 1
                }
            }
            
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 5 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "showOnlineContactCell", for: indexPath)
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.customSystemBlue
                cell.textLabel?.text = "Show All Active Contacts"
                cell.textLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 18.0)
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "contactsListCell", for: indexPath) as! UIContactTableCell
                cell.userModel = self.onlineContactsList[indexPath.row]
                return cell
            }
        } else {
            if self.isShimmeringModeOn == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "contactShimmeringCell", for: indexPath) as! UIContactsShimmeringCell
                cell.setUpViews()
                cell.setUpViewsFrames()
                cell.startShimmering()
                return cell
            } else {
                if self.contactsList.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "noContactViewCell", for: indexPath)
                    return cell
                } else {
                    if indexPath.row != self.contactsList.count {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsListCell", for: indexPath) as! UIContactTableCell
                        cell.userModel = self.contactsList[indexPath.row]
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "contactLoadingCell", for: indexPath) as! UITableViewLoadingCell
                        if CHAllContacts.isAllContactsLoaded == true {
                            cell.showNoMoreResultLabel()
                        } else {
                            cell.showSpinnerView()
                        }
                        return cell
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 5 {
                let controller = OnlineUserViewController()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(
                    controller, animated: true)
            } else {
                let controller = UIConversationViewController()
                controller.user = self.onlineContactsList[indexPath.row]
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(
                    controller, animated: true)
            }
        } else {
            if indexPath.row != self.contactsList.count {
                let controller = UIConversationViewController()
                controller.user = self.contactsList[indexPath.row]
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(
                    controller, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else {
            return
        }
        guard self.contactsList.count > 0 else {
            return
        }
        if indexPath.row == self.contactsList.count - 3 {
            CHAllContacts.getContacts()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 75
        } else {
            if self.isShimmeringModeOn == true {
                return 75
            } else {
                if self.contactsList.count == 0 {
                    return 230
                } else {
                    return 75
                }
            }
        }
        //return 75
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if self.onlineContactsList.count > 0 {
                return "Online Contacts"
            } else {
                return nil
            }
        } else {
            return CHLocalized(key: "pmAllMembers")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if self.onlineContactsList.count > 0 {
                return 15
            } else {
                return 0
            }
        } else {
            return 30
        }
    }
    
    // MARK:- API Functions
    private func getOnlineContacts() {
        var params = [String:Any]()
        params.updateValue(10, forKey: "limit")
        params.updateValue(0, forKey: "skip")
        params.updateValue(false, forKey: "includeBlocked")
        params.updateValue(true, forKey: "online")
        ChannelizeAPIService.getFriendsList(params: params, completion: {(users,errorString) in
            guard errorString == nil else {
                print("Error in getting Online Users")
                print(errorString ?? "")
                return
            }
            if let recievedUsers = users {
                self.onlineContactsList = recievedUsers
                self.tableView.performBatchUpdates({
                    self.tableView.reloadSections(IndexSet(integer: 0), with: .right)
                }, completion: nil)
            }
        })
    }
    
    // MARK: - Contacts Updates Delegate Function
    func didLoadContacts(contacts: [CHUser]) {
        self.isShimmeringModeOn = false
        self.contactsList.append(contentsOf: contacts)
        self.tableView.reloadData()
    }
    
    func didUserAddedInContactList(user: CHUser) {
        // Online List Update check
        if user.isOnline == true {
            if !self.onlineContactsList.contains(where: {
                $0.id == user.id
            }) {
                self.onlineContactsList.insert(user, at: 0)
                self.tableView.performBatchUpdates({
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
                }, completion: nil)
            }
        }
        
        // Update Contact List
        if !self.contactsList.contains(where: {
            $0.id == user.id
        }) {
            self.contactsList.insert(user, at: 0)
            if self.contactsList.count == 1 {
                self.tableView.reloadData()
            } else {
                self.tableView.performBatchUpdates({
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .left)
                }, completion: nil)
            }
        }
    }
    
    func didUserRemovedFromContactList(user: CHUser) {
        if let firstIndex = self.onlineContactsList.firstIndex(where: {
            $0.id == user.id
        }) {
            self.onlineContactsList.remove(at: firstIndex)
            self.tableView.performBatchUpdates({
                self.tableView.deleteRows(at: [IndexPath(row: firstIndex, section: 0)], with: .left)
            }, completion: nil)
        }
        
        // Remove from All Contacts List
        if let firstIndex = self.contactsList.firstIndex(where: {
            $0.id == user.id
        }) {
            self.contactsList.remove(at: firstIndex)
            if self.contactsList.count == 0 {
                self.tableView.reloadData()
            } else {
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: [IndexPath(row: firstIndex, section: 1)], with: .left)
                }, completion: nil)
            }
        }
    }
    
    func didUserStatusUpdated(updatedUser: CHUser) {
        guard updatedUser.id != Channelize.getCurrentUserId() else {
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
        // Update Status in Contact List
        if let userIndex = self.contactsList.firstIndex(where: {
            $0.id == updatedUser.id
        }) {
            let user = self.contactsList[userIndex]
            user.isOnline = updatedUser.isOnline
            self.tableView.performBatchUpdates({
                self.tableView.reloadRows(at: [IndexPath(row: userIndex, section: 1)], with: .none)
            }, completion: nil)
            
        }
    }
    
    // MARK:- IndexPath Calculator
    private func calculateIndexPathsToInsert(from newUsers: [CHUser]) -> [IndexPath] {
        let startIndex = self.contactsList.count > 0 ? self.contactsList.count - newUsers.count : 0
        let endIndex = startIndex + newUsers.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 1)}
    }
    
    private func reloadTable(withNewIndexPaths: [IndexPath]) {
        self.tableView.performBatchUpdates({
            self.tableView.insertRows(at: withNewIndexPaths, with: .none)
        }, completion: nil)
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


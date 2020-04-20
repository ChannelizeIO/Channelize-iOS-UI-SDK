//
//  BlockedUserViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/11/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

class BlockedUserViewController: UITableViewController {

    var blockedUser = [CHUser]()
    var screenIdentifier: UUID!
    var isApiLoadingInProgress = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Blocked Users"
        self.screenIdentifier = UUID()
        ChannelizeAPI.addUserEventDelegate(delegate: self, identifier: self.screenIdentifier)
        self.tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UIContactTableCell.self, forCellReuseIdentifier: "contactTableCell")
        self.tableView.register(NoContactsTableCell.self, forCellReuseIdentifier: "noBlockedContact")
        self.getBlockedUsers()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if self.isMovingFromParent {
            ChannelizeAPI.removeUserEventDelegate(identifier: self.screenIdentifier)
        }
    }
    
    // MARK:- API Functions
    private func getBlockedUsers() {
        var params = [String:Any]()
        params.updateValue(50, forKey: "limit")
        params.updateValue(0, forKey: "skip")
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.getBlockedUsers(params: params, completion: {(blockedUsers,errorString) in
            self.isApiLoadingInProgress = false
            guard errorString == nil else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
                return
            }
            if let blockedUsers = blockedUsers {
                blockedUsers.forEach({
                    self.blockedUser.append($0)
                })
            }
            disMissProgressView()
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.isApiLoadingInProgress == true {
            return 0
        } else {
            if self.blockedUser.count == 0 {
                return 1
            } else {
                return self.blockedUser.count
            }
        }
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isApiLoadingInProgress == true {
            return 0
        } else {
            if self.blockedUser.count == 0 {
                return UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height ?? 0)
            } else {
                return 75
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isApiLoadingInProgress == true {
            return UITableViewCell()
        } else {
            if self.blockedUser.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noBlockedContact", for: indexPath) as! NoContactsTableCell
                cell.assignCustomData(image: "noResultFound.png", message: "No blocked contacts.")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "contactTableCell", for: indexPath) as! UIContactTableCell
                cell.userModel = self.blockedUser[indexPath.row]
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.isApiLoadingInProgress == false else {
            return
        }
        guard self.blockedUser.count > 0 else {
            return
        }
        let user = self.blockedUser[indexPath.row]
        self.showUnBlockAlert(for: user)
    }

    private func showUnBlockAlert(for user: CHUser) {
        let actionAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let unblockAction = UIAlertAction(title: CHLocalized(key: "pmUnblock"), style: .default, handler: {(action) in
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            showProgressView(superView: self.tableView, string: nil)
            ChannelizeAPIService.unblockUser(userId: user.id ?? "", completion: {(status,errorString) in
                if status {
                    showProgressSuccessView(superView: self.tableView, withStatusString: nil)
                } else {
                    showProgressErrorView(superView: self.tableView, errorString: errorString)
                }
            })
            
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        actionAlert.addAction(unblockAction)
        actionAlert.addAction(cancelAction)
        self.present(actionAlert, animated: true, completion: nil)
    }
}

extension BlockedUserViewController: CHUserEventDelegates {
    func didUserBlocked(model: CHUserBlockModel?) {
        guard let blockerUserId = model?.blockerUser?.id else {
            return
        }
        
        guard blockerUserId == ChannelizeAPI.getCurrentUserId() else {
            return
        }
        guard let blockedUser = model?.blockedUser else {
            return
        }
        self.blockedUser.append(blockedUser)
        self.tableView.reloadData()
    }
    
    func didUserUnBlocked(model: CHUserUnblockModel?) {
        guard let unBlockerUserId = model?.unblockerUser?.id else {
            return
        }
       
        guard unBlockerUserId == ChannelizeAPI.getCurrentUserId() else {
            return
        }
        
        guard let unblockedUser = model?.unblockedUser else {
            return
        }
        
        if let index = self.blockedUser.firstIndex(where: {
            $0.id == unblockedUser.id
        }) {
            self.blockedUser.remove(at: index)
            if self.blockedUser.count == 0 {
                self.tableView.reloadData()
            } else {
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
}


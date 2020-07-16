//
//  CHBlockedViewController.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/6/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire

class CHBlockedViewController: NewCHTableViewController, CHUserEventDelegates {

    private var noBlockedContactsView: NoContactsView = {
        let view = NoContactsView()
        return view
    }()
    
    var blockedUsers = [CHUser]()
    var isLoadingBlockedUsers = false
    var apiCallLimit = 50
    var currentOffset = 0
    var isAllBlockedUsersLoaded = false
    
    private var screenIdentifier = UUID()
    
    init() {
        super.init(tableStyle: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Channelize.addUserEventDelegate(delegate: self, identifier: self.screenIdentifier)
        self.title = CHLocalized(key: "pmBlockedUsers")
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.plainTableBackGroundColor : CHLightThemeColors.plainTableBackGroundColor
        self.tableView.register(CHContactTableCell.self, forCellReuseIdentifier: "blockedContactCell")
        self.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor
        self.tableView.tableFooterView = UIView()
        self.tableView.delaysContentTouches = false
        self.tableView.allowsSelection = true
        self.getBlockedUsers()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            Channelize.removeUserEventDelegate(identifier: self.screenIdentifier)
        }
    }
    
    deinit {
        Channelize.removeUserEventDelegate(identifier: self.screenIdentifier)
    }
    
    // MARK: - API Functions
    private func getBlockedUsers() {
        let blockedUserQueryBuilder = CHUserQueryBuilder()
        blockedUserQueryBuilder.limit = self.apiCallLimit
        blockedUserQueryBuilder.skip = self.currentOffset
        self.isLoadingBlockedUsers = true
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.getBlockedUsers(queryBuilder: blockedUserQueryBuilder, completion: {(blockedUsers,errorString) in
            self.isLoadingBlockedUsers = false
            guard errorString == nil else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
                print("Failed to Get Blocked Users")
                print("Error: \(errorString ?? "")")
                return
            }
            
            if let recievedUsers = blockedUsers {
                self.blockedUsers.append(contentsOf: recievedUsers)
                if recievedUsers.count < self.apiCallLimit {
                    self.isAllBlockedUsersLoaded = true
                }
                self.currentOffset += recievedUsers.count
            }
            self.checkAndSetNoContentView()
            disMissProgressView()
        })
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.blockedUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockedContactCell", for: indexPath) as! CHContactTableCell
        cell.setUpViews()
        cell.setUpViewsFrames()
        cell.user = self.blockedUsers[indexPath.row]
        cell.assignData()
        cell.setUpUIProperties()
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.blockedUsers.count > 0, indexPath.row == self.blockedUsers.count - 3 else {
            return
        }
        if self.isLoadingBlockedUsers == false {
            if self.isAllBlockedUsersLoaded == false {
                self.isLoadingBlockedUsers = true
                self.getBlockedUsers()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let user = self.blockedUsers[indexPath.row]
        self.showUnBlockAlert(for: user)
    }
    
    // MARK: - Other UI Functions
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.tableView.reloadData()
    }
    
    private func showUnBlockAlert(for user: CHUser) {
        let unBlockAction = CHActionSheetAction(title: CHLocalized(key: "pmUnblock"), image: nil, actionType: .default, handler: {(action) in
            showProgressView(superView: self.navigationController?.view, string: nil)
            ChannelizeAPIService.unblockUser(userId: user.id ?? "", completion: {(status,errorString) in
                if status {
                    showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
                    self.blockedUsers.removeAll(where: {
                        $0.id == user.id
                    })
                    self.checkAndSetNoContentView()
                } else {
                    showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
                }
            })
        })
        let controller = CHActionSheetController()
        controller.actions = [unBlockAction]
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Other Functions
    private func checkAndSetNoContentView() {
        if self.blockedUsers.count == 0 {
            self.view.addSubview(self.noBlockedContactsView)
            self.noBlockedContactsView.frame.origin = .zero
            self.noBlockedContactsView.frame.size = self.view.frame.size
            self.noBlockedContactsView.assignCustomData(image: "noResultFound.png", message: "No blocked contacts.")
        } else {
            self.noBlockedContactsView.removeFromSuperview()
        }
        self.tableView.reloadData()
    }
    
    
    // MARK: - MQTT Events Delegates
    func didUserBlocked(model: CHUserBlockModel?) {
        guard let blockerUserId = model?.blockerUser?.id else {
            return
        }
        guard blockerUserId == Channelize.getCurrentUserId() else {
            return
        }
        guard let blockedUser = model?.blockedUser else {
            return
        }
        self.blockedUsers.append(blockedUser)
        self.blockedUsers.sort(by: { $0.displayName?.capitalized ?? "" < $1.displayName?.capitalized ?? ""})
        self.checkAndSetNoContentView()
    }
    
    func didUserUnBlocked(model: CHUserUnblockModel?) {
        guard let unBlockerUserId = model?.unblockerUser?.id else {
            return
        }
        guard unBlockerUserId == Channelize.getCurrentUserId() else {
            return
        }
        guard let unblockedUser = model?.unblockedUser else {
            return
        }
        self.blockedUsers.removeAll(where: {
            $0.id == unblockedUser.id
        })
        self.checkAndSetNoContentView()
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




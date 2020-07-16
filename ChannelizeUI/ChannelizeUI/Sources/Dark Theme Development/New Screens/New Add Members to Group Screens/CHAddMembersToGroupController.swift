//
//  CHSelectMembersForGroup.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/3/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage
import Alamofire
import InputBarAccessoryView

class CHAddMembersToGroupController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var allContacts = [CHUser]()
    var searchedUsers = [CHUser]()
    
    private var selectedUsers = [CHUser]()
    
    var skipUserIds = [String]()
    
    var isLoadingContacts = false
    var isAllContactsLoaded = false
    var isAllSearchedResultsLoaded = false
    var currentOffset = 0
    var apiCallLimit = 50
    var isSearchingContacts = false
    
    var searchTask: DispatchWorkItem?
    var selectedViewHeightConstraint: NSLayoutConstraint!
    var keyBoardManager: KeyboardManager?
    
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
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
        //searchBar.addBottomBorder(with: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor, andWidth: 1.0)
        return searchBar
    }()
    
    var seletedUsersView: CHSelectedUsersView = {
        let view = CHSelectedUsersView()
        return view
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var onDoneButtonPressed: ((_ selectedUsers: [CHUser]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.title = "Select Members"
        self.view.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor(hex: "#f2f2f8")
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(sender:)))
        self.navigationItem.rightBarButtonItem = doneButton
        
        
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.plainTableBackGroundColor : CHLightThemeColors.instance.plainTableBackGroundColor
        self.tableView.indicatorStyle = CHAppConstant.themeStyle == .dark ? .white : .black
        self.tableView.register(CHTableViewLoadingCell.self, forCellReuseIdentifier: "loadingCell")
        self.tableView.register(CHContactSelectTableCell.self, forCellReuseIdentifier: "userSelectCell")
        self.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor
        self.tableView.allowsMultipleSelection = true
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.seletedUsersView)
        self.view.addSubview(self.tableView)
        
        self.searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.searchBar.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.searchBar.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.searchBar.setHeightAnchor(constant: 50)
        self.searchBar.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
        
        self.seletedUsersView.translatesAutoresizingMaskIntoConstraints = false
        self.seletedUsersView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.seletedUsersView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.seletedUsersView.setTopAnchor(relatedConstraint: searchBar.bottomAnchor, constant: 0)
        self.selectedViewHeightConstraint = NSLayoutConstraint(item: self.seletedUsersView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0)
        self.selectedViewHeightConstraint.isActive = true
        self.view.addConstraint(self.selectedViewHeightConstraint)
        
        self.seletedUsersView.userRemoved = {user in
            self.selectedUsers.removeAll(where: {
                $0.id == user?.id
            })
            if let firstIndex = self.searchedUsers.firstIndex(where: {
                $0.id == user?.id
            }) {
                self.tableView.reloadRows(at: [IndexPath(row: firstIndex, section: 0)], with: .none)
            }
            if let unWrappedUser = user {
                self.updateSelectedContainerView(with: unWrappedUser)
            }
        }
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.tableView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.tableView.setTopAnchor(relatedConstraint: self.seletedUsersView.bottomAnchor, constant: 0)
        self.tableView.setBottomAnchor(relatedConstraint: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        
        self.searchBar.delegate = self
        
        self.keyBoardManager = KeyboardManager()
        self.keyBoardManager?.on(event: .willHide, do: {notification in
           // self.searchBar.resignFirstResponder()
            self.searchBar.setShowsCancelButton(false, animated: true)
            self.tableView.contentInset.bottom = 0
        }).on(event: .willShow, do: { notification in
            self.tableView.contentInset.bottom = notification.endFrame.height
        })
        
        self.getContactsList()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc private func doneButtonPressed(sender: UIBarButtonItem) {
        self.onDoneButtonPressed?(self.selectedUsers)
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - API Functions
    private func getContactsList() {
        let queryBuilder = CHFriendQueryBuilder()
        queryBuilder.limit = self.apiCallLimit
        queryBuilder.skip = self.currentOffset
        queryBuilder.includeBlocked = false
        queryBuilder.skipUserIds = self.skipUserIds
        ChannelizeAPIService.getFriendsList(queryBuilder: queryBuilder, completion: {(users,errorString) in
            self.isLoadingContacts = false
            guard errorString == nil else {
                return
            }
            if let recievedUsers = users {
                self.allContacts.append(contentsOf: recievedUsers)
                if recievedUsers.count < self.apiCallLimit {
                    self.isAllContactsLoaded = true
                }
                self.currentOffset += recievedUsers.count
            }
            self.searchedUsers = self.allContacts
            let selectedIndexPaths = self.tableView.indexPathsForSelectedRows ?? []
            self.tableView.reloadData()
            selectedIndexPaths.forEach({
                self.tableView.selectRow(at: $0, animated: false, scrollPosition: .none)
            })
            //self.tableView.reloadData()
        })
    }
    
    private func performUserSearch(searchQuery: String) {
        let onlineContactsQueryBuilder = CHFriendQueryBuilder()
        onlineContactsQueryBuilder.limit = self.apiCallLimit
        onlineContactsQueryBuilder.skip = 0
        onlineContactsQueryBuilder.includeBlocked = false
        onlineContactsQueryBuilder.searchQuery = searchQuery
        onlineContactsQueryBuilder.skipUserIds = self.skipUserIds
        ChannelizeAPIService.getFriendsList(queryBuilder: onlineContactsQueryBuilder, completion: {(users,errorString) in
            guard errorString == nil else {
                return
            }
            if let recievedUsers = users {
                if recievedUsers.count < self.apiCallLimit {
                    self.isAllSearchedResultsLoaded = true
                }
                self.isSearchingContacts = false
                self.searchedUsers.removeAll()
                self.searchedUsers = recievedUsers
                ChUserCache.instance.appendUsers(newUsers: recievedUsers)
            }
            self.tableView.reloadData()
            self.updateSelectedCells()
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
        return self.searchedUsers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.searchedUsers.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! CHTableViewLoadingCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            if self.isSearchingContacts {
                cell.showIndicatorView()
            } else {
                if self.searchBar.text != "" {
                    if self.isAllSearchedResultsLoaded {
                        if self.searchedUsers.count == 0 {
                            cell.showInfoLabel(withText: "No Result Found")
                        } else {
                            cell.hideIndicatorView()
                        }
                    }
                } else {
                    if self.isAllContactsLoaded {
                        if self.searchedUsers.count == 0 {
                            cell.showInfoLabel(withText: "No More Contacts to Add")
                        } else {
                            cell.hideIndicatorView()
                        }
                    }
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userSelectCell", for: indexPath) as! CHContactSelectTableCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            let userModel = self.searchedUsers[indexPath.row]
            cell.user = userModel
            cell.assignData()
            cell.setUpUIProperties()
            
            if self.selectedUsers.contains(where: {
                $0.id == userModel.id
            }) == true {
                cell.setCellSelected()
            } else {
                cell.setCellUnselected()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.allContacts.count > 0, indexPath.row == self.allContacts.count - 3 else {
            return
        }
        if self.isAllContactsLoaded == false {
            if self.isLoadingContacts == false {
                self.isLoadingContacts = true
                self.getContactsList()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if let cell = tableView.cellForRow(at: indexPath) as? CHContactSelectTableCell{
            if let cellUser = cell.user{
                self.selectedUsers.append(cellUser)
                self.updateSelectedContainerView(with: cellUser)
            }
            cell.isSelected = true
            cell.setCellSelected()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CHContactSelectTableCell{
            
            if let cellUser = cell.user{
                self.selectedUsers.removeAll(where: {
                    $0.id == cellUser.id
                })
                self.updateSelectedContainerView(with: cellUser)
            }
            cell.isSelected = false
            cell.setCellUnselected()
        }
    }
    
    // MARK: - UISearch Bar Delegates
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar.showsCancelButton {
            return false
        } else {
            return true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(false, animated: true)
        self.view.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //var searchTask: DispatchWorkItem?
        if searchText == "" {
            self.searchTask?.cancel()
            self.cancelPreviousRequest()
            self.isSearchingContacts = false
            self.searchedUsers = self.allContacts
            self.tableView.reloadData()
            self.updateSelectedCells()
        } else {
            self.searchTask?.cancel()
            let task = DispatchWorkItem { [weak self] in
                self?.cancelPreviousRequest()
                self?.isSearchingContacts = true
                self?.isAllSearchedResultsLoaded = false
                self?.searchedUsers.removeAll()
                self?.tableView.reloadData()
                self?.performUserSearch(searchQuery: searchText)
            }
            self.searchTask = task
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: task)
        }
    }
    
    func updateSelectedContainerView(with user: CHUser) {
        
        UIView.animate(withDuration: 0.33, delay: 0.0, options: [.transitionCrossDissolve,.layoutSubviews], animations: {
            self.selectedViewHeightConstraint.constant = self.selectedUsers.count > 0 ? 120 : 0
            self.view.layoutIfNeeded()
        }, completion: {(completed) in
            
            if self.selectedUsers.contains(where: {
                $0.id == user.id
            }) {
                self.seletedUsersView.addNewItemToCollectionView(item: user)
            } else {
                self.seletedUsersView.removeItemFromCollectionView(itemId: user.id ?? "")
            }
            self.seletedUsersView.collectionView.reloadData()
            self.seletedUsersView.collectionView.scrollToLast(animated: true, position: .centeredHorizontally)
        })
    }
    
    func updateSelectedCells() {
        self.selectedUsers.forEach({
            let user = $0
            if let indexPath = self.searchedUsers.firstIndex(where: {
                $0.id == user.id
            }) {
                self.tableView.selectRow(at: IndexPath(row: indexPath, section: 0), animated: false, scrollPosition: .none)
            }
        })
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




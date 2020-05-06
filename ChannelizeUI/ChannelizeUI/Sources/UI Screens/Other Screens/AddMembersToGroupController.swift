//
//  AddMembersToGroupController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/3/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire

class AddMembersToGroupViewController: ChannelizeController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, AddMembersSelectedViewDelegates {
    
    var allUsers = [CHUser]()
    var searchedUsers = [CHUser]()
    var currentMembers = [CHMember]()
    var selectedUsers = [CHUser]()
    
    private var isInitialLoading = true
    private var isAllUsersLoaded = false
    private var currentOffSet = 0
    private var isApiLoading = false
    
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.tintColor = .white
        searchBar.textField?.tintColor = .black
        searchBar.setTextFieldBackgroundColor(color: .white)
        return searchBar
    }()
    
    var selectedUsersView: AddMembersSelectedView = {
        let view = AddMembersSelectedView()
        view.backgroundColor = UIColor.customSystemTeal
        view.addBottomBorder(with: CHUIConstants.appDefaultColor, andWidth: 1.0)
        return view
    }()
    
    var delegate: AddMembersToGroupControllerDelegate?
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        //tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.allowsMultipleSelection = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.edgesForExtendedLayout = []
        self.searchBar.delegate = self
        let cancelButton = UIBarButtonItem(title: CHLocalized(key: "pmCancel"), style: .plain, target: self, action: #selector(didPressCanceButton(sender:)))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didPressDoneButton(sender:)))
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        self.tableView.tableHeaderView = UIView()
        self.tableView.tableFooterView = UIView()
        self.tableView.keyboardDismissMode = .onDrag
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.titleView = self.searchBar
        self.tableView.allowsMultipleSelection = true
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.tableView.register(CreateGroupUserSelectCell.self, forCellReuseIdentifier: "userSelectCell")
        self.tableView.register(UITableViewLoadingCell.self, forCellReuseIdentifier: "loadingCell")
        self.tableView.contentInset.bottom = 70
        
        self.view.addSubview(self.selectedUsersView)
        self.view.addSubview(self.tableView)
        
        self.selectedUsersView.frame.origin = .zero
        self.selectedUsersView.frame.size.width = self.view.frame.width
        self.selectedUsersView.frame.size.height = 0
        
        self.tableView.frame.origin.x = 0
        self.tableView.frame.origin.y = getViewOriginYEnd(view: self.selectedUsersView)
        self.tableView.frame.size.width = self.view.frame.width
        self.tableView.frame.size.height = self.view.frame.height - self.tableView.frame.origin.y
        
        self.selectedUsersView.delegate = self
        
        self.getNonGroupMembersUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchBar.becomeFirstResponder()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func didPressCanceButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func didPressDoneButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        if self.selectedUsers.count > 0 {
            self.delegate?.didSelectMembersToAdd(users: self.selectedUsers)
        }
        
    }
    
    // MARK: - Search Bar Delegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.cancelPreviousRequest()
            self.searchedUsers.removeAll()
            self.searchedUsers = self.allUsers
            self.isApiLoading = false
            self.tableView.reloadData()
            self.updateSelectedCells()
        } else {
            self.performSearchQuery(withText: searchText)
        }
    }
    
    // MARK: - API Functions
    private func getNonGroupMembersUsers() {
        var params = [String:Any]()
        params.updateValue(50, forKey: "limit")
        params.updateValue(self.currentOffSet, forKey: "skip")
        var loadedUserIds = [String]()
        self.currentMembers.forEach({
            loadedUserIds.append($0.user?.id ?? "")
        })
        params.updateValue(loadedUserIds.joined(separator: ","), forKey: "skipUserIds")
        ChannelizeAPIService.getFriendsList(params: params, completion: {(users,errorString) in
            guard errorString == nil else {
                return
            }
            if self.currentOffSet == 0 {
                self.isInitialLoading = false
            }
            if let recievedUsers = users {
                if recievedUsers.count < 50 {
                    self.isAllUsersLoaded = true
                }
                self.currentOffSet += recievedUsers.count
                recievedUsers.forEach({
                    self.allUsers.append($0)
                })
                self.searchedUsers = self.allUsers
                self.isApiLoading = false
                self.tableView.reloadData()
                self.updateSelectedCells()
            }
        })
        
    }
    
    private func performSearchQuery(withText: String) {
        self.cancelPreviousRequest()
        self.searchedUsers.removeAll()
        self.isApiLoading = true
        self.tableView.reloadData()
        self.updateSelectedCells()
        self.getFriendsList(searchQuery: withText)
    }
    
    private func getFriendsList(searchQuery: String) {
        var params = [String:Any]()
        params.updateValue(50, forKey: "limit")
        params.updateValue(0, forKey: "skip")
        params.updateValue(searchQuery, forKey: "search")
        var loadedUserIds = [String]()
        self.currentMembers.forEach({
            loadedUserIds.append($0.user?.id ?? "")
        })
        params.updateValue(loadedUserIds.joined(separator: ","), forKey: "skipUserIds")
        
        ChannelizeAPIService.getFriendsList(params: params, completion: {(users,errorString) in
            guard errorString == nil else {
                return
            }
            if let recievedUsers = users {
                self.searchedUsers = recievedUsers
                self.isApiLoading = false
                self.tableView.reloadData()
                self.updateSelectedCells()
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
    
    func didPressRemovedButton(for user: CHUser?) {
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
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.isInitialLoading {
            return 1
        } else {
            return searchedUsers.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isInitialLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! UITableViewLoadingCell
            cell.backgroundColor = UIColor.white
            cell.showSpinnerView()
            return cell
        } else {
            if indexPath.row != self.searchedUsers.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "userSelectCell", for: indexPath) as! CreateGroupUserSelectCell
                let userModel = self.searchedUsers[indexPath.row]
                cell.userModel = userModel
                cell.backgroundColor = UIColor.white
                cell.activateSelectionMode()
                if self.selectedUsers.contains(where: {
                    $0.id == userModel.id
                }) == true {
                    cell.isSelected = true
                    cell.selectedCirlceImageView.isHidden = false
                    cell.unSelectedCircleImageView.isHidden = true
                } else {
                    cell.isSelected = false
                    cell.selectedCirlceImageView.isHidden = true
                    cell.unSelectedCircleImageView.isHidden = false
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! UITableViewLoadingCell
                cell.backgroundColor = UIColor.white
                if self.isApiLoading == true {
                    cell.showSpinnerView()
                } else {
                    if self.isAllUsersLoaded {
                        cell.showNoResultFound(string: "No more contacts to add.")
                    } else {
                        cell.showNoResultFound(string: "No result found.")
                    }
                    
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getDeviceWiseAspectedHeight(constant: 85)
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CreateGroupUserSelectCell{
            
            if let cellUser = cell.userModel{
                self.selectedUsers.removeAll(where: {
                    $0.id == cellUser.id
                })
                self.updateSelectedContainerView(with: cellUser)
            }
            cell.isSelected = false
            cell.unSelectedCircleImageView.isHidden = false
            cell.selectedCirlceImageView.isHidden = true
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CreateGroupUserSelectCell{
            if let cellUser = cell.userModel{
                self.selectedUsers.append(cellUser)
                self.updateSelectedContainerView(with: cellUser)
            }
            cell.isSelected = true
            cell.unSelectedCircleImageView.isHidden = true
            cell.selectedCirlceImageView.isHidden = false
            
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.isApiLoading == false else {
            return
        }
        guard self.isInitialLoading == false else {
            return
        }
        guard self.searchedUsers.count > 0 else {
            return
        }
        
        if indexPath.row == self.searchedUsers.count - 1 && self.searchedUsers.count > 0 {
            
            let user = self.searchedUsers[indexPath.row]
            if self.selectedUsers.contains(where: {
                $0.id == user.id
            }) {
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
            
            if self.isAllUsersLoaded == false {
                if self.isApiLoading == false {
                    self.isApiLoading = true
                    var loadedUserIds = [String]()
                    self.currentMembers.forEach({
                        loadedUserIds.append($0.user?.id ?? "")
                    })
                    self.getNonGroupMembersUsers()
                }
            }
        }
    }
    
    func updateSelectedContainerView(with user: CHUser) {
        
        UIView.animate(withDuration: 0.33, delay: 0.0, options: [.transitionCrossDissolve,.layoutSubviews], animations: {
            self.selectedUsersView.frame.size.height = self.selectedUsers.count > 0 ? 120 : 0
            self.tableView.frame.origin.y = getViewOriginYEnd(view: self.selectedUsersView)
        }, completion: {(completed) in
            
            if self.selectedUsers.contains(where: {
                $0.id == user.id
            }) {
                self.selectedUsersView.addNewItemToCollectionView(
                    item: user)
            } else {
                self.selectedUsersView.removeItemFromCollectionView(
                    itemId: user.id ?? "")
            }
            
            //self.selectedUsersView.collectionView.reloadData()
            self.selectedUsersView.collectionView.scrollToLast(
                animated: true, position: .centeredHorizontally)
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
    
    // MARK: - UITableView Delegates
    
}



protocol AddMembersToGroupControllerDelegate {
    func didSelectMembersToAdd(users: [CHUser])
}

class AddMembersToGroupController: UITableViewController, UISearchBarDelegate {

    var allUsers = [CHUser]()
    var searchedUsers = [CHUser]()
    var currentMembers = [CHMember]()
    var selectedUsers = [CHUser]()
    private var isInitialLoading = true
    private var isAllUsersLoaded = false
    private var currentOffSet = 0
    private var isApiLoading = false
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.tintColor = .white
        searchBar.textField?.tintColor = .black
        searchBar.setTextFieldBackgroundColor(color: .white)
        return searchBar
    }()
    
    var delegate: AddMembersToGroupControllerDelegate?
    var selectedUsersView: AddMembersSelectedView = {
        let view = AddMembersSelectedView()
        return view
    }()
    
    init() {
        super.init(style: .plain)
        //self.getNonGroupMembersUsers()
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
        self.searchBar.delegate = self
        let cancelButton = UIBarButtonItem(title: CHLocalized(key: "pmCancel"), style: .plain, target: self, action: #selector(didPressCanceButton(sender:)))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didPressDoneButton(sender:)))
        self.tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        self.tableView.tableHeaderView = UIView()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.titleView = self.searchBar
        self.tableView.allowsMultipleSelection = true
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.tableView.register(CreateGroupUserSelectCell.self, forCellReuseIdentifier: "userSelectCell")
        self.tableView.register(UITableViewLoadingCell.self, forCellReuseIdentifier: "loadingCell")
        self.tableView.contentInset.bottom = 70
        
        self.getNonGroupMembersUsers()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func didPressCanceButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func didPressDoneButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        if self.selectedUsers.count > 0 {
            self.delegate?.didSelectMembersToAdd(users: self.selectedUsers)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Search Bar Delegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.cancelPreviousRequest()
            self.searchedUsers.removeAll()
            self.searchedUsers = self.allUsers
            self.isApiLoading = false
            self.tableView.reloadData()
            self.updateSelectedCells()
        } else {
            self.performSearchQuery(withText: searchText)
        }
    }
    
    // MARK: - API Functions
    private func getNonGroupMembersUsers() {
        var params = [String:Any]()
        params.updateValue(50, forKey: "limit")
        params.updateValue(self.currentOffSet, forKey: "skip")
        var loadedUserIds = [String]()
        self.currentMembers.forEach({
            loadedUserIds.append($0.user?.id ?? "")
        })
        params.updateValue(loadedUserIds.joined(separator: ","), forKey: "skipUserIds")
        ChannelizeAPIService.getFriendsList(params: params, completion: {(users,errorString) in
            guard errorString == nil else {
                return
            }
            if self.currentOffSet == 0 {
                self.isInitialLoading = false
            }
            if let recievedUsers = users {
                if recievedUsers.count < 50 {
                    self.isAllUsersLoaded = true
                }
                self.currentOffSet += recievedUsers.count
                recievedUsers.forEach({
                    self.allUsers.append($0)
                })
                self.isApiLoading = false
                self.tableView.reloadData()
                self.updateSelectedCells()
            }
        })
        
    }
    
    private func performSearchQuery(withText: String) {
        self.cancelPreviousRequest()
        self.searchedUsers.removeAll()
        self.isApiLoading = true
        self.tableView.reloadData()
        self.updateSelectedCells()
        self.getFriendsList(searchQuery: withText)
    }
    
    private func getFriendsList(searchQuery: String) {
        var params = [String:Any]()
        params.updateValue(50, forKey: "limit")
        params.updateValue(0, forKey: "skip")
        params.updateValue(searchQuery, forKey: "search")
        var loadedUserIds = [String]()
        self.currentMembers.forEach({
            loadedUserIds.append($0.user?.id ?? "")
        })
        params.updateValue(loadedUserIds.joined(separator: ","), forKey: "skipUserIds")
        
        ChannelizeAPIService.getFriendsList(params: params, completion: {(users,errorString) in
            guard errorString == nil else {
                return
            }
            if let recievedUsers = users {
                self.searchedUsers = recievedUsers
                self.isApiLoading = false
                self.tableView.reloadData()
                self.updateSelectedCells()
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
        if self.isInitialLoading {
            return 1
        } else {
            if self.searchBar.text == "" || self.searchBar.text == nil {
                return allUsers.count
            } else {
                return searchedUsers.count + 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isInitialLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! UITableViewLoadingCell
            cell.backgroundColor = UIColor.white
            cell.showSpinnerView()
            return cell
        } else {
            if self.searchBar.text == "" || self.searchBar.text == nil{
                let cell = tableView.dequeueReusableCell(withIdentifier: "userSelectCell", for: indexPath) as! CreateGroupUserSelectCell
                let userModel = self.allUsers[indexPath.row]
                cell.backgroundColor = UIColor.white
                cell.userModel = userModel
                cell.activateSelectionMode()
                if self.selectedUsers.contains(where: {
                    $0.id == userModel.id
                }) == true {
                    cell.isSelected = true
                    cell.selectedCirlceImageView.isHidden = false
                    cell.unSelectedCircleImageView.isHidden = true
                } else {
                    cell.isSelected = false
                    cell.selectedCirlceImageView.isHidden = true
                    cell.unSelectedCircleImageView.isHidden = false
                }
                
                return cell
            } else {
                if indexPath.row != self.searchedUsers.count {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "userSelectCell", for: indexPath) as! CreateGroupUserSelectCell
                    let userModel = self.searchedUsers[indexPath.row]
                    cell.userModel = userModel
                    cell.backgroundColor = UIColor.white
                    cell.activateSelectionMode()
                    if self.selectedUsers.contains(where: {
                        $0.id == userModel.id
                    }) == true {
                        cell.isSelected = true
                        cell.selectedCirlceImageView.isHidden = false
                        cell.unSelectedCircleImageView.isHidden = true
                    } else {
                        cell.isSelected = false
                        cell.selectedCirlceImageView.isHidden = true
                        cell.unSelectedCircleImageView.isHidden = false
                    }
                    
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! UITableViewLoadingCell
                    cell.backgroundColor = UIColor.white
                    if self.isApiLoading == true {
                        cell.showSpinnerView()
                    } else {
                        cell.showNoMoreResultLabel()
                    }
                    return cell
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getDeviceWiseAspectedHeight(constant: 85)
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CreateGroupUserSelectCell{
            
            if let cellUser = cell.userModel{
                self.selectedUsers.removeAll(where: {
                    $0.id == cellUser.id
                })
            }
            cell.isSelected = false
            cell.unSelectedCircleImageView.isHidden = false
            cell.selectedCirlceImageView.isHidden = true
            self.updateSelectedContainerView()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CreateGroupUserSelectCell{
            if let cellUser = cell.userModel{
                self.selectedUsers.append(cellUser)
            }
            cell.isSelected = true
            cell.unSelectedCircleImageView.isHidden = true
            cell.selectedCirlceImageView.isHidden = false
            self.updateSelectedContainerView()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.isApiLoading == false else {
            return
        }
        guard self.isInitialLoading == false else {
            return
        }
        guard self.searchedUsers.count > 0 else {
            return
        }
        let user = self.searchedUsers[indexPath.row]
        if self.selectedUsers.contains(where: {
            $0.id == user.id
        }) {
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        if indexPath.row == self.allUsers.count - 1 && self.allUsers.count > 0 {
            
            if self.isAllUsersLoaded == false {
                if self.isApiLoading == false {
                    self.isApiLoading = true
                    var loadedUserIds = [String]()
//                    self.allUsers.forEach({
//                        loadedUserIds.append($0.id ?? "")
//                    })
                    self.currentMembers.forEach({
                        loadedUserIds.append($0.user?.id ?? "")
                    })
                    self.getNonGroupMembersUsers()
                }
            }
//            if CHAllContacts.isAllContactsLoaded == false {
//                if self.isApiLoading == false {
//                self.isApiLoading = true
//                var loadedUserIds = [String]()
//                self.allUsers.forEach({
//                    loadedUserIds.append($0.id ?? "")
//                })
//                    self.currentMembers.forEach({
//                        loadedUserIds.append($0.user?.id ?? "")
//                    })
//
//                CHAllContacts.getFriendsBySkippingIds(ids: loadedUserIds, completion: {(users,error) in
//                    if let recievedUsers = users {
//                        self.allUsers.append(contentsOf: recievedUsers)
//                    }
//                    self.isApiLoading = false
//                    self.tableView.reloadData()
//                })
//            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.selectedUsersView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.selectedUsers.count == 0 ? 0 : 120
    }
    
    func updateSelectedContainerView() {
        var showSelectedView = false
        if self.selectedUsers.count > 0 {
            showSelectedView = true
        }
        self.selectedUsersView.selectedUsers = self.selectedUsers
        if self.selectedUsers.count == 1 {
            
        }
        UIView.animate(withDuration: 0.00, animations: {
            let selectedIndexPaths = self.tableView.indexPathsForSelectedRows ?? []
            self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            selectedIndexPaths.forEach({
                self.tableView.selectRow(at: $0, animated: false, scrollPosition: .none)
            })
        }, completion: {(completed) in
            self.selectedUsersView.collectionView.reloadData()
            self.selectedUsersView.collectionView.scrollToLast(animated: false, position: .centeredHorizontally)
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
    
}


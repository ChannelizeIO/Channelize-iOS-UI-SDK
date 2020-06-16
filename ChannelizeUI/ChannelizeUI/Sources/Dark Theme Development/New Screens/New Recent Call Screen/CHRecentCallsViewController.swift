//
//  CHRecentCallsViewController.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

class CHRecentCallsViewController: NewCHTableViewController {

    var recentCalls = [CHRecentCall]()
    var isShimmeringModeOn = true
    
    var headerView: CHNavHeaderView = {
        let headerView = CHNavHeaderView()
        return headerView
    }()
    
    var noConversationView: NoRecentConversationView = {
        let view = NoRecentConversationView()
        return view
    }()
    
    init() {
        super.init(tableStyle: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = headerView
        self.headerView.assignTitle(text: CHLocalized(key: "pmCalls"))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.plainTableBackGroundColor : CHLightThemeColors.instance.plainTableBackGroundColor
        self.tableView.register(CHRecentCallTableCell.self, forCellReuseIdentifier: "recentCallCell")
        self.tableView.register(RecentConversationShimmeringCell.self, forCellReuseIdentifier: "shimmeringCell")
        self.getRecentCallsList(currentOffset: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(processStatusBarChangeNotification), name: NSNotification.Name(rawValue: "changeBarStyle"), object: nil)
        
        self.headerView.chatPlusButtonPressed = {
            let newGroupOption = CHActionSheetAction(title: CHLocalized(key: "pmNewGroup"), image: nil, actionType: .default, handler: {(action) in
                let controller = CHSelectMembersForGroup()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            let newMessageOption = CHActionSheetAction(title: "New Message", image: nil, actionType: .default, handler: {(action) in
                let controller = CHNewMessageController()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            let newCallOption = CHActionSheetAction(title: "Start a Call", image: nil, actionType: .default, handler: {(action) in
                let controller = CHNewCallViewController()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            
            var controllerActions = [CHActionSheetAction]()
            controllerActions.append(newGroupOption)
            controllerActions.append(newMessageOption)
            if CHCustomOptions.callModuleEnabled {
                controllerActions.append(newCallOption)
            }
            
            let controller = CHActionSheetController()
            controller.actions = controllerActions
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        }
        self.headerView.onSearchButtonPressed = {
            let controller = CHSearchViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        self.headerView.onBackButtonPressed = {
            if CHCustomOptions.showLogoutButton {
                let alertController = UIAlertController(title: nil, message: "Logout?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: CHLocalized(key: "pmLogout"), style: .destructive, handler: {(action) in
                    self.logout()
                })
                let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                if #available(iOS 13.0, *) {
                    // Always adopt a light interface style.
                    if CHAppConstant.themeStyle == .dark {
                        alertController.overrideUserInterfaceStyle = .dark
                    } else {
                        alertController.overrideUserInterfaceStyle = .light
                    }
                }
                self.present(alertController, animated: true, completion: nil)
            } else {
                ChUI.instance.isCHOpen = false
                ChUserCache.instance.users.removeAll()
                self.navigationController?.parent?.navigationController?.popViewController(animated: true)
            }
        }
        
        self.setNavigationColor(animated: false)
        self.headerView.updateViewsColors()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isShimmeringModeOn == true {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.isShimmeringModeOn == true {
            return 10
        } else {
            return self.recentCalls.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isShimmeringModeOn == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shimmeringCell", for: indexPath) as! RecentConversationShimmeringCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            cell.startShimmering()
            return cell
        } else {
            if indexPath.row != self.recentCalls.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recentCallCell", for: indexPath) as! CHRecentCallTableCell
                cell.recentCallModel = self.recentCalls[indexPath.row]
                cell.setUpUIProperties()
                return cell
            } else {
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isShimmeringModeOn {
            return 75
        } else {
            if self.recentCalls.count == 0 {
                let screenHeight = UIScreen.main.bounds.height
                let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
                let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0.0
                return screenHeight - navBarHeight - tabBarHeight
            } else {
                return 75
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.isShimmeringModeOn == false else {
            return
        }
        guard indexPath.row != self.recentCalls.count else {
            return
        }
        let callData = self.recentCalls[indexPath.row]
        let controller = CHDetailedCallLogController()
        controller.callPartner = callData.callPartnerMember
        controller.calls = callData.calls ?? []
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    // MARK:- API Functions
    private func getRecentCallsList(currentOffset: Int) {
        var params = [String:Any]()
        params.updateValue(currentOffset, forKey: "skip")
        params.updateValue(25, forKey: "limit")
        params.updateValue("calls", forKey: "includes")
        params.updateValue(Channelize.getCurrentUserId(), forKey: "userId")
        ChannelizeAPIService.getRecentCalls(params: params, completion: {(calls,errorString) in
            guard errorString == nil else {
                return
            }
            if let recentCalls = calls {
                recentCalls.forEach({
                    self.recentCalls.append($0)
                })
            }
            self.isShimmeringModeOn = false
            self.checkAndSetNoContentView()
            //self.tableView.reloadData()
        })
    }
        
    func logout() {
        showProgressView(superView: self.navigationController?.view, string: nil)
        Channelize.logout(completion: {(status,errorString) in
            disMissProgressView()
            if status {
                ChUI.instance.isCHOpen = false
                ChUserCache.instance.users.removeAll()
                self.navigationController?
                    .parent?.navigationController?.popViewController(
                        animated: true)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    
    // MARK: - Other UIViews Functions
    private func checkAndSetNoContentView() {
        if self.recentCalls.count == 0 {
            self.view.addSubview(noConversationView)
            self.noConversationView.translatesAutoresizingMaskIntoConstraints = false
            self.noConversationView.pinEdgeToSuperView(superView: self.view)
        } else {
            self.noConversationView.removeFromSuperview()
        }
        self.tableView.reloadData()
    }

    @objc func processStatusBarChangeNotification() {
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.headerView.updateViewsColors()
        self.noConversationView.updateColors()
        self.setNavigationColor(animated: true)
    }

}

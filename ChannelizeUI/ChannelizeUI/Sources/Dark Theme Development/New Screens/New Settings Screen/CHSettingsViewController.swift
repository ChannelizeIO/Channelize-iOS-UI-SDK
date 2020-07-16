//
//  CHSettingsViewController.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/1/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Reachability

class CHSettingsViewController: NewCHTableViewController {

    var settings = [CHLocalized(key: "pmIm"), CHLocalized(key: "pmBlockedUsers"), CHLocalized(key: "pmNotifications"),CHLocalized(key: "pmDarkTheme")]
    let statusArray = [CHLocalized(key: "pmOffline"), CHLocalized(key: "pmOnline")]
    let videoQualityArray = ["1280x720","960x720","840x480","640x480","480x480","640x360","480x360","360x360","424x240","320x240","240x240","320x180","240x180"]
    let mySwitch: UISwitch = UISwitch()
    
    var headerView: CHNavHeaderView = {
        let headerView = CHNavHeaderView()
        return headerView
    }()
    
    private var themeSwitchView: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.setOn(CHAppConstant.themeStyle == .dark ? true : false, animated: false)
        return uiSwitch
    }()
    
    //let reachability = try! Reachability()
    
    init() {
        super.init(tableStyle: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CHConstants.isChannelizeCallAvailable {
            settings.insert(CHLocalized(key: "pmVideoCallResolution"), at: 3)
        }
        self.navigationItem.titleView = self.headerView
        self.headerView.assignTitle(text: CHLocalized(key: "pmSettings"))
        self.tableView.tableFooterView = UIView()
        self.tableView.tableHeaderView = UIView()
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.plainTableBackGroundColor : CHLightThemeColors.instance.plainTableBackGroundColor
        self.tableView.register(CHUserSettingsTableCell.self, forCellReuseIdentifier: "chSettingCell")
        self.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor
        self.themeSwitchView.addTarget(self, action: #selector(themeChanged(sender:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(processStatusBarChangeNotification), name: NSNotification.Name(rawValue: "changeBarStyle"), object: nil)
        
        self.headerView.chatPlusButtonPressed = {
            let newGroupOption = CHActionSheetAction(title: CHLocalized(key: "pmNewGroup"), image: nil, actionType: .default, handler: {(action) in
                let controller = CHSelectMembersForGroup()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            let newMessageOption = CHActionSheetAction(title: CHLocalized(key: "pmNewMessage"), image: nil, actionType: .default, handler: {(action) in
                let controller = CHNewMessageController()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            let newCallOption = CHActionSheetAction(title: CHLocalized(key: "pmStartNewCall"), image: nil, actionType: .default, handler: {(action) in
                let controller = CHNewCallViewController()
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            })
            
            var controllerActions = [CHActionSheetAction]()
            controllerActions.append(newGroupOption)
            controllerActions.append(newMessageOption)
            if CHConstants.isChannelizeCallAvailable {
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
            } else {
    
                ChUI.instance.isCHOpen = false
                ChUserCache.instance.users.removeAll()
                self.navigationController?.parent?.navigationController?.popViewController(animated: true)
            }
        }
        self.setNavigationColor()
        self.headerView.updateViewsColors()
        
        
//        reachability.whenReachable = { reachability in
//            if reachability.connection == .wifi {
//                self.extraInfoContainerView.viewWithTag(40058)?.removeFromSuperview()
//                self.extraInfoContainerViewHeight = 0
//            } else {
//                self.extraInfoContainerView.viewWithTag(40058)?.removeFromSuperview()
//                self.extraInfoContainerViewHeight = 0
//            }
//        }
//        reachability.whenUnreachable = { _ in
//            let noInternetLabel = UILabel()
//            noInternetLabel.translatesAutoresizingMaskIntoConstraints = false
//            noInternetLabel.backgroundColor = UIColor.systemRed
//            noInternetLabel.textColor = UIColor.white
//            noInternetLabel.font = CHCustomStyles.mediumSizeMediumFont
//            noInternetLabel.text = "No Internet Connection."
//            noInternetLabel.tag = 40058
//            noInternetLabel.textAlignment = .center
//            self.extraInfoContainerView.addSubview(noInternetLabel)
//            noInternetLabel.pinEdgeToSuperView(superView: self.extraInfoContainerView)
//            self.extraInfoContainerViewHeight = 35
//        }
//
//        do {
//            try reachability.startNotifier()
//        } catch {
//            print("Unable to start notifier")
//        }
        
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.settings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingCell = tableView.dequeueReusableCell(withIdentifier: "chSettingCell", for: indexPath) as! CHUserSettingsTableCell
        settingCell.selectionStyle = .none
        settingCell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        var secondaryText: String?
        var showDiscloseIndicator = true
        var cellAccessoryView: UIView?
        let cellSetting = settings[indexPath.row]
        if indexPath.row == 0 {
            let isOnline = UserDefaults.standard.value(forKey: ChannelizeKeys.isUserOnline.key()) as? Bool
            secondaryText = isOnline ?? false ? statusArray[1] : statusArray[0]
            showDiscloseIndicator = true
            cellAccessoryView = nil
        } else if indexPath.row == 1 {
            
            secondaryText = nil
            showDiscloseIndicator = true
            cellAccessoryView = nil
        } else if indexPath.row == 2 {
            
            secondaryText = nil
            showDiscloseIndicator = false
            let isOn = UserDefaults.standard.value(forKey: ChannelizeKeys.isNotificationOn.key()) as? Bool ?? false
            mySwitch.setOn(isOn, animated: false)
            mySwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            cellAccessoryView = mySwitch
        } else if indexPath.row == 3 {
            
            if CHConstants.isChannelizeCallAvailable {
                secondaryText = UserDefaults.standard.value(forKey: "CHVideoCallQuality") as? String ?? VideoCallQuality.Quality960x720.rawValue
                showDiscloseIndicator = true
                cellAccessoryView = nil
            } else {
                secondaryText = nil
                showDiscloseIndicator = false
                cellAccessoryView = self.themeSwitchView
                let isOnDarkTheme = UserDefaults.standard.value(forKey: "CHDarkThemOn") as? Bool ?? false
                self.themeSwitchView.setOn(isOnDarkTheme, animated: false)
            }
        } else if indexPath.row == 4 {
            secondaryText = nil
            showDiscloseIndicator = false
            cellAccessoryView = self.themeSwitchView
            let isOnDarkTheme = UserDefaults.standard.value(forKey: "CHDarkThemOn") as? Bool ?? false
            self.themeSwitchView.setOn(isOnDarkTheme, animated: false)
        } else if indexPath.row == 5 {
            
        }
        settingCell.assignData(mainText: cellSetting, secondaryText: secondaryText, showDiscloseIndicator: showDiscloseIndicator, cellExtraView: cellAccessoryView)
        return settingCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let controller = OptionsSelectorTableController()
            controller.dataString = statusArray
            controller.onStatusChanged = {
                self.tableView.reloadData()
            }
            controller.title = settings[indexPath.item]
            controller.selectorType = .userOnlineOffline
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case 3:
            if CHConstants.isChannelizeCallAvailable {
                let controller = OptionsSelectorTableController()
                controller.dataString = videoQualityArray
                controller.onVideoQualityOptionChange = {
                    self.tableView.reloadData()
                }
                controller.title = settings[indexPath.item]
                controller.selectorType = .videoQuality
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
            break
        case 1:
            let controller = CHBlockedViewController()
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
            break
        default:
            break
        }
    }
    
    func setViewDetails(_ cell: UITableViewCell, indexPath: IndexPath){
        
        switch indexPath.row {
        case 0:
            let isOnline = UserDefaults.standard.value(forKey: ChannelizeKeys.isUserOnline.key()) as? Bool
            cell.detailTextLabel?.text = isOnline ?? false ? statusArray[1] : statusArray[0]
            cell.accessoryType = .disclosureIndicator
            break
        case 1:
            let locale = NSLocale.autoupdatingCurrent
            let language = UserDefaults.standard.value(forKey: "isOnline") as? String
            if( language != nil && locale.localizedString(forLanguageCode: language!) != nil){
                cell.detailTextLabel?.text = locale.localizedString(forLanguageCode: language!)!
            }else{
                cell.detailTextLabel?.text = locale.localizedString(forLanguageCode: "en")
            }
            break
            
        case 2:
            cell.accessoryType = .disclosureIndicator
            break
            
        case 3:
            let isOn = UserDefaults.standard.value(forKey: ChannelizeKeys.isNotificationOn.key()) as? Bool ?? false
            mySwitch.setOn(isOn, animated: false)
            mySwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = mySwitch
            break
        case 4:
            let quality = UserDefaults.standard.value(forKey: "CHVideoCallQuality") as? String
            cell.detailTextLabel?.text = quality ?? VideoCallQuality.Quality960x720.rawValue
            cell.accessoryType = .disclosureIndicator
            break
        default:
            break
            
        }
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        var params = [String:Any]()
        params.updateValue(sender.isOn, forKey: "notification")
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.updateUserSettings(params: params, completion: {(status,errorString) in
            
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
                UserDefaults.standard.set(sender.isOn, forKey: ChannelizeKeys.isNotificationOn.key())
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
            
            
            
        })
    }
    
    @objc private func themeChanged(sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "CHDarkThemOn")
            CHAppConstant.themeStyle = .dark
        } else {
            UserDefaults.standard.set(false, forKey: "CHDarkThemOn")
            CHAppConstant.themeStyle = .light
        }
        self.setNavigationColor(animated: false)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeBarStyle"), object: nil, userInfo: nil)
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
    
    // MARK: - Notification Function
    @objc func processStatusBarChangeNotification() {
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.headerView.updateViewsColors()
        self.setNavigationColor(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



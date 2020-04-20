//
//  OptionsSelectorTableController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/1/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import UIKit

enum OptionScreenType {
    case videoQuality
    case userOnlineOffline
}

protocol VideoQualityDelegate {
    func didSelectVideoQuality(quality:String)
    func didChangeUserStatus()
}


class OptionsSelectorTableController: UITableViewController {
    
    var dataString = [String]()
    var lastSelection: IndexPath?
    var qualityDelegate : VideoQualityDelegate?
    var selectorType : OptionScreenType? = .userOnlineOffline
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.tableView.backgroundColor = .white
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
        self.tableView.allowsMultipleSelection = false
        
        if self.selectorType == .videoQuality{
            let videoQuality = UserDefaults.standard.object(forKey: "CHVideoCallQuality") as? String ?? VideoCallQuality.Quality960x720.rawValue
            if let index = dataString.firstIndex(of: videoQuality){
                lastSelection = IndexPath(item: index, section: 0)
            }
        } else if self.selectorType == .userOnlineOffline{
            let status = UserDefaults.standard.object(forKey: "channelize_userOnline") as? Bool ?? false
            if status{
                lastSelection = IndexPath(item: 1, section: 0)
            } else{
                lastSelection = IndexPath(item: 0, section: 0)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataString.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        
        cell.selectionStyle = .none
        cell.textLabel?.text = self.dataString[indexPath.item]
        cell.textLabel?.font = CHUIConstants.contactNameFont
        cell.selectionStyle = .none
        cell.backgroundColor = .white
        cell.textLabel?.textColor = CHUIConstants.contactNameColor
        if indexPath.item == lastSelection?.item {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.lastSelection != nil {
            self.tableView.cellForRow(at: self.lastSelection!)?.accessoryType = .none
        }
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        if self.selectorType == .videoQuality{
            self.qualityDelegate?.didSelectVideoQuality(quality: self.dataString[indexPath.item])
            UserDefaults.standard.set(self.dataString[indexPath.item], forKey: "CHVideoCallQuality")
        } else if self.selectorType == .userOnlineOffline{
            let value = (indexPath.item as NSNumber).boolValue
            var params = [String:Any]()
            params.updateValue(value, forKey: "isOnline")
            showProgressView(superView: self.navigationController?.view, string: nil)
            ChannelizeAPIService.updateUserSettings(params: params, completion: {(status,errorString) in
                if status {
                    showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
                    UserDefaults.standard.set(value, forKey: ChannelizeKeys.isUserOnline.key())
                    self.qualityDelegate?.didChangeUserStatus()
                } else {
                    showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
                }
            })
        }
        self.lastSelection = indexPath
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


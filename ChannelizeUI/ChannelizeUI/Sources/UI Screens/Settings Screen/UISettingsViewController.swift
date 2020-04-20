//
//  UISettingsViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/22/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire

class UISettingsViewController: CHTableViewController, VideoQualityDelegate {
    
    var settings = ["I am","Default Language","Blocked Users","Notifications"]
    let statusArray = ["Offline", "Online"]
     let videoQualityArray = ["1280x720","960x720","840x480","640x480","480x480","640x360","480x360","360x360","424x240","320x240","240x240","320x180","240x180"]
    let mySwitch: UISwitch = UISwitch()
    
    init() {
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        if CHConstants.isChannelizeCallAvailable {
            settings.append("Video Call Resolution")
        }
        self.tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        self.tableView.tableFooterView = UIView()
        self.tableView.tableHeaderView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.settings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "settingCell")
        cell.textLabel?.font = CHUIConstants.contactNameFont
        cell.selectionStyle = .none
        cell.backgroundColor = .white
        cell.textLabel?.textColor = CHUIConstants.contactNameColor
        let cellSetting = settings[indexPath.row]
        cell.textLabel?.text = cellSetting
        cell.detailTextLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: CHUIConstants.mediumFontSize)
        cell.detailTextLabel?.textColor = CHUIConstants.contactNameColor
        setViewDetails(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let controller = OptionsSelectorTableController()
            controller.dataString = statusArray
            controller.qualityDelegate = self
            controller.title = settings[indexPath.item]
            controller.selectorType = .userOnlineOffline
            self.navigationController?.pushViewController(
                controller, animated: true)
            break
        case 4:
            let controller = OptionsSelectorTableController()
            controller.dataString = videoQualityArray
            controller.qualityDelegate = self
            controller.title = settings[indexPath.item]
            controller.selectorType = .videoQuality
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case 2:
            /*
            let messageQuery = CHMessageQueryBuilder()
            
            let attachment1 = CHImageAttachmentQueryBuilder()
            attachment1.attachMentIdentifier = UUID()
            attachment1.imageData = getImage("noMessages.png")?.jpegData(compressionQuality: 1.0)
            
            let attachment2 = CHImageAttachmentQueryBuilder()
            attachment2.attachMentIdentifier = UUID()
            attachment2.imageData = getImage("noResultFound.png")?.jpegData(compressionQuality: 1.0)
            
            let attachment3 = CHImageAttachmentQueryBuilder()
            attachment3.attachMentIdentifier = UUID()
            attachment3.imageData = getImage("noGroups.png")?.jpegData(compressionQuality: 1.0)
            
            let attachment4 = CHImageAttachmentQueryBuilder()
            attachment4.attachMentIdentifier = UUID()
            attachment4.imageData = getImage("noContacts.png")?.jpegData(compressionQuality: 1.0)
            
            let allAttachments = [attachment1,attachment2,attachment3,attachment4]
            messageQuery.attachments = allAttachments
            
            ChannelizeAPIService.sendMessage(queryBuilder: messageQuery, uploadProgress: {(identifier,progress) in
                print("Upload progress for Identifier(\((identifier ?? UUID()).uuidString)) is \(progress ?? 0.0)")
            })
            
            let locationAttachmentQueryBuilder = CHLocationAttachmentQueryBuilder()
            locationAttachmentQueryBuilder.locationTitle = "Union Square"
            locationAttachmentQueryBuilder.locationAddress = "320 Geary St, San Francisco 94102, United States"
            locationAttachmentQueryBuilder.locationLatitude = 37.7873589
            locationAttachmentQueryBuilder.locationLongitude = -122.408227

            let gifQueryBuilder = CHGifAttachmentQueryBuilder()
            gifQueryBuilder.gifStillUrl = "https://media3.giphy.com/media/KenDhChWfWEgliudjI/200_s.gif"
            gifQueryBuilder.gifDownSampledUrl = "https://media3.giphy.com/media/KenDhChWfWEgliudjI/200_d.gif"
            gifQueryBuilder.gifOriginalUrl = "https://media3.giphy.com/media/KenDhChWfWEgliudjI/200.gif"

            let stickerQueryBuilder = CHStickerAttachmentQueryBuilder()
            stickerQueryBuilder.stickerDownSampledUrl = "https://media3.giphy.com/media/KenDhChWfWEgliudjI/200_d.gif"
            stickerQueryBuilder.stickerStillUrl = "https://media3.giphy.com/media/KenDhChWfWEgliudjI/200_s.gif"
            stickerQueryBuilder.stickerOriginalUrl = "https://media3.giphy.com/media/KenDhChWfWEgliudjI/200.gif"
            let messageQuery = CHMessageQueryBuilder()
            messageQuery.conversationId = "42025f71-736e-11ea-b7d0-09b0f8c95115"
            messageQuery.attachments = [locationAttachmentQueryBuilder,gifQueryBuilder,stickerQueryBuilder]
            messageQuery.body = "Multiple attachment Test"
            messageQuery.messageType = .normal
            
            ChannelizeAPIService.sendMessage(queryBuilder: messageQuery, uploadProgress: {(identifier,progress) in
                
            }, completion: {(message,errorString) in
                guard errorString == nil else {
                    print("Failed to send message. Error \(errorString ?? "")")
                    return
                }
                if let recievedMessage = message {
                    print(recievedMessage.toJSON())
                }
            })
            */
            
            
            let controller = BlockedUserViewController()
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(
                controller, animated: true)
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
        showProgressView(superView: self.superView, string: nil)
        ChannelizeAPIService.updateUserSettings(params: params, completion: {(status,errorString) in
            
            if status {
                showProgressSuccessView(superView: self.superView, withStatusString: nil)
                UserDefaults.standard.set(sender.isOn, forKey: ChannelizeKeys.isNotificationOn.key())
            } else {
                showProgressErrorView(superView: self.superView, errorString: errorString)
            }
            
            
            
        })
    }
    
    func didSelectVideoQuality(quality: String) {
        self.tableView.reloadData()
    }
    
    func didChangeUserStatus() {
        self.tableView.reloadData()
    }
}


enum VideoCallQuality : String{
    case Quality640x480 = "640*480"
    case Quality1280x720 = "1280*720"
    case Quality960x720 = "960x720"
    case Quality840x480 = "840x480"
    case Quality480x480 = "480x480"
    case Quality640x360 = "640x360"
}

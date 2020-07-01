//
//  CHDetailedCallLogController.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

class CHDetailedCallLogController: NewCHTableViewController {
    
    private var headerView: DetailedCallLogHeaderView = {
        let view = DetailedCallLogHeaderView()
        return view
    }()
    
    init() {
        super.init(tableStyle: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var calls = [CHCall]()
    var callPartner: CHCallMember?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.titleView = self.headerView
        self.headerView.onBackButtonTapped = {[weak self](sender) in
            self?.navigationController?.popViewController(animated: true)
        }
        self.headerView.onVoiceCallButtonTapped = {[weak self](sender) in
            self?.voiceCallButtonPressed()
        }
        self.headerView.onVideoCallButtonTapped = {[weak self](sender) in
            self?.videoCallButtonPressed()
        }
        self.headerView.assignHeaderViewData(callPartner: callPartner)
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.plainTableBackGroundColor : CHLightThemeColors.instance.plainTableBackGroundColor
        self.tableView.tableFooterView = UIView()
        self.tableView.register(CHDetailedCallLogCell.self, forCellReuseIdentifier: "detailedCallLogCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func voiceCallButtonPressed() {
        let bundleUrl = Bundle.url(forResource: "ChannelizeCall", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
        let bundle = Bundle(url: bundleUrl!)
        bundle?.load()
        let aClass : AnyClass? = NSClassFromString("ChannelizeCall.CHCall")
        if let callMainClass = aClass as? CallSDKDelegates.Type{
            if let unwrappedUser = self.callPartner?.user {
                callMainClass.launchCallViewController(navigationController: self.navigationController, user: unwrappedUser, type: CHCallScreen.voice.rawValue)
            }
        }
    }
    
    private func videoCallButtonPressed() {
        let bundleUrl = Bundle.url(forResource: "ChannelizeCall", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
        let bundle = Bundle(url: bundleUrl!)
        bundle?.load()
        let aClass : AnyClass? = NSClassFromString("ChannelizeCall.CHCall")
        if let callMainClass = aClass as? CallSDKDelegates.Type{
            if let unwrappedUser = self.callPartner?.user {
                callMainClass.launchCallViewController(navigationController: self.navigationController, user: unwrappedUser, type: CHCallScreen.video.rawValue)
            }
        }
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.calls.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailedCallLogCell", for: indexPath) as! CHDetailedCallLogCell
        let callData = self.calls[indexPath.row]
        let callType = callData.callType ?? .voice
        let callStatusType = callData.myRecipient?.state ?? .Out
        let callDuration = callData.myRecipient?.duration ?? 0.0
        let callTime = callData.createdAt ?? Date()
        
        if callType == .voice {
            cell.imageView?.image = getImage("chVoiceCallIcon")
        } else {
            cell.imageView?.image = getImage("chVideoCallIcon")
        }
        cell.textLabel?.font = CHCustomStyles.normalSizeRegularFont
        cell.detailTextLabel?.font = CHCustomStyles.mediumSizeRegularFont
        cell.detailTextLabel?.textColor = CHUIConstant.recentConversationMessageColor
        switch callStatusType {
        case .In:
            cell.textLabel?.textColor = CHUIConstant.recentConversationTitleColor
            cell.textLabel?.text = CHLocalized(key: "pmIncoming")
            cell.imageView?.tintColor = CHUIConstant.appTintColor//CHUIConstant.appTintColor
            break
        case .Missed:
            cell.textLabel?.textColor = UIColor.customSystemRed
            cell.imageView?.tintColor = UIColor.customSystemRed
            cell.textLabel?.text = CHLocalized(key: "pmMissed")
            break
        case .Out:
            cell.textLabel?.textColor = CHUIConstant.recentConversationTitleColor
            cell.textLabel?.text = CHLocalized(key: "pmOutgoing")
            cell.imageView?.tintColor = UIColor.customSystemGreen
            break
        case .Rejected:
            cell.textLabel?.textColor = CHUIConstant.recentConversationTitleColor
            cell.textLabel?.text = CHLocalized(key: "pmRejected")
            cell.imageView?.tintColor = UIColor.systemGray
            break
        }
        let callDurationText = (callDuration/1000).asString(style: .abbreviated)
        let callTimingText = callTime.convertDateFormatter()
        let detailedText = "(\(callDurationText)) \(callTimingText)"
        cell.detailTextLabel?.text = detailedText
        cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        cell.imageView?.frame.size = CGSize(width: 30, height: 30)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
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


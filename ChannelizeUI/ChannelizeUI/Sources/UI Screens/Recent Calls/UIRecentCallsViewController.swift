//
//  UIRecentCallsViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

class UIRecentCallsViewController: CHTableViewController {

    var recentCalls = [CHRecentCall]()
    var isShimmeringModeOn = true
    
    init() {
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Calls"
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        self.tableView.register(UIRecentCallTableCell.self, forCellReuseIdentifier: "recentCallCell")
        self.tableView.register(RecentConversationShimmerCell.self, forCellReuseIdentifier: "shimmeringCell")
        self.tableView.register(NoConversationMessageCell.self, forCellReuseIdentifier: "noCallsLogCell")
        self.getRecentCallsList(currentOffset: 0)
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
        if self.isShimmeringModeOn == true {
            return 10
        } else {
            if self.recentCalls.count == 0 {
                tableView.isScrollEnabled = false
                return 1
            } else {
                tableView.isScrollEnabled = true
                return self.recentCalls.count + 1
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isShimmeringModeOn == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shimmeringCell", for: indexPath) as! RecentConversationShimmerCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            cell.startShimmering()
            return cell
        } else {
            if self.recentCalls.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noCallsLogCell", for: indexPath) as! NoConversationMessageCell
                cell.assignCustomData(image: "noConversations.png", title: "No Call Logs available.")
                return cell
            } else {
                if indexPath.row != self.recentCalls.count {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "recentCallCell", for: indexPath) as! UIRecentCallTableCell
                    cell.recentCallModel = self.recentCalls[indexPath.row]
                    return cell
                } else {
                    return UITableViewCell()
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.isShimmeringModeOn == false else {
            return
        }
        guard indexPath.row != self.recentCalls.count else {
            return
        }
        let callData = self.recentCalls[indexPath.row]
        let controller = UIDetailedCallLogController()
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
        params.updateValue(ChannelizeAPI.getCurrentUserId(), forKey: "userId")
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
            self.tableView.reloadData()
        })
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

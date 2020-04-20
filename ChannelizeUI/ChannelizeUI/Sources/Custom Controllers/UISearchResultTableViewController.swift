//
//  UISearchResultTableViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/21/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

enum UISearchType {
    case contacts
    case conversations
}

class UISearchResultTableViewController: UITableViewController {
    
    var users = [CHUser]()
    var conversations = [CHConversation]()
    var isLoadingApi = false
    var isAllConversationLoaded = false
    var searchType: UISearchType = .contacts
    
    var onTappedCell: ((_ conversation: CHConversation?, _ user: CHUser?) ->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(hex: "#f2f2f7")
        self.tableView.register(UIContactTableCell.self, forCellReuseIdentifier: "searchResultCell")
        self.tableView.register(UITableViewLoadingCell.self, forCellReuseIdentifier: "contactLoadingCell")
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
        if self.isLoadingApi {
            return 1
        } else {
            if self.searchType == .contacts {
                if self.users.count == 0 {
                    return 1
                } else {
                    return self.users.count
                }
            } else {
                if self.conversations.count == 0 {
                    return 1
                } else {
                    return self.conversations.count
                }
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isLoadingApi {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactLoadingCell", for: indexPath) as! UITableViewLoadingCell
            cell.showSpinnerView()
            return cell
        } else {
            if self.searchType == .contacts {
                if self.users.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "contactLoadingCell", for: indexPath) as! UITableViewLoadingCell
                    cell.showNoResultFound(string: "No result Found.")
                    cell.backgroundColor = .white
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! UIContactTableCell
                    cell.userModel = self.users[indexPath.row]
                    return cell
                }
                
            } else {
                if self.conversations.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "contactLoadingCell", for: indexPath) as! UITableViewLoadingCell
                    cell.showNoResultFound(string: "No result Found.")
                    cell.backgroundColor = .white
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! UIContactTableCell
                    let conversation = self.conversations[indexPath.row]
                    cell.assignExtraData(imageUrl: conversation.conversationProfileImage, title: conversation.coversationTitle)
                    return cell
                }
                
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.isLoadingApi == false else {
            return
        }
        if self.searchType == .contacts {
            let user = self.users[indexPath.row]
            self.onTappedCell?(nil,user)
//            self.dismiss(animated: false, completion: {
//                self.onTappedCell?(nil,user)
//            })
        } else if self.searchType == .conversations {
            let conversation = self.conversations[indexPath.row]
            self.onTappedCell?(conversation,nil)
//            self.dismiss(animated: false, completion: {
//                self.onTappedCell?(conversation,nil)
//            })
            
        }
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
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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


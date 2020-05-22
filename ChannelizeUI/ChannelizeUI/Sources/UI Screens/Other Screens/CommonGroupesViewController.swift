//
//  CommonGroupesViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/30/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

private let reuseIdentifier = "Cell"

class CommonGroupesViewController: UICollectionViewController, CHAllConversationsDelegate, UICollectionViewDelegateFlowLayout {

    var allConversation = [CHConversation]()
    private var isApiLoading = true
    private var isAllConversationLoaded = false
    private var isShimmeringModeOn = true
    private var currentOffset = 0
    
    var user: CHUser?
    var screenIdentifier: UUID!
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        self.screenIdentifier = UUID()
        CHAllConversations.addConversationDelegates(delegate: self, identifier: self.screenIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor(hex: "#f2f2f7") 
        self.collectionView.register(UIGroupCollectionViewCell.self, forCellWithReuseIdentifier: "groupListCell")
        self.collectionView.register(GroupsListShimmeringCell.self, forCellWithReuseIdentifier: "groupShimmeringCell")
        self.collectionView.register(CollectionViewLoadingCell.self, forCellWithReuseIdentifier: "loadingCell")
        self.collectionView.register(NoGroupConversationCell.self, forCellWithReuseIdentifier: "noGroupConversationCell")
        self.getCommonGroups()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    // MARK: - API Functions
    private func getCommonGroups() {
        let memberIds = [self.user?.id ?? "",Channelize.getCurrentUserId()]
        var params = [String:Any]()
        params.updateValue(true, forKey: "isGroup")
        params.updateValue(memberIds.joined(separator: ","), forKey: "membersIncluded")
        params.updateValue("members", forKey: "include")
        params.updateValue(50, forKey: "limit")
        params.updateValue(0, forKey: "skip")
        ChannelizeAPIService.getConversationList(params: params, completion: {(conversations,errorString) in
            self.isShimmeringModeOn = false
            if let recievedConversations = conversations {
                self.allConversation.append(contentsOf: recievedConversations)
                self.collectionView.reloadData()
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if self.isShimmeringModeOn == true {
            return 10
        } else {
            if self.allConversation.count == 0 {
                return 1
            } else {
                return self.allConversation.count
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isShimmeringModeOn == true {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupShimmeringCell", for: indexPath) as! GroupsListShimmeringCell
            cell.startShimmering()
            return cell
        } else {
            if self.allConversation.count == 0 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "noGroupConversationCell", for: indexPath)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "groupListCell", for: indexPath) as! UIGroupCollectionViewCell
                cell.conversation = self.allConversation[indexPath.item]
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.isShimmeringModeOn == true {
            let width = self.view.frame.width / 2 - 15
            return CGSize(width: width, height: getDeviceWiseAspectedHeight(constant: 220))
        } else {
            if self.allConversation.count == 0 {
                let screenHeight = UIScreen.main.bounds.height
                let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
                let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0.0
                return CGSize(width: self.view.frame.width, height: screenHeight - navBarHeight - tabBarHeight)
                //return screenHeight - navBarHeight - tabBarHeight
            } else {
                let width = self.view.frame.width / 2 - 10
                return CGSize(width: width, height: getDeviceWiseAspectedHeight(constant: 220))
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 6.5, bottom: 5, right: 6.5)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.isShimmeringModeOn == false else {
            return
        }
        guard indexPath.item != self.allConversation.count else {
            return
        }
        let conversation = self.allConversation[indexPath.item]
        let controller = UIConversationViewController()
        controller.conversation = conversation
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

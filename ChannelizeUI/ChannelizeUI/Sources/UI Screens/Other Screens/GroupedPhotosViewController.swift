//
//  GroupedPhotosViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/16/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

private let reuseIdentifier = "Cell"

class GroupedPhotosViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var selectBarButtonItem: UIBarButtonItem!
    var doneBarButtonItem: UIBarButtonItem!
    var selectAllBarButton: UIBarButtonItem!
    var deselectAllBarButtonItem: UIBarButtonItem!
    
    var imagesModels = [ImageMessageModel]()
    var selectedMessageIds = [String]()
    var isMessageSelectorOn = false
    
    var deleteMessageToolBarButton: UIBarButtonItem!
    var forwardMessageToolBarButton: UIBarButtonItem!
    
    var selectedMessageCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont(fontStyle: .robotoSlabMedium, size: 17.0)
        label.backgroundColor = .clear
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        self.collectionView.backgroundColor = UIColor.black
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.register(GroupedPhotosViewCell.self, forCellWithReuseIdentifier: "groupedPhotoCell")
        
        self.selectBarButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectBarButtonItemPressed(sender:)))
        self.doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemPressed(sender:)))
        self.selectAllBarButton = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(selectAllBarButtonItemPressed(sender:)))
        self.deselectAllBarButtonItem = UIBarButtonItem(title: "Deselect All", style: .plain, target: self, action: #selector(deSelectAllBarButtonItemPressed(sender:)))
        
        self.navigationItem.rightBarButtonItem = self.selectBarButtonItem
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            self.navigationController?.setToolbarHidden(true, animated: false)
        }
    }

    @objc private func selectBarButtonItemPressed(sender: UIBarButtonItem) {
        self.isMessageSelectorOn = true
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
        self.collectionView.reloadData()
        
        deleteMessageToolBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didPressDeleteMessageButton(sender:)))
        deleteMessageToolBarButton.tintColor = UIColor.customSystemRed
        deleteMessageToolBarButton.isEnabled = false
        forwardMessageToolBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didPressForwardMessageButton(sender:)))
        forwardMessageToolBarButton.tintColor = CHUIConstants.appDefaultColor
        forwardMessageToolBarButton.isEnabled = false
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let customBarButton = UIBarButtonItem(customView: selectedMessageCountLabel)
        
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [deleteMessageToolBarButton,space,customBarButton,rightSpace,forwardMessageToolBarButton]
        selectedMessageCountLabel.text = "\(self.selectedMessageIds.count) Photos Selected"
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    @objc func didPressDeleteMessageButton(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteForMeAction = UIAlertAction(title: CHLocalized(key: "pmDeleteForMe"), style: .destructive, handler: {(action) in
            self.deleteMessages(messageIds: self.selectedMessageIds)
        })
        let deleteForEveryOneAction = UIAlertAction(title: CHLocalized(key: "pmDeleteForEveryone"), style: .destructive, handler: {(action) in
            self.deleteMessagesForEveryOne(messageIds: self.selectedMessageIds)
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        actionSheet.addAction(deleteForMeAction)
        actionSheet.addAction(cancelAction)
        
        if let firstItem = self.imagesModels.first {
            if firstItem.senderId == ChannelizeAPI.getCurrentUserId() {
                actionSheet.addAction(deleteForEveryOneAction)
            }
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func didPressForwardMessageButton(sender: UIBarButtonItem) {
        let forwardMessagecontroller = MessageForwardController()
        forwardMessagecontroller.allUsers = CHAllContacts.contactsList
        forwardMessagecontroller.messageIds = self.selectedMessageIds
        forwardMessagecontroller.allConversations = CHAllConversations.allConversations.filter({
            $0.isGroup == true
        })
        self.selectedMessageIds.removeAll()
        self.isMessageSelectorOn = false
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.collectionView.reloadData()
        self.navigationController?.pushViewController(
            forwardMessagecontroller, animated: true)
    }
    
    @objc private func doneBarButtonItemPressed(sender: UIBarButtonItem) {
        self.isMessageSelectorOn = false
        self.selectedMessageIds.removeAll()
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationItem.rightBarButtonItem = selectBarButtonItem
        self.collectionView.reloadData()
    }
    
    @objc private func selectAllBarButtonItemPressed(sender: UIBarButtonItem) {
        
    }
    
    @objc private func deSelectAllBarButtonItemPressed(sender: UIBarButtonItem) {
        
    }
    
    // MARK: - API Functions
    func deleteMessages(messageIds: [String]) {
        self.selectedMessageIds.removeAll()
        self.isMessageSelectorOn = false
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.collectionView.reloadData()
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.deleteMessages(messageIds: messageIds, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
                self.removeItemsFromCollectionView(ids: messageIds)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
    
    func deleteMessagesForEveryOne(messageIds: [String]) {
        self.selectedMessageIds.removeAll()
        self.isMessageSelectorOn = false
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.collectionView.reloadData()
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.deleteMessagesForEveryOne(messageIds: messageIds, completion: {(status,errorString) in
            if status {
                self.removeItemsFromCollectionView(ids: messageIds)
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
    
    func removeItemsFromCollectionView(ids: [String]) {
        ids.forEach({
            let messageId = $0
            self.imagesModels.removeAll(where: {
                $0.messageId == messageId
            })
        })
        self.collectionView.reloadData()
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.imagesModels.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupedPhotoCell", for: indexPath) as! GroupedPhotosViewCell
        cell.imageModel = self.imagesModels[indexPath.item]
        if self.isMessageSelectorOn == false {
            cell.hideSelectorView()
        } else {
            cell.showSelectorView()
            if self.selectedMessageIds.contains(where: {
                $0 == self.imagesModels[indexPath.item].messageId
            }) {
                cell.setSelected()
            } else {
                cell.setUnSelected()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 450)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isMessageSelectorOn == true {
            if let cell = collectionView.cellForItem(at: indexPath) as? GroupedPhotosViewCell {
                if let messageId = cell.imageModel?.messageId {
                    self.selectedMessageIds.append(messageId)
                }
                cell.isSelected = true
                cell.setSelected()
            }
            if selectedMessageIds.count == 0 {
                self.deleteMessageToolBarButton.isEnabled = false
                self.forwardMessageToolBarButton.isEnabled = false
            } else {
                self.deleteMessageToolBarButton.isEnabled = true
                self.forwardMessageToolBarButton.isEnabled = true
            }
            selectedMessageCountLabel.text = "\(self.selectedMessageIds.count) Photos Selected"
        } else {
            var channelizeImages = [ChannelizeImages]()
            for imageModel in self.imagesModels {
                let chImage = ChannelizeImages(imageUrlString: imageModel.imageUrl, videoUrlString: nil, owner: imageModel.senderName, date: imageModel.messageDate)
                channelizeImages.append(chImage)
            }
            
            let controller = PhotoViewerController(imagesArray: channelizeImages, index: 0, offset: 0, chatId: "", messageCount: self.imagesModels.count)
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.modalPresentationStyle = .currentContext
            navigationController.modalTransitionStyle = .crossDissolve
            self.present(navigationController,animated: true,completion: nil)
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if self.isMessageSelectorOn == true {
            if let cell = collectionView.cellForItem(at: indexPath) as? GroupedPhotosViewCell {
                if let messageId = cell.imageModel?.messageId {
                    self.selectedMessageIds.removeAll(where: {
                        $0 == messageId
                    })
                }
                cell.isSelected = false
                cell.setUnSelected()
            }
        }
        
        if selectedMessageIds.count == 0 {
            self.deleteMessageToolBarButton.isEnabled = false
            self.forwardMessageToolBarButton.isEnabled = false
        } else {
            self.deleteMessageToolBarButton.isEnabled = true
            self.forwardMessageToolBarButton.isEnabled = true
        }
        selectedMessageCountLabel.text = "\(self.selectedMessageIds.count) Photos Selected"
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


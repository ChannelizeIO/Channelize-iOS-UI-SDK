//
//  CreateGroupController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/2/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

class CreateGroupController: ChannelizeController, CHAllContactsDelegates {

    private var allFriends = [CHUser]()
    private var isApiLoading = false
    private var selectedUsers = [CHUser]()
    
    private var groupTitle: String?
    private var groupSelectedImage: UIImage?
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor(hex: "#f3f1f7")
        tableView.allowsMultipleSelection = true
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private var screenIndentifier: UUID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.title = "Create Group"
        self.view.backgroundColor = .white
        self.screenIndentifier = UUID()
        CHAllContacts.addContactsLoadDelegates(delegate: self, identifier: self.screenIndentifier)
        self.setUpViews()
        self.setUpViewsFrames()
        self.getInitialContacts()
        
        let createButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(doneButtonPressed(sender:)))
        self.navigationItem.rightBarButtonItem = createButton
        
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.tabBarController?.tabBar.isHidden = false
        if self.isMovingFromParent {
            Channelize.removeConversationDelegate(identifier: self.screenIndentifier)
            Channelize.removeUserEventDelegate(identifier: self.screenIndentifier)
        }
    }
    
    
    private func setUpViews() {
        self.view.addSubview(tableView)
        self.tableView.backgroundColor = .white
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(CreateGroupHeaderCell.self, forCellReuseIdentifier: "headerCell")
        self.tableView.register(CreateGroupUserSelectCell.self, forCellReuseIdentifier: "userSelectCell")
    }
    
    private func setUpViewsFrames() {
        self.tableView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.tableView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.tableView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
        self.tableView.setBottomAnchor(relatedConstraint: self.view.bottomAnchor, constant: 0)
        
    }
    
    private func getInitialContacts() {
        self.allFriends = CHAllContacts.contactsList
        self.tableView.reloadData()
    }
    
    // MARK: - Contacts Events Delegates
    func didLoadContacts(contacts: [CHUser]) {
        self.isApiLoading = false
        contacts.forEach({
            let user = $0
            if self.allFriends.filter({
                $0.id == user.id
            }).count == 0 {
                self.allFriends.append(user)
            }
        })
        self.tableView.reloadData()
    }
    
    func didUserAddedInContactList(user: CHUser) {
        
    }
    
    func didUserRemovedFromContactList(user: CHUser) {
        
    }
    
    func didUserStatusUpdated(updatedUser: CHUser) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @objc func doneButtonPressed(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        guard let newGroupTitle = self.groupTitle else {
            self.showSimpleAlert(withTitle: "Error", message: "Please enter group name.")
            return
        }
        
        var usersArray = [String]()
        for selectedUser in self.selectedUsers{
            if let userId = selectedUser.id{
                usersArray.append(userId)
            }
        }
        usersArray.append(Channelize.getCurrentUserId())
        
        if usersArray.count < 2{
            self.showSimpleAlert(withTitle: "Error", message: "Please Select Atleast One Member")
            return
        } else{
            var imageData : Data?
            imageData = self.groupSelectedImage?.jpegData(compressionQuality: 0.5)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            showProgressView(superView: self.view, string: nil)
            ChannelizeAPIService.createNewConversation(title: newGroupTitle, membersIds: usersArray, profileImageData: imageData, completion: {(conversation,errorString) in
                guard errorString == nil else {
                    showProgressErrorView(superView: self.view, errorString: errorString)
                    return
                }
                showProgressSuccessView(superView: self.view, withStatusString: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    disMissProgressView()
                    self.navigationController?.popToRootViewController(animated: false)
                })
            })
        }
    }
    
    func showSimpleAlert(withTitle: String?, message: String?){
        let alertViewController = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertViewController.addAction(okAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            alertViewController.overrideUserInterfaceStyle = .light
        }
        #endif
        self.present(alertViewController,animated: true,completion: nil)
    }
    
}

extension CreateGroupController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.allFriends.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! CreateGroupHeaderCell
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userSelectCell", for: indexPath) as! CreateGroupUserSelectCell
            let friendData = self.allFriends[indexPath.row]
            cell.userModel = friendData
            cell.backgroundColor = UIColor(hex: "#ffffff")
            cell.activateSelectionMode()
            if self.selectedUsers.contains(where: {
                $0.id == friendData.id
            }) == true {
                cell.selectedCirlceImageView.isHidden = false
                cell.unSelectedCircleImageView.isHidden = true
            } else {
                cell.selectedCirlceImageView.isHidden = true
                cell.unSelectedCircleImageView.isHidden = false
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return getDeviceWiseAspectedHeight(constant: 150)
        } else {
            return getDeviceWiseAspectedHeight(constant: 85)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if let cell = tableView.cellForRow(at: indexPath) as? CreateGroupUserSelectCell{
            if let cellUser = cell.userModel{
                self.selectedUsers.append(cellUser)
            }
            cell.isSelected = true
            cell.unSelectedCircleImageView.isHidden = true
            cell.selectedCirlceImageView.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CreateGroupUserSelectCell{
            
            if let cellUser = cell.userModel{
                self.selectedUsers.removeAll(where: {
                    $0.id == cellUser.id
                })
            }
            cell.isSelected = false
            cell.unSelectedCircleImageView.isHidden = false
            cell.selectedCirlceImageView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            print(indexPath)
            if indexPath.row == self.allFriends.count - 3 && self.allFriends.count > 0 {
                if CHAllContacts.isAllContactsLoaded == false {
                    self.isApiLoading = true
                    CHAllContacts.getContacts()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        let textField = UITextField()
        textField.backgroundColor = .clear
        let placeHolderAttributes: [NSAttributedString.Key:Any] = [
            NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: 18.0)!,
            NSAttributedString.Key.foregroundColor: CHUIConstants.conversationMessageColor
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Search and add Friends", attributes: placeHolderAttributes)
        textField.tintColor = .white
        textField.textColor = .white
        textField.autocorrectionType = .no
        textField.font = UIFont(fontStyle: .robotoSlabRegualar, size: 18.0)
        containerView.addSubview(textField)
        textField.delegate = self
        textField.frame.origin = CGPoint(x: 7.5, y: 0)
        textField.frame.size = CGSize(width: self.view.frame.width - 15, height: 45)
        textField.setLeftIcon(iconName: "chSearchIcon", iconHeight: 45)
        if section == 1 {
            return containerView
        } else {
            return nil
        }
        
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 {
            return 45
        } else {
            return 0
        }
    }
}

extension CreateGroupController: UITextFieldDelegate, SearchUserControllerDelegate {
    
    func didFinishSelectingUsers(selectedUsers: [CHUser]) {
        self.selectedUsers = selectedUsers
        self.selectedUsers.forEach({
            let user = $0
            if let selectedUserIndex = self.allFriends.firstIndex(where: {
                $0.id == user.id
            }) {
                self.allFriends.remove(at: selectedUserIndex)
                self.allFriends.insert(user, at: 0)
            } else {
                self.allFriends.insert(user, at: 0)
            }
        })
        self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        //self.tableView.reloadData()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let controller = SearchUsersController()
        controller.allUsers = self.allFriends
        controller.selectedUsers = self.selectedUsers
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
        return false
    }
}

extension CreateGroupController: CreateGroupHeaderCellDelegate {
    func didPressImageOptionButton() {
        self.editPhoto()
    }
    
    func didPressImageButton() {
        self.pickUpPhoto()
    }
    
    func didChangeGroupTitle(newText: String?) {
        self.groupTitle = newText
    }
}

extension CreateGroupController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pickUpPhoto(){
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.allowsEditing = true
        present(photoPicker, animated: true, completion: nil)
    }
    
    func editPhoto(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "New Photo", style: .default, handler: {(action) in
            self.pickUpPhoto()
        })
        
        let deletePhotoAction = UIAlertAction(title: "Delete Photo", style: .destructive, handler: {(action) in
            let headerCell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! CreateGroupHeaderCell
            headerCell.setNewImage(newImage: nil)
            self.groupSelectedImage = nil
        })
        
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(deletePhotoAction)
        alert.addAction(cancelAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            alert.overrideUserInterfaceStyle = .light
        }
        #endif
        if let popoverController = alert.popoverPresentationController {
            showIpadActionSheet(sourceView: self.view, popoverController: popoverController)
        }
        self.present(alert,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var groupImage : UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            groupImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            groupImage = originalImage
        }
        if let selectedImage = groupImage {
            let headerCell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! CreateGroupHeaderCell
            headerCell.setNewImage(newImage: selectedImage)
            self.groupSelectedImage = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreateGroupController: CHConversationEventDelegate {
    
}


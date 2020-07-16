//
//  NewGroupViewController.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/1/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage
import InputBarAccessoryView

class CHNewGroupViewController: NewCHTableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var selectedUsers = [CHUser]()
    private var groupTitle: String?
    private var groupSelectedImage: UIImage?
    var keyboardManager: KeyboardManager?
    init() {
        super.init(tableStyle: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Group"
        self.tableView.register(CreateGroupHeaderViewCell.self, forCellReuseIdentifier: "createGroupHeaderCell")
        self.tableView.register(ContactActionTableCell.self, forCellReuseIdentifier: "selectedUserCell")
        self.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.groupedTableBackGroundColor : CHLightThemeColors.instance.groupedTableBackGroundColor
        let createButton = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(createButtonPressed(sender:)))
        self.navigationItem.rightBarButtonItem = createButton
        
        self.keyboardManager = KeyboardManager()
        self.keyboardManager?.on(event: .willShow, do: {notification in
            self.tableView.contentInset.bottom = notification.endFrame.height
        }).on(event: .willHide, do: {notfication in
            self.tableView.contentInset.bottom = 0
        })
    }
    
    @objc private func createButtonPressed(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.callCreateGroupApi()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.selectedUsers.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "createGroupHeaderCell", for: indexPath) as! CreateGroupHeaderViewCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
            cell.onGroupTitleUpdated = {[weak self] newTitle in
                self?.groupTitle = newTitle
            }
            cell.onEditPhotoButtonPressed = {[weak self] in
                self?.editPhoto()
            }
            cell.onPickUpPhotoButtonPressed = {[weak self] in
                self?.pickUpPhoto()
            }
            return cell
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectedUserCell", for: indexPath) as! ContactActionTableCell
            cell.setUpViews()
            cell.setUpViewsFrames()
            cell.user = self.selectedUsers[indexPath.row]
            cell.assignUser()
            cell.setUpUIProperties()
            cell.onRemoveButtonPressed = {[weak self] userId in
                self?.removeUserFromList(userId: userId)
            }
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Private Group"
            cell.textLabel?.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor.black
            cell.textLabel?.font = UIFont(fontStyle: .regular, size: 17.0)
            cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
            cell.selectionStyle = .none
            
            let accessoryImageView = UIImageView(image: UIImage(named: "chRightArrow"))
            accessoryImageView.contentMode = .scaleAspectFit
            accessoryImageView.tintColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#e6e6e6")
            cell.accessoryView = accessoryImageView
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 120
        } else if indexPath.section == 1{
            return 70
        } else {
            return 50
        }
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "Group Title is mandatory"
//        } else {
//            return nil
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            if self.selectedUsers.count == 0 {
                return nil
            } else {
                let backGroundView = UIView()
                backGroundView.backgroundColor = .clear//CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : .white
                
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = "Members"
                label.textColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#E6E6E6") : UIColor(hex: "#4a505a")
                label.font = UIFont(fontStyle: .regular, size: 16)
                backGroundView.addSubview(label)
                label.setTopAnchor(relatedConstraint: backGroundView.topAnchor, constant: 10)
                label.setBottomAnchor(relatedConstraint: backGroundView.bottomAnchor, constant: 0)
                label.setRightAnchor(relatedConstraint: backGroundView.rightAnchor, constant: -10)
                label.setLeftAnchor(relatedConstraint: backGroundView.leftAnchor, constant: 15)
                return backGroundView
            }
        } else {
            let backGroundView = UIView()
            backGroundView.backgroundColor = .clear//CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : .white
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Group Title is mandatory"
            label.textColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#E6E6E6") : UIColor(hex: "#4a505a")
            label.font = UIFont(fontStyle: .regular, size: 16)
            backGroundView.addSubview(label)
            label.setTopAnchor(relatedConstraint: backGroundView.topAnchor, constant: 10)
            label.setBottomAnchor(relatedConstraint: backGroundView.bottomAnchor, constant: 0)
            label.setRightAnchor(relatedConstraint: backGroundView.rightAnchor, constant: -10)
            label.setLeftAnchor(relatedConstraint: backGroundView.leftAnchor, constant: 15)
            return backGroundView
        }
    }
    
    
    // MARK: - Other Functions
    private func removeUserFromList(userId: String) {
        if let userIndex = self.selectedUsers.firstIndex(where: {
            $0.id == userId
        }) {
            self.selectedUsers.remove(at: userIndex)
            if self.selectedUsers.count == 0 {
                self.tableView.reloadData()
            } else {
                let deletedIndexPath = IndexPath(row: userIndex, section: 1)
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: [deletedIndexPath], with: .automatic)
                }, completion: nil)
            }
            
        }
    }
    
    // MARK: - API Functions
    private func callCreateGroupApi() {
        guard let groupTitleString = self.groupTitle, groupTitleString != "" else {
            let chAlertController = CHAlertViewController()
            chAlertController.alertTitle = CHLocalized(key: "pmError")
            chAlertController.alertDescription = CHLocalized(key: "pmEnterGroupName")
            let okAction = CHActionSheetAction(title: CHLocalized(key: "pmOk"), image: nil, actionType: .default, handler: nil)
            chAlertController.actions.append(okAction)
            chAlertController.modalPresentationStyle = .overCurrentContext
            chAlertController.modalTransitionStyle = .crossDissolve
            self.present(chAlertController, animated: true, completion: nil)
            return
        }
        guard self.selectedUsers.count > 0 else {
            let chAlertController = CHAlertViewController()
            chAlertController.alertTitle = CHLocalized(key: "pmError")
            chAlertController.alertDescription = CHLocalized(key: "pmMemberCountErrorMsg")
            let okAction = CHActionSheetAction(title: CHLocalized(key: "pmOk"), image: nil, actionType: .default, handler: nil)
            chAlertController.actions.append(okAction)
            chAlertController.modalPresentationStyle = .overCurrentContext
            chAlertController.modalTransitionStyle = .crossDissolve
            self.present(chAlertController, animated: true, completion: nil)
            return
        }
        var userIds: [String] = self.selectedUsers.compactMap({$0.id ?? ""})
        userIds.append(Channelize.getCurrentUserId())
        let newGroupQueryBuilder = CHNewConversationQueryBuilder()
        newGroupQueryBuilder.isGroup = true
        newGroupQueryBuilder.members = userIds
        newGroupQueryBuilder.title = groupTitleString
        showProgressView(superView: self.navigationController?.view, string: nil)
        var imageData : Data?
        imageData = self.groupSelectedImage?.jpegData(compressionQuality: 0.5)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        ChannelizeAPIService.createNewConversation(title: groupTitleString, membersIds: userIds, profileImageData: imageData, completion: {(conversation,errorString) in
            guard errorString == nil else {
                print("Error in creating New Group")
                print("Error: \(errorString ?? "")")
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
                return
            }
            showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                disMissProgressView()
                self.navigationController?.popToRootViewController(animated: false)
            })
        })
    }
    
    // MARK: - Media Functions
    func pickUpPhoto(){
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.allowsEditing = true
        present(photoPicker, animated: true, completion: nil)
    }
    
    func editPhoto(){
        let newPhotoAction = CHActionSheetAction(title: "New Photo", image: nil, actionType: .default, handler: {(action) in
            self.pickUpPhoto()
        })
        let deletePhotoAction = CHActionSheetAction(title: "Delete Photo", image: nil, actionType: .destructive, handler: {(action) in
            let headerCell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! CreateGroupHeaderViewCell
            headerCell.setNewImage(image: nil)
            self.groupSelectedImage = nil
        })
        let controller = CHActionSheetController()
        controller.actions = [newPhotoAction,deletePhotoAction]
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var groupImage : UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            groupImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            groupImage = originalImage
        }
        if let selectedImage = groupImage {
            let headerCell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! CreateGroupHeaderViewCell
            headerCell.setNewImage(image: selectedImage)
            self.groupSelectedImage = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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



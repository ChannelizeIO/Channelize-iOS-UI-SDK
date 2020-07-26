//
//  CHSelectedUsersView.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/3/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire

class CHSelectedUsersView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var selectedUsers = [CHUser]()
    var collectionView: UICollectionView!
    
    var userRemoved: ((_ user: CHUser?) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.register(CHSelectedUserCell.self, forCellWithReuseIdentifier: "selectedChatModel")
        self.collectionView.delegate = self
        self.collectionView.tag = 100
        self.collectionView.dataSource = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.collectionView)
        self.collectionView.pinEdgeToSuperView(superView: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedChatModel", for: indexPath) as! CHSelectedUserCell
        let model = self.selectedUsers[indexPath.item]
        cell.assignUser(user: model)
        cell.onRemoveButtonPressed = {[weak self](user) in
            self?.removeItemFromCollectionView(itemId: user?.id ?? "")
            self?.userRemoved?(user)
            //self?.removeItemFromCollectionView(itemId: model?.id ?? "")
            //self?.delegate?.didPressRemovedButton(for: user)
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 100)
    }
    
    func removeItemFromCollectionView(itemId: String) {
        if let itemIndex = self.selectedUsers.firstIndex(where: {
            $0.id == itemId
        }) {
            self.selectedUsers.remove(at: itemIndex)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [IndexPath(item: itemIndex, section: 0)])
            }, completion: nil)
        }
        if self.selectedUsers.count == 0 {
            self.viewWithTag(10001)?.removeFromSuperview()
        } else {
            if self.viewWithTag(10001) == nil {
                self.addBottomBorder(with: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor, andWidth: 0.5)
            }
        }
    }
    
    func addNewItemToCollectionView(item: CHUser) {
        if self.selectedUsers.count == 0 {
            if self.selectedUsers.filter({
                $0.id == item.id
            }).count == 0 {
                self.selectedUsers.append(item)
                self.collectionView.reloadData()
            }
        } else {
            if self.selectedUsers.filter({
                $0.id == item.id
            }).count == 0 {
                self.selectedUsers.append(item)
                let insertedIndexPath = IndexPath(item: self.selectedUsers.count-1, section: 0)
                self.collectionView.performBatchUpdates({
                    self.collectionView.insertItems(at: [insertedIndexPath])
                }, completion: nil)
            }
        }
        if self.selectedUsers.count == 0 {
            self.viewWithTag(10001)?.removeFromSuperview()
        } else {
            if self.viewWithTag(10001) == nil {
                self.addBottomBorder(with: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor, andWidth: 0.5)
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}



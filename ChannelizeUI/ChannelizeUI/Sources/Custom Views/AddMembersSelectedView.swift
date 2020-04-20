//
//  AddMembersSelectedView.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 4/6/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

protocol AddMembersSelectedViewDelegates {
    func didPressRemovedButton(for user: CHUser?)
}

class AddMembersSelectedView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var selectedUsers = [CHUser]()
    var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate: AddMembersSelectedViewDelegates?
    
    private func setUpViews() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .white
        self.collectionView.register(SelectedChatModelCell.self, forCellWithReuseIdentifier: "selectedChatModel")
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedChatModel", for: indexPath) as! SelectedChatModelCell
        let model = self.selectedUsers[indexPath.item]
        cell.assignUser(user: model)
        cell.onRemoveButtonPressed = {[weak self](model,user) in
            self?.removeItemFromCollectionView(itemId: model?.id ?? "")
            self?.delegate?.didPressRemovedButton(for: user)
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
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
    }
    
    func addNewItemToCollectionView(item: CHUser) {
        if self.selectedUsers.count == 0 {
            self.selectedUsers.append(item)
            self.collectionView.reloadData()
        } else {
            self.selectedUsers.append(item)
            let insertedIndexPath = IndexPath(item: self.selectedUsers.count-1, section: 0)
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: [insertedIndexPath])
            }, completion: nil)
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

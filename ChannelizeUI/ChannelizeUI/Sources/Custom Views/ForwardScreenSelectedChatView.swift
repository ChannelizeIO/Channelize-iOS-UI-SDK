//
//  ForwardScreenSelectedChatView.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/29/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

enum SelectedChatModelType {
    case user
    case conversation
}

class SelecteChatModel {
    var id: String
    var type: SelectedChatModelType
    var title: String
    var profileImageUrl: String
    
    init(id: String, type: SelectedChatModelType, title: String, profileImageUrl: String) {
        self.id = id
        self.type = type
        self.title = title
        self.profileImageUrl = profileImageUrl
    }
}

protocol ForwardScreenChatViewDelegates {
    func didPressRemovedButton(for model: SelecteChatModel?)
}

class ForwardScreenSelectedChatView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var selectedChatModels = [SelecteChatModel]()
    
    var forwardButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = CHUIConstants.appDefaultColor
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageEdgeInsets = UIEdgeInsets(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5)
        button.setImage(getImage("chMessageSendButton"), for: .normal)
        button.layer.masksToBounds = true
        return button
    }()
    
    var collectionView: UICollectionView!
    var delegate: ForwardScreenChatViewDelegates?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        self.addSubview(forwardButton)
        self.forwardButton.isHidden = true
        self.forwardButton.setViewAsCircle(circleWidth: 50)
        self.forwardButton.setCenterYAnchor(relatedConstraint: self.topAnchor, constant: 0)
        self.forwardButton.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -15)
        self.collectionView.pinEdgeToSuperView(superView: self)
        collectionView.addTopBorder(with: CHUIConstants.appDefaultColor, andWidth: 2.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedChatModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedChatModel", for: indexPath) as! SelectedChatModelCell
        let model = self.selectedChatModels[indexPath.item]
        cell.assignData(model: model)
        cell.onRemoveButtonPressed = {[weak self](model,user) in
            self?.removeItemFromCollectionView(itemId: model?.id ?? "")
            self?.delegate?.didPressRemovedButton(for: model)
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
    
    func removeItemFromCollectionView(itemId: String) {
        if let itemIndex = self.selectedChatModels.firstIndex(where: {
            $0.id == itemId
        }) {
            self.selectedChatModels.remove(at: itemIndex)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [IndexPath(item: itemIndex, section: 0)])
            }, completion: nil)
        }
    }
    
    func addNewItemToCollectionView(item: SelecteChatModel) {
        if self.selectedChatModels.count == 0 {
            self.selectedChatModels.append(item)
            self.collectionView.reloadData()
        } else {
            self.selectedChatModels.append(item)
            let insertedIndexPath = IndexPath(item: self.selectedChatModels.count-1, section: 0)
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

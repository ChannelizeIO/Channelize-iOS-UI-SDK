//
//  CHSelectedUsersAndConverstionView.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/13/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import Alamofire

class CHSelectedUsersAndConverstionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var selectedUsers = [CHUser]()
    var selectedConversations = [CHConversation]()
    var collectionView: UICollectionView!
    var selectedModels = [SelecteChatModel]()
    
    var userRemoved: ((_ user: CHUser?) -> Void)?
    var onSelectedModelRemoved: ((_ model: SelecteChatModel?) -> Void)?
    
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
        self.collectionView.register(CHSelectedUsersAndConverstionCell.self, forCellWithReuseIdentifier: "selectedChatModel")
        self.collectionView.delegate = self
        self.collectionView.tag = 100
        self.collectionView.dataSource = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.collectionView)
        self.collectionView.pinEdgeToSuperView(superView: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedChatModel", for: indexPath) as! CHSelectedUsersAndConverstionCell
        let model = self.selectedModels[indexPath.item]
        cell.assignData(model: model)
        cell.onRemoveButtonPressed = { model in
            self.onSelectedModelRemoved?(model)
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 100)
    }
}


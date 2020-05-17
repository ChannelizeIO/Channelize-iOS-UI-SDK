//
//  MessageReactionView.swift
//  ChannelizeUI
//
//  Created by bigstep on 5/3/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

class MessageReactionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var collectionView: UICollectionView!
    private var emojiReactions = [EmojiReactionModel]()
    private var emojisString = [ "\u{1f44d}","\u{1f44e}","\u{1f606}","\u{1f621}","\u{1f622}","\u{1f60a}","\u{1f31f}","\u{1f389}","\u{1f381}"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createEmojiModels()
        self.configureCollectionView()
        self.addSubview(self.collectionView)
        
        self.collectionView.pinEdgeToSuperView(superView: self)
        self.collectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.backgroundColor = UIColor(hex: "#dedede")
        //self.collectionView.isPagingEnabled = true
        self.collectionView.showsHorizontalScrollIndicator = true
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate.normal
        self.collectionView.allowsSelection = false
        self.collectionView.indicatorStyle = .default
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset.bottom = 0
        //self.collectionView.alwaysBounceHorizontal = false
        self.collectionView.alwaysBounceVertical = false
        self.collectionView.contentInset.top = 0
        self.collectionView.tintColor = .white
        //self.collectionView.alwaysBounceVertical = true
        self.collectionView.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: "emojiCell")
    }
    
    func createEmojiModels() {
        emojisString.forEach({
            let emojiModel = EmojiReactionModel()
            emojiModel.emojiCode = $0
            emojiModel.isSelected = false
            self.emojiReactions.append(emojiModel)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.emojiReactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as! EmojiCollectionCell
        cell.model = self.emojiReactions[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 45, height: 60)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

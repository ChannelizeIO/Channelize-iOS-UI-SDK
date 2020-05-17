//
//  ReactionPopOverController.swift
//  ChannelizeUI
//
//  Created by bigstep on 5/3/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

protocol ReactionPopOverControllerDelegate {
    func didSelectReaction(reaction: EmojiReactionModel, messageId: String?)
    func didRemoveReaction(reaction: EmojiReactionModel, messageId: String?)
}

class ReactionPopOverController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    private var collectionView: UICollectionView!
    private var emojiReactions = [EmojiReactionModel]()
    
    var myReactions = [String]()
    var delegate: ReactionPopOverControllerDelegate?
    var emojisString = ["\u{1f44d}","\u{1f44e}","\u{1f606}","\u{1f621}","\u{1f622}","\u{1f60a}","\u{1f31f}","\u{1f389}","\u{1f381}"]
    var messageId: String?
    
    private var horizontalView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.customSystemRed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        #endif
        self.view.backgroundColor = .white
        self.createEmojiModels()
        self.configureCollectionView()
        self.view.addSubview(self.collectionView)
       
        self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
       self.collectionView.reloadData()
       self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
       
       /*
       self.view.addSubview(horizontalView)
       
       self.horizontalView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
       self.horizontalView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
       self.horizontalView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
       self.horizontalView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
       // Do any additional setup after loading the view.
*/
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.flashScrollIndicators()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.flashScrollIndicators()
    }
   
   func configureCollectionView() {
       let collectionViewLayout = UICollectionViewFlowLayout()
       collectionViewLayout.scrollDirection = .horizontal
       self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
       self.collectionView.translatesAutoresizingMaskIntoConstraints = false
       self.collectionView.backgroundColor = .clear
       self.collectionView.showsHorizontalScrollIndicator = true
        self.collectionView.scrollIndicatorInsets.left = 5
       self.collectionView.decelerationRate = UIScrollView.DecelerationRate.normal
       self.collectionView.allowsSelection = true
       self.collectionView.indicatorStyle = .default
       self.collectionView.delegate = self
       self.collectionView.dataSource = self
       self.collectionView.contentInset.bottom = 0
       //self.collectionView.alwaysBounceHorizontal = false
       self.collectionView.alwaysBounceVertical = false
       self.collectionView.contentInset.top = 0
       self.collectionView.tintColor = .white
    self.collectionView.contentInset.left = 5
    self.collectionView.contentInset.right = 5
       //self.collectionView.alwaysBounceVertical = true
       self.collectionView.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: "emojiCell")
   }
   
    func createEmojiModels() {
        let sortedEmojis = emojiCodes.sorted(by: {$0.value > $1.value})
        sortedEmojis.forEach({
            let key = $0.key
            let value = $0.value
            let emojiModel = EmojiReactionModel()
            emojiModel.emojiCode = value
            emojiModel.emojiKey = key
            if self.myReactions.contains(key) {
                emojiModel.isSelected = true
            } else {
                emojiModel.isSelected = false
            }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reaction = self.emojiReactions[indexPath.item]
        self.dismiss(animated: true, completion: {
            if reaction.isSelected == true {
                self.delegate?.didRemoveReaction(reaction: reaction, messageId: self.messageId)
            } else {
                self.delegate?.didSelectReaction(reaction: reaction, messageId: self.messageId)
            }
        })
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

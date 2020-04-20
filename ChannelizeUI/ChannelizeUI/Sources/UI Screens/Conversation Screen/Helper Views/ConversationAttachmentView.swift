//
//  ConversationAttachmentView.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/13/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

protocol ConversationAttachmentViewDelegate {
    func didPressCancelButton()
    func didPressAttachmentOptionCell(attachmentType: AttachmentType)
}

class ConversationAttachmentView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var attachmentOptions = [AttachmentModel]()
    private var collectionView: UICollectionView!
    
    var delegate: ConversationAttachmentViewDelegate?
    
    private var containerVisualView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .regular)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: "#f3f1f7")
        return view
    }()
    
    private var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "#1c1c1c")
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(getImage("chCloseIcon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    
    private var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.white
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(CHLocalized(key: "pmCancel"), for: .normal)
        button.setTitleColor(CHUIConstants.appDefaultColor, for: .normal)
        button.titleLabel?.font = UIFont(fontStyle: .robotoRegular, size: CHUIConstants.normalFontSize)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hex: "#f3f1f7")
        self.configureCollectionView()
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.backgroundColor = UIColor(hex: "#f3f1f7")
        self.collectionView.showsHorizontalScrollIndicator = true
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate.normal
        self.collectionView.indicatorStyle = .white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset.top = 0
        self.collectionView.isScrollEnabled = false
        self.collectionView.register(AttachmentOptionCell.self, forCellWithReuseIdentifier: "collectionViewCell")
    }
    
    private func setUpViews() {
        //self.addSubview(closeButton)
        self.addSubview(containerVisualView)
        self.containerVisualView.contentView.addSubview(collectionView)
        self.containerVisualView.contentView.addSubview(cancelButton)
        
        self.cancelButton.addTarget(self, action: #selector(didPressCancelButton(sender:)), for: .touchUpInside)
    }
    
    private func setUpViewsFrames() {
        
        self.containerVisualView.pinEdgeToSuperView(superView: self)
        
        self.cancelButton.setBottomAnchor(relatedConstraint: self.bottomAnchor, constant: -5)
        self.cancelButton.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 15)
        self.cancelButton.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -15)
        self.cancelButton.setHeightAnchor(constant: 40)
        
        self.collectionView.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 0)
        self.collectionView.setRightAnchor(relatedConstraint: self.rightAnchor, constant: 0)
        self.collectionView.setBottomAnchor(relatedConstraint: self.cancelButton.topAnchor, constant: -10)
        self.collectionView.setTopAnchor(relatedConstraint: self.topAnchor, constant: 5)
        
    }
    
    func assignAttachmentOptions(options: [AttachmentModel]) {
        self.attachmentOptions = options
        self.collectionView.reloadData()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // MARK:- UICollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.attachmentOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! AttachmentOptionCell
        cell.model = self.attachmentOptions[indexPath.row]
        cell.onSelfTapped = {[weak self](cell) in
            self?.delegate?.didPressAttachmentOptionCell(attachmentType: cell.model?.type ?? .undefined)
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.attachmentOptions[indexPath.row]
        //self.delegate?.didPressAttachmentOptionCell(attachmentType: model.type ?? .undefined)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.frame.width/3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    @objc private func didPressCancelButton(sender: UIButton) {
        self.delegate?.didPressCancelButton()
    }
}


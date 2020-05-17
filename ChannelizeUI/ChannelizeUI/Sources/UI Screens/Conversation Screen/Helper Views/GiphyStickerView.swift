//
//  GiphyStickerView.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/8/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import InputBarAccessoryView
import Alamofire

protocol GiphyStickerViewDelegate {
    func didPressGiphyStickerViewCloseButton()
    func didSelectMedia(type: GiphType, model: CHGiphImageModel)
}

class GiphyStickerView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barTintColor = CHUIConstants.appDefaultColor
        searchBar.tintColor = CHCustomStyles.searchBarTintColor
        searchBar.setTextFieldBackgroundColor(color: CHCustomStyles.searchBarBackgroundColor)
        searchBar.textField?.tintColor = CHCustomStyles.searchBarTextColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(getImage("chCloseIcon"), for: .normal)
        return button
    }()
    
    private var closeButtonWidthConstraint: NSLayoutConstraint!
    
    private var collectionView: UICollectionView!
    private var models = [CHGiphImageModel]()
    private var isInitialLoadingOn = true
    private var isApiLoadingInProgress = false
    
    var requesterViewType: GiphType = .gif

    var keyBoardManger = KeyboardManager()
    var delegate: GiphyStickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = CHUIConstants.appDefaultColor
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
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.showsHorizontalScrollIndicator = true
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate.normal
        self.collectionView.indicatorStyle = .white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset.top = 0
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "initialCell")
        self.collectionView.register(GiphyMediaCell.self, forCellWithReuseIdentifier: "gifStickerCell")
        self.collectionView.register(CollectionViewLoadingCell.self, forCellWithReuseIdentifier: "loadingCell")
    }
    
    private func setUpViews() {
        self.addSubview(searchBar)
        self.searchBar.delegate = self
        self.addSubview(closeButton)
        self.addSubview(collectionView)
        
        self.closeButton.addTarget(self, action: #selector(didPressCloseButton(sender:)), for: .touchUpInside)
    }
    
    private func setUpViewsFrames() {
        
        self.closeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.closeButtonWidthConstraint = NSLayoutConstraint(item: self.closeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 30)
        self.closeButtonWidthConstraint.isActive = true
        self.addConstraint(closeButtonWidthConstraint)
        //self.closeButton.setViewAsCircle(circleWidth: 30)
        self.closeButton.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -10)
        self.closeButton.setCenterYAnchor(relatedConstraint: self.searchBar.centerYAnchor, constant: 0)
        
        //self.closeButton.setTopAnchor(relatedConstraint: self.topAnchor, constant: 0)
        
        self.searchBar.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 0)
        self.searchBar.setRightAnchor(relatedConstraint: self.closeButton.leftAnchor, constant: -10)
        self.searchBar.setTopAnchor(relatedConstraint: self.topAnchor, constant: 0)
        self.searchBar.setHeightAnchor(constant: 50)
        
        self.collectionView.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 0)
        self.collectionView.setRightAnchor(relatedConstraint: self.rightAnchor, constant: 0)
        self.collectionView.setTopAnchor(relatedConstraint: self.searchBar.bottomAnchor, constant: 0)
        self.collectionView.setBottomAnchor(relatedConstraint: self.bottomAnchor, constant: 0)
    }
    
    // MARK:- CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isInitialLoadingOn == true {
            return 20
        } else {
            return models.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isInitialLoadingOn == true {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "initialCell", for: indexPath)
            cell.backgroundColor = UIColor(hex: "#f0f0f0")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gifStickerCell", for: indexPath) as! GiphyMediaCell
            cell.mediaModel = self.models[indexPath.item]
            cell.backgroundColor = UIColor(hex: "#f0f0f0")
            cell.onTapGiphySticker = {[weak self](model) in
                if let strongSelf = self {
                    strongSelf.delegate?.didSelectMedia(type: strongSelf.requesterViewType, model: model)
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.isInitialLoadingOn == false else {
            return
        }
        let mediaModel = self.models[indexPath.item]
        //self.delegate?.didSelectMedia(type: self.requesterViewType, model: mediaModel)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.frame.width/2 - 5
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.5
    }
    
    func updateCollectionViewBottomInset(with value: CGFloat) {
        self.collectionView.contentInset.bottom = value
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.cancelPreviousRequest()
        self.models.removeAll()
        self.isInitialLoadingOn = true
        self.collectionView.reloadData()
        guard searchText != "" else {
            self.getGiphModels()
            return
        }
        self.performSearchQuery(with: searchText)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.closeButton.alpha = 0.0
            self.closeButtonWidthConstraint.constant = 0
            self.layoutIfNeeded()
        }, completion: {(completed) in
            if completed {
                self.closeButton.isHidden = true
            }
        })
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.closeButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.closeButtonWidthConstraint.constant = 30
            self.closeButton.alpha = 1.0
            self.layoutIfNeeded()
        })
        if searchBar.text == "" {
            self.cancelPreviousRequest()
            self.models.removeAll()
            self.isInitialLoadingOn = true
            self.collectionView.reloadData()
            self.getGiphModels()
        }
    }
    
    @objc private func didPressCloseButton(sender: UIButton) {
        self.searchBar.text = nil
        self.searchBar.endEditing(true)
        self.delegate?.didPressGiphyStickerViewCloseButton()
    }
    
    
    // MARK:- API Functions
    func getGiphModels() {
        CHGiphyApiService.instance.createGiphyStickerGetTrendingRequest(offset: 0, type: self.requesterViewType, completion: {(models,errorString) in
            self.isInitialLoadingOn = false
            self.isApiLoadingInProgress = false
            guard errorString == nil else {
                return
            }
            if let recievedModels = models {
                recievedModels.forEach({
                    self.models.append($0)
                })
            }
            self.collectionView.reloadData()
        })
    }
    
    func performSearchQuery(with text: String) {
        CHGiphyApiService.instance.createGiphyStickerSearchRequest(with: text, offset: 0, type: self.requesterViewType, completion: {(models,errorString) in
            self.isInitialLoadingOn = false
            self.isApiLoadingInProgress = false
            guard errorString == nil else {
                return
            }
            if let recievedModels = models {
                recievedModels.forEach({
                    self.models.append($0)
                })
            }
            self.collectionView.reloadData()
        })
    }
    
    private func cancelPreviousRequest() {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach {
                print("Cancelling -> \($0.originalRequest?.url?.absoluteURL.path ?? "")")
                if ($0.originalRequest?.url?.absoluteURL.path == "/v1/gifs/search")
                {
                    $0.cancel()
                } else if ($0.originalRequest?.url?.absoluteURL.path == "/v1/stickers/search") {
                    $0.cancel()
                }
            }
        }
    }
    
    func clearOnViewClose() {
        self.models.removeAll()
        self.isInitialLoadingOn = true
        self.collectionView.reloadData()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


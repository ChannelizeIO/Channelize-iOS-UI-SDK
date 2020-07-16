//
//  GiphStickerViewController.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/1/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import InputBarAccessoryView
import Alamofire
import UIKit

protocol GiphyStickerSelectorDelegate {
    func didSelectMedia(type: GiphType, model: CHGiphImageModel)
}

class CHGiphStickerViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var keyBoardManager: KeyboardManager?
    var lastSearchedWord: String?
    var lastSearchedGiphQuery: String?
    var lastSearchedStickerQuery: String?
    var delegate: GiphyStickerSelectorDelegate?
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search GIFs and Stickers"
        searchBar.keyboardAppearance = CHAppConstant.themeStyle == .dark ? .dark : .light
        searchBar.textField?.tintColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor.black
        searchBar.textField?.borderStyle = .roundedRect
        searchBar.textField?.layer.borderWidth = 0.0
        searchBar.textField?.font = UIFont(fontStyle: .regular, size: 17.0)
        searchBar.textField?.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor.black
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: UIBarMetrics.default)
        searchBar.setTextFieldBackgroundColor(color: CHAppConstant.themeStyle == .dark ? UIColor(hex: "#2c2c2c") : UIColor(hex: "#e6e6e6"))
        let closeIconImage = getImage("chCloseIcon")?.selfResize(targetSize: CGSize(width: 17.5, height: 17.5))
        searchBar.setImage(closeIconImage?.imageWithColor(tintColor: CHAppConstant.themeStyle == .dark ? UIColor(hex: "#E6E6E6") : UIColor(hex: "#8b8b8b")), for: .clear, state: .normal)
        searchBar.setImage(getImage("chSearchIcon")?.imageWithColor(tintColor: CHAppConstant.themeStyle == .dark ? UIColor(hex: "#E6E6E6") : UIColor(hex: "#8b8b8b")), for: .search, state: .normal)
        searchBar.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        return searchBar
    }()
    
    var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        button.imageView?.tintColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#1c1c1c") //.white
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(getImage("chCloseIcon"), for: .normal)
        return button
    }()
    
    var segmentControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.layer.cornerRadius = 10
        control.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        control.layer.masksToBounds = true
        control.insertSegment(withTitle: "GIFs", at: 0, animated: false)
        control.insertSegment(withTitle: "Stickers", at: 1, animated: false)
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor(hex: "#2c2c2c")
        control.setBackgroundImage(UIImage.imageWithColor(color: CHAppConstant.themeStyle == .dark ? UIColor(hex: "#5c5c5c") : UIColor(hex: "#e6e6e6")), for: .selected, barMetrics: .default)
        control.setBackgroundImage(UIImage.imageWithColor(color: .clear), for: .normal, barMetrics: .default)
        control.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(fontStyle: .medium, size: 15.0)!
            ], for: .selected)
        control.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor.black,
            NSAttributedString.Key.font: UIFont(fontStyle: .medium, size: 15.0)!]
            , for: .normal)
        return control
    }()
    
    var collectionView: UICollectionView!
    private var searchedGiphsModels = [CHGiphImageModel]()
    private var searchedStickerModels = [CHGiphImageModel]()
    
    private var selectedSegment = 0
    
    private var giphsModels = [CHGiphImageModel]()
    private var stickersModels = [CHGiphImageModel]()
    
    private var isInitialLoadingOn = true
    private var isApiLoadingInProgress = false
    var isSearchingModeOn = false
    var requesterViewType: GiphType = .gif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addTopBorder(with: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor, andWidth: 0.5)
        self.view.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.view.layer.shadowColor = CHAppConstant.themeStyle == .dark ? UIColor.white.cgColor : UIColor.black.cgColor
        self.view.layer.shadowRadius = 5
        self.view.layer.shadowOffset = CGSize(width: 0, height: -5)
        //self.view.addTopBorder(with: .white, andWidth: 1.0)
        self.configureCollectionView()
        
        searchBar.frame.size = CGSize(width: self.view.frame.width - 40, height: 50)
        searchBar.frame.origin.x = 5
        searchBar.frame.origin.y = 0
        
        self.closeButton.frame.size = CGSize(width: 35, height: 35)
        self.closeButton.frame.origin.x = self.view.frame.width - 40
        self.closeButton.center.y = self.searchBar.center.y
        
        self.segmentControl.frame.size = CGSize(width: self.view.frame.width-60, height: 32.5)
        self.segmentControl.frame.origin.x = 30
        self.segmentControl.frame.origin.y = getViewEndOriginY(view: self.searchBar) + 7.5
        
        self.collectionView.frame.origin.x = 0
        self.collectionView.frame.origin.y = getViewEndOriginY(view: self.segmentControl) + 7.5
        self.collectionView.frame.size.width = self.view.frame.width
        self.collectionView.frame.size.height = 330 - self.collectionView.frame.origin.y
        
        self.view.addSubview(closeButton)
        self.view.addSubview(searchBar)
        self.view.addSubview(segmentControl)
        self.view.addSubview(collectionView)
        
        self.closeButton.addTarget(self, action: #selector(didPressCloseButton(sender:)), for: .touchUpInside)
        self.segmentControl.addTarget(self, action: #selector(didControlSegmentChanged(sender:)), for: .valueChanged)
        
        searchBar.delegate = self
        self.keyBoardManager = KeyboardManager()
        self.keyBoardManager?.on(event: .willShow, do: {notification in
            UIView.animate(withDuration: notification.timeInterval, animations: {
                self.view.frame.origin.y -= notification.endFrame.height
            })
        })
        self.keyBoardManager?.on(event: .willHide, do: {notification in
            UIView.animate(withDuration: notification.timeInterval, animations: {
                self.view.frame.origin.y += notification.startFrame.height
            })
        })
        CHGifyService.configureGiphy(with: "Hbj9gr7HtEv0QyE2REtUVa24WjvCsGdu")
        self.getInitialGiphModels()
        self.getInitialStickerModels()
        
    }
    
    func getInitialStickerModels() {
        CHGiphyApiService.instance.createGiphyStickerGetTrendingRequest(
            offset: 0, type: .sticker, completion: {(models,errorString) in
            self.isInitialLoadingOn = false
            self.isApiLoadingInProgress = false
            guard errorString == nil else {
                return
            }
            if let recievedModels = models {
                recievedModels.forEach({
                    self.stickersModels.append($0)
                })
                self.searchedStickerModels = self.stickersModels
            }
            self.collectionView.reloadData()
        })
    }
    
    func getInitialGiphModels() {
        CHGiphyApiService.instance.createGiphyStickerGetTrendingRequest(
            offset: 0, type: .gif, completion: {(models,errorString) in
            self.isInitialLoadingOn = false
            self.isApiLoadingInProgress = false
            guard errorString == nil else {
                return
            }
            if let recievedModels = models {
                recievedModels.forEach({
                    self.giphsModels.append($0)
                })
                self.searchedGiphsModels = self.giphsModels
            }
            self.collectionView.reloadData()
        })
    }
    
    private func configureCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.collectionView.showsHorizontalScrollIndicator = true
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate.normal
        self.collectionView.indicatorStyle = CHAppConstant.themeStyle == .dark ? .white : .black//.default
        self.collectionView.delegate = self
        self.collectionView.allowsSelection = true
        self.collectionView.dataSource = self
        self.collectionView.contentInset.top = 0
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "initialCell")
        self.collectionView.register(CHGiphyMediaCell.self, forCellWithReuseIdentifier: "gifStickerCell")
        self.collectionView.register(CHCollectionViewLoadingCell.self, forCellWithReuseIdentifier: "loadingCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.searchBar.sizeToFit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didPressCloseButton(sender: UIButton) {
        
        guard parent != nil else {
            return
        }
        self.view.frame = .zero
        view.removeFromSuperview()
        willMove(toParent: nil)
        removeFromParent()
        
        //self.remove()
    }
    
    @objc func didControlSegmentChanged(sender: UISegmentedControl) {
        self.selectedSegment = sender.selectedSegmentIndex
        if sender.selectedSegmentIndex == 0 {
            self.requesterViewType = .gif
        } else {
            self.requesterViewType = .sticker
        }
        if self.searchBar.text != "" && self.searchBar.text != nil {
            if self.selectedSegment == 0 {
                if self.lastSearchedGiphQuery == searchBar.text {
                    self.collectionView.reloadData()
                } else {
                    self.searchedGiphsModels.removeAll()
                    self.isInitialLoadingOn = true
                    self.collectionView.reloadData()
                    self.performSearchQuery(with: self.searchBar.text ?? "")
                }
            } else {
                if self.lastSearchedStickerQuery == searchBar.text {
                    self.collectionView.reloadData()
                } else {
                    self.searchedStickerModels.removeAll()
                    self.isInitialLoadingOn = true
                    self.collectionView.reloadData()
                    self.performSearchQuery(with: self.searchBar.text ?? "")
                }
            }
        } else {
            self.searchedStickerModels = self.stickersModels
            self.searchedGiphsModels = self.giphsModels
            self.collectionView.reloadData()
        }
    }
    
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        UIView.animate(withDuration: duration, animations: {
            self.view.frame.origin.y -= 300
        })
        
        print(duration) // you got animation's duration safely unwraped as a double
    }
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        UIView.animate(withDuration: duration, animations: {
            self.view.frame.origin.y += 300
        })
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.isSearchingModeOn = true
        UIView.animate(withDuration: 0.33, animations: {
            self.closeButton.frame.size = .zero
            self.closeButton.isHidden = true
            self.searchBar.frame.size.width = self.view.frame.width
            self.searchBar.setShowsCancelButton(true, animated: true)
        })
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.isSearchingModeOn = false
        UIView.animate(withDuration: 0.33, animations: {
            self.closeButton.isHidden = false
            self.closeButton.frame.size = CGSize(width: 35, height: 35)
            self.searchBar.frame.size.width = self.view.frame.width - 40
            self.searchBar.setShowsCancelButton(false, animated: true)
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.cancelPreviousRequest()
        //self.models.removeAll()
        self.isInitialLoadingOn = true
        self.collectionView.reloadData()
        guard searchText != "" else {
            self.isInitialLoadingOn = false
            if self.selectedSegment == 0 {
                self.searchedGiphsModels = self.giphsModels
            } else {
                self.searchedStickerModels = self.stickersModels
            }
            self.collectionView.reloadData()
            return
        }
        self.performSearchQuery(with: searchText)
    }
    
    func performSearchQuery(with text: String) {
        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .right, animated: false)
        CHGiphyApiService.instance.createGiphyStickerSearchRequest(with: text, offset: 0, type: self.requesterViewType, completion: {(models,errorString) in
            self.lastSearchedWord = text
            self.isInitialLoadingOn = false
            self.isApiLoadingInProgress = false
            guard errorString == nil else {
                return
            }
            if let recievedModels = models {
                if self.selectedSegment == 0 {
                    self.lastSearchedGiphQuery = text
                    self.searchedGiphsModels.removeAll()
                    recievedModels.forEach({
                        self.searchedGiphsModels.append($0)
                    })
                } else {
                    self.lastSearchedStickerQuery = text
                    self.searchedStickerModels.removeAll()
                    recievedModels.forEach({
                        self.searchedStickerModels.append($0)
                    })
                }
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
    
    // MARK: - UICollectionView Delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isInitialLoadingOn == true {
            return 20
        } else {
            if self.selectedSegment == 0 {
                return self.searchedGiphsModels.count
            } else {
                return self.searchedStickerModels.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isInitialLoadingOn == true {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "initialCell", for: indexPath)
            cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#4c4c4c") : UIColor(hex: "#e6e6e6")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gifStickerCell", for: indexPath) as! CHGiphyMediaCell
            let model: CHGiphImageModel?
            if self.selectedSegment == 0 {
                model = self.searchedGiphsModels[indexPath.item]
            } else {
                model = self.searchedStickerModels[indexPath.item]
            }
            cell.mediaModel = model
            cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
            cell.onTapGiphySticker = {[weak self](model) in
                
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width/2 - 5
        return CGSize(width: width, height: 115)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.isInitialLoadingOn == false else {
            return
        }
        if self.selectedSegment == 0 {
            let model = self.searchedGiphsModels[indexPath.row]
            self.delegate?.didSelectMedia(type: .gif, model: model)
        } else {
            let model = self.searchedStickerModels[indexPath.row]
            self.delegate?.didSelectMedia(type: .sticker, model: model)
        }
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



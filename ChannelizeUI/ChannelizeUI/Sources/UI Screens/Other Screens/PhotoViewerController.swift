//
//  File.swift
//  Channelize
//
//  Created by Ashish-BigStep on 7/10/19.
//  Copyright © 2019 bigstep. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import AVKit
import AVFoundation
import ChannelizeAPI

class PhotoViewerController: ChannelizeController {
    
    var images = [ChannelizeImages]()
    var initialIndex = 0
    var messagesOffset = 0
    var conversationId : String?
    var isLoadingNewImages = false
    var totalMessageCount : Int?
    
    var photoCollectionView : UICollectionView!
    var miniPhotoCollectionView : UICollectionView!
    
    var currentVisibleIndex : IndexPath? {
        get{
            let visibleCell = self.photoCollectionView.visibleCells
            if visibleCell.count > 0 {
                let indexPath = self.photoCollectionView.indexPath(for: visibleCell[0])
                return indexPath
            }
            return nil
        }
    }
    
    var topView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    var backButton : UIButton = {
        let button = UIButton()
        button.setTitle(CHLocalized(key: "pmBack"), for: UIControl.State())
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: UIControl.State())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        return button
    }()
    
    var photoOwnerLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = .white
        label.text = "Owner Name"
        label.numberOfLines = 1
        return label
    }()
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = ""
        return label
    }()
    
    var bottomPadding : CGFloat = 5
    var bottomMarginForPhotoCollection : CGFloat = 100
    
    public init(imagesArray:[ChannelizeImages],index:Int = 0,offset:Int,chatId:String,messageCount:Int?){
        self.images = imagesArray
        self.initialIndex = index
        self.conversationId = chatId
        self.messagesOffset = offset
        self.totalMessageCount = messageCount
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //disableDarkThemeMode()
        self.view.backgroundColor = .black
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .black
        self.navigationController?.navigationBar.isTranslucent = false
        
        let backButton = UIBarButtonItem(title: CHLocalized(key: "pmBack"), style: .plain, target: self, action: #selector(closePhotoView))
        self.navigationItem.leftBarButtonItem = backButton
        
        if #available(iOS 11.0, *) {
            bottomPadding += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            bottomMarginForPhotoCollection = bottomPadding+100
        } else {
            bottomPadding += topLayoutGuide.length
            bottomMarginForPhotoCollection = bottomPadding+100
        }
        
        self.setUpCollectionView()
        self.setUpTopView()
        self.setUpBottomCollectionView()
        photoCollectionView.setNeedsLayout()
        photoCollectionView.layoutIfNeeded()
        self.scrollToItem(index: self.initialIndex)
        
        let imageObject = self.images[initialIndex]
        if let videoUrl = imageObject.videoUrl{
            if let url = URL(string: videoUrl){
                let videoController = AVPlayerViewController()
                videoController.player = AVPlayer(url: url)
                self.present(videoController, animated: true) {
                    
                    videoController.player?.play()
                }
            }
        }
        //        } else{
        //            self.scrollToItem(index: initialIndex)
        //        }
    }
    
    @objc func allMediaAction(){
        
    }
    
    func setUpCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //self.photoCollectionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.photoCollectionView.backgroundColor = .clear
        self.photoCollectionView.register(PhotoCollectionCell.self, forCellWithReuseIdentifier: "photoCell")
        self.photoCollectionView.delegate = self
        self.photoCollectionView.tag = 100
        self.photoCollectionView.dataSource = self
        self.photoCollectionView.isPagingEnabled = true
        self.view.addSubview(self.photoCollectionView)
        
        self.view.addConstraintsWithFormat(format: "H:|[v0]|",views: photoCollectionView)
        self.view.addConstraintsWithFormat(format: "V:|[v0]-\(bottomMarginForPhotoCollection)-|", views: photoCollectionView)
    }
    
    func setUpTopView(){
        self.topView.frame = CGRect(x: 0, y: 0, width: 1000, height: 64)
        self.topView.addSubview(self.titleLabel)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let leftButtonWidth: CGFloat = 50
        let rightButtonWidth: CGFloat = 50
        let width = view.frame.width - leftButtonWidth - rightButtonWidth
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.topView.bottomAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: width),
            titleLabel.centerXAnchor.constraint(equalTo: self.topView.centerXAnchor)
            ])
        self.navigationItem.titleView = self.topView
        //        self.navigationItem.titleView = titleLabel
    }
    
    func setUpBottomCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.miniPhotoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.miniPhotoCollectionView.backgroundColor = .black
        self.miniPhotoCollectionView.register(MiniPhotoCollectionCell.self, forCellWithReuseIdentifier: "miniPhotoCell")
        self.miniPhotoCollectionView.delegate = self
        self.miniPhotoCollectionView.tag = 101
        self.miniPhotoCollectionView.dataSource = self
        self.view.addSubview(self.miniPhotoCollectionView)
        //self.view.addConstraintsWithFormat("H:|[v0]|", views: miniPhotoCollectionView)
        miniPhotoCollectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        miniPhotoCollectionView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        self.view.addConstraintsWithFormat(format: "V:[v0(100)]-\(bottomPadding)-|", views: miniPhotoCollectionView)
    }
    
    func scrollToItem(index:Int){
        let indexPath = IndexPath(item: index, section: 0)
        if index == 0{
            if let owner = self.images[index].ownerName?.capitalized{
                let photoDate = self.images[index].photoDate ?? Date()
                let currentDate = Date()
                let photoDateString = timeAgoSinceDate(photoDate, currentDate: currentDate, numericDates: true)
                
                let ownerStringAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: UIColor.white]
                let photoDateStringAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0),NSAttributedString.Key.foregroundColor:UIColor.lightGray]
                
                let titleString = NSMutableAttributedString(string: "\(owner)\n", attributes: ownerStringAttributes)
                let subtitleString = NSAttributedString(string: photoDateString, attributes: photoDateStringAttributes)
                
                titleString.append(subtitleString)
                self.titleLabel.attributedText = titleString
            }
        } else{
            self.photoCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.miniPhotoCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closePhotoView(){
        self.dismiss(animated: true, completion: nil)
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

extension PhotoViewerController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 100{
            return self.images.count
        } else{
            return self.images.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("Visible Index Path is \(currentVisibleIndex?.row ?? 0)")
        if collectionView.tag == 100{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionCell
            cell.delegate = self
            cell.imageObject = self.images[indexPath.item]
            
            self.miniPhotoCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            return cell
        } else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "miniPhotoCell", for: indexPath) as! MiniPhotoCollectionCell
            cell.imageObject = self.images[indexPath.item]
            if cell.isSelected{
                cell.setSelectedLayer()
            } else{
                cell.removeSelectedLayer()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 100{
            return CGSize(width: self.view.frame.width, height: self.view.frame.height-bottomMarginForPhotoCollection)
        } else{
            return CGSize(width: 50, height: 80)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == 100{
            return 0
        } else{
            return 5
        }
        //return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //        if collectionView.tag == 100{
        //            self.miniPhotoCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        //            let miniCell = self.miniPhotoCollectionView.cellForItem(at: indexPath) as! MiniPhotoCollectionCell
        //            miniCell.setSelectedLayer()
        //        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.tag == 100{
            self.setSelectedCell()
            //let miniCell = self.miniPhotoCollectionView.cellForItem(at: indexPath) as! MiniPhotoCollectionCell
            //miniCell.removeSelectedLayer()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 101{
            self.photoCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        } else if collectionView.tag == 100{
            let imageObject = self.images[indexPath.item]
            if let videoUrl = imageObject.videoUrl{
                let url = URL(string: videoUrl)
                let videoController = AVPlayerViewController()
                videoController.player = AVPlayer(url: url!)
                self.present(videoController, animated: true) {
                    videoController.player?.play()
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: self.photoCollectionView.contentOffset, size: self.photoCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = self.photoCollectionView.indexPathForItem(at: visiblePoint){
            if visibleIndexPath.item != self.images.count{
                if let owner = self.images[visibleIndexPath.item].ownerName?.capitalized{
                    let photoDate = self.images[visibleIndexPath.item].photoDate ?? Date()
                    let currentDate = Date()
                    let photoDateString = timeAgoSinceDate(photoDate, currentDate: currentDate, numericDates: true)
                    
                    let ownerStringAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: UIColor.white]
                    let photoDateStringAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0),NSAttributedString.Key.foregroundColor:UIColor.lightGray]
                    
                    let titleString = NSMutableAttributedString(string: "\(owner)\n", attributes: ownerStringAttributes)
                    let subtitleString = NSAttributedString(string: photoDateString, attributes: photoDateStringAttributes)
                    
                    titleString.append(subtitleString)
                    self.titleLabel.attributedText = titleString
                }
            }
        }
    }
}

extension PhotoViewerController{
    func setSelectedCell(){
        for cell in self.miniPhotoCollectionView.visibleCells{
            if let miniCell = cell as? MiniPhotoCollectionCell{
                miniCell.isSelected = false
            }
        }
        let visibleCells = self.photoCollectionView.visibleCells
        if let firstCell = visibleCells.first{
            if let indexPath = self.photoCollectionView.indexPath(for: firstCell){
                if let miniCell = self.miniPhotoCollectionView.cellForItem(at: indexPath) as? MiniPhotoCollectionCell{
                    miniCell.isSelected = true
                    self.miniPhotoCollectionView.reloadItems(at: [indexPath])
                    //miniCell.setSelectedLayer()
                }
            }
        }
    }
}

extension PhotoViewerController: MediaCellTapped{
    func didCellTapped(url: URL) {
        let videoController = AVPlayerViewController()
        videoController.player = AVPlayer(url: url)
        self.present(videoController, animated: true) {
            videoController.player?.play()
        }
    }
}




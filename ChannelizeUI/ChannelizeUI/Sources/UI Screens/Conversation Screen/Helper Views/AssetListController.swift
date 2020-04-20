//
//  AssetPickerController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/1/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit
import Photos

public protocol AssetListControllerDelegate{
    func accessAssetImages(assetImages:[UIImage])
    func accessSelectedAssets(assets:[PHAsset])
}

class AssetListController: UICollectionViewController {
    
    var collection : PHAssetCollection?
    private let allPhotosOptions = PHFetchOptions()
    private var currentCollectionAssets = PHFetchResult<PHAsset>()
    fileprivate let imageManager = PHCachingImageManager()
    private var manager = PHImageManager.default()
    private var size : CGSize!
    private var width : CGFloat!
    private let scale = UIScreen.main.scale
    private var isAssetLoaded = false
    private let serialQueue = DispatchQueue(label: "com.channelize.demo.processQueue")
    private let option = PHImageRequestOptions()
    private var imageCache2 : NSCache<NSString,UIImage>? = NSCache<NSString,UIImage>()
    var delegate : AssetListControllerDelegate?
    var appDefaultColor = UIColor(hex: "#E76DDC")
    var isAnyCallOngoing = false
    var isMaximumAssetsSelected = false
    private var selectedAssets = [PHAsset](){
        didSet{
            if self.selectedAssets.count > 0{
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else{
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
            
            if self.selectedAssets.count == 10{
                self.isMaximumAssetsSelected = true
            } else{
                self.isMaximumAssetsSelected = false
            }
        }
    }
    
    private var cameraButton : UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 30
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = CHUIConstants.appDefaultColor
        button.imageEdgeInsets = UIEdgeInsets(top: 12.5, left: 12.5, bottom: 12.5, right: 12.7)
        button.setImage(getImage("chCameraIcon"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.collectionView.backgroundColor = .black
        self.collectionView.allowsSelection = true
        self.collectionView.allowsMultipleSelection = true
        
        self.collectionView.decelerationRate = .normal
        self.collectionView.prefetchDataSource = self
        
        width = (view.frame.width/3)-2.5
        imageCache2?.totalCostLimit = 30 * 1024 * 1024
        size = CGSize(width: width, height: width)
        option.isSynchronous = false
        option.isNetworkAccessAllowed = true
        let rightButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(processPhoto))
        navigationItem.rightBarButtonItem = rightButton
        collectionView!.register(CollectionPhotoListCell.self, forCellWithReuseIdentifier: "photoCell")
        
        
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraButton)
        cameraButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        cameraButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        cameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        cameraButton.addTarget(self, action: #selector(openCamera(sender:)), for: .touchUpInside)
        
        PHPhotoLibrary.shared().register(self)
        self.checkPhotoLibraryAuthorization()
        //getAllAssetsOfCollection()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func checkPhotoLibraryAuthorization(){
        let photoAuthorization = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorization {
        case .authorized:
            DispatchQueue.main.async {[weak self] in
                self?.getAllAssetsOfCollection()
            }
            break
        case .denied:
            self.showLocationAlertView()
            break
        case .restricted:
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({[weak self](status) in
                if status == .authorized{
                    DispatchQueue.main.async {[weak self] in
                        self?.getAllAssetsOfCollection()
                    }
                } else if status == .denied{
                    self?.showLocationAlertView()
                }
            })
            break
        }
    }
    
    func showLocationAlertView() {
        let alertController = UIAlertController(title: "Error", message: "To send Photo Message, allow Photos Access. Please go to Settings and turn on Permissions", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: {(alerAction) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .destructive, handler: {(alertAction) -> Void in
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
//        if let popoverController = alertController.popoverPresentationController {
//            showIpadActionSheet(sourceView: self.view, popoverController: popoverController)
//        }
        self.present(alertController,animated: true,completion: nil)
    }
    
    @objc func openCamera(sender:UIButton){
        
        if isAnyCallOngoing {
            let alert = UIAlertController(title: nil, message: "Camera Error", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert,animated: true,completion: nil)
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.takePicture()
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func processPhoto(){
        DispatchQueue.global().async {[weak self] in
            self?.delegate?.accessSelectedAssets(assets: self?.selectedAssets ?? [])
        }
        navigationController?.popViewController(animated: true)
    }
    
    func getAllAssetsOfCollection(){
        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d",PHAssetMediaType.image.rawValue)
        allPhotosOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        let results = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        
        currentCollectionAssets = results
        isAssetLoaded = true
        collectionView.reloadData()
    }
    
    func downsampleWithData(imageData : Data,to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
            return nil
        }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        return UIImage(cgImage: downsampledImage, scale: scale, orientation: .up)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return isAssetLoaded ? currentCollectionAssets.count : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionPhotoListCell
        let asset = currentCollectionAssets[indexPath.item]
        cell.cellAsset = asset
        let identifier = NSString(string: asset.localIdentifier)
        cell.photoIdentifier = asset.localIdentifier
        cell.cellImageView.image = nil
        // Configure the cell
        
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.borderWidth = 0.0
        
        if cell.requestId != 0 {
            if cell.requestId != nil{
                imageManager.cancelImageRequest(PHImageRequestID(cell.requestId))
            }
        }
        
        if let image = imageCache2?.object(forKey: identifier){
            DispatchQueue.main.async {
                UIView.transition(with: cell.cellImageView,duration: 0.01,options: [.curveEaseOut, .transitionCrossDissolve],animations: {
                    cell.cellImageView.image = image
                }
                )}
        } else{
            print("Fetching Asset for IndexPath \(indexPath.item)")
            let targetSize = CGSize(width: size.width*scale, height: size.height*scale)
            cell.requestId = Int(imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: self.option, resultHandler: {[weak self](image,info) in
                if let fetchedImage = image{
                    self?.imageCache2?.setObject(fetchedImage, forKey: identifier)
                    if cell.photoIdentifier == asset.localIdentifier{
                        cell.cellImageView.image = image
                    }
                }
            }))
        }
        
        if cell.isSelected{
            if let itemIndex = getSelectedIndex(for: indexPath){
                cell.selectedLabel.isHidden = false
                cell.selectedView.isHidden = false
                cell.selectedLabel.text = String(itemIndex)
                cell.layer.borderColor = CHUIConstants.appDefaultColor.cgColor
                cell.layer.borderWidth = 5.0
            }
        } else{
            cell.selectedView.isHidden = true
            cell.selectedLabel.isHidden = true
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("Did End displaying cell at indexpath \(indexPath.item)")
        if let photoLibraryCell = cell as? CollectionPhotoListCell
        {
            if let imageRequestID = photoLibraryCell.requestId{
                print(imageRequestID)
                print("Cancelling Image Request for Indexpath \(indexPath.item)")
                imageManager.cancelImageRequest(PHImageRequestID(imageRequestID))
            }
        }
    }
    
    func reloadAfterCompletion(withName:String?){
        if let operationName = withName{
            self.currentCollectionAssets.enumerateObjects({(asset,index,stop) in
                if asset.localIdentifier == operationName{
                    let indexPath = IndexPath(item: index, section: 0)
                    self.collectionView.reloadItems(at: [indexPath])
                    //print("Block Completed at index \(index)")
                }
            })
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isMaximumAssetsSelected == false else{
            let alert = UIAlertController(title: nil, message: "Maximum Image Selected", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert,animated: true,completion: nil)
            if let cell = collectionView.cellForItem(at: indexPath) as? CollectionPhotoListCell{
                cell.isSelected = false
            }
            return
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionPhotoListCell{
            cell.isSelected = true
            if let cellAsset = cell.cellAsset{
                let imageManager = PHImageManager.default()
                let fetchOption = PHImageRequestOptions()
                fetchOption.isSynchronous = false
                fetchOption.isNetworkAccessAllowed = true
                fetchOption.progressHandler = {(progress,error,stop,info) in
                    print(stop)
                    DispatchQueue.main.async {
                        if progress == 1.0{
                            cell.progressView.isHidden = true
                            cell.selectedView.isHidden = false
                            cell.selectedImageView.isHidden = false
                        } else{
                            cell.selectedView.isHidden = true
                            cell.selectedImageView.isHidden = true
                            cell.progressView.isHidden = false
                            cell.progressView.setProgress(to: progress, withAnimation: true)
                        }
                        
                    }
                    print(progress)
                }
                selectedAssets.append(cellAsset)
                cell.selectedLabel.isHidden = false
                cell.layer.borderColor = CHUIConstants.appDefaultColor.cgColor
                cell.layer.borderWidth = 5.0
                setIndexForSelectedItems()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if isMaximumAssetsSelected == false{
            return true
        } else{
            let alert = UIAlertController(title: nil, message: "Maximum Image Selected!!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert,animated: true,completion: nil)
            return false
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionPhotoListCell{
            cell.isSelected = false
            cell.selectedView.isHidden = true
            cell.selectedImageView.isHidden = true
            cell.selectedLabel.isHidden = true
            cell.selectedLabel.text = nil
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0.0
            if let cellAsset = cell.cellAsset{
                selectedAssets = selectedAssets.filter({
                    $0.localIdentifier != cellAsset.localIdentifier
                })
                setIndexForSelectedItems()
            }
        }
    }
    
    
    func getSelectedIndex(for indexPath: IndexPath)->Int?{
        let enumeration = selectedAssets.enumerated()
        for (index,element) in enumeration{
            let asset = currentCollectionAssets[indexPath.item]
            if asset == element{
                return index+1
            }
        }
        return nil
    }
    
    func setIndexForSelectedItems(){
        let enumeration = selectedAssets.enumerated()
        for (index,element) in enumeration{
            let cellIndex = currentCollectionAssets.index(of: element)
            let indexPath = IndexPath(item: cellIndex, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? CollectionPhotoListCell{
                cell.layer.borderColor = CHUIConstants.appDefaultColor.cgColor
                cell.layer.borderWidth = 5.0
                cell.selectedLabel.isHidden = false
                cell.selectedView.isHidden = false
                cell.selectedLabel.text = String(index+1)
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageCache2?.removeAllObjects()
        imageCache2 = nil
    }
    
    deinit {
        collectionView?.delegate = nil
        collectionView?.dataSource = nil
    }
    
    // MARK: UICollectionViewDelegate
    
}

extension AssetListController : UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            let asset = self.currentCollectionAssets[indexPath.item]
            let identifier = NSString(string: asset.localIdentifier)
            if imageCache2?.object(forKey: identifier) == nil{
                let targetSize = CGSize(width: size.width*scale, height: size.height*scale)
                self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .default, options: self.option, resultHandler: {[weak self](image,info) in
                    if let fetchedImage = image{
                        self?.imageCache2?.setObject(fetchedImage, forKey: identifier)
                    }
                })
            }
        }
    }
}

extension AssetListController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let width = (self.view.frame.width/3)-2.5
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

extension AssetListController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.delegate?.accessAssetImages(assetImages: [image])
        }
        dismiss(animated: false, completion: {[weak self] in
            self?.navigationController?.popViewController(animated: false)
        })
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension AssetListController : PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        let _fetchResult = currentCollectionAssets
        if let _ = changeInstance.changeDetails(for: _fetchResult){
            DispatchQueue.main.async {[weak self] in
                self?.getAllAssetsOfCollection()
            }
        }
    }
}



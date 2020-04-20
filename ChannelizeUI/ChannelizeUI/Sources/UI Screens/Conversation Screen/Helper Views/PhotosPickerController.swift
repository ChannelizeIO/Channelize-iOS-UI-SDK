//
//  PhotosPickerController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 4/1/20.
//  Copyright © 2020 Channelize. All rights reserved.
//
/*
import UIKit
import Photos
import SDWebImagePhotosPlugin

private let reuseIdentifier = "Cell"

class PhotosListCollectionCell: UICollectionViewCell {
    
    //let loader = SDWebImageManager(cache: SDImageCache.shared, loader: SDImagePhotosLoader.shared)
    
    var photoOptions = PHImageRequestOptions()
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 0
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        photoOptions.sd_targetSize = CGSize(width: 200, height: 200)
        photoOptions.isNetworkAccessAllowed = true
        photoOptions.deliveryMode = .highQualityFormat
        photoOptions.isSynchronous = true
        photoOptions.version = .original
        self.addSubview(imageView)
        self.imageView.pinEdgeToSuperView(superView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignUrl(url: NSURL, with loader: SDWebImageManager) {
        
        imageView.sd_setImage(with: url as URL, placeholderImage: nil, options: [], context: [.photosImageRequestOptions: photoOptions, .customManager: loader], progress: nil, completed: {(image,error,cache,url) in
            if let _image = image {
                print("===================")
                print(_image.size)
                print(_image.jpegData(compressionQuality: 1.0)?.count ?? 0)
                print("++++++++++++++++++++")
            }
        })
        
//        imageView.sd_setImage(with: url as URL, placeholderImage: nil, options: [], context: [.imageLoader: loader.imageLoader, .storeCacheType: SDImageCacheType.none], progress: nil, completed: {(image,error,cache,url) in
//            if let _image = image {
//                print("===================")
//                print(_image.size)
//                print(_image.jpegData(compressionQuality: 1.0)?.count ?? 0)
//                print("++++++++++++++++++++")
//            }
//        })
        
        //self.imageView.sd_setImage(with: url as URL, completed: nil)
    }
    
}

class PhotosPickerController: UICollectionViewController, PHPhotoLibraryChangeObserver, UICollectionViewDelegateFlowLayout {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
    

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
    var appDefaultColor = UIColor(hex: "#E76DDC")
    var isAnyCallOngoing = false
    var isMaximumAssetsSelected = false
    
    var loader: SDWebImageManager!
    
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
    
    var photosUrls = [NSURL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        width = (view.frame.width/3)-2.5
        
        let options = PHImageRequestOptions()
        //options.version = .original
        //options.deliveryMode = .highQualityFormat
        //options.sd_targetSize = PHImageManagerMaximumSize
        options.sd_targetSize = CGSize(width: 350, height: 350)
        //options.sd_targetSize = PHImageManagerMaximumSize
        SDImagePhotosLoader.shared.imageRequestOptions = options
        SDImagePhotosLoader.shared.requestImageAssetOnly = true
        
        loader = SDWebImageManager(cache: SDImageCache.shared, loader: SDImagePhotosLoader.shared)
        self.view.backgroundColor = .black
        self.collectionView.backgroundColor = .black
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.decelerationRate = .normal
        
        PHPhotoLibrary.shared().register(self)
        self.checkPhotoLibraryAuthorization()
        //self.collectionView.prefetchDataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(PhotosListCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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
            self.showPhotoAccessAlertView()
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
                    self?.showPhotoAccessAlertView()
                }
            })
            break
        }
    }
    
    func showPhotoAccessAlertView() {
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
        self.present(alertController,animated: true,completion: nil)
    }
        
    func getAllAssetsOfCollection(){
        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d",PHAssetMediaType.image.rawValue)
        allPhotosOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        let results = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        
        currentCollectionAssets = results
        isAssetLoaded = true
        for i in 0 ..< currentCollectionAssets.count {
            let asset = currentCollectionAssets.object(at: i)
            if let url = NSURL.sd_URL(with: asset) {
                self.photosUrls.append(url)
            }
        }
        collectionView.reloadData()
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
        return self.photosUrls.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotosListCollectionCell
        cell.assignUrl(url: self.photosUrls[indexPath.item], with: self.loader)
        //cell.backgroundColor = .red
        // Configure the cell
    
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
         return CGSize(width: width, height: width)
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
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
*/

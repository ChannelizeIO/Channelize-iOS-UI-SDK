//
//  PhotoCollectionCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/27/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

protocol MediaCellTapped {
    func didCellTapped(item: ChannelizeImages)
}

class PhotoCollectionCell:UICollectionViewCell, UIScrollViewDelegate{
    
    var doubleTapGestureRecognizer : UITapGestureRecognizer?
    var singleTapGestureRecognizer : UITapGestureRecognizer?
    var delegate : MediaCellTapped?
    
    var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset = .zero
        scrollView.contentSize = .zero
        return scrollView
    }()
    
    var photoImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        return imageView
    }()
    
    var videoPlayIconView : UIImageView = {
        let imageView = UIImageView(image: getImage("chPlayButton"))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.white
        imageView.tintColor = CHAppConstant.lightThemeTintColor
        imageView.isHidden = true
        return imageView
    }()
    
    var imageObject : ChannelizeImages? {
        didSet{
            self.assignData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    
    func setUpView(){
        self.addSubview(scrollView)
        self.scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        scrollView.contentSize = self.frame.size
        //scrollView.contentOffset = .zero
        
        self.scrollView.addSubview(photoImageView)
        photoImageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5.0
        
        videoPlayIconView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        videoPlayIconView.center = self.contentView.center
        self.scrollView.addSubview(videoPlayIconView)
        
    }
    
    @objc func handleDoubleTap(gesture:UITapGestureRecognizer){
        
        if self.scrollView.zoomScale == 1 {
            self.scrollView.zoom(to: zoomRectForScale(self.scrollView.maximumZoomScale, center: gesture.location(in: gesture.view)), animated: true)
        } else {
            self.scrollView.setZoomScale(1, animated: true)
        }
    }
    
    @objc func handleSingleTap(gesture:UITapGestureRecognizer){
        guard let videoItem = self.imageObject else {
            return
        }
        self.delegate?.didCellTapped(item: videoItem)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoImageView
    }
    
    func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = self.photoImageView.frame.size.height/scale
        zoomRect.size.width = self.photoImageView.frame.size.width/scale
        let newCenter = convert(center, from: self.photoImageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width/2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height/2.0)
        return zoomRect
    }
    
    func assignData() {
        if let object = imageObject{
            
            if let image = SDImageCache.shared.imageFromCache(forKey: object.messageId) {
                self.photoImageView.image = image
            } else {
                self.photoImageView.sd_imageTransition = .fade
                self.photoImageView.sd_imageIndicator = CHAppConstant.themeStyle == .dark ? SDWebImageActivityIndicator.white : SDWebImageActivityIndicator.gray
                if let imageUrlString = object.imageUrl{
                    if let imageUrl = URL(string: imageUrlString){
                        self.photoImageView.sd_setImage(with: imageUrl, completed: nil)
                    }
                }
                if object.videoUrl != nil{
                    self.videoPlayIconView.isHidden = false
                    self.singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(gesture:)))
                    self.singleTapGestureRecognizer?.numberOfTapsRequired = 1
                    self.scrollView.addGestureRecognizer(self.singleTapGestureRecognizer!)
                } else{
                    self.videoPlayIconView.isHidden = true
                    self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(gesture:)))
                    self.doubleTapGestureRecognizer?.numberOfTapsRequired = 2
                    self.scrollView.addGestureRecognizer(self.doubleTapGestureRecognizer!)
                }
            }
            //self.videoPlayIconView.image = UIImage(named: "ic_play_circle")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




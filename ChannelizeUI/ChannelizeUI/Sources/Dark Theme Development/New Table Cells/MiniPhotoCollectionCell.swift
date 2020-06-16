import Foundation
import UIKit
import SDWebImage

class MiniPhotoCollectionCell : UICollectionViewCell{
    
    var photoImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .black
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
        self.addSubview(photoImageView)
        self.addConstraintsWithFormat(format: "H:|[v0]|", views: photoImageView)
        self.addConstraintsWithFormat(format: "V:|[v0]|", views: photoImageView)
    }
    
    func assignData() {
        if let object = imageObject{
            self.photoImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.photoImageView.sd_imageTransition = .fade
            if let imageUrlString = object.imageUrl{
                if let imageUrl = URL(string: imageUrlString){
                    self.photoImageView.sd_setImage(with: imageUrl, completed: nil)
                }
                
            }
        }
    }
    
    func setSelectedLayer(){
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.blue.cgColor
    }
    
    func removeSelectedLayer(){
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



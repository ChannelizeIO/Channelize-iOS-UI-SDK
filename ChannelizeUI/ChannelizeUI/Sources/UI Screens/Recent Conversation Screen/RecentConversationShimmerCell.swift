import Foundation
import UIKit
class RecentConversationShimmerCell: UITableViewCell {
    
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.lightGray
        return imageView
    }()
    
    private var titleView: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()
    
    private var messageView: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()
    
    private var timeView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        return label
    }()
    
    private var statusView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .white// CHConstants.recentScreencellBackGroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        self.addSubview(profileImageView)
        self.addSubview(titleView)
        self.addSubview(messageView)
        self.addSubview(timeView)
        self.addSubview(statusView)
    }
    
    private func getViewOriginXEnd(view: UIView) -> CGFloat {
        return view.frame.width + view.frame.origin.x
    }
    
    private func getViewOriginYEnd(view: UIView) -> CGFloat {
        return view.frame.height + view.frame.origin.y
    }
    
    func setUpViewsFrames() {
        
        self.profileImageView.frame.size = CGSize(width: getDeviceWiseAspectedWidth(constant: 50), height: getDeviceWiseAspectedWidth(constant: 50))
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.frame.origin.x = getDeviceWiseAspectedWidth(constant: 12.5)
        self.profileImageView.center.y = self.frame.height/2
        
        
        self.titleView.frame.size = CGSize(width: getDeviceWiseAspectedWidth(constant: 190), height: getDeviceWiseAspectedHeight(constant: 22.5))
        self.titleView.frame.origin.x = getViewOriginXEnd(view: self.profileImageView) + getDeviceWiseAspectedWidth(constant: 12.5)
        self.titleView.frame.origin.y = self.profileImageView.frame.origin.y + getDeviceWiseAspectedHeight(constant: 2.5)
        
        self.messageView.frame.size = CGSize(width: getDeviceWiseAspectedWidth(constant: 210), height: getDeviceWiseAspectedHeight(constant: 17.5))
        self.messageView.frame.origin.x = getViewOriginXEnd(view: self.profileImageView) + getDeviceWiseAspectedWidth(constant: 12.5)
        self.messageView.frame.origin.y = self.getViewOriginYEnd(view: self.titleView) + getDeviceWiseAspectedHeight(constant: 5)
        
        self.timeView.frame.size = CGSize(width: getDeviceWiseAspectedWidth(constant: 50), height: getDeviceWiseAspectedHeight(constant: 17.5))
        self.timeView.frame.origin.y = self.titleView.frame.origin.y
        self.timeView.frame.origin.x = self.frame.width - getDeviceWiseAspectedWidth(constant: 65.5)
        
        self.statusView.frame.size = CGSize(width: getDeviceWiseAspectedWidth(constant: 30), height: getDeviceWiseAspectedWidth(constant: 16))
        self.statusView.center.y = self.messageView.center.y
        self.statusView.frame.origin.x = self.frame.width - getDeviceWiseAspectedWidth(constant: 45.5)
        
        self.separatorInset.left = getDeviceWiseAspectedWidth(constant: 75)
    }
    
    func startShimmering() {
        ABLoader().startShining(profileImageView)
        ABLoader().startShining(titleView)
        ABLoader().startShining(messageView)
        ABLoader().startShining(timeView)
        ABLoader().startShining(statusView)
    }
    
    private func stopShimmering() {
        for subView in self.subviews {
            ABLoader().stopShining(subView)
        }
    }
}


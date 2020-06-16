//
//  CHUserSettingsTableCell.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI

class CHUserSettingsTableCell: UITableViewCell {

    var mainLabel: UILabel = {
        let label = UILabel()
        label.font = CHCustomStyles.normalSizeRegularFont
        label.backgroundColor = .clear
        return label
    }()
    
    var secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = CHCustomStyles.normalSizeRegularFont
        label.backgroundColor = .clear
        return label
    }()
    
    var discloseIndicatorView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.image = getImage("chRightArrowIcon")
        return imageView
    }()
    
    var cellAccessoryView: UIView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func assignData(mainText: String?, secondaryText: String?, showDiscloseIndicator: Bool, cellExtraView: UIView?) {
        
        self.addSubview(self.discloseIndicatorView)
        if showDiscloseIndicator {
            self.discloseIndicatorView.frame.size = CGSize(width: 25, height: 25)
        } else {
            self.discloseIndicatorView.frame.size = .zero
        }
        self.discloseIndicatorView.frame.origin.x = self.frame.width - self.discloseIndicatorView.frame.width - 5
        self.discloseIndicatorView.center.y = self.frame.height/2
        
        if cellExtraView != nil {
            self.cellAccessoryView = cellExtraView!
            self.addSubview(cellAccessoryView!)
            cellAccessoryView?.sizeToFit()
            cellAccessoryView?.frame.origin.x = self.discloseIndicatorView.frame.origin.x - cellAccessoryView!.frame.width - 2.5
            cellAccessoryView?.center.y = self.frame.height/2
        } else {
            self.cellAccessoryView = UIView()
            self.addSubview(self.cellAccessoryView!)
            self.cellAccessoryView?.frame.size = .zero
            self.cellAccessoryView?.frame.origin.x = self.discloseIndicatorView.frame.origin.x
            self.cellAccessoryView?.center.y = self.frame.height/2
        }
        
        self.addSubview(secondaryLabel)
        self.secondaryLabel.text = secondaryText
        let secondaryLabelWidth = secondaryText?.width(withConstrainedHeight: self.frame.height, font: self.secondaryLabel.font)
        self.secondaryLabel.frame.size = CGSize(width: secondaryLabelWidth ?? 0, height: self.frame.height)
        self.secondaryLabel.frame.origin.x = (self.cellAccessoryView?.frame.origin.x ?? 0) - self.secondaryLabel.frame.width - 2.5
        self.secondaryLabel.center.y = self.frame.height/2
        
        self.addSubview(mainLabel)
        self.mainLabel.text = mainText
        self.mainLabel.frame.origin.x = 15
        self.mainLabel.frame.size.height = self.frame.height
        self.mainLabel.frame.size.width = self.secondaryLabel.frame.origin.x - 5 - self.mainLabel.frame.origin.x
        self.mainLabel.center.y = self.frame.height/2
        
        self.mainLabel.textColor = CHUIConstant.settingsScreenMainLabelColor
        self.secondaryLabel.textColor = CHUIConstant.settingsScreenSecondaryLabelColor
        self.discloseIndicatorView.tintColor = CHUIConstant.settingsSceenDiscloseIndicatorColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  CreateGroupHeaderViewCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/2/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import UIKit
import ChannelizeAPI

class CreateGroupHeaderViewCell: UITableViewCell, UITextFieldDelegate {
    
    private var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#4c4c4c") : UIColor(hex: "#eaeaea")
        imageView.isUserInteractionEnabled = false
        imageView.layer.borderColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor.cgColor : CHLightThemeColors.seperatorColor.cgColor
        imageView.layer.borderWidth = 1.0
        return imageView
    }()
    
    private var selecteImageButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        //button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.imageView?.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        button.setImage(getImage("chCameraIcon"), for: .normal)
        return button
    }()
    
    private var groupTitleTextField: UITextField = {
        let textField = UITextField()
        textField.addBottomBorder(with: CHAppConstant.themeStyle == .dark ? UIColor(hex: "#E6E6E6") : UIColor.lightGray, andWidth: 1.0)
        textField.backgroundColor = .clear
        textField.keyboardAppearance = CHAppConstant.themeStyle == .dark ? .dark : .light
        let placeHolderAttributes: [NSAttributedString.Key:Any] = [
            NSAttributedString.Key.font: UIFont(fontStyle: .regular, size: 17.0)!,
            NSAttributedString.Key.foregroundColor: CHAppConstant.themeStyle == .dark ? UIColor(hex: "#E6E6E6") : UIColor.lightGray
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Group Title", attributes: placeHolderAttributes)
        textField.tintColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#4a505a")
        textField.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#4a505a")
        textField.autocorrectionType = .no
        textField.font = UIFont(fontStyle: .regular, size: 17.0)
        return textField
    }()
    
    var onEditPhotoButtonPressed: (() -> Void)?
    var onPickUpPhotoButtonPressed: (() -> Void)?
    var onGroupTitleUpdated: ((_ newTitle: String?) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews() {
        self.addSubview(selectedImageView)
        self.addSubview(selecteImageButton)
        self.addSubview(groupTitleTextField)
        self.groupTitleTextField.delegate = self
        self.selecteImageButton.addTarget(self, action: #selector(editPhotoButtonPressed(sender:)), for: .touchUpInside)
    }
    
    func setUpViewsFrames() {
        
        self.selectedImageView.frame.size = CGSize(width: 80, height: 80)
        self.selectedImageView.frame.origin.x = 10
        self.selectedImageView.center.y = self.frame.height/2
        self.selectedImageView.setViewCircular()
        
        self.selecteImageButton.frame.size = CGSize(width: 80, height: 80)
        self.selecteImageButton.frame.origin.x = 10
        self.selecteImageButton.center.y = self.frame.height/2
        self.selecteImageButton.setViewCircular()
        
        self.groupTitleTextField.frame.size.height = 40
        self.groupTitleTextField.frame.size.width = self.frame.width - getViewEndOriginX(view: self.selectedImageView) - 20
        self.groupTitleTextField.frame.origin.x = getViewEndOriginX(view: self.selectedImageView) + 10
        self.groupTitleTextField.center.y = self.frame.height/2
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.onGroupTitleUpdated?(textField.text)
    }
    
    @objc private func editPhotoButtonPressed(sender: UIButton) {
        if self.selectedImageView.image == nil {
            self.onPickUpPhotoButtonPressed?()
        } else {
            self.onEditPhotoButtonPressed?()
        }
    }
    
    
    func setNewImage(image: UIImage?) {
        if image == nil {
            self.selectedImageView.backgroundColor = UIColor.clear
        } else {
            self.selectedImageView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
        self.selectedImageView.image = image
    }
}



//
//  CreateGroupHeaderCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/2/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit

protocol CreateGroupHeaderCellDelegate {
    func didChangeGroupTitle(newText: String?)
    func didPressImageButton()
    func didPressImageOptionButton()
}

class CreateGroupHeaderCell: UITableViewCell, UITextFieldDelegate {

    private var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor(hex: "#eaeaea")
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var selecteImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.clear
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 35, left: 35, bottom: 35, right: 35)
        button.setImage(getImage("chCameraIcon"), for: .normal)
        return button
    }()
    
    private var groupTitleTextField: UITextField = {
        let textField = UITextField()
        textField.addBottomBorder(with: .lightGray, andWidth: 1.0)
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        let placeHolderAttributes: [NSAttributedString.Key:Any] = [
            NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: 18.0)!,
            NSAttributedString.Key.foregroundColor: UIColor.lightGray
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Group Title", attributes: placeHolderAttributes)
        textField.tintColor = CHUIConstants.contactNameColor
        textField.textColor = CHUIConstants.contactNameColor
        textField.autocorrectionType = .no
        textField.font = UIFont(fontStyle: .robotoSlabRegualar, size: 18.0)
        return textField
    }()
    
    private var groupDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        label.textColor = CHUIConstants.conversationMessageColor
        label.text = "Please provide a group title and optional group icon."
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    var delegate: CreateGroupHeaderCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        self.setUpViews()
        self.setUpViewsFrames()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.contentView.addSubview(selectedImageView)
        self.contentView.addSubview(selecteImageButton)
        self.contentView.addSubview(groupTitleTextField)
        self.contentView.addSubview(groupDescriptionLabel)
        self.selecteImageButton.addTarget(self, action: #selector(didPressChangeImageButton(sender:)), for: .touchUpInside)
        self.groupTitleTextField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    }
    
    private func setUpViewsFrames() {
        
        self.selectedImageView.setViewAsCircle(circleWidth: 100)
        self.selectedImageView.setLeftAnchor(relatedConstraint: self.contentView.leftAnchor, constant: 10)
        self.selectedImageView.setCenterYAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        
        self.selecteImageButton.setViewAsCircle(circleWidth: 100)
        self.selecteImageButton.setLeftAnchor(relatedConstraint: self.contentView.leftAnchor, constant: 10)
        self.selecteImageButton.setCenterYAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: 0)
        
        self.groupTitleTextField.setCenterYAnchor(relatedConstraint: self.contentView.centerYAnchor, constant: -5)
        self.groupTitleTextField.setLeftAnchor(relatedConstraint: self.selecteImageButton.rightAnchor, constant: 15)
        self.groupTitleTextField.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -10)
        self.groupTitleTextField.setHeightAnchor(constant: 40)
        
        self.groupDescriptionLabel.setLeftAnchor(relatedConstraint: self.selecteImageButton.rightAnchor, constant: 15)
        self.groupDescriptionLabel.setTopAnchor(relatedConstraint: self.groupTitleTextField.bottomAnchor, constant: 2.5)
        self.groupDescriptionLabel.setRightAnchor(relatedConstraint: self.contentView.rightAnchor, constant: -10)
        self.groupDescriptionLabel.setHeightAnchor(constant: 45)
    }
    
    @objc private func didPressChangeImageButton(sender: UIButton) {
        if self.selectedImageView.image == nil {
            self.delegate?.didPressImageButton()
        } else {
            self.delegate?.didPressImageOptionButton()
        }
        
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        self.delegate?.didChangeGroupTitle(newText: textField.text)
    }
    
    func setNewImage(newImage: UIImage?) {
        if newImage == nil {
            self.selecteImageButton.setImage(getImage("chCameraIcon"), for: .normal)
        } else {
            self.selecteImageButton.setImage(nil, for: .normal)
        }
        self.selectedImageView.image = newImage
        
        
    }
    
}


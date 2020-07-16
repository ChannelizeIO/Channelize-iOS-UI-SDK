//
//  InputTextBarView.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/10/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import InputBarAccessoryView
import UIKit

class InputTextBarView: InputBarAccessoryView {
    
    private var attachmentButton: InputBarButtonItem = {
        let button = InputBarButtonItem()
        button.image = getImage("chPlusIconOutLined")
        button.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        button.backgroundColor = .clear
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.title = nil
        button.setSize(CGSize(width: 40, height: 40), animated: false)
        return button
    }()
    
    var micButton: InputBarButtonItem = {
        let button = InputBarButtonItem()
        button.image = getImage("chMicIcon")
        button.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        button.backgroundColor = .clear
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.title = nil
        button.setSize(CGSize(width: 40, height: 40), animated: false)
        return button
    }()
    
    var onAttachmentButtonPressed: (() -> Void)?
    var onMicButtonPressed: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        self.translatesAutoresizingMaskIntoConstraints = false
        configure()
    }
    
    func configure() {
        
        self.attachmentButton.onTouchUpInside({ _ in
            self.onAttachmentButtonPressed?()
        })
        
        self.micButton.onTouchUpInside({ _ in
            self.onMicButtonPressed?()
        })
        
        self.sendButton.image = getImage("chMessageSendButton")
        self.sendButton.title = nil
        self.sendButton.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
        self.sendButton.imageView?.contentMode = .scaleAspectFit
        self.sendButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.sendButton.setSize(CGSize(width: 40, height: 40), animated: false)
        
        inputTextView.backgroundColor = UIColor.clear
        inputTextView.placeholder = CHLocalized(key: "pmTypeMessage")
        inputTextView.font = UIFont(fontStyle: .regular, size: 17.0)
        inputTextView.placeholderTextColor = UIColor(hex: "#8a8a8a")
        inputTextView.tintColor = UIColor(hex: "#8a8a8a")
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 4)
        inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 0.0
        inputTextView.layer.cornerRadius = 10.0
        inputTextView.layer.masksToBounds = true
        inputTextView.keyboardAppearance = CHAppConstant.themeStyle == .dark ? .dark : .light
        inputTextView.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor.black
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        if CHCustomOptions.enableAttachments {
            setStackViewItems([attachmentButton], forStack: .left, animated: false)
            setLeftStackViewWidthConstant(to: 40, animated: false)
        } else {
            setLeftStackViewWidthConstant(to: 0, animated: false)
        }
        if CHCustomOptions.enableAudioMessages {
            setStackViewItems([micButton], forStack: .right, animated: false)
            setRightStackViewWidthConstant(to: 40, animated: false)
        } else {
            setRightStackViewWidthConstant(to: 0, animated: false)
        }
        middleContentViewPadding.left = 5
        middleContentViewPadding.top = 0
        middleContentViewPadding.bottom = 0
        separatorLine.isHidden = false
        separatorLine.height = 0.5
        //separatorLine.tintColor = UIColor.customSystemGray
        isTranslucent = false
    }
    
    override func inputTextViewDidEndEditing() {
        items.forEach { $0.keyboardEditingEndsAction() }
        let trimmedText = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty == true {
            if CHCustomOptions.enableAudioMessages {
                setStackViewItems([micButton], forStack: .right, animated: true)
                setRightStackViewWidthConstant(to: 40, animated: false)
            } else {
                setRightStackViewWidthConstant(to: 0, animated: true)
            }
        } else {
            setStackViewItems([sendButton], forStack: .right, animated: true)
            setRightStackViewWidthConstant(to: 40, animated: true)
        }
    }
    
    override func inputTextViewDidBeginEditing() {
        items.forEach { $0.keyboardEditingBeginsAction() }
        self.setStackViewItems([sendButton], forStack: .right, animated: true)
        setRightStackViewWidthConstant(to: 40, animated: true)
        //self.buttonDelegate?.didStartTextEditing()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


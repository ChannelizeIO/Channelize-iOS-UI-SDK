//
//  InputeTextBar.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/29/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import InputBarAccessoryView

protocol CHInputTextBarViewDelegate {
    func didPressAttachmentButton()
    func didStartTextEditing()
}

extension CHInputTextBarViewDelegate {
    func didStartTextEditing() {}
}

class CHInputTextBarView: InputBarAccessoryView {
    
    private var attachmentButton: InputBarButtonItem = {
        let button = InputBarButtonItem()
        button.image = getImage("chAttachmentIcon")
        button.tintColor = CHUIConstants.appDefaultColor
        button.backgroundColor = .clear
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.title = nil
        button.setSize(CGSize(width: 40, height: 40), animated: false)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        configure()
    }
    
    var buttonDelegate: CHInputTextBarViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
        self.attachmentButton.onTouchUpInside({ _ in
            self.buttonDelegate?.didPressAttachmentButton()
        })
        
        self.sendButton.image = getImage("chMessageSendButton")
        self.sendButton.title = nil
        self.sendButton.tintColor = CHUIConstants.appDefaultColor
        self.sendButton.imageView?.contentMode = .scaleAspectFit
        self.sendButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.sendButton.setSize(CGSize(width: 40, height: 40), animated: false)
        
        inputTextView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        inputTextView.placeholder = "Type a Message..."
        inputTextView.placeholderTextColor = .lightGray
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 10.0
        inputTextView.layer.masksToBounds = true
        inputTextView.keyboardAppearance = .dark
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //setStackViewItems([attachmentButton], forStack: .left, animated: false)
        //setLeftStackViewWidthConstant(to: 40, animated: false)
        setStackViewItems([attachmentButton], forStack: .right, animated: false)
        setRightStackViewWidthConstant(to: 40, animated: false)
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
            setStackViewItems([attachmentButton], forStack: .right, animated: true)
        } else {
            setStackViewItems([sendButton], forStack: .right, animated: true)
        }
    }
    
    override func inputTextViewDidBeginEditing() {
        items.forEach { $0.keyboardEditingBeginsAction() }
        self.setStackViewItems([sendButton], forStack: .right, animated: true)
        self.buttonDelegate?.didStartTextEditing()
    }
    
    override func inputTextViewDidChange() {
        
        let originalText = inputTextView.text
        
        let trimmedText = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty == true {
            //setStackViewItems([attachmentButton], forStack: .right, animated: true)
            //setLeftStackViewWidthConstant(to: 35, animated: true)
            print("Text View Check -> Text is Empty")
        } else {
            //setStackViewItems([sendButton], forStack: .right, animated: true)
            //setLeftStackViewWidthConstant(to: 0, animated: true)
            print("Text View Check -> Text is not Empty")
        }
        
        if shouldManageSendButtonEnabledState {
            var isEnabled = !trimmedText.isEmpty
            if !isEnabled {
                // The images property is more resource intensive so only use it if needed
                isEnabled = inputTextView.images.count > 0
            }
            sendButton.isEnabled = isEnabled
        }
        
        // Capture change before iterating over the InputItem's
        let shouldInvalidateIntrinsicContentSize = requiredInputTextViewHeight != inputTextView.bounds.height
        
        items.forEach { $0.textViewDidChangeAction(with: self.inputTextView) }
        delegate?.inputBar(self, textViewTextDidChangeTo: trimmedText)
        
        if shouldInvalidateIntrinsicContentSize {
            // Prevent un-needed content size invalidation
            invalidateIntrinsicContentSize()
        }
    }
    
    func showAttachMentButton() {
        self.setStackViewItems([attachmentButton], forStack: .right, animated: true)
    }
    
}


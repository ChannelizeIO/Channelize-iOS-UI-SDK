//
//  UIConversationView+TextBar.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit
import InputBarAccessoryView
import ChannelizeAPI
import ObjectMapper
import Alamofire

extension UIConversationViewController: InputBarAccessoryViewDelegate, CHInputTextBarViewDelegate, AutocompleteManagerDelegate, AutocompleteManagerDataSource {
    
    func didPressAttachmentButton() {
        let attachmentActionSheet = UIAlertController(title: CHLocalized(key: "pmAlertMessage"), message: nil, preferredStyle: .actionSheet)
        
        let imageOption = UIAlertAction(title: CHLocalized(key: "pmSendImage"), style: .default, handler: {[weak self] (action) in
            self?.openImageSelector()
        })
        let videoOption = UIAlertAction(title: CHLocalized(key: "pmSendVideo"), style: .default, handler: {[weak self] (action) in
            self?.openVideoPicker()
        })
        let audioOption = UIAlertAction(title: "Send Audio", style: .default, handler: {[weak self](action) in
            self?.openAudioRecordingView()
        })
        let locationAction = UIAlertAction(title: CHLocalized(key: "pmLocation"), style:.default, handler: {[weak self] (action) in
            self?.openLocationShareController()
        })
        
        
        let gifAction = UIAlertAction(title: "Send Gifs and Stickers", style: .default, handler: {[weak self] (action) in
            self?.openGifStickerSelectorView(type: .gif)
        })
//        let stickerAction = UIAlertAction(title: "Send Stickers", style: .default, handler: {[weak self] (action) in
//            self?.openGifStickerSelectorView(type: .sticker)
//        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        
        attachmentActionSheet.addAction(imageOption)
        attachmentActionSheet.addAction(videoOption)
        attachmentActionSheet.addAction(audioOption)
        attachmentActionSheet.addAction(locationAction)
        if CHConstants.isGifStickerMessageEnabled {
            attachmentActionSheet.addAction(gifAction)
        }
        //attachmentActionSheet.addAction(stickerAction)
        attachmentActionSheet.addAction(cancelAction)
        self.present(attachmentActionSheet, animated: true, completion: nil)
        
        /*
        
        
        var attachmentOptions = [AttachmentModel]()
        let imageOption = AttachmentModel(type: .image, label: "Image", icon: "chPhotoLibrary")
        let videoOption = AttachmentModel(type: .video, label: "Video", icon: "chVideoLibrary")
        let audioOption = AttachmentModel(type: .audio, label: "Audio", icon: "chMicIcon")
        let locationOption = AttachmentModel(type: .location, label: "Location", icon: "chLocationIcon")
        let gifOption = AttachmentModel(type: .gif, label: "GIF", icon: "chGifIcon")
        let stickerOption = AttachmentModel(type: .sticker, label: "Stickers", icon: "chStickerIcon")
        attachmentOptions.append(imageOption)
        attachmentOptions.append(videoOption)
        attachmentOptions.append(audioOption)
        attachmentOptions.append(locationOption)
        attachmentOptions.append(gifOption)
        attachmentOptions.append(stickerOption)
        self.attachmentOptionView.assignAttachmentOptions(options: attachmentOptions)
        self.attachmentOptionView.backgroundColor = UIColor.black
        self.attachmentOptionView.delegate = self
        let totalLines: Double = Double(Double(attachmentOptions.count)/3).rounded(.up)
        
    self.topStackViewContainer.addArrangedSubview(attachmentOptionView)
        self.attachmentOptionView.setLeftAnchor(relatedConstraint: self.topStackViewContainer.leftAnchor, constant: 0)
        self.attachmentOptionView.setRightAnchor(relatedConstraint: self.topStackViewContainer.rightAnchor, constant: 0)
        let totalheight = ((self.view.frame.width/3)*CGFloat(totalLines) + 45)
        self.attachmentOptionView.heightAnchor.constraint(equalToConstant: totalheight).isActive = true
        UIView.animate(withDuration: 0.3, animations: {
            self.textViewContainerHeightConstraint.constant = 0
            self.topStackContainerHeightConstraint.constant = totalheight
            self.view.layoutIfNeeded()
        })
 */
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        var userTags = [[String:Any]]()
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        var order = 1
        var textToSend = text
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (attributes, range, stop) in
            
            let substring = attributedText.attributedSubstring(from: range)
            if let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil){
                let wordsCount = substring.string.split(separator: " ")
                if let dicContext = context as? NSDictionary{
                    if let userId = dicContext["memberId"] as? String{
                        var tagDic = [String:Any]()
                        tagDic.updateValue(userId, forKey: "userId")
                        tagDic.updateValue(wordsCount.count, forKey: "wordCount")
                        tagDic.updateValue(order, forKey: "order")
                        if let taggedUser = dicContext["userObject"] as? [String:Any] {
                            tagDic.updateValue(taggedUser, forKey: "user")
                        }
                        userTags.append(tagDic)
                        order += 1
                        textToSend = textToSend.replacingOccurrences(of: substring.string, with: "%s")
                    }
                }
            }
        }
        
        let messageId = UUID().uuidString
        let senderName = ChannelizeAPI.getCurrentUserDisplayName()
        let senderId = ChannelizeAPI.getCurrentUserId()
        let senderImageUrl = ChannelizeAPI.getCurrentUserProfileImageUrl() ?? ""
        let messageDate = Date()
        let messageStatus = BaseMessageStatus.sending
        
        var messageParams = [String:Any]()
        messageParams.updateValue(messageId, forKey: "id")
        messageParams.updateValue(senderName, forKey: "ownerName")
        messageParams.updateValue(senderId, forKey: "ownerId")
        if self.currentQuotedModel != nil {
            messageParams.updateValue("reply", forKey: "type")
            messageParams.updateValue(self.currentQuotedModel?.parentMessageId ?? "", forKey: "parentId")
        } else {
            messageParams.updateValue("normal", forKey: "type")
        }
        
        messageParams.updateValue(textToSend, forKey: "body")
        messageParams.updateValue(userTags, forKey: "mentionedUsers")
        messageParams.updateValue(self.conversation?.id ?? "", forKey: "conversationId")
        
        let baseMessageData = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl, messageDate: messageDate, status: messageStatus)
        
        var mentionedUsers = [CHMentionedUser]()
        userTags.forEach({
            if let mentionedUser = Mapper<CHMentionedUser>().map(JSON: $0) {
                mentionedUsers.append(mentionedUser)
            }
        })
        
        let textMessageModel = TextMessageModel(messageBody: textToSend, mentionedUsers: mentionedUsers.count > 0 ? mentionedUsers : nil, baseMessageModel: baseMessageData)
        self.insertNewChatItemAtBottom(chatItem: textMessageModel)
        
        ChannelizeAPIService.sendTextMessage(params: messageParams, completion: {(message,errorString) in
            guard errorString == nil else {
                return
            }
            self.updateSendingMessageStatus(message: message)
            
        })
        inputBar.inputTextView.text = ""
        self.topStackViewContainer.subviews.forEach({
            $0.removeFromSuperview()
        })
        UIView.animate(withDuration: 0.2, animations: {
            self.topStackContainerHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: { completed in
            self.currentQuotedModel = nil
        })
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
        if(!text.isEmpty && !isTyping){
            isTyping = true
            ChannelizeAPIService.sendIsTypingStatus(conversationId: self.conversation?.id ?? "", isTyping: true, completion: {(status,errorString) in
                if status {
                    
                } else {
                    print(errorString ?? "")
                }
            })
            runTimer()
        }
        
        guard autocompleteManager.currentSession != nil, autocompleteManager.currentSession?.prefix == "@", self.conversation?.isGroup == true else {
            
            return
        }
        if self.conversation?.isGroup == true{
            DispatchQueue.global(qos: .default).async {
                DispatchQueue.main.async { [weak self] in
                    self?.autocompleteManager.reloadData()
                }
            }
        }
    }
    
    @objc func updateTimer(){
        seconds+=1
        if(seconds == 3 && isTyping){
            isTyping = false
            ChannelizeAPIService.sendIsTypingStatus(conversationId: self.conversation?.id ?? "", isTyping: false, completion: {(status,errorString) in
                if status {
                    
                } else {
                    print(errorString ?? "")
                }
            })
            timer?.invalidate()
            seconds = 0
        }
    }
    
    fileprivate func runTimer(){
        timer?.invalidate()
        seconds = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        var lastYOffset = self.collectionView.contentOffset.y
        lastYOffset = lastYOffset + size.height - 50
        self.collectionView.setContentOffset(CGPoint(x: 0, y: lastYOffset), animated: true)
        
        
        if size.height <= 50 {
            UIView.animate(withDuration: 0.2, animations: {
                self.textViewContainerHeightConstraint.constant = 50
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.textViewContainerHeightConstraint.constant = size.height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func configureAutoCompleter(){
        let autoCompleterAttributes: [NSAttributedString.Key: Any] = [ NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: 18.0)!, NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), NSAttributedString.Key.backgroundColor: UIColor(red: 0, green: 122/255, blue: 1, alpha: 0.1)]
        autocompleteManager.register(prefix: "@", with: autoCompleterAttributes)
        autocompleteManager.maxSpaceCountDuringCompletion = 1 // Allow for autocompletes with a space
        autocompleteManager.deleteCompletionByParts = false
        autocompleteManager.keepPrefixOnCompletion = false
        // Set plugins
        self.textInputBarView.inputPlugins = [autocompleteManager]
        
        autocompleteManager.tableView.register(TaggedUserCell.self, forCellReuseIdentifier: "userlist")
        autocompleteManager.tableView.contentInset.top = 3
        autocompleteManager.tableView.separatorStyle = .singleLine
        autocompleteManager.tableView.separatorInset.left = 55
        autocompleteManager.tableView.separatorInset.right = 5
        autocompleteManager.tableView.separatorColor = UIColor(white: 0.8, alpha: 1.0)
        autocompleteManager.tableView.layer.borderWidth = 0.5
        autocompleteManager.tableView.layer.borderColor = UIColor(white: 0.65, alpha: 1.0).cgColor
    }
    
    
    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        
        if prefix == "@" {
            if let members = self.conversation?.members{
                
                let filteredMembersList = members.filter({ $0.user?.id != ChannelizeAPI.getCurrentUserId()})
                return filteredMembersList.map{ member in
                    
                    var userObject = [String:Any]()
                    userObject.updateValue(member.user?.id ?? "", forKey: "id")
                    userObject.updateValue(member.user?.displayName ?? "", forKey: "displayName")
                    if let imageUrl = member.user?.profileImageUrl {
                        userObject.updateValue(imageUrl, forKey: "profileImageUrl")
                    }
                    
                    return AutocompleteCompletion(text: member.user?.displayName?.capitalized ?? "", context: ["memberId": member.userId ?? "", "userObject": userObject])
                }
            }
        }
        return []
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        self.setAutocompleteManager(active: shouldBecomeVisible)
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userlist", for: indexPath) as? TaggedUserCell else{
            fatalError("Oops, some unknown error occurred")
        }
        cell.selectionStyle = .none
        let name = session.completion?.text ?? ""
        var id = ""
        if let sessionContext = session.completion?.context{
            if let memberId = sessionContext["memberId"] as? String{
                id = memberId
            }
        }
        
        if let members = self.conversation?.members{
            let member = members.filter{ return $0.userId == id}.first
            if member != nil{
                if let imageUrlString = member?.user?.profileImageUrl{
                    if let imageUrl = URL(string: imageUrlString){
                        cell.userImage.sd_setImage(with: imageUrl, placeholderImage: nil, options: [.scaleDownLargeImages], completed: nil)
                    } else{
                        let imageSize = CGSize(width: 50, height: 50)
                        let imageGenerator = ImageFromStringProvider(name: name, imageSize: imageSize)
                        cell.userImage.image = imageGenerator.generateImage()
                    }
                } else{
                    let imageSize = CGSize(width: 50, height: 50)
                    let imageGenerator = ImageFromStringProvider(name: name, imageSize: imageSize)
                    cell.userImage.image = imageGenerator.generateImage()
                }
            }
        }
        cell.userName.attributedText = NSAttributedString(string: name.capitalized)
        return cell
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, shouldComplete prefix: String, with text: String) -> Bool {
        
        return true
    }
    
    func setAutocompleteManager(active: Bool) {
        if active && !self.topStackViewContainer.contains(
            autocompleteManager.tableView) {
            //
            autocompleteManager.tableView.translatesAutoresizingMaskIntoConstraints = false
            self.topStackViewContainer.addArrangedSubview(
                autocompleteManager.tableView)
            let numberOfItems = autocompleteManager.tableView.numberOfRows(inSection: 0)
            //print(autocompleteManager.tableView.numberOfRows(inSection: 0))
            let tableHeight: CGFloat = numberOfItems * 45 > 125 ? 125 : CGFloat((numberOfItems * 45) + 10)
            let totalSubView = self.topStackViewContainer.arrangedSubviews.count
            self.autoCompleteTableHeightConstraint = NSLayoutConstraint(item: self.autocompleteManager.tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: tableHeight)
            self.autoCompleteTableHeightConstraint.isActive = true
            self.topStackViewContainer.addConstraint(self.autoCompleteTableHeightConstraint)
            self.autocompleteManager.tableView.setRightAnchor(relatedConstraint: self.topStackViewContainer.rightAnchor, constant: 0)
            self.autocompleteManager.tableView.setLeftAnchor(relatedConstraint: self.topStackViewContainer.leftAnchor, constant: 0)
            print("Total Views in Top Stack are \(self.topStackViewContainer.arrangedSubviews.count)")
            UIView.animate(withDuration: 0.33, animations: {
                self.topStackContainerHeightConstraint.constant = totalSubView == 2 ? tableHeight + 60 : tableHeight
                self.topStackViewContainer.layoutIfNeeded()
                self.view.layoutIfNeeded()
            })
        } else if !active && self.topStackViewContainer.contains(autocompleteManager.tableView) {
            
            //self.topStackViewContainer.removeArrangedSubview(
                //self.autocompleteManager.tableView)
            self.autocompleteManager.tableView.removeFromSuperview()
            
            print("Total Views in Top Stack are \(self.topStackViewContainer.arrangedSubviews.count)")
            UIView.animate(withDuration: 0.33, animations: {
                if self.quotedMessageViewContainer.subviews.count > 0 {
                    self.topStackContainerHeightConstraint.constant = 60
                } else {
                    self.topStackContainerHeightConstraint.constant = 0
                }
                self.topStackViewContainer.layoutIfNeeded()
                self.view.layoutIfNeeded()
            })
        } else {
            
            let numberOfItems = autocompleteManager.tableView.numberOfRows(inSection: 0)
            //print(autocompleteManager.tableView.numberOfRows(inSection: 0))
            let tableHeight: CGFloat = numberOfItems * 45 > 125 ? 125 : CGFloat((numberOfItems * 45) + 10)
            let totalSubView = self.topStackViewContainer.arrangedSubviews.count
            UIView.animate(withDuration: 0.33, animations: {
                self.autoCompleteTableHeightConstraint.constant = tableHeight
                self.topStackContainerHeightConstraint.constant = totalSubView == 2 ? tableHeight + 60 : tableHeight
                self.topStackViewContainer.layoutIfNeeded()
                self.view.layoutIfNeeded()
            })
            
//            autocompleteManager.tableView.translatesAutoresizingMaskIntoConstraints = false
//            self.topStackViewContainer.addArrangedSubview(
//                autocompleteManager.tableView)
//            let numberOfItems = autocompleteManager.tableView.numberOfRows(inSection: 0)
//            //print(autocompleteManager.tableView.numberOfRows(inSection: 0))
//            let tableHeight: CGFloat = numberOfItems * 45 > 125 ? 125 : CGFloat(numberOfItems * 45)
//            self.autocompleteManager.tableView.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
//            self.autocompleteManager.tableView.setRightAnchor(relatedConstraint: self.topStackViewContainer.rightAnchor, constant: 0)
//            self.autocompleteManager.tableView.setLeftAnchor(relatedConstraint: self.topStackViewContainer.leftAnchor, constant: 0)
//            UIView.animate(withDuration: 0.2, animations: {
//                self.topStackContainerHeightConstraint.constant += tableHeight
//                self.view.layoutIfNeeded()
//            })
            
            
            print(autocompleteManager.tableView.numberOfRows(inSection: 0))
        }
    }
    
    
}

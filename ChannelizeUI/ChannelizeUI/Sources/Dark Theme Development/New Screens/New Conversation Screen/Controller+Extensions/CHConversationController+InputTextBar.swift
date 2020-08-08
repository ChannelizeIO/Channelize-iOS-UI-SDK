//
//  CHConversationController+InputTextBar.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/10/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import InputBarAccessoryView
import ChannelizeAPI
import ObjectMapper
import DifferenceKit
import VirgilE3Kit

extension CHConversationViewController: InputBarAccessoryViewDelegate, AutocompleteManagerDelegate, AutocompleteManagerDataSource {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        var lastYOffset = self.collectionView.contentOffset.y
        if size.height > self.currentInputBarHeight {
            lastYOffset = lastYOffset + 22
        } else {
            lastYOffset = lastYOffset - 15
        }
        self.currentInputBarHeight = size.height
        //lastYOffset = lastYOffset + max(self.currentInputBarHeight,0)
        
        //self.collectionView.contentInset.bottom = size.height - 50
        self.collectionView.setContentOffset(CGPoint(x: 0, y: lastYOffset), animated: true)
       // self.currentInputBarHeight = size.height
        
        
        if size.height <= 50 {
            UIView.animate(withDuration: 0.33, animations: {
                self.inputBarHeightConstraint.constant = 50
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.33, animations: {
                self.inputBarHeightConstraint.constant = size.height + 1
                self.view.layoutIfNeeded()
            })
        }
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
        
        var apiMentionedUsers = [CHMentionedUserQueryBuilder]()
        
        var mentionedUsers = [CHMentionedUser]()
        userTags.forEach({
            if let mentionedUser = Mapper<CHMentionedUser>().map(JSON: $0) {
                let apiMentioned = CHMentionedUserQueryBuilder()
                apiMentioned.order = mentionedUser.order
                apiMentioned.userId = mentionedUser.userId
                apiMentioned.wordCount = mentionedUser.wordCount
                apiMentionedUsers.append(apiMentioned)
                mentionedUsers.append(mentionedUser)
            }
        })
        
        let messageId = UUID().uuidString
        let senderName = Channelize.getCurrentUserDisplayName()
        let senderId = Channelize.getCurrentUserId()
        let senderImageUrl = Channelize.getCurrentUserProfileImageUrl() ?? ""
        let messageDate = Date()
        let messageStatus = BaseMessageStatus.sending
        
        let baseMessageData = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl, messageDate: messageDate, status: messageStatus)
        let textMessageData = TextMessageData(messageBody: text, mentionedUsers: mentionedUsers)
        let textMessageItem = TextMessageItem(baseMessageModel: baseMessageData, textMessageData: textMessageData, isDeletedMessage: false)
        
        var messageTextString: String?
        if ChVirgilE3Kit.isEndToEndEncryptionEnabled {
            do {
                messageTextString = try self.ethreeObject?.authEncrypt(text: textToSend, for: self.myLookUpResults)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            messageTextString = textToSend
        }
        
        
        let messageQueryBuilder = CHMessageQueryBuilder()
        messageQueryBuilder.body = messageTextString
        messageQueryBuilder.isEncrypted = ChVirgilE3Kit.isEndToEndEncryptionEnabled
        if self.conversation?.id != nil {
            messageQueryBuilder.conversationId = self.conversation?.id
        } else {
            messageQueryBuilder.userId = self.conversation?.conversationPartner?.id
        }
        messageQueryBuilder.id = messageId
        if self.currentQuotedModel != nil {
            messageQueryBuilder.messageType = .quotedMessage
            messageQueryBuilder.parentId = self.currentQuotedModel?.parentMessageId
        } else {
            messageQueryBuilder.messageType = .normal
        }
        messageQueryBuilder.ownerId = senderId
        messageQueryBuilder.mentionedUsers = apiMentionedUsers.count > 0 ? apiMentionedUsers : nil
        messageQueryBuilder.createdAt = messageDate
        
        self.conversation?.lastReadDictionary?.updateValue(
            ISODateTransform().transformToJSON(messageDate) ?? "", forKey: Channelize.getCurrentUserId())
        self.conversation?.updateLastMessageOldestRead()
        
        
        let oldItems = self.chatItems.copy()
        self.chatItems.append(textMessageItem)
        self.reprepareChatItems()
        let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
        self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
            self.chatItems = data
        }, completion: {
            self.currentQuotedModel = nil
            self.scrollToBottom(animated: true)
        })
        inputBar.inputTextView.text = ""
        self.topStackViewContainer.arrangedSubviews.first(where: {
            $0.tag == 50001
        })?.removeFromSuperview()
        self.topStackViewContainer.arrangedSubviews.forEach({
            $0.removeFromSuperview()
        })
        self.topStackContainerHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
        self.checkAndSetNoContentView()
        ChannelizeAPIService.sendMessage(queryBuilder: messageQueryBuilder, uploadProgress: { _,_ in }, completion: {(message,errorString) in
            guard errorString == nil else {
                return
            }
            if message != nil {
                let oldItems = self.chatItems.copy()
                textMessageItem.messageStatus = .sent
                let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
                self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                    self.chatItems = data
                })
                if self.conversation?.id == nil {
                    self.getConversationWithId(conversationId: message?.conversationId ?? "")
                }
                self.checkAndSetNoContentView()
            }
        })
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if(!text.isEmpty && !isTyping){
            isTyping = true
            if self.conversation?.id != nil {
                ChannelizeAPIService.sendIsTypingStatus(conversationId: self.conversation?.id ?? "", isTyping: true, completion: {(status,errorString) in
                    if status {
                        
                    } else {
                        print(errorString ?? "")
                    }
                })
                runTimer()
            }
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
        guard self.conversation?.id != nil else {
            return
        }
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
    
    func configureAutoCompleter(){
        let autoCompleterAttributes: [NSAttributedString.Key: Any] = [ NSAttributedString.Key.font: UIFont(fontStyle: .regular, size: 17.0)!, NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), NSAttributedString.Key.backgroundColor: UIColor(red: 0, green: 122/255, blue: 1, alpha: 0.1)]
        autocompleteManager.register(prefix: "@", with: autoCompleterAttributes)
        autocompleteManager.maxSpaceCountDuringCompletion = 1 // Allow for autocompletes with a space
        autocompleteManager.deleteCompletionByParts = false
        autocompleteManager.keepPrefixOnCompletion = false
        // Set plugins
        self.inputBar.inputPlugins = [autocompleteManager]
        autocompleteManager.defaultTextAttributes = [NSAttributedString.Key.font: UIFont(fontStyle: .regular, size: 17.0)!, NSAttributedString.Key.foregroundColor: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.secondaryColor : CHLightThemeColors.secondaryColor]
        autocompleteManager.tableView.register(TaggedUserCell.self, forCellReuseIdentifier: "userlist")
        autocompleteManager.tableView.contentInset.top = 0
        autocompleteManager.tableView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        autocompleteManager.tableView.separatorStyle = .singleLine
        autocompleteManager.tableView.separatorInset.left = 55
        autocompleteManager.tableView.separatorInset.right = 5
        autocompleteManager.tableView.separatorColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.seperatorColor : CHLightThemeColors.seperatorColor
        autocompleteManager.tableView.rowHeight = 60
        autocompleteManager.tableView.addTopBorder(with: UIColor(white: 0.65, alpha: 1.0), andWidth: 0.5)
        //autocompleteManager.tableView.layer.borderWidth = 0.5
        //autocompleteManager.tableView.layer.borderColor = UIColor(white: 0.65, alpha: 1.0).cgColor
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        self.setAutocompleteManager(active: shouldBecomeVisible)
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        if prefix == "@" {
            if let members = self.conversation?.members{
                let filteredMembersList = members.filter({ $0.user?.id != Channelize.getCurrentUserId()})
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
    
    func autocompleteManager(_ manager: AutocompleteManager, shouldComplete prefix: String, with text: String) -> Bool {
        return true
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userlist", for: indexPath) as? TaggedUserCell else{
            fatalError("Oops, some unknown error occurred")
        }
        cell.selectionStyle = .none
        cell.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
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
        let textAttributes: [NSAttributedString.Key:Any] = [NSAttributedString.Key.font: UIFont(fontStyle: .regular, size: 14.0)!, NSAttributedString.Key.foregroundColor: CHAppConstant.themeStyle == .dark ? UIColor.white : .black]
        
        cell.userName.attributedText = NSAttributedString(string: name.capitalized, attributes: textAttributes)
        return cell
    }
    
    func setAutocompleteManager(active: Bool) {
        if active && !self.topStackViewContainer.contains(
            autocompleteManager.tableView) {
            //
            autocompleteManager.tableView.translatesAutoresizingMaskIntoConstraints = false
            self.topStackViewContainer.addArrangedSubview(autocompleteManager.tableView)
            let numberOfItems = autocompleteManager.tableView.numberOfRows(inSection: 0)
            let tableHeight: CGFloat = numberOfItems * 60 > 180 ? 180 : CGFloat((numberOfItems * 60))
            let totalSubView = self.topStackViewContainer.arrangedSubviews.count
            self.autoCompleteTableHeightConstraint = NSLayoutConstraint(item: self.autocompleteManager.tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0)
            self.topStackViewContainer.addConstraint(self.autoCompleteTableHeightConstraint)
            self.autocompleteManager.tableView.setRightAnchor(relatedConstraint: self.topStackViewContainer.rightAnchor, constant: 0)
            self.autocompleteManager.tableView.setLeftAnchor(relatedConstraint: self.topStackViewContainer.leftAnchor, constant: 0)
            print("Total Views in Top Stack are \(self.topStackViewContainer.arrangedSubviews.count)")
            
            UIView.animate(withDuration: 0.33, delay: 0, options: [.layoutSubviews], animations: {
                self.autoCompleteTableHeightConstraint.isActive = true
                self.autoCompleteTableHeightConstraint.constant = tableHeight
                self.topStackContainerHeightConstraint.constant = totalSubView == 2 ? tableHeight + 60 : tableHeight
                self.topStackViewContainer.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else if !active && self.topStackViewContainer.contains(autocompleteManager.tableView) {
            let totalSubView = self.topStackViewContainer.arrangedSubviews.count
            
            print("Total Views in Top Stack are \(self.topStackViewContainer.arrangedSubviews.count)")
            UIView.animate(withDuration: 0.33, delay: 0, options: [], animations: {
                self.topStackContainerHeightConstraint.constant = totalSubView == 2 ? 60 : 0
                self.autoCompleteTableHeightConstraint.constant = 0
                self.topStackViewContainer.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.autocompleteManager.tableView.removeFromSuperview()
            })
        } else {
            let numberOfItems = autocompleteManager.tableView.numberOfRows(inSection: 0)
            let tableHeight: CGFloat = numberOfItems * 60 > 180 ? 180 : CGFloat((numberOfItems * 60))
            let totalSubView = self.topStackViewContainer.arrangedSubviews.count
            
            UIView.animate(withDuration: 0.33, delay: 0, options: [], animations: {
                self.autoCompleteTableHeightConstraint.constant = tableHeight
                self.topStackContainerHeightConstraint.constant = totalSubView == 2 ? tableHeight + 60 : tableHeight
                self.topStackViewContainer.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}


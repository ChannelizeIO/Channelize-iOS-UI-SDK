//
//  UIConversationViewScreen+ConversationEvents.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/24/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import UIKit
import ObjectMapper
import Alamofire

extension UIConversationViewController: CHUserEventDelegates {
    
    func didUserBlocked(model: CHUserBlockModel?) {
        guard self.conversation?.isGroup == false else {
            return
        }
        guard let blockerUser = model?.blockerUser else {
            return
        }
        guard let blockedUser = model?.blockedUser else {
            return
        }
        if blockerUser.id == ChannelizeAPI.getCurrentUserId() {
            if blockedUser.id == self.conversation?.conversationPartner?.id {
                self.conversation?.isPartnerIsBlocked = true
                self.updateBlockViewStatus()
            }
        } else if blockerUser.id == self.conversation?.conversationPartner?.id {
            if blockedUser.id == ChannelizeAPI.getCurrentUserId() {
                self.conversation?.isPartenerHasBlocked = true
                self.updateBlockViewStatus()
            }
        }
    }
    
    func didUserUnBlocked(model: CHUserUnblockModel?) {
        guard self.conversation?.isGroup == false else {
            return
        }
        guard let unBlockerUser = model?.unblockerUser else {
            return
        }
        guard let unBlockedUser = model?.unblockedUser else {
            return
        }
        if unBlockerUser.id == ChannelizeAPI.getCurrentUserId() {
            if unBlockedUser.id == self.conversation?.conversationPartner?.id {
                self.conversation?.isPartnerIsBlocked = false
                self.updateBlockViewStatus()
            }
        } else if unBlockerUser.id == self.conversation?.conversationPartner?.id {
            if unBlockedUser.id == ChannelizeAPI.getCurrentUserId() {
                self.conversation?.isPartenerHasBlocked = false
                self.updateBlockViewStatus()
            }
        }
    }
    
    func didUserStatusUpdated(model: CHUserStatusUpdatedModel?) {
        guard let userModel = model?.updatedUser else {
            return
        }
        guard userModel.id != ChannelizeAPI.getCurrentUserId() else {
            return
        }
        guard userModel.id == self.conversation?.conversationPartner?.id else {
            return
        }
        guard self.conversation?.isGroup == false else {
            return
        }
        self.conversation?.conversationPartner?.isOnline = userModel.isOnline
        self.conversation?.conversationPartner?.lastSeen = userModel.lastSeen
        if userModel.isOnline == true {
            self.conversationHeaderView.updateConversationInfoView(
                infoString: "Online")
        } else {
            self.conversation?.conversationPartner?.lastSeen = Date()
            userModel.lastSeen = Date()
            self.conversationHeaderView.updateConversationInfoView(
                infoString: getLastSeen(lastSeenDate: userModel.lastSeen))
        }
    }
}


extension UIConversationViewController: CHConversationEventDelegate {
    
    func updateMessagesStatus() {
        let dateTransformer = ISODateTransform()
        if let lastReadInfoDic = self.conversation?.lastReadDictionary {
            var lastReadData = [String:Date]()
            lastReadInfoDic.forEach({(id,date) in
                if let memberReadDate = dateTransformer.transformFromJSON(date) {
                    lastReadData.updateValue(memberReadDate, forKey: id)
                }
            })
            lastReadData.removeValue(forKey: ChannelizeAPI.getCurrentUserId())
            
            let sortedData = lastReadData.sorted(by: {$0.value < $1.value})
            if let oldestReader = sortedData.first {
                let oldestReadDate = oldestReader.value
                let unreadMessages = self.chatItems.filter({
                    $0.messageStatus == .sent
                })
                unreadMessages.forEach({
                    let messageDate = $0.messageDate
                    if messageDate <= oldestReadDate {
                        $0.messageStatus = .seen
                    }
                })
            }
            self.collectionView.reloadData()
        }
    }
    
    
    func didConversationMarkAsRead(model: CHConversationMarkReadModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        guard let markReadUser = model?.user else {
            return
        }
        if self.conversation?.isGroup == true {
            let dateTransformer = ISODateTransform()
            let dateString = dateTransformer.transformToJSON(model?.timeStamp)
            conversation?.lastReadDictionary?.updateValue(
                dateString ?? "", forKey: markReadUser.id ?? "")
            self.updateMessagesStatus()
        } else {
            if markReadUser.id != ChannelizeAPI.getCurrentUserId() {
                let sentItems = self.chatItems.filter({
                    $0.messageStatus == .sent
                })
                let unreadSentItems = sentItems.filter({
                    $0.messageDate <= model?.timeStamp ?? Date()
                })
                unreadSentItems.forEach({
                    $0.messageStatus = .seen
                })
                self.collectionView.reloadData()
            }
        }
    }
    
    func didConversationMessageDeleted(model: CHMessageDeletedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        guard let deletedMessages = model?.deletedMessages else {
            return
        }
        var deletedMessageIds = [String]()
        deletedMessages.forEach({
            let messageId = $0.id ?? ""
            deletedMessageIds.append(messageId)
        })
        self.removeItemsFromCollectionView(itemsIds: deletedMessageIds)
    }
    
    func didConversationMessageDeletedForEveryOne(model: CHMessageDeletedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        guard let deletedMessages = model?.deletedMessages else {
            return
        }
        var deletedMessageIds = [String]()
        deletedMessages.forEach({
            let message = $0
            let messageId = message.id ?? ""
            message.isDeleted = true
            if let deletedMessageModel = self.createChatItemFromMessage(message: message) {
                self.replaceMessageWithNewItem(messageId: messageId, deletedChatItem: deletedMessageModel)
            }
        })
    }
    
    func didRecieveNewMessage(model: CHNewMessageRecievedModel?) {
        guard model?.message?.conversationId == self.conversation?.id else {
            return
        }
        guard let messageId = model?.message?.id else {
            return
        }
        if let messageIndex = self.chatItems.firstIndex(where: {
            $0.messageId == messageId
        }) {
            let chatItem = self.chatItems[messageIndex]
            if chatItem.messageStatus == .sending {
                self.updateSendingMessageStatus(message: model?.message)
            }
        } else {
            if let recievedMessage = model?.message {
                if let chatItem = self.createChatItemFromMessage(message: recievedMessage) {
                    
                    self.insertNewChatItemAtBottom(chatItem: chatItem, isScrollToLast: chatItem.senderId == ChannelizeAPI.getCurrentUserId())
                    //self.insertNewChatItemAtBottom(chatItem: chatItem)
                    if chatItem.messageType == .text || chatItem.messageType == .quotedMessage {
                        if let textItem = chatItem as? TextMessageModel {
                            self.detectAndAddLinkMessages(with: textItem)
                        }
                    }
                    //self.chatItems.append(chatItem)
                    //self.prepareItemsWithGroupedImages()
                    //self.reprepareChatItems()
                    //self.collectionView.reloadData()
                    
                    
//                    if let lastItem = self.chatItems.last {
//                        if !calendar.isDate(lastItem.messageDate, inSameDayAs: chatItem.messageDate) {
//                            chatItem.showDataSeperator = true
//                            if chatItem.isIncoming {
//                                chatItem.showSenderName = true
//                            }
//                        }
//                        if chatItem.isIncoming && chatItem.senderId != lastItem.senderId{
//                            chatItem.showSenderName = true
//                        }
//                        if lastItem.senderId == chatItem.senderId {
//                            lastItem.showMessageStatusView = false
//                        }
//                        chatItem.showMessageStatusView = true
//                    } else {
//                        chatItem.showDataSeperator = true
//                        chatItem.showMessageStatusView = true
//                        if chatItem.isIncoming {
//                            chatItem.showSenderName = true
//                        }
//                    }
//                    self.chatItems.append(chatItem)
//                    self.collectionView.reloadData()
                    
                    if chatItem.senderId != ChannelizeAPI.getCurrentUserId() {
                        if plusButton.isHidden == false {
                            plusButton.updateBadgeCount()
                        }
                    } else {
                        self.scrollToBottom(animated: false)
                    }
                    ChannelizeAPIService.markConversationRead(
                        conversationId: self.conversation?.id ?? "", completion: {(status,errorString) in
                            
                    })
                    
                }
            }
        }
    }
    
    func didConversationCleared(model: CHConversationClearModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.plusButton.isHidden = true
        self.chatItems.removeAll()
        self.collectionView.reloadData()
    }
    
    func didConversationDeleted(model: CHConversationDeleteModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.chatItems.removeAll()
        self.collectionView.reloadData()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func didNewAdminAddedToConversation(model: CHNewAdminAddedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        if let adminUser = model?.adminUser {
            if let firstUser = self.conversation?.members?.first(where: {
                $0.user?.id == adminUser.id
            }) {
                firstUser.isAdmin = true
            }
        }
    }
    
    func didNewMembersAddedToConversation(model: CHNewMemberAddedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        if let addedMembers = model?.addedMembers {
            addedMembers.forEach({
                let member = $0
                if self.conversation?.members?.contains(where: {
                    $0.user?.id == member.user?.id
                }) == false {
                    self.conversation?.members?.append($0)
                }
            })
        }
        if self.conversation?.isGroup == true {
            self.conversationHeaderView.updateConversationInfoView(
                infoString: "\(model?.conversation?.membersCount ?? 0) Members")
        }
        
    }
    
    func didMembersRemovedFromConversation(model: CHMembersRemovedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        guard var conversationMembers = self.conversation?.members else {
            return
        }
        if let removedUsers = model?.removedUsers {
            removedUsers.forEach({
                let userId = $0.id
                conversationMembers.removeAll(where: {
                    $0.user?.id == userId
                })
            })
        }
        conversation?.members = conversationMembers
        if self.conversation?.isGroup == true {
            self.conversationHeaderView.updateConversationInfoView(infoString: "\(model?.conversation?.membersCount ?? 0) Members")
        }
    }
    
    func didCurrentUserRemovedFromConversation(model: CHCurrentUserRemovedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        conversation?.canReplyToConversation = false
        //self.updateBlockViewStatus()
        conversation?.members?.removeAll(where: {
            $0.user?.id == ChannelizeAPI.getCurrentUserId()
        })
        if self.conversation?.isGroup == true {
            self.conversationHeaderView.updateConversationInfoView(infoString: "\(model?.conversation?.membersCount ?? 0) Members")
        }
    }
    
    func didUpdateConversationMuteStatus(model: CHConversationMuteStatusModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        conversation?.isMute = model?.conversation?.isMute
    }
    
    func didConversationInfoUpdated(model: CHConversationUpdatedModel?) {
        guard model?.conversationID == self.conversation?.id else {
            return
        }
        conversation?.coversationTitle = model?.title
        conversation?.conversationProfileImage = model?.profileImageUrl
        conversation?.lastUpDatedAt = model?.timeStamp
        conversation?.membersCount = model?.memberCount
        self.conversationHeaderView.updateConversationTitleView(
            conversationTitle: model?.title)
        self.conversationHeaderView.updateProfileImageView(
            imageUrlString: model?.profileImageUrl, conversationTitle: model?.title)
        self.conversationHeaderView.updateConversationInfoView(
            infoString: "\(model?.memberCount ?? 0) Members")
    }
    
    func didCurrentUserJoinedConversation(model: CHCurrentUserJoinConversationModel?) {
        guard model?.conversation?.id == model?.conversation?.id else {
            return
        }
        conversation?.canReplyToConversation = true
        var params = [String:Any]()
        params.updateValue(UUID().uuidString, forKey: "id")
        params.updateValue(ChannelizeAPI.getCurrentUserId(), forKey: "userId")
        params.updateValue(false, forKey: "isAdmin")
        if let member = Mapper<CHMember>().map(JSON: params) {
            
            var userParams = [String:Any]()
            userParams.updateValue(ChannelizeAPI.getCurrentUserId(), forKey: "id")
            userParams.updateValue(ChannelizeAPI.getCurrentUserDisplayName(), forKey: "displayName")
            if ChannelizeAPI.getCurrentUserProfileImageUrl() != nil {
                userParams.updateValue(ChannelizeAPI.getCurrentUserProfileImageUrl()!, forKey: "profileImageUrl")
            }
            let userObject = Mapper<CHUser>().map(JSON: userParams)
            member.user = userObject
            self.conversation?.members?.append(member)
        }
        self.updateBlockViewStatus()
    }
    
    func didTypingUserStatusUpdated(model: CHUserTypingStatusModel?) {
        guard let typingConversation = model?.conversation, typingConversation.id == self.conversation?.id else {
            return
        }
        guard let typingUser = model?.user else {
            return
        }
        self.conversation?.isTyping = model?.isTyping
        self.conversation?.typingUserName = typingUser.displayName
        let typingUserName = typingUser.displayName?.capitalized ?? ""
        var typingText = ""
        if model?.isTyping == true {
            if self.conversation?.isGroup == true {
                typingText = String(format: "%@ is Typing...", typingUserName)
            } else {
                typingText = "Typing..."
            }
            self.conversationHeaderView.updateConversationInfoView(
                infoString: typingText)
        } else {
            if self.conversation?.isGroup == true {
                self.conversationHeaderView.updateConversationInfoView(
                    infoString: "\(typingConversation.membersCount ?? 0) Members")
            } else {
                if self.conversation?.conversationPartner?.isOnline == true {
                    self.conversationHeaderView.updateConversationInfoView(
                        infoString: "Online")
                } else {
                    self.conversationHeaderView.updateConversationInfoView(
                        infoString: getLastSeen(lastSeenDate: self.conversation?.conversationPartner?.lastSeen))
                }
                
            }
        }
        
    }
    
    func updateImageMessageData(chatItem: BaseMessageItemProtocol, messageIndex: Int) {
        if let imageChatItem = chatItem as? ImageMessageModel {
            let oldChatItem = self.chatItems[messageIndex] as? ImageMessageModel
            imageChatItem.localImage = oldChatItem?.localImage
            self.chatItems.remove(at: messageIndex)
            self.chatItems.insert(imageChatItem, at: messageIndex)
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [IndexPath(item: messageIndex, section: 0)])
                self.collectionView.insertItems(at: [IndexPath(item: messageIndex, section: 0)])
            }, completion: nil)
        }
    }
    
    
    func replaceMessageWithNewItem(messageId: String, deletedChatItem: BaseMessageItemProtocol) {
        if let index = self.chatItems.firstIndex(where: {
            $0.messageId.contains(messageId)
        }) {
            let chatItem = self.chatItems[index]
            if let groupedModel = chatItem as? GroupedImagesModel {
                if let deletedModelIndex = groupedModel.imagesModel.firstIndex(where: {
                    $0.messageId == messageId
                }) {
                    let leftModels = groupedModel.imagesModel[0..<deletedModelIndex]
                    let rightModels = groupedModel.imagesModel.suffix(from: deletedModelIndex+1)
                    
                    var deletedIndexPaths = [IndexPath]()
                    var insertedIndexPaths = [IndexPath]()
                    
                    let leftGroupedModel = GroupedImagesModel(models: Array(leftModels))
                    let rightGroupedModel = GroupedImagesModel(models: Array(rightModels))
                    self.chatItems.remove(at: index)
                    deletedIndexPaths.append(IndexPath(item: index, section: 0))
                    
                    if leftGroupedModel.imagesModel.count > 0 {
                        self.chatItems.insert(leftGroupedModel, at: index)
                        self.chatItems.insert(deletedChatItem, at: index+1)
                        if rightGroupedModel.imagesModel.count > 0 {
                            self.chatItems.insert(rightGroupedModel, at: index+2)
                        }
                    } else {
                        self.chatItems.insert(deletedChatItem, at: index)
                        if rightGroupedModel.imagesModel.count > 0 {
                            self.chatItems.insert(rightGroupedModel, at: index+1)
                        }
                    }
                    self.prepareItemsWithGroupedImages()
                    self.reprepareChatItems()
                    self.collectionView.reloadData()
                    
                    /*
                    if leftGroupedModel.imagesModel.count > 0 {
                        self.chatItems.insert(leftGroupedModel, at: index)
                        self.chatItems.insert(deletedChatItem, at: index+1)
                        insertedIndexPaths.append(IndexPath(item: index, section: 0))
                        insertedIndexPaths.append(IndexPath(item: index+1, section: 0))
                        if rightGroupedModel.imagesModel.count > 0 {
                            self.chatItems.insert(rightGroupedModel, at: index+1)
                            insertedIndexPaths.append(IndexPath(item: index+2, section: 0))
                        }
                    } else {
                        self.chatItems.insert(deletedChatItem, at: index)
                        insertedIndexPaths.append(IndexPath(item: index, section: 0))
                        if rightGroupedModel.imagesModel.count > 0 {
                            self.chatItems.insert(rightGroupedModel, at: index+1)
                            insertedIndexPaths.append(IndexPath(item: index+1, section: 0))
                        }
                    }
                    
                    self.collectionView.performBatchUpdates({
                        self.collectionView.deleteItems(at: deletedIndexPaths)
                        self.collectionView.insertItems(at: insertedIndexPaths)
                    }, completion: nil)
                    */
                }
            } else {
                self.chatItems.remove(at: index)
                self.chatItems.insert(deletedChatItem, at: index)
                
                if chatItem is TextMessageModel || chatItem is QuotedMessageModel {
                    self.chatItems.removeAll(where: {
                        $0.messageId.contains(
                            "#\(chatItem.messageId)#")
                    })
                }
                
                self.prepareItemsWithGroupedImages()
                self.reprepareChatItems()
                self.collectionView.reloadData()
//                self.collectionView.performBatchUpdates({
//                    self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
//                    self.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
//                }, completion: nil)
            }
        }
    }
    
    func removeItemsFromCollectionView(itemsIds: [String]) {
        itemsIds.forEach({
            let itemId = $0
            if let firstIndex = self.chatItems.firstIndex(where: {
                $0.messageId.contains(itemId)
            }) {
                let chatItem = self.chatItems[firstIndex]
                if let groupedModel = chatItem as? GroupedImagesModel {
                    groupedModel.imagesModel.removeAll(where: {
                        $0.messageId == itemId
                    })
                    if groupedModel.imagesModel.count == 1 {
                        self.chatItems.remove(at: firstIndex)
                        if let imageChatItem = groupedModel.imagesModel.first {
                            self.chatItems.insert(imageChatItem, at: firstIndex)
                        }
                    } else if groupedModel.imagesModel.count > 1{
                        self.chatItems.remove(at: firstIndex)
                        self.chatItems.insert(groupedModel, at: firstIndex)
                    } else {
                        self.chatItems.remove(at: firstIndex)
                    }
                } else {
        
                    self.chatItems.remove(at: firstIndex)
                    if chatItem is TextMessageModel || chatItem is QuotedMessageModel {
                        self.chatItems.removeAll(where: {
                            $0.messageId.contains(
                                "#\(chatItem.messageId)#")
                        })
                    }
                    /*
                    
                    var previousItem: BaseMessageItemProtocol?
                    var nextItem: BaseMessageItemProtocol?
                    
                    let isPreviousIndexValid = self.chatItems.indices.contains(firstIndex - 1)
                    let isNextIndexValid = self.chatItems.indices.contains(firstIndex + 1)
                    
                    if isNextIndexValid {
                        nextItem = self.chatItems[firstIndex + 1]
                    }
                    if isPreviousIndexValid {
                        previousItem = self.chatItems[firstIndex - 1]
                    }
                        
                    self.chatItems.remove(at: firstIndex)
                    if let previous = previousItem {
                        previous.showMessageStatusView = chatItem.showMessageStatusView
                    }
                    if let next = nextItem {
                        if next.senderId == chatItem.senderId {
                            next.showSenderName = chatItem.showSenderName
                        } else {
                            if next.senderId == previousItem?.senderId {
                                next.showSenderName = false
                            } else {
                                next.showSenderName = true
                            }
                        }
                        next.showDataSeperator = chatItem.showDataSeperator
                    }
                     */
                }
            }
        })
        self.prepareItemsWithGroupedImages()
        self.reprepareChatItems()
        self.collectionView.reloadData()
        //self.collectionView.reloadData()
        /*
        itemsIds.forEach({
            let itemId = $0
            if let firstIndex = self.chatItems.firstIndex(where: {
                $0.messageId.contains(itemId)
            }) {
                let chatItem = self.chatItems[firstIndex]
                if let groupedModel = chatItem as? GroupedImagesModel {
                    groupedModel.imagesModel.removeAll(where: {
                        $0.messageId == itemId
                    })
                    self.chatItems.remove(at: firstIndex)
                    self.chatItems.insert(groupedModel, at: firstIndex)
                    let deletedIndexPath = IndexPath(item: firstIndex, section: 0)
                    let insertedIndexPath = IndexPath(item: firstIndex, section: 0)
                    deletedIndexPaths.append(deletedIndexPath)
                    insertedIndexPaths.append(insertedIndexPath)
                } else {
                    self.chatItems.removeAll(where: {
                        $0.messageId == itemId
                    })
                    let deletedIndexPath = IndexPath(item: firstIndex, section: 0)
                    deletedIndexPaths.append(deletedIndexPath)
                }
                //self.collectionView.reloadData()
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: deletedIndexPaths)
                    self.collectionView.insertItems(at: insertedIndexPaths)
                    self.collectionView.reloadItems(at: reloadedIndexPaths)
                }, completion: { _ in
                    self.collectionView.reloadData()
                })
            }
        })
 */
    }
    
    
    
}


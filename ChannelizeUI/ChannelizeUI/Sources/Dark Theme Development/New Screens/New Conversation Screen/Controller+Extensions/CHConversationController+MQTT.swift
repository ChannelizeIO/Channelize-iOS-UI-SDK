//
//  CHConversationController+MQTT.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import DifferenceKit

extension CHConversationViewController: CHUserEventDelegates, CHConversationEventDelegate {
    // MARK: - Users Related MQTT Events Functions
    func didUserBlocked(model: CHUserBlockModel?) {
        guard let blockedUser = model?.blockedUser, let blockerUser = model?.blockerUser else {
            return
        }
        if blockedUser.id == Channelize.getCurrentUserId() {
            if blockerUser.id == self.conversation?.conversationPartner?.id {
                self.getConversationMembers()
            }
        } else {
            if blockedUser.id == self.conversation?.conversationPartner?.id {
                self.getConversationMembers()
            }
        }
    }
    
    func didUserUnBlocked(model: CHUserUnblockModel?) {
        guard let unblockedUser = model?.unblockedUser, let unblockerUser = model?.unblockerUser else {
            return
        }
        if unblockedUser.id == Channelize.getCurrentUserId() {
            if unblockerUser.id == self.conversation?.conversationPartner?.id {
                self.getConversationMembers()
            }
        } else {
            if unblockedUser.id == self.conversation?.conversationPartner?.id {
                self.getConversationMembers()
            }
        }
    }
    
    func didUserStatusUpdated(model: CHUserStatusUpdatedModel?) {
        guard model?.updatedUser?.id == self.conversation?.conversationPartner?.id else {
            return
        }
        guard let partnerId = self.conversation?.conversationPartner?.id else {
            return
        }
        ChannelizeAPIService.getUserInfo(userId: partnerId, completion: {(user,errorString) in
            guard errorString == nil else {
                print("Failed to Get User")
                print("Error: \(errorString ?? "")")
                return
            }
            self.conversation?.conversationPartner = user
            self.headerView.updatePartnerStatus(conversation: self.conversation)
        })
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
                typingText = String(format: CHLocalized(key: "pmUserTyping"), typingUserName)
            } else {
                typingText = CHLocalized(key: "pmTyping")
            }
            self.headerView.setTypingText(string: typingText)
        } else {
            if self.conversation?.isGroup == true {
                self.headerView.updateGroupMembersInfo(conversation: self.conversation)
            } else {
                self.headerView.updatePartnerStatus(conversation: self.conversation)
            }
        }
    }
    
    // MARK: - Conversations Related MQTT Events Functions
    func didUpdateConversationMuteStatus(model: CHConversationMuteStatusModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.conversation?.isMute = model?.conversation?.isMute
        self.conversation?.lastUpDatedAt = model?.conversation?.lastUpDatedAt
    }
    
    func didConversationDeleted(model: CHConversationDeleteModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func didConversationCleared(model: CHConversationClearModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.chatItems.removeAll()
        self.checkAndSetNoContentView()
    }
    
    func didMembersRemovedFromConversation(model: CHMembersRemovedModel?) {
        guard self.conversation?.isGroup == true else {
            return
        }
        guard self.conversation?.id == model?.conversation?.id else {
            return
        }
        guard let removedUsers = model?.removedUsers else {
            return
        }
        removedUsers.forEach({
            let userId = $0.id
            self.conversation?.members?.removeAll(where: {
                $0.user?.id == userId
            })
        })
        self.conversation?.membersCount = self.conversation?.members?.count
        self.headerView.updateGroupMembersInfo(conversation: self.conversation)
    }
    
    func didNewMembersAddedToConversation(model: CHNewMemberAddedModel?) {
        guard self.conversation?.isGroup == true else {
            return
        }
        guard self.conversation?.id == model?.conversation?.id else {
            return
        }
        guard let addedMembers = model?.addedMembers else {
            return
        }
        addedMembers.forEach({
            let member = $0
            if self.conversation?.members?.filter({
                $0.user?.id == member.user?.id
            }).count == 0 {
                self.conversation?.members?.append(member)
            }
        })
        self.conversation?.membersCount = self.conversation?.members?.count
        self.headerView.updateGroupMembersInfo(conversation: self.conversation)
    }
    
    func didCurrentUserRemovedFromConversation(model: CHCurrentUserRemovedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.conversation?.members?.removeAll(where: {
            $0.user?.id == Channelize.getCurrentUserId()
        })
        self.conversation?.membersCount = self.conversation?.members?.count
        self.conversation?.isActive = false
        self.headerView.updateGroupMembersInfo(conversation: self.conversation)
        self.blockStatusView.updateBlockStatusView(conversation: self.conversation, relationModel: nil)
    }
    
    func didCurrentUserJoinedConversation(model: CHCurrentUserJoinConversationModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        self.conversation?.isActive = true
        self.getConversationMembers()
    }
    
    func didNewAdminAddedToConversation(model: CHNewAdminAddedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        if let addedAdmin = model?.adminUser {
            if let adminMember = self.conversation?.members?.first(where: {
                $0.user?.id == addedAdmin.id
            }) {
                adminMember.isAdmin = true
            }
        }
        self.headerView.updateGroupMembersInfo(conversation: self.conversation)
    }
    
    func didConversationInfoUpdated(model: CHConversationUpdatedModel?) {
        guard model?.conversationID == self.conversation?.id else {
            return
        }
        self.conversation?.membersCount = model?.memberCount
        self.conversation?.profileImageUrl = model?.profileImageUrl
        self.conversation?.title = model?.title
        self.conversation?.createdAt = model?.createdAt
        self.conversation?.isGroup = model?.isGroup
        self.conversation?.lastUpDatedAt = model?.timeStamp
        self.headerView.updateGroupMembersInfo(conversation: self.conversation)
        self.headerView.updateGroupInformation(conversation: self.conversation)
    }
    
    func didConversationMarkAsRead(model: CHConversationMarkReadModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        if let readTimeDateString = ISODateTransform().transformToJSON(model?.timeStamp) {
            self.conversation?.lastReadDictionary?.updateValue(readTimeDateString, forKey: model?.user?.id ?? "")
            self.conversation?.updateLastMessageOldestRead()
        }
        let oldItems = self.chatItems.copy()
        let unreadMessages = self.chatItems.filter({
            $0.messageStatus == .sent
        })
        unreadMessages.forEach({
            let messageDate = $0.messageDate
            if messageDate <= self.conversation?.lastMessageOldestRead ?? Date() {
                $0.messageStatus = .seen
            }
        })
        let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
        self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
            self.chatItems = data
        }, completion: nil)
    }
    
    func didConversationMessageDeleted(model: CHMessageDeletedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        guard let deletedMessages = model?.deletedMessages else {
            return
        }
        
        let oldChatItems = self.chatItems.copy()
        let deletedMessageIds = deletedMessages.compactMap({ $0.id ?? ""})
        self.chatItems.removeAll(where: {
            deletedMessageIds.contains($0.messageId)
        })
        deletedMessageIds.forEach({
            let messageId = $0
            self.chatItems.removeAll(where: {
                $0.messageId.contains(messageId)
            })
        })
        
        self.reprepareChatItems()
        let changeSet = StagedChangeset(source: oldChatItems, target: self.chatItems)
        self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount < 500 }, setData: { data in
            self.chatItems = data
        })
        if self.chatItems.count == 0 {
            self.checkAndSetNoContentView()
        }
    }
    
    func didConversationMessageDeletedForEveryOne(model: CHMessageDeletedModel?) {
        guard model?.conversation?.id == self.conversation?.id else {
            return
        }
        guard let deletedMessages = model?.deletedMessages else {
            return
        }
        let oldChatItems = self.chatItems.copy()
        deletedMessages.forEach({
            let message = $0
            message.isDeleted = true
            if let deletedChatItem = self.prepareChatItems(message: message) {
                if let messageIndex = self.chatItems.firstIndex(where: {
                    $0.messageId == message.id
                }) {
                    self.chatItems.remove(at: messageIndex)
                    self.chatItems.insert(deletedChatItem, at: messageIndex)
                }
            }
            self.chatItems.removeAll(where: {
                $0.messageType == .linkPreview && ($0 as? LinkMessageItem)?.linkMetaData?.parentMessageId == message.id
            })
        })
        self.reprepareChatItems()
        let changeSet = StagedChangeset(source: oldChatItems, target: self.chatItems)
        self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount < 500 }, setData: { data in
            self.chatItems = data
        })
    }
    
    func didRecieveNewMessage(model: CHNewMessageRecievedModel?) {
        guard let recievedMessage = model?.message else {
            return
        }
        if self.conversation?.id == nil {
            if let firstConversation = CHConversationCache.instance.conversations.first(where: {
                $0.isGroup == false && $0.conversationPartner?.id == self.conversation?.conversationPartner?.id
            }) {
                self.conversation = firstConversation
                guard recievedMessage.conversationId == self.conversation?.id else {
                    return
                }
                self.appendMessage(recievedMessage: recievedMessage)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    if let firstConversation = CHConversationCache.instance.conversations.first(where: {
                        $0.isGroup == false && $0.conversationPartner?.id == self.conversation?.conversationPartner?.id
                    }) {
                        self.conversation = firstConversation
                        guard recievedMessage.conversationId == self.conversation?.id else {
                            return
                        }
                        self.appendMessage(recievedMessage: recievedMessage)
                    }
                })
            }
        } else {
            guard recievedMessage.conversationId == self.conversation?.id else {
                return
            }
            self.appendMessage(recievedMessage: recievedMessage)
        }
    }
    
    func appendMessage(recievedMessage: CHMessage) {
        self.noMessageContentView.removeFromSuperview()
        if let messageIndex = self.chatItems.firstIndex(where: {
            $0.messageId == recievedMessage.id
        }) {
            if let recievedChatItem = self.prepareChatItems(message: recievedMessage) {
                let oldChatItems = self.chatItems.copy()
                recievedChatItem.messageStatus = .sent
                self.chatItems.remove(at: messageIndex)
                self.chatItems.insert(recievedChatItem, at: messageIndex)
                self.reprepareChatItems()
                let changeSet = StagedChangeset(source: oldChatItems, target: self.chatItems)
                self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                    self.chatItems = data
                }, completion: {
                    
                })
            }
        } else {
            if let chatItem = self.prepareChatItems(message: recievedMessage) {
                let oldChatItems = self.chatItems.copy()
                self.chatItems.append(chatItem)
                self.reprepareChatItems()
                let changeSet = StagedChangeset(source: oldChatItems, target: self.chatItems)
                self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                    self.chatItems = data
                }, completion: {
                    if recievedMessage.ownerId == Channelize.getCurrentUserId() {
                        self.scrollToBottom(animated: false)
                    } else {
                        if self.moveToBottomButton.isHidden == false {
                            self.moveToBottomButton.updateBadgeCount()
                        }
                    }
                })
            }
        }
    }
    
    
    func didMessageReactionAdded(model: CHReactionEventModel?) {
        guard let reactionModel = model else {
            return
        }
        if let messageIndex = self.chatItems.firstIndex(where: {
            $0.messageId == reactionModel.message?.id
        }) {
            let chatItem = self.chatItems[messageIndex]
            
            if let existingReaction = chatItem.reactions.first(where: {
                $0.unicode == emojiCodes["\(reactionModel.reactionKey ?? "")"]
            }) {
                if reactionModel.reactingUserId == Channelize.getCurrentUserId() {
                    if !chatItem.myMessageReactions.contains(reactionModel.reactionKey ?? "") {
                        existingReaction.counts = (existingReaction.counts ?? 0) + 1
                        chatItem.reactions.sort(by: {
                            $0.counts ?? 0 > $1.counts ?? 0
                        })
                    }
                }
            } else {
                let model = ReactionModel()
                model.counts = 1
                model.unicode = emojiCodes["\(reactionModel.reactionKey ?? "")"]
                chatItem.reactions.append(model)
            }
            chatItem.reactions.sort(by: {
                $0.counts ?? 0 > $1.counts ?? 0
            })
            
            //chatItem.reactionCountsInfo = reactionModel.message?.reactionsCount ?? [:]
            
            if reactionModel.reactingUserId == Channelize.getCurrentUserId() {
                if let myReactionKey = reactionModel.reactionKey {
                    if chatItem.myMessageReactions.filter({
                        $0 == myReactionKey
                    }).count == 0 {
                        chatItem.myMessageReactions.append(myReactionKey)
                    }
                }
            }
            let indexPath = IndexPath(item: messageIndex, section: 0)
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [indexPath])
            }, completion: nil)
        }
    }
        
    func didMessageReactionRemoved(model: CHReactionEventModel?) {
        guard let reactionModel = model else {
            return
        }
        if let messageIndex = self.chatItems.firstIndex(where: {
            $0.messageId == reactionModel.message?.id
        }) {
            let chatItem = self.chatItems[messageIndex]
            if let existingReactionIndex = chatItem.reactions.firstIndex(where: {
                $0.unicode == emojiCodes["\(reactionModel.reactionKey ?? "")"]
            }) {
                let existingReaction = chatItem.reactions[existingReactionIndex]
                if reactionModel.reactingUserId == Channelize.getCurrentUserId() {
                    if chatItem.myMessageReactions.contains(reactionModel.reactionKey ?? "") {
                        if existingReaction.counts ?? 0 > 1 {
                            existingReaction.counts = (existingReaction.counts ?? 0) - 1
                        } else {
                            chatItem.reactions.remove(at: existingReactionIndex)
                        }
                    }
                } else {
                    if existingReaction.counts ?? 0 > 1 {
                        existingReaction.counts = (existingReaction.counts ?? 0) - 1
                    } else {
                        chatItem.reactions.remove(at: existingReactionIndex)
                    }
                }
                chatItem.reactions.sort(by: {
                    $0.counts ?? 0 > $1.counts ?? 0
                })
            }
//            chatItem.reactionCountsInfo = reactionModel.message?.reactionsCount ?? [:]
            if reactionModel.reactingUserId == Channelize.getCurrentUserId() {
                if let myReactionKey = reactionModel.reactionKey {
                    chatItem.myMessageReactions.removeAll(where: {
                        $0 == myReactionKey
                    })
                }
            }
            let indexPath = IndexPath(item: messageIndex, section: 0)
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [indexPath])
            }, completion: nil)
        }
    }
}


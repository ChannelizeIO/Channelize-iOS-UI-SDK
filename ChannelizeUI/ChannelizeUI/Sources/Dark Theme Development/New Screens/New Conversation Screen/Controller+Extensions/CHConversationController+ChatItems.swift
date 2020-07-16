//
//  CHConversationController+ChatItems.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import UIKit
import DifferenceKit

extension CHConversationViewController {
    
    func prepareNormalMessageItems(with messages: [CHMessage], isInitialLoad: Bool) {
        if isInitialLoad {
            messages.forEach({
                let message = $0
                if let chatItem = self.prepareChatItems(message: message) {
                    self.chatItems.insert(chatItem, at: 0)
                }
            })
            self.reprepareChatItems()
            self.getUnreadMessageItem()
            self.collectionView.reloadData()
            self.scrollToBottom(animated: false)
            self.markConversationRead()
        } else {
            let oldItems = self.chatItems.copy()
            var newChatItems = [ChannelizeChatItem]()
            messages.forEach({
                let message = $0
                if let chatItem = self.prepareChatItems(message: message) {
                    newChatItems.insert(chatItem, at: 0)
                }
            })
            self.chatItems.insert(contentsOf: newChatItems, at: 0)
            let oldOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.reprepareChatItems()
            let changeset = StagedChangeset(source: oldItems, target: self.chatItems)
            self.collectionView.reload(using: changeset, interrupt: { $0.changeCount > 500 }, setData: { data in
                self.chatItems = data
            }, completion: {
                self.collectionView.setContentOffset(CGPoint(x: 0, y: self.collectionView.contentSize.height - oldOffset), animated: false)
                self.isLoadingMessage = false
                CATransaction.commit()
            })
        }
    }
    
    func reprepareChatItems() {
        var modifiedItems = [ChannelizeChatItem]()
        for (index,item) in self.chatItems.enumerated() {
            let prev : ChannelizeChatItem? = (index > 0) ? chatItems[index - 1] : nil
            let next: ChannelizeChatItem? = (index + 1 < chatItems.count) ? chatItems[index + 1] : nil
            
            /// Set Properties compared to previous item
            if let previousItem = prev {
                // Check for date
                if !calendar.isDate(previousItem.messageDate, inSameDayAs: item.messageDate) {
                    item.showDataSeperator = true
                } else {
                    item.showDataSeperator = false
                }
                // Check for sender Id
                if previousItem.senderId == item.senderId {
                    item.showSenderName = false
                } else {
                    if item.isIncoming {
                        item.showSenderName = true
                    } else {
                        item.showSenderName = false
                    }
                }
            } else {
                item.showDataSeperator = true
                if item.isIncoming {
                    item.showSenderName = true
                } else {
                    item.showSenderName = false
                }
            }
            
            /// Set Properties Related to Next Item
            if let nextItem = next {
                // Check for Message Status View
                if item.senderId == nextItem.senderId {
                    if !calendar.isDate(item.messageDate, inSameDayAs: nextItem.messageDate) {
                        item.showMessageStatusView = true
                    } else {
                        item.showMessageStatusView = false
                    }
                } else {
                    item.showMessageStatusView = true
                }
            } else {
                item.showMessageStatusView = true
            }
            //modifiedItems.insert(item, at: 0)
            modifiedItems.append(item)
        }
        self.chatItems.removeAll()
        self.chatItems = modifiedItems
        
        self.chatItems.forEach({
            print($0.messageStatus)
            if self.conversation?.isGroup == false {
                $0.showSenderName = false
            }
            $0.isMessageSelectorOn = false
        })
        
    }
    
    func getUnreadMessageItem() {
        if let lastReadDateInfo = self.conversation?.lastReadDateDictionary {
            if let myLastReadDate = lastReadDateInfo.first(where: {
                $0.key == Channelize.getCurrentUserId()
            }) {
                self.chatItems.first(where: {
                    $0.messageDate > myLastReadDate.value && $0.senderId != Channelize.getCurrentUserId()
                })?.showUnreadMessageLabel = true
            }
        }
    }
    
    func prepareChatItems(message: CHMessage) -> ChannelizeChatItem?{
        let baseMessageData = self.prepareBaseMessageModel(message: message)
        let messageType = self.getMessageType(message: message)
        switch messageType {
        case .deletedMessage:
            let textMessageData = TextMessageData(messageBody: message.body, mentionedUsers: message.mentionedUser)
            let textChatItem = TextMessageItem(baseMessageModel: baseMessageData, textMessageData: textMessageData, isDeletedMessage: true)
            return textChatItem
        case .text:
            var messageBody: String?
            if message.isEncrypted == true {
                do {
                    messageBody = try self.ethreeObject?.authDecrypt(text: message.body ?? "", from: self.myLookUpResults?[message.owner?.id ?? ""])
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                messageBody = message.body
            }
            let textMessageData = TextMessageData(messageBody: messageBody, mentionedUsers: message.mentionedUser)
            let textChatItem = TextMessageItem(baseMessageModel: baseMessageData, textMessageData: textMessageData, isDeletedMessage: false)
            if CHCustomOptions.enableMessageReactions {
                textChatItem.myMessageReactions = message.myReactions ?? []
                textChatItem.reactionCountsInfo = message.reactionsCount ?? [:]
                textChatItem.reactions = createMessageReactionModels(chatItem: textChatItem)
            }
            return textChatItem
        case .gifSticker:
            let gifStickerData = GifStickerMessageData(stillUrl: message.attachments?.first?.gifStickerStillUrl, downSampledUrl: message.attachments?.first?.gifStickerDownloadUrl, originalUrl: message.attachments?.first?.gifStickerOriginalUrl)
            let gifStickerMessageItem = GifStickerMessageItem(baseMessageModel: baseMessageData, gifStickerData: gifStickerData)
            if CHCustomOptions.enableMessageReactions {
                gifStickerMessageItem.myMessageReactions = message.myReactions ?? []
                gifStickerMessageItem.reactionCountsInfo = message.reactionsCount ?? [:]
                gifStickerMessageItem.reactions = createMessageReactionModels(chatItem: gifStickerMessageItem)
            }
            return gifStickerMessageItem
        case .location:
            let locationMessageData = LocationMessageData(locationName: message.attachments?.first?.locationTitle, locationAddress: message.attachments?.first?.locationAddress, locationLatitude: message.attachments?.first?.locationLatitude, locationLongitude: message.attachments?.first?.locationLongitude)
            let locationMessageItem = LocationMessageItem(baseMessageModel: baseMessageData, locationData: locationMessageData)
            if CHCustomOptions.enableMessageReactions {
                locationMessageItem.myMessageReactions = message.myReactions ?? []
                locationMessageItem.reactionCountsInfo = message.reactionsCount ?? [:]
                locationMessageItem.reactions = createMessageReactionModels(chatItem: locationMessageItem)
            }
            return locationMessageItem
        case .audio:
            let audioMessageData = AudioMessageData(url: message.attachments?.first?.fileUrl, duration: message.attachments?.first?.audioDuration)
            let audioMessageItem = AudioMessageItem(baseMessageModel: baseMessageData, audioData: audioMessageData)
            if CHCustomOptions.enableMessageReactions {
                audioMessageItem.myMessageReactions = message.myReactions ?? []
                audioMessageItem.reactionCountsInfo = message.reactionsCount ?? [:]
                audioMessageItem.reactions = createMessageReactionModels(chatItem: audioMessageItem)
            }
            audioMessageItem.isEncrypted = message.isEncrypted
            return audioMessageItem
        case .video:
            let videoMessageData = VideoMessageData(videoUrlString: message.attachments?.first?.fileUrl, thumbnailUrlString: message.attachments?.first?.thumbnailUrl)
            let videoChatItem = VideoMessageItem(baseMessageModel: baseMessageData, videoMessageData: videoMessageData)
            if CHCustomOptions.enableMessageReactions {
                videoChatItem.myMessageReactions = message.myReactions ?? []
                videoChatItem.reactionCountsInfo = message.reactionsCount ?? [:]
                videoChatItem.reactions = createMessageReactionModels(chatItem: videoChatItem)
            }
            videoChatItem.isEncrypted = message.isEncrypted
            return videoChatItem
        case .image:
            let imageMessageData = ImageMessageData(imageUrlString: message.attachments?.first?.fileUrl)
            let imageChatItem = ImageMessageItem(baseMessageModel: baseMessageData, imageMessageData: imageMessageData)
            if CHCustomOptions.enableMessageReactions {
                imageChatItem.myMessageReactions = message.myReactions ?? []
                imageChatItem.reactionCountsInfo = message.reactionsCount ?? [:]
                imageChatItem.reactions = createMessageReactionModels(chatItem: imageChatItem)
            }
            imageChatItem.isEncrypted = message.isEncrypted
            return imageChatItem
        case .doc:
            let fileName = message.attachments?.first?.name
            let docDownloadUrl = message.attachments?.first?.fileUrl
            let fileType = message.attachments?.first?.attachmentExtension
            let fileSize = message.attachments?.first?.attachMentSize
            
            let docMessageData = DocMessageData(fileName: fileName, downloadUrl: docDownloadUrl, fileType: fileType, fileSize: fileSize, mimeType: message.attachments?.first?.mimeType, fileExtension: message.attachments?.first?.attachmentExtension)
            let docMessageModel = DocMessageItem(baseMessageModel: baseMessageData, docMessageData: docMessageData)
            if CHCustomOptions.enableMessageReactions {
                docMessageModel.myMessageReactions = message.myReactions ?? []
                docMessageModel.reactionCountsInfo = message.reactionsCount ?? [:]
                docMessageModel.reactions = createMessageReactionModels(chatItem: docMessageModel)
            }
            if let fileUrl = URL(string: docMessageModel.docMessageData?.downloadUrl ?? "") {
                let fileName = fileUrl.lastPathComponent
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent(fileName)
                if NSData(contentsOf: fileURL) != nil {
                    docMessageModel.docStatus = .availableLocal
                }
            }
            docMessageModel.isEncrypted = message.isEncrypted
            return docMessageModel
        case .metaMessage:
            if let firstAttachment = message.attachments?.first {
                guard firstAttachment.type == .metaMessage else  {
                    return nil
                }
                guard let messageType = firstAttachment.adminMessageType else {
                    return nil
                }
                guard let metaData = firstAttachment.metaData else {
                    return nil
                }
                let metaMessageData = MetaMessageData(type: messageType, subId: metaData.subjectId, subType: metaData.subjectType, objType: metaData.objectType, object: metaData.objectValues, subjectUser: metaData.subjectUser, objectUsers: metaData.objectUsers)
                let metaMessageChatItem = MetaMessageItem(baseMessageModel: baseMessageData, metaMessageData: metaMessageData)
                return metaMessageChatItem
            }
            return nil
        case .quotedMessage:
            var messageBody: String?
            if message.isEncrypted == true {
                do {
                    messageBody = try self.ethreeObject?.authDecrypt(text: message.body ?? "", from: self.myLookUpResults?[message.owner?.id ?? ""])
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                messageBody = message.body
            }
            let quotedMessageData = QuotedMessageData(messageBody: messageBody, mentionedUsers: message.mentionedUser, quotedMessageModel: nil)
            let quotedMessageItem = QuotedMessageItem(baseMessageModel: baseMessageData, parentMessage: message.parentMessage, isDeletedMessage: false, quotedMessageData: quotedMessageData)
            if CHCustomOptions.enableMessageReactions {
                quotedMessageItem.myMessageReactions = message.myReactions ?? []
                quotedMessageItem.reactionCountsInfo = message.reactionsCount ?? [:]
                quotedMessageItem.reactions = createMessageReactionModels(chatItem: quotedMessageItem)
            }
            return quotedMessageItem
        default:
            return nil
        }
    }
    
    private func prepareBaseMessageModel(message: CHMessage) -> BaseMessageModel{
        
        let messageId = message.id ?? ""
        let senderId = message.ownerId ?? ""
        let senderName = message.owner?.displayName ?? ""
        let senderImageUrl = message.owner?.profileImageUrl ?? ""
        let messageDate = message.createdAt ?? Date()
        let messageStatus = self.getMessageStatus(messageDate: messageDate)
        
        let baseMessageData = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl, messageDate: messageDate, status: messageStatus)
        return baseMessageData
    }
    
    private func getMessageStatus(messageDate: Date) -> BaseMessageStatus {
        if let oldestRead = self.conversation?.lastMessageOldestRead {
            if messageDate <= oldestRead {
                return .seen
            } else {
                return .sent
            }
        } else {
            return .sent
        }
    }
    
    private func getMessageType(message: CHMessage) -> BaseMessageType{
        
        guard let messageType = message.messageType else {
            return .undefined
        }
        if message.isDeleted == true {
            return .deletedMessage
        }
        
        switch messageType {
        case .normal, .forward :
            if message.body != nil {
                return .text
            } else {
                guard let firstAttachment = message.attachments?.first else {
                    return .undefined
                }
                guard let attachmentType = firstAttachment.type else {
                    return .undefined
                }
                switch attachmentType {
                case .image:
                    return .image
                case .location:
                    return .location
                case .audio:
                    return .audio
                case .video:
                    return .video
                case .gif, .sticker:
                    return .gifSticker
                case .doc:
                    return .doc
                default:
                    return .undefined
                }
            }
        case .admin:
            if let firstAttachment = message.attachments?.first {
                guard firstAttachment.type == .metaMessage else  {
                    return .undefined
                }
                guard let messageType = firstAttachment.adminMessageType else {
                    return .undefined
                }
                guard firstAttachment.metaData != nil else {
                    return .undefined
                }
                if messageType == .missedVideoCall {
                    return .missedVideoCall
                } else if messageType == .missedVoiceCall {
                    return .missedVoiceCall
                } else {
                    return .metaMessage
                }
                
            }
        default:
            return .quotedMessage
        }
        return .undefined
    }
    
    func createMessageReactionModels(chatItem: ChannelizeChatItem) -> [ReactionModel] {
        var reactionsModels = [ReactionModel]()
        let reactionCountInfo = chatItem.reactionCountsInfo.sorted(by: { $0.value > $1.value })
        reactionCountInfo.forEach({
            let model = ReactionModel()
            model.counts = $0.value
            model.unicode = emojiCodes[$0.key]
            if model.counts ?? 0 > 0 {
                reactionsModels.append(model)
            }
        })
        return reactionsModels
    }

}


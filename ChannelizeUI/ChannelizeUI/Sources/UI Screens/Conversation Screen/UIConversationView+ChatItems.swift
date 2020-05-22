//
//  UIConversationView+ChatItems.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import ObjectMapper
import UIKit

extension UIConversationViewController {
    func addMoreMessagesOnTop(messages: [CHMessage]) {
        var chatMessageItems = [BaseMessageItemProtocol]()
        messages.forEach({
            if let chatItem = self.createChatItemFromMessage(message: $0) {
                chatMessageItems.insert(chatItem, at: 0)
            }
        })
        var newItems = [BaseMessageItemProtocol]()
        for(index, item) in chatMessageItems.enumerated() {
            let prev : BaseMessageItemProtocol? = (index > 0) ? chatMessageItems[index - 1] : nil
            let next: BaseMessageItemProtocol? = (index + 1 < chatMessageItems.count) ? chatMessageItems[index + 1] : nil
            if prev == nil {
                item.showDataSeperator = true
                if item.isIncoming {
                    item.showSenderName = true
                }
                item.messageStatus = self.getMessageStatus(
                itemMessageDate: item.messageDate)
                if let nextItem = next {
                    if nextItem.senderId == item.senderId {
                        item.showMessageStatusView = false
                    } else {
                        item.showMessageStatusView = true
                    }
                } else {
                    item.showMessageStatusView = true
                }
                newItems.append(item)
            } else {
                if let previousItem = prev {
                    if !calendar.isDate(item.messageDate, inSameDayAs: previousItem.messageDate) {
                        // Also show sender name if applicable
                        if item.isIncoming {
                            item.showSenderName = true
                        }
                        item.showDataSeperator = true
                    }
                    // 2. Check for Sender Name
                    if item.senderId != previousItem.senderId {
                        if item.isIncoming {
                            item.showSenderName = true
                        }
                    } else {
                        if previousItem is MetaMessageModel {
                            if item.isIncoming {
                                item.showSenderName = true
                            } else {
                                item.showSenderName = false
                            }
                            
                        }
                    }
                }
                item.messageStatus = self.getMessageStatus(
                    itemMessageDate: item.messageDate)
                if let nextItem = next {
                    if nextItem.senderId == item.senderId {
                        item.showMessageStatusView = false
                    } else {
                        item.showMessageStatusView = true
                    }
                } else {
                    item.showMessageStatusView = true
                }
                newItems.append(item)
            }
        }
        let oldTopItem = self.chatItems[0]
        let newLastItem = newItems[newItems.count - 1]
        if calendar.isDate(oldTopItem.messageDate, inSameDayAs: newLastItem.messageDate) {
            oldTopItem.showDataSeperator = false
        }
        if oldTopItem.senderId == newLastItem.senderId {
            newLastItem.showMessageStatusView = false
            oldTopItem.showSenderName = false
        }
        
        self.chatItems.insert(contentsOf: newItems, at: 0)
        self.chatItems.forEach({
            if self.conversation?.isGroup == false {
                $0.showSenderName = false
            }
            if $0.messageType == .missedVoiceCall || $0.messageType == .missedVideoCall {
                $0.isMessageSelectorOn = false
            } else {
                $0.isMessageSelectorOn = self.isMessageSelectorOn
            }
        })
        
        var reloadedIndexPaths = [IndexPath]()
        let reloadedIndex = IndexPath(item: 0, section: 0)
        reloadedIndexPaths.append(reloadedIndex)
        
        var insertedIndexPaths = [IndexPath]()
        insertedIndexPaths = (0..<chatMessageItems.count).map { return IndexPath(item: $0, section: 0)}
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let oldOffset2 = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: reloadedIndexPaths)
            self.collectionView.insertItems(at: insertedIndexPaths)
        }, completion: { _ in
            self.isLoadingMessage = false
            self.collectionView.setContentOffset(CGPoint(x: 0, y: self.collectionView.contentSize.height - oldOffset2), animated: false)
            CATransaction.commit()
        })
    }
    
    func prepareConversationItems(messages: [CHMessage]) {
        var chatMessageItems = [BaseMessageItemProtocol]()
        messages.forEach({
            if let chatItem = self.createChatItemFromMessage(message: $0) {
                chatMessageItems.insert(chatItem, at: 0)
            }
        })
        
        for(index, item) in chatMessageItems.enumerated() {
            let prev : BaseMessageItemProtocol? = (index > 0) ? chatMessageItems[index - 1] : nil
            let next: BaseMessageItemProtocol? = (index + 1 < chatMessageItems.count) ? chatMessageItems[index + 1] : nil
            if prev == nil {
                item.showDataSeperator = true
                if item.isIncoming {
                    item.showSenderName = true
                }
                item.messageStatus = self.getMessageStatus(
                itemMessageDate: item.messageDate)
                if let nextItem = next {
                    if nextItem.senderId == item.senderId {
                        item.showMessageStatusView = false
                    } else {
                        item.showMessageStatusView = true
                    }
                } else {
                    item.showMessageStatusView = true
                }
                self.chatItems.append(item)
            } else {
                if let previousItem = prev {
                    if !calendar.isDate(item.messageDate, inSameDayAs: previousItem.messageDate) {
                        // Also show sender name if applicable
                        if item.isIncoming {
                            item.showSenderName = true
                        }
                        item.showDataSeperator = true
                    }
                    // 2. Check for Sender Name
                    if item.senderId != previousItem.senderId {
                        if item.isIncoming {
                            item.showSenderName = true
                        }
                    } else {
                        if previousItem is MetaMessageModel {
                            if item.isIncoming {
                                item.showSenderName = true
                            } else {
                                item.showSenderName = false
                            }
                            
                        }
                    }
                }
                item.messageStatus = self.getMessageStatus(
                    itemMessageDate: item.messageDate)
                if let nextItem = next {
                    if nextItem.senderId == item.senderId {
                        item.showMessageStatusView = false
                    } else {
                        item.showMessageStatusView = true
                    }
                } else {
                    item.showMessageStatusView = true
                }
                self.chatItems.append(item)
            }
        }
        /*
        for(index,item) in preparedChatItems.enumerated() {
            let prev : BaseMessageItemProtocol? = (index > 0) ? preparedChatItems[index - 1] : nil
            let next: BaseMessageItemProtocol? = (index + 1 < preparedChatItems.count) ? preparedChatItems[index + 1] : nil
            // Check Previous Message, if it is nil, means it is first message, add date seperator to it
            if prev == nil {
                item.showDataSeperator = true
                if item.isIncoming {
                    item.showSenderName = true
                }
                item.messageStatus = self.getMessageStatus(
                    itemMessageDate: item.messageDate)
                if let nextItem = next {
                    if nextItem.senderId == item.senderId {
                        item.showMessageStatusView = false
                    } else {
                        item.showMessageStatusView = true
                    }
                } else {
                    item.showMessageStatusView = true
                }
                self.chatItems.append(item)
                //self.chatItems.append(item)
            } else {
                // Means there is previous Message
                if let previousItem = prev {
                    // 1. First Check Date of Message
                    if !calendar.isDate(item.messageDate, inSameDayAs: previousItem.messageDate) {
                        // Also show sender name if applicable
                        if item.isIncoming {
                            item.showSenderName = true
                        }
                        item.showDataSeperator = true
                    }
                    // 2. Check for Sender Name
                    if item.senderId != previousItem.senderId {
                        if item.isIncoming {
                            item.showSenderName = true
                        }
                    } else {
                        if previousItem is MetaMessageModel {
                            if item.isIncoming {
                                item.showSenderName = true
                            } else {
                                item.showSenderName = false
                            }
                            
                        }
                    }
                }
                item.messageStatus = self.getMessageStatus(
                    itemMessageDate: item.messageDate)
                if let nextItem = next {
                    if nextItem.senderId == item.senderId {
                        item.showMessageStatusView = false
                    } else {
                        item.showMessageStatusView = true
                    }
                } else {
                    item.showMessageStatusView = true
                }
                self.chatItems.append(item)
            }
        }
        
        
        
        
        
        var preparedChatItems = [BaseMessageItemProtocol]()
        var currentGroup = [BaseMessageItemProtocol]()
        for(index,item) in chatMessageItems.enumerated() {
            let previous: BaseMessageItemProtocol? = (index > 0) ? chatMessageItems[index - 1] : nil
            let last: BaseMessageItemProtocol? = index == chatMessageItems.count - 1 ? item : nil
            if let pre = previous {
                if pre.senderId == item.senderId {
                    if pre.messageType == item.messageType && item.messageType == .image {
                        currentGroup.append(item)
                    } else {
                        if item.messageType == .image {
                            currentGroup.append(item)
                        } else {
                            if currentGroup.count > 0 {
                                if currentGroup.count == 1 {
                                    preparedChatItems.append(
                                        currentGroup.first!)
                                    currentGroup.removeAll()
                                } else {
                                    let groupedImagesModel = GroupedImagesModel(models: currentGroup)
                                    if groupedImagesModel.imagesModel.count > 0 {
                                        preparedChatItems.append(
                                            groupedImagesModel)
                                        currentGroup.removeAll()
                                    }
                                }
                            }
                            preparedChatItems.append(item)
                        }
                    }
                } else {
                    if currentGroup.count > 0 {
                        if currentGroup.count == 1 {
                            preparedChatItems.append(currentGroup.first!)
                            currentGroup.removeAll()
                        } else {
                            let groupedImagesModel = GroupedImagesModel(models: currentGroup)
                            if groupedImagesModel.imagesModel.count > 0 {
                                preparedChatItems.append(
                                    groupedImagesModel)
                                currentGroup.removeAll()
                            }
                        }
                    }
                    if item.messageType == .image {
                        currentGroup.append(item)
                    } else {
                        if currentGroup.count > 0 {
                            if currentGroup.count == 1 {
                                preparedChatItems.append(currentGroup.first!)
                                currentGroup.removeAll()
                            } else {
                                let groupedImagesModel = GroupedImagesModel(models: currentGroup)
                                if groupedImagesModel.imagesModel.count > 0 {
                                    preparedChatItems.append(
                                        groupedImagesModel)
                                    currentGroup.removeAll()
                                }
                            }
                        }
                        preparedChatItems.append(item)
                    }
                }
            } else {
                if item.messageType == .image {
                    currentGroup.append(item)
                } else {
                    preparedChatItems.append(item)
                }
            }
            if last != nil {
                if currentGroup.count > 0 {
                    if currentGroup.count == 1 {
                        preparedChatItems.append(currentGroup.first!)
                        currentGroup.removeAll()
                    } else {
                        let groupedImagesModel = GroupedImagesModel(models: currentGroup)
                        if groupedImagesModel.imagesModel.count > 0 {
                            preparedChatItems.append(groupedImagesModel)
                            currentGroup.removeAll()
                        }
                    }
                }
            }
        }
        
        for(index,item) in preparedChatItems.enumerated() {
            let prev : BaseMessageItemProtocol? = (index > 0) ? preparedChatItems[index - 1] : nil
            let next: BaseMessageItemProtocol? = (index + 1 < preparedChatItems.count) ? preparedChatItems[index + 1] : nil
            // Check Previous Message, if it is nil, means it is first message, add date seperator to it
            if prev == nil {
                item.showDataSeperator = true
                if item.isIncoming {
                    item.showSenderName = true
                }
                item.messageStatus = self.getMessageStatus(
                    itemMessageDate: item.messageDate)
                if let nextItem = next {
                    if nextItem.senderId == item.senderId {
                        item.showMessageStatusView = false
                    } else {
                        item.showMessageStatusView = true
                    }
                } else {
                    item.showMessageStatusView = true
                }
                self.chatItems.append(item)
                //self.chatItems.append(item)
            } else {
                // Means there is previous Message
                if let previousItem = prev {
                    // 1. First Check Date of Message
                    if !calendar.isDate(item.messageDate, inSameDayAs: previousItem.messageDate) {
                        // Also show sender name if applicable
                        if item.isIncoming {
                            item.showSenderName = true
                        }
                        item.showDataSeperator = true
                    }
                    // 2. Check for Sender Name
                    if item.senderId != previousItem.senderId {
                        if item.isIncoming {
                            item.showSenderName = true
                        }
                    } else {
                        if previousItem is MetaMessageModel {
                            if item.isIncoming {
                                item.showSenderName = true
                            } else {
                                item.showSenderName = false
                            }
                            
                        }
                    }
                }
                item.messageStatus = self.getMessageStatus(
                    itemMessageDate: item.messageDate)
                if let nextItem = next {
                    if nextItem.senderId == item.senderId {
                        item.showMessageStatusView = false
                    } else {
                        item.showMessageStatusView = true
                    }
                } else {
                    item.showMessageStatusView = true
                }
                self.chatItems.append(item)
            }
        }
        */
        self.chatItems.forEach({
            print($0.messageStatus)
            if self.conversation?.isGroup == false {
                $0.showSenderName = false
            }
            $0.isMessageSelectorOn = false
        })
        if let firstUnreadItemIndex = self.getFirstUnreadMessageIndex() {
            let unreadMessageModel = UnReadMessageModel()
            self.chatItems.insert(unreadMessageModel, at: firstUnreadItemIndex)
        }
        print(self.chatItems)
    }
    
    func getFirstUnreadMessageIndex() -> Int? {
        if let lastReadByMe = self.conversation?.lastReadByMe {
            if let firstMessageIndex = self.chatItems.firstIndex(where: {
                $0.messageDate > lastReadByMe
            }) {
                return firstMessageIndex
            }
        }
        return nil
    }
    
    func getMessageStatus(itemMessageDate: Date) -> BaseMessageStatus {
        let dateTransformer = ISODateTransform()
        if let lastReadInfoDic = self.conversation?.lastReadDictionary {
            var lastReadData = [String:Date]()
            lastReadInfoDic.forEach({(id,date) in
                if let memberReadDate = dateTransformer.transformFromJSON(date) {
                    lastReadData.updateValue(memberReadDate, forKey: id)
                }
            })
            let sortedData = lastReadData.sorted(by: {$0.value < $1.value})
            if let oldestReader = sortedData.first {
                let oldestReadDate = oldestReader.value
                if itemMessageDate <= oldestReadDate {
                    return .seen
                } else {
                    return .sent
                }
            }
        }
        return .sent
    }
    
    func createChatItemFromMessage(
        message: CHMessage) -> BaseMessageItemProtocol? {
        let baseMessageData = self.prepareBaseMessageModel(message: message)
        let messageType = self.getMessageType(message: message)
        switch messageType {
        case .gifSticker:
            let downSampledUrl = message.attachments?.first?.gifStickerDownloadUrl
            let stillUrl = message.attachments?.first?.gifStickerStillUrl
            let originalUrl = message.attachments?.first?.gifStickerOriginalUrl
            let gifStickerModel = GifStickerMessageModel(baseMessageModel: baseMessageData, downSampledUrl: downSampledUrl, stillUrl: stillUrl, originalUrl: originalUrl)
            if CHCustomOptions.enableMessageReactions {
                gifStickerModel.myMessageReactions = message.myReactions ?? []
                gifStickerModel.reactionCountsInfo = message.reactionsCount ?? [:]
                gifStickerModel.reactions = createReactionModels(chatItem: gifStickerModel)
            }
            return gifStickerModel
        case .deletedMessage:
            let deletedMessageModel = TextMessageModel(messageBody: nil, mentionedUsers: nil, baseMessageModel: baseMessageData, isDeleted: true)
            return deletedMessageModel
        case .text:
            let messageBody = message.body
            let textMessageModel = TextMessageModel(messageBody: messageBody, mentionedUsers: message.mentionedUser, baseMessageModel: baseMessageData)
            if CHCustomOptions.enableMessageReactions {
                textMessageModel.myMessageReactions = message.myReactions ?? []
                textMessageModel.reactionCountsInfo = message.reactionsCount ?? [:]
                textMessageModel.reactions = createReactionModels(chatItem: textMessageModel)
            }
            return textMessageModel
        case .image:
            let imageUrl = message.attachments?.first?.fileUrl
            let imageMessageModel = ImageMessageModel(baseMessageModel: baseMessageData, fileImageUrl: imageUrl)
            if CHCustomOptions.enableMessageReactions {
                imageMessageModel.myMessageReactions = message.myReactions ?? []
                imageMessageModel.reactionCountsInfo = message.reactionsCount ?? [:]
                imageMessageModel.reactions = createReactionModels(chatItem: imageMessageModel)
            }
            return imageMessageModel
        case .video:
            let videoUrl = message.attachments?.first?.fileUrl
            let thumbnailUrl = message.attachments?.first?.thumbnailUrl
            let videoMessageModel = VideoMessageModel(baseMessageModel: baseMessageData, videoUrl: videoUrl, thumbnailUrl: thumbnailUrl)
            if CHCustomOptions.enableMessageReactions {
                videoMessageModel.myMessageReactions = message.myReactions ?? []
                videoMessageModel.reactionCountsInfo = message.reactionsCount ?? [:]
                videoMessageModel.reactions = createReactionModels(chatItem: videoMessageModel)
            }
            return videoMessageModel
        case .audio:
            let audioUrl = message.attachments?.first?.fileUrl
            let audioDuration = message.attachments?.first?.audioDuration
            let audioMessageModel = AudioMessageModel(baseMessageModel: baseMessageData, audioUrl: audioUrl, audioDuration: audioDuration)
            if CHCustomOptions.enableMessageReactions {
                audioMessageModel.myMessageReactions = message.myReactions ?? []
                audioMessageModel.reactionCountsInfo = message.reactionsCount ?? [:]
                audioMessageModel.reactions = createReactionModels(chatItem: audioMessageModel)
            }
            return audioMessageModel
        case .location:
            let locationName = message.attachments?.first?.locationTitle
            let locationAddress = message.attachments?.first?.locationAddress
            let locationLatitude = message.attachments?.first?.locationLatitude
            let locationLongitude = message.attachments?.first?.locationLongitude
            let locationMessageModel = LocationMessageModel(baseMessageModel: baseMessageData, locationName: locationName, locationAddress: locationAddress, locationLatitude: locationLatitude, locationLongitude: locationLongitude)
            if CHCustomOptions.enableMessageReactions {
                locationMessageModel.myMessageReactions = message.myReactions ?? []
                locationMessageModel.reactionCountsInfo = message.reactionsCount ?? [:]
                locationMessageModel.reactions = createReactionModels(chatItem: locationMessageModel)
            }
            return locationMessageModel
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
                let metaMessageModel = MetaMessageModel(baseMessageModel: baseMessageData, metaMessageData: metaMessageData)
                return metaMessageModel
            }
            return nil
        case .quotedMessage:
            let messageBody = message.body
            let quotedMessageModel = QuotedMessageModel(messageBody: messageBody, mentionedUsers: message.mentionedUser, baseMessageModel: baseMessageData, parentMessage: message.parentMessage)
            if CHCustomOptions.enableMessageReactions {
                quotedMessageModel.myMessageReactions = message.myReactions ?? []
                quotedMessageModel.reactionCountsInfo = message.reactionsCount ?? [:]
                quotedMessageModel.reactions = createReactionModels(chatItem: quotedMessageModel)
            }
            return quotedMessageModel
        case .missedVideoCall:
            let callerName = message.attachments?.first?.metaData?.objectUser?.displayName?.capitalized
            let callerId = message.attachments?.first?.metaData?.objectUser?.id
            let recieverName = message.attachments?.first?.metaData?.subjectUser?.displayName?.capitalized
            let recieverId = message.attachments?.first?.metaData?.subjectUser?.id
            let missCallModel = MissCallMessageModel(baseMessageModel: baseMessageData, callType: .video, callerName: callerName, callerId: callerId, recieverName: recieverName, recieverId: recieverId)
            return missCallModel
        case .missedVoiceCall:
            let callerName = message.attachments?.first?.metaData?.objectUser?.displayName?.capitalized
            let callerId = message.attachments?.first?.metaData?.objectUser?.id
            let recieverName = message.attachments?.first?.metaData?.subjectUser?.displayName?.capitalized
            let recieverId = message.attachments?.first?.metaData?.subjectUser?.id
            let missCallModel = MissCallMessageModel(baseMessageModel: baseMessageData, callType: .voice, callerName: callerName, callerId: callerId, recieverName: recieverName, recieverId: recieverId)
            return missCallModel
        case .doc:
            let fileName = message.attachments?.first?.name
            let docDownloadUrl = message.attachments?.first?.fileUrl
            let fileType = message.attachments?.first?.attachmentExtension
            let fileSize = message.attachments?.first?.attachMentSize
            
            let docMessageData = DocMessageData(fileName: fileName, downloadUrl: docDownloadUrl, fileType: fileType, fileSize: fileSize, mimeType: message.attachments?.first?.mimeType, fileExtension: message.attachments?.first?.attachmentExtension)
            let docMessageModel = DocMessageModel(baseMessageModel: baseMessageData, messageData: docMessageData)
            if CHCustomOptions.enableMessageReactions {
                docMessageModel.myMessageReactions = message.myReactions ?? []
                docMessageModel.reactionCountsInfo = message.reactionsCount ?? [:]
                docMessageModel.reactions = createReactionModels(chatItem: docMessageModel)
            }
            if let fileUrl = URL(string: docMessageModel.docMessageData.downloadUrl ?? "") {
                let fileName = fileUrl.lastPathComponent
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent(fileName)
                if NSData(contentsOf: fileURL) != nil {
                    docMessageModel.docStatus = .availableLocal
                }
            }
            return docMessageModel
        default:
            return nil
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
    
    private func getMessageStatus(messageDate: Date) -> BaseMessageStatus{
        if self.conversation?.isGroup == true {
            //self.conversation?.lastReadAtByPartner
        } else {
            for(memberId,lastReadDate) in self.conversation?.lastReadDictionary ?? ["":""] {
                if memberId != Channelize.getCurrentUserId() {
                    let dateTrasform = ISODateTransform()
                    if let readDate = dateTrasform.transformFromJSON(lastReadDate) {
                        self.conversation?.lastReadAtByPartner = readDate
                    }
                }
            }
            if messageDate <= self.conversation?.lastReadAtByPartner ?? Date() {
                return .seen
            } else {
                return .sent
            }
            
        }
        return .sent
    }
    
    func detectLinkItems() {
        let textItems = self.chatItems.filter({
            $0.messageType == .text || $0.messageType == .quotedMessage
        })
        textItems.forEach({
            if let textModel = $0 as? TextMessageModel {
                self.detectAndAddLinkMessages(with: textModel)
            }
        })
    }
    
    func detectAndAddLinkMessages(with message: TextMessageModel){
        let textString = message.messageBody ?? ""
        
        var shouldAddLinkModel = true
        
        self.chatItems.forEach({
            if let linkItem = $0 as? LinkPreviewModel {
                if linkItem.linkData?.parentMessageId == message.messageId{
                    shouldAddLinkModel = false
                }
            }
        })
        
        if shouldAddLinkModel == false{
            return
        }
        
        do{
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let range = NSRange(location: 0, length: textString.utf16.count)
            let resultArray = detector.matches(in: textString, options: [], range: range)
            
            let linkMetaData = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: DispatchQueue.main, cache: DisabledCache.instance)
            for result in resultArray.reversed(){
                guard let range = Range(result.range, in: textString) else { continue }
                let url = textString[range]
                print("Detected Links in Text message is \(url)")
                
                linkMetaData.preview(String(url), onSuccess: { response in
                    print("===============")
                    print(response.title ?? "")
                    print(response.description ?? "")
                    print(response.image ?? "")
                    
                    let linkMetaModel = LinkMetaDataModel(title: response.title, description: response.description, imageUrl: response.image, parentId: message.messageId, linkUrl: response.finalUrl?.absoluteString)
                    
                    let prefixId = self.randomId(length: 4)
                    let suffixId = self.randomId(length: 4)
                    let messageId = "\(prefixId)#\(message.messageId ?? "")#\(suffixId)"
                    
                    var baseMessageModel = BaseMessageModel(uid: messageId, senderId: message.senderId, senderName: message.senderName, senderImageUrl: message.senderImageUrl, messageDate: message.messageDate, status: .sent)
                    
                    let linkPreviewModel = LinkPreviewModel(baseMessageModel: baseMessageModel, linkData: linkMetaModel)
                    if let parentMessageIndex = self.chatItems.firstIndex(where: {
                        $0.messageId == message.messageId
                    }) {
                        self.chatItems.insert(linkPreviewModel, at: parentMessageIndex + 1)
                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        let oldOffset2 = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
                        self.collectionView.performBatchUpdates({
                            self.collectionView.insertItems(at: [IndexPath(item: parentMessageIndex + 1, section: 0)])
                        }, completion: {(completed) in
                            self.collectionView.setContentOffset(CGPoint(x: 0, y: self.collectionView.contentSize.height - oldOffset2), animated: false)
                            CATransaction.commit()
                        })
                    }
                    
                    print("+++++++++++++++")
                }, onError: { error in
                    print("===============")
                    print(error.description)
                    print("+++++++++++++++")
                })
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func randomId(length:Int=6) -> String{
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    
    func insertNewChatItemAtBottom(chatItem: BaseMessageItemProtocol, isScrollToLast: Bool = true) {
        var reloadPreviousIndex = false
        
        if let previousItem = self.chatItems.last {
            // Check for date
            if !calendar.isDate(previousItem.messageDate, inSameDayAs: chatItem.messageDate) {
                chatItem.showDataSeperator = true
            } else {
                chatItem.showDataSeperator = false
            }
            // Check for sender Id
            if previousItem.senderId == chatItem.senderId {
                chatItem.showSenderName = false
            } else {
                if chatItem.isIncoming {
                    chatItem.showSenderName = true
                } else {
                    chatItem.showSenderName = false
                }
            }

            if previousItem.senderId == chatItem.senderId {
                reloadPreviousIndex = true
                previousItem.showMessageStatusView = false
            } else {
                previousItem.showMessageStatusView = true
            }
            chatItem.showMessageStatusView = true
            
        } else {
            chatItem.showDataSeperator = true
            if chatItem.isIncoming {
                chatItem.showSenderName = true
            } else {
                chatItem.showSenderName = false
            }
            chatItem.showMessageStatusView = true
        }
        self.chatItems.append(chatItem)
        if self.chatItems.count == 1 {
            self.collectionView.reloadSections(IndexSet(integer: 0))
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.collectionView.reloadData()
            CATransaction.commit()
            //self.collectionView.reloadData()
            //self.collectionView.reloadSections(IndexSet(integer: 0))
            /*
            var reloadedIndexPaths = [IndexPath]()
            let insertedIndexPath = IndexPath(item: self.chatItems.count - 1, section: 0)
            if reloadPreviousIndex {
                let reloadedIndexPath = IndexPath(item: self.chatItems.count - 2, section: 0)
                reloadedIndexPaths.append(reloadedIndexPath)
            }
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: [insertedIndexPath])
                self.collectionView.reloadItems(at: reloadedIndexPaths)
            }, completion: {(completed) in
                if completed {
                    self.collectionView.scrollToLast(animated: false)
                }
            })
        */
        }
        if isScrollToLast {
            self.collectionView.scrollToLast(animated: false)
        }
    }
    
    func reloadDataOnMessageLoad(isInitialLoad: Bool) {
        if isInitialLoad {
            self.collectionView.reloadData()
        } else {
            
        }
    }
    
    
    func prepareNormalMessageItems(with messages: [CHMessage], isInitialLoad: Bool) {
        if isInitialLoad {
            messages.forEach({
                let message = $0
                if let chatItem = self.createChatItemFromMessage(message: message) {
                    self.chatItems.insert(chatItem, at: 0)
                }
//                if let jsonObject = Mapper<CHRealmMessageModel>().map(JSON: $0.toJSON()) {
//                    print(jsonObject)
//                    RealmService.shared.updateObject(jsonObject)
//                }
            })
            self.isLoadingMessage = false
            self.isLoadingInitialMessage = false
            self.prepareItemsWithGroupedImages()
            self.reprepareChatItems()
            self.collectionView.reloadData()
            if self.chatItems.count > 0 {
                self.scrollToBottom(animated: false)
            }
        } else {
            let oldNumberOfItems = self.chatItems.count
            messages.forEach({
                let message = $0
                if let chatItem = self.createChatItemFromMessage(message: message) {
                    self.chatItems.insert(chatItem, at: 0)
                }
//                if let jsonObject = Mapper<CHRealmMessageModel>().map(JSON: $0.toJSON()) {
//                    print(jsonObject)
//                    RealmService.shared.updateObject(jsonObject)
//                }
            })
            self.prepareItemsWithGroupedImages()
            self.reprepareChatItems()
            let newNumberOfItems = self.chatItems.count
            let newInsertedItemsCount = newNumberOfItems - oldNumberOfItems
            var insertedIndexPaths = [IndexPath]()
            for i in 0 ..< newInsertedItemsCount {
                let path = IndexPath(item: i, section: 0)
                insertedIndexPaths.append(path)
            }
            var reloadedIndexPaths = [IndexPath]()
            for i in newNumberOfItems ..< self.chatItems.count {
                let path = IndexPath(item: i, section: 0)
                reloadedIndexPaths.append(path)
            }
            let oldOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            self.collectionView.performBatchUpdates({
                //self.collectionView.reloadItems(at: reloadedIndexPaths)
                self.collectionView.insertItems(at: insertedIndexPaths)
            }, completion: {(completed) in
                self.collectionView.setContentOffset(CGPoint(x: 0, y: self.collectionView.contentSize.height - oldOffset), animated: false)
                self.collectionView.reloadData()
                self.isLoadingMessage = false
                CATransaction.commit()
            })
            
            
        }
        
    }
    
    
    func prepareItemsWithGroupedImages() {
        var preparedChatItems = [BaseMessageItemProtocol]()
        var currentGroup = [BaseMessageItemProtocol]()
        for(index,item) in chatItems.enumerated() {
            let previous: BaseMessageItemProtocol? = (index > 0) ? chatItems[index - 1] : nil
            let last: BaseMessageItemProtocol? = index == chatItems.count - 1 ? item : nil
            if let pre = previous {
                if pre.senderId == item.senderId {
                    if pre.messageType == item.messageType && item.messageType == .image {
                        currentGroup.append(item)
                    } else {
                        if item.messageType == .image {
                            currentGroup.append(item)
                        } else {
                            if currentGroup.count > 0 {
                                if currentGroup.count == 1 {
                                    preparedChatItems.append(
                                        currentGroup.first!)
                                    currentGroup.removeAll()
                                } else {
                                    let groupedImagesModel = GroupedImagesModel(models: currentGroup)
                                    if groupedImagesModel.imagesModel.count > 0 {
                                        preparedChatItems.append(
                                            groupedImagesModel)
                                        currentGroup.removeAll()
                                    }
                                }
                            }
                            preparedChatItems.append(item)
                        }
                    }
                } else {
                    if currentGroup.count > 0 {
                        if currentGroup.count == 1 {
                            preparedChatItems.append(currentGroup.first!)
                            currentGroup.removeAll()
                        } else {
                            let groupedImagesModel = GroupedImagesModel(models: currentGroup)
                            if groupedImagesModel.imagesModel.count > 0 {
                                preparedChatItems.append(
                                    groupedImagesModel)
                                currentGroup.removeAll()
                            }
                        }
                    }
                    if item.messageType == .image {
                        currentGroup.append(item)
                    } else {
                        if currentGroup.count > 0 {
                            if currentGroup.count == 1 {
                                preparedChatItems.append(currentGroup.first!)
                                currentGroup.removeAll()
                            } else {
                                let groupedImagesModel = GroupedImagesModel(models: currentGroup)
                                if groupedImagesModel.imagesModel.count > 0 {
                                    preparedChatItems.append(
                                        groupedImagesModel)
                                    currentGroup.removeAll()
                                }
                            }
                        }
                        preparedChatItems.append(item)
                    }
                }
            } else {
                if item.messageType == .image {
                    currentGroup.append(item)
                } else {
                    preparedChatItems.append(item)
                }
            }
            if last != nil {
                if currentGroup.count > 0 {
                    if currentGroup.count == 1 {
                        preparedChatItems.append(currentGroup.first!)
                        currentGroup.removeAll()
                    } else {
                        let groupedImagesModel = GroupedImagesModel(models: currentGroup)
                        if groupedImagesModel.imagesModel.count > 0 {
                            preparedChatItems.append(groupedImagesModel)
                            currentGroup.removeAll()
                        }
                    }
                }
            }
        }
        self.chatItems.removeAll()
        self.chatItems = preparedChatItems
    }
    
    func reprepareChatItems() {
        var modifiedItems = [BaseMessageItemProtocol]()
        for (index,item) in self.chatItems.enumerated() {
            let prev : BaseMessageItemProtocol? = (index > 0) ? chatItems[index - 1] : nil
            let next: BaseMessageItemProtocol? = (index + 1 < chatItems.count) ? chatItems[index + 1] : nil
            
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
            modifiedItems.append(item)
        }
        self.chatItems.removeAll()
        self.chatItems = modifiedItems
    }
    
    
    func updateSendingMessageStatus(message: CHMessage?) {
        guard let messageId = message?.id else {
            return
        }
        if let messageIndex = self.chatItems.firstIndex(where: {
            $0.messageId == messageId
        }) {
            if let recievedMessage = message {
                if let chatItem = self.createChatItemFromMessage(message: recievedMessage) {
                    switch chatItem.messageType {
                    case .image:
                        self.updateImageMessageData(chatItem: chatItem, messageIndex: messageIndex)
                        break
                    case .doc:
                        if let docMessageModel = chatItem as? DocMessageModel {
                            docMessageModel.messageStatus = .sent
                            if let fileUrl = URL(string: docMessageModel.docMessageData.downloadUrl ?? "") {
                                let newFileName = fileUrl.lastPathComponent
                                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                let newFileUrl = documentsURL.appendingPathComponent(newFileName)
                                if FileManager.default.fileExists(atPath: newFileUrl.path) {
                                    docMessageModel.docStatus = .availableLocal
                                } else {
                                    docMessageModel.docStatus = .notAvailableLocal
                                }
                            }
                        }
                        let oldChatItem = self.chatItems[messageIndex]
                        chatItem.showSenderName = oldChatItem.showSenderName
                        chatItem.showDataSeperator = oldChatItem.showDataSeperator
                        chatItem.showMessageStatusView = oldChatItem.showMessageStatusView
                        self.chatItems.remove(at: messageIndex)
                        self.chatItems.insert(chatItem, at: messageIndex)
                        let reloadedIndexPath = IndexPath(item: messageIndex, section: 0)
                        self.collectionView.performBatchUpdates({
                            self.collectionView.reloadItems(at: [reloadedIndexPath])
                        }, completion: nil)
                        break
                    default:
                        let oldChatItem = self.chatItems[messageIndex]
                        chatItem.showSenderName = oldChatItem.showSenderName
                        chatItem.showDataSeperator = oldChatItem.showDataSeperator
                        chatItem.showMessageStatusView = oldChatItem.showMessageStatusView
                        self.chatItems.remove(at: messageIndex)
                        self.chatItems.insert(chatItem, at: messageIndex)
                        let reloadedIndexPath = IndexPath(item: messageIndex, section: 0)
                        self.collectionView.performBatchUpdates({
                            self.collectionView.reloadItems(at: [reloadedIndexPath])
                        }, completion: nil)
                        if chatItem.messageType == .text || chatItem.messageType == .quotedMessage {
                            if let textItem = chatItem as? TextMessageModel {
                                self.detectAndAddLinkMessages(with: textItem)
                            }
                        }
                        break
                    }
                }
            }
        }
    }
}

func createReactionModels(chatItem: BaseMessageItemProtocol) -> [ReactionModel] {
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

//
//  CHQuotedMessageModel.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/11/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import DifferenceKit
import UIKit

class QuotedMessageData: Equatable {
    static func == (lhs: QuotedMessageData, rhs: QuotedMessageData) -> Bool {
        return lhs.messageBody == rhs.messageBody
    }
    
    var messageBody: String?
    var mentionedUsers: [CHMentionedUser]?
    var quotedMessageModel: QuotedViewModel?
    
    init(messageBody: String?, mentionedUsers: [CHMentionedUser]?, quotedMessageModel: QuotedViewModel? = nil) {
        self.messageBody = messageBody
        self.mentionedUsers = mentionedUsers
        self.quotedMessageModel = quotedMessageModel
        self.decodeHtmlBody()
    }
    
    private func decodeHtmlBody() {
        var mutabelMessage = self.messageBody
        mutabelMessage = mutabelMessage?.replacingOccurrences(of: "&lt;", with: "<")
        mutabelMessage = mutabelMessage?.replacingOccurrences(of: "&gt;", with: ">")
        mutabelMessage = mutabelMessage?.replacingOccurrences(of: "&amp;", with: "&")
        mutabelMessage = mutabelMessage?.replacingOccurrences(of: "&#39;", with: "'")
        mutabelMessage = mutabelMessage?.replacingOccurrences(of: "&quot;", with: "\"")
        self.messageBody = mutabelMessage
    }
}

class QuotedMessageItem: ChannelizeChatItem {
    var attributedString: NSAttributedString?
    var quotedMessageData: QuotedMessageData?
    var parentMessage: CHMessage?
    var isDeletedMessage: Bool?
    
    var isTranslated: Bool? = false
    var translatedAttributedString: NSAttributedString?
    var translatedString: String? {
        didSet {
            let attributes = [NSAttributedString.Key.font: CHCustomStyles.textMessageFont!, NSAttributedString.Key.foregroundColor: CHUIConstant.outGoingTextMessageColor]
            if self.translatedString != nil || self.translatedString != "" {
                self.translatedAttributedString = NSAttributedString(string: self.translatedString ?? "", attributes: attributes)
            } else {
                self.translatedAttributedString = nil
            }
        }
    }
    
    init(baseMessageModel: BaseMessageModel, parentMessage: CHMessage?, isDeletedMessage: Bool?, quotedMessageData: QuotedMessageData?) {
        super.init(baseMessageModel: baseMessageModel, messageType: isDeletedMessage == true ? .deletedMessage : .quotedMessage)
        self.isDeletedMessage = isDeletedMessage
        self.parentMessage = parentMessage
        self.quotedMessageData = quotedMessageData
        self.prepareAttributedString()
        self.prepareQuotedMessageModel(message: self.parentMessage)
    }
    
    private func prepareQuotedMessageModel(message: CHMessage?) {
        guard let recievedMessage = message else {
            return
        }
        let isIncoming = self.baseMessageModel.isIncoming
        
        var textBody = recievedMessage.body ?? ""
        textBody = textBody.replacingOccurrences(of: "&lt;", with: "<")
        textBody = textBody.replacingOccurrences(of: "&gt;", with: ">")
        textBody = textBody.replacingOccurrences(of: "&amp;", with: "&")
        textBody = textBody.replacingOccurrences(of: "&#39;", with: "'")
        textBody = textBody.replacingOccurrences(of: "&quot;", with: "\"")
        let formattedMessageBody = textBody.replacingOccurrences(of: "%s", with: "%@")
        var mentionedNames = [String]()
        var mentionedUserDictionary = [String:String]()
        
        if let mentionedUsers = recievedMessage.mentionedUser {
            mentionedUsers.forEach({
                mentionedNames.append(
                    $0.user?.displayName?.capitalized ?? "")
            })
        }
        let taggedBodyString = String(format: formattedMessageBody, arguments: mentionedNames)
        if let mentionedUsers = recievedMessage.mentionedUser?.sorted(by: { $0.order! < $1.order!}) {
            if mentionedUsers.count > 0 {
                mentionedUsers.forEach({
                    mentionedUserDictionary.updateValue(
                        $0.user?.displayName?.capitalized ?? "", forKey: $0.user?.id ?? "")
                })
            }
        }
        let newBody = taggedBodyString.replacingOccurrences(of: "```", with: "$")
        let markDownMessage = MarkDown.shared.tranverseString(string: newBody, startingIndex: 0, textColor: self.isIncoming == true ? CHUIConstant.incomingTextMessageColor : CHUIConstant.outGoingTextMessageColor, withFont: CHCustomStyles.smallSizeRegularFont!)
        
        var attributedString: NSMutableAttributedString!
        attributedString = markDownMessage
        
        for (_,memberName) in mentionedUserDictionary{
            let allRanges = attributedString.string.ranges(of: memberName)
            if allRanges.count > 0 {
                for range in allRanges {
                    let nsRange = NSRange(range, in: attributedString.string)
                    attributedString.addAttribute(.font, value: UIFont(fontStyle: .medium, size: CHCustomStyles.smallSizeRegularFont!.pointSize)!, range: nsRange)
                    attributedString.addAttribute(
                    .foregroundColor, value: self.isIncoming == true ? CHUIConstant.incomingTextMessageColor : CHUIConstant.outGoingTextMessageColor, range: nsRange)
                }
            }
        }
        let parentMessageId = recievedMessage.id
        let senderName = recievedMessage.owner?.displayName
        let senderId = recievedMessage.owner?.id
        var imageUrl = recievedMessage.attachments?.first?.thumbnailUrl
        
        if imageUrl == nil {
            imageUrl = recievedMessage.attachments?.first?.gifStickerStillUrl
        }
        
        var textMessage = attributedString
        let typeOfMessage: BaseMessageType = self.getMessageType(message: recievedMessage)
        if typeOfMessage == .doc {
            if let fileExtension = recievedMessage.attachments?.first?.attachmentExtension?.lowercased() {
                imageUrl = mimeTypeIcon["\(fileExtension)"]
            } else {
                imageUrl = "chFileIcon"
            }
            textMessage = NSMutableAttributedString(string: recievedMessage.attachments?.first?.name ?? "", attributes: [ NSAttributedString.Key.font: CHCustomStyles.smallSizeRegularFont!, NSAttributedString.Key.foregroundColor: isIncoming ? UIColor(hex: "#3A3C4C") : UIColor.white])
        }
        self.quotedMessageData?.quotedMessageModel = QuotedViewModel(parentId: parentMessageId, senderName: senderName, senderId: senderId, imageUrl: imageUrl, textMessage: textMessage, messageType: typeOfMessage, isIncoming: isIncoming)
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let item = QuotedMessageItem(baseMessageModel: self.baseMessageModel, parentMessage: self.parentMessage, isDeletedMessage: self.isDeletedMessage, quotedMessageData: self.quotedMessageData)
        item.messageStatus = self.messageStatus
        item.showSenderName = self.showSenderName
        item.showDataSeperator = self.showDataSeperator
        item.showMessageStatusView = self.showMessageStatusView
        item.isMessageSelectorOn = self.isMessageSelectorOn
        item.isMessageSelected = self.isMessageSelected
        item.reactions = self.reactions
        item.myMessageReactions = self.myMessageReactions
        item.reactionCountsInfo = self.reactionCountsInfo
        item.showUnreadMessageLabel = self.showUnreadMessageLabel
        return item
    }
    
    override func isContentEqual(to source: ChannelizeChatItem) -> Bool {
        guard let textMessage = source as? QuotedMessageItem else {
            return false
        }
        let check = textMessage.baseMessageModel == self.baseMessageModel &&
            textMessage.messageType == self.messageType &&
            textMessage.messageStatus == self.messageStatus &&
            textMessage.showSenderName == self.showSenderName &&
            textMessage.showDataSeperator == self.showDataSeperator &&
            textMessage.showMessageStatusView == self.showMessageStatusView &&
            textMessage.isMessageSelectorOn == self.isMessageSelectorOn &&
            textMessage.isMessageSelected == self.isMessageSelected &&
            textMessage.reactions == self.reactions &&
            textMessage.myMessageReactions == self.myMessageReactions &&
            textMessage.reactionCountsInfo == self.reactionCountsInfo &&
            textMessage.isDeletedMessage == self.isDeletedMessage &&
            textMessage.showUnreadMessageLabel == self.showUnreadMessageLabel
        return check
    }
    
    private func prepareAttributedString() {
        
        if self.isDeletedMessage == true {
            let deletedMessageAttributes: [NSAttributedString.Key:Any] = [
                NSAttributedString.Key.font: UIFont(fontStyle: .lightItalic, size: CHCustomStyles.textMessageFont!.pointSize)!,
                NSAttributedString.Key.foregroundColor: self.baseMessageModel.isIncoming == true ? CHUIConstant.incomingTextMessageColor : CHUIConstant.outGoingTextMessageColor
            ]
            let deletedAttributedString = NSAttributedString(string: "This message was deleted", attributes: deletedMessageAttributes)
            self.attributedString = deletedAttributedString
        } else {
            let messageBody = self.quotedMessageData?.messageBody ?? ""
            let formattedMessageBody = messageBody.replacingOccurrences(of: "%s", with: "%@")
            var mentionedNames = [String]()
            var mentionedUserDictionary = [String:String]()
            
            if let mentionedUsers = self.quotedMessageData?.mentionedUsers {
                mentionedUsers.forEach({
                    mentionedNames.append($0.user?.displayName?.capitalized ?? "")
                })
            }
            let taggedBodyString = String(format: formattedMessageBody, arguments: mentionedNames)
            if let mentionedUsers = self.quotedMessageData?.mentionedUsers?.sorted(by: { $0.order! < $1.order! }), mentionedUsers.count > 0 {
                mentionedUsers.forEach({
                    mentionedUserDictionary.updateValue(
                        $0.user?.displayName?.capitalized ?? "", forKey: $0.user?.id ?? "")
                })
            }
            
            let newBody = taggedBodyString.replacingOccurrences(of: "```", with: "$")
            let markDownMessage = MarkDown.shared.tranverseString(string: newBody, startingIndex: 0, textColor: self.isIncoming == true ? CHUIConstant.incomingTextMessageColor : CHUIConstant.outGoingTextMessageColor, withFont: CHCustomStyles.textMessageFont!)
            
            var attributedString: NSMutableAttributedString!
            attributedString = markDownMessage
            
            for (_,memberName) in mentionedUserDictionary{
                let allRanges = attributedString.string.ranges(of: memberName)
                if allRanges.count > 0 {
                    for range in allRanges {
                        let nsRange = NSRange(range, in: attributedString.string)
                        attributedString.addAttribute(.font, value: UIFont(fontStyle: .medium, size: CHUIConstant.textMessageFont.pointSize)!, range: nsRange)
                        attributedString.addAttribute(
                            .foregroundColor, value: self.isIncoming == true ? CHUIConstant.incomingTextMessageColor : CHUIConstant.outGoingTextMessageColor, range: nsRange)
                    }
                }
            }
            self.attributedString = attributedString
        }
    }
    
    private func getMessageType(message: CHMessage) -> BaseMessageType{
        
        guard let messageType = message.messageType else {
            return .location
        }
        if message.isDeleted == true {
            return .deletedMessage
        }
        
        switch messageType {
        case .normal:
            if message.body != nil {
                return .text
            } else {
                guard let firstAttachment = message.attachments?.first else {
                    return .location
                }
                guard let attachmentType = firstAttachment.type else {
                    return .location
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
                    return .location
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
    
}


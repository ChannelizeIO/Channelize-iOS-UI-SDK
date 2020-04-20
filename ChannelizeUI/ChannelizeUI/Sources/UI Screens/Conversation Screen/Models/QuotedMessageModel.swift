//
//  QuotedMessageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/24/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import DifferenceKit

class QuotedMessageModel: BaseMessageItemProtocol, Differentiable {
    
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: QuotedMessageModel) -> Bool {
        return self.showMessageStatusView == source.showMessageStatusView && self.showSenderName == source.showSenderName && self.showDataSeperator == source.showDataSeperator
    }
    
    var showSenderName: Bool = false
    
    var showDataSeperator: Bool = false
    
    var showMessageStatusView: Bool = false
    
    var messageId: String {
        return self.baseMessageModel.messageId
    }
    
    var isIncoming: Bool {
        return self.baseMessageModel.isIncoming
    }
    
    var senderId: String {
        return self.baseMessageModel.senderId
    }
    
    var senderName: String {
        return self.baseMessageModel.senderName
    }
    
    var senderImageUrl: String {
        return self.baseMessageModel.senderImageUrl
    }
    
    var messageDate: Date {
        return self.baseMessageModel.messageDate
    }
    
    var messageStatus: BaseMessageStatus
    
    var messageType: BaseMessageType {
        return .quotedMessage
    }
    
    var isMessageSelectorOn: Bool = false
    
    var isMessageSelected: Bool = false
    
    var uploadProgress: Double = 0.0
    
    var baseMessageModel: BaseMessageModel
    
    var messageBody: String?
    
    var mentionedUsers: [CHMentionedUser]?
    
    var attributedString: NSAttributedString?
    
    var isDeletedMessage: Bool
    
    var quotedMessageModel: QuotedViewModel?
    
    init(messageBody: String?, mentionedUsers: [CHMentionedUser]?, baseMessageModel: BaseMessageModel, isDeleted: Bool = false, parentMessage: CHMessage?) {
        self.baseMessageModel = baseMessageModel
        self.messageBody = messageBody
        self.mentionedUsers = mentionedUsers
        self.messageStatus = baseMessageModel.messageStatus
        self.isDeletedMessage = isDeleted
        self.decodeHtmlBody()
        self.prepareAttributedString()
        self.prepareQuotedMessageModel(message: parentMessage)
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
        let markDownMessage = MarkDown.shared.tranverseString(string: newBody, startingIndex: 0, textColor: isIncoming ? UIColor(hex: "#3A3C4C") : UIColor.white , withFont: UIFont(fontStyle: .robotoSlabRegualar, size: CHUIConstants.normalFontSize)!)
        
        var attributedString: NSMutableAttributedString!
        attributedString = markDownMessage
        
        for (_,memberName) in mentionedUserDictionary{
            let allRanges = attributedString.string.ranges(of: memberName)
            if allRanges.count > 0 {
                for range in allRanges {
                    let nsRange = NSRange(range, in: attributedString.string)
                    attributedString.addAttribute(.font, value: UIFont(fontStyle: .robotoSlabMedium, size: CHUIConstants.normalFontSize)!, range: nsRange)
                    attributedString.addAttribute(
                        .foregroundColor, value: self.isIncoming == true ? UIColor(hex: "#3A3C4C") : UIColor.white, range: nsRange)
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
        
        let textMessage = attributedString
        let typeOfMessage: BaseMessageType = self.getMessageType(message: recievedMessage)
        self.quotedMessageModel = QuotedViewModel(parentId: parentMessageId, senderName: senderName, senderId: senderId, imageUrl: imageUrl, textMessage: textMessage, messageType: typeOfMessage, isIncoming: isIncoming)
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
            break
        }
        return .undefined
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
    
    private func prepareAttributedString() {
        
        if self.isDeletedMessage == true {
            let deletedMessageAttributes: [NSAttributedString.Key:Any] = [
                NSAttributedString.Key.font: UIFont(fontStyle: .robotoItalic, size: CHUIConstants.normalFontSize)!,
                NSAttributedString.Key.foregroundColor: self.isIncoming == true ? UIColor(hex: "#1c1c1c") : UIColor.white
            ]
            let deletedAttributedString = NSAttributedString(string: "This message was deleted", attributes: deletedMessageAttributes)
            self.attributedString = deletedAttributedString
        } else {
            let messageBody = self.messageBody ?? ""
            let formattedMessageBody = messageBody.replacingOccurrences(of: "%s", with: "%@")
            var mentionedNames = [String]()
            var mentionedUserDictionary = [String:String]()
            
            if let mentionedUsers = self.mentionedUsers {
                mentionedUsers.forEach({
                    mentionedNames.append($0.user?.displayName?.capitalized ?? "")
                })
            }
            let taggedBodyString = String(format: formattedMessageBody, arguments: mentionedNames)
            if let mentionedUsers = self.mentionedUsers?.sorted(by: { $0.order! < $1.order! }), mentionedUsers.count > 0 {
                
                mentionedUsers.forEach({
                    mentionedUserDictionary.updateValue(
                        $0.user?.displayName?.capitalized ?? "", forKey: $0.user?.id ?? "")
                })
            }
            let newBody = taggedBodyString.replacingOccurrences(of: "```", with: "$")
            let markDownMessage = MarkDown.shared.tranverseString(string: newBody, startingIndex: 0, textColor: self.isIncoming == true ? UIColor(hex: "#3A3C4C") : UIColor.white, withFont: UIFont(fontStyle: .robotoRegular, size: CHUIConstants.normalFontSize)!)
            
            var attributedString: NSMutableAttributedString!
            attributedString = markDownMessage
            
            for (_,memberName) in mentionedUserDictionary{
                let allRanges = attributedString.string.ranges(of: memberName)
                if allRanges.count > 0 {
                    for range in allRanges {
                        let nsRange = NSRange(range, in: attributedString.string)
                        attributedString.addAttribute(.font, value: UIFont(fontStyle: .robotoMedium, size: CHUIConstants.normalFontSize)!, range: nsRange)
                        attributedString.addAttribute(
                            .foregroundColor, value: self.isIncoming == true ? UIColor(hex: "#1c1c1c") : UIColor.white, range: nsRange)
                    }
                }
            }
            self.attributedString = attributedString
        }

    }
}


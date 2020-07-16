//
//  CHTextMessageItem.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit
import ChannelizeAPI

class TextMessageData: Equatable {
    static func == (lhs: TextMessageData, rhs: TextMessageData) -> Bool {
        return lhs.attributedString == rhs.attributedString
    }
    
    var messageBody: String?
    var mentionedUsers: [CHMentionedUser]?
    var attributedString: NSAttributedString?
    
    init(messageBody: String?, mentionedUsers: [CHMentionedUser]?) {
        self.messageBody = messageBody
        self.mentionedUsers = mentionedUsers
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

class TextMessageItem: ChannelizeChatItem {
    var attributedString: NSAttributedString?
    var textMessageData: TextMessageData?
    var isDeletedMessage: Bool?
    init(baseMessageModel: BaseMessageModel, textMessageData: TextMessageData?, isDeletedMessage: Bool?) {
        super.init(baseMessageModel: baseMessageModel, messageType: isDeletedMessage == true ? .deletedMessage : .text)
        self.textMessageData = textMessageData
        self.isDeletedMessage = isDeletedMessage
        self.prepareAttributedString()
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let item = TextMessageItem(baseMessageModel: self.baseMessageModel, textMessageData: self.textMessageData, isDeletedMessage: self.isDeletedMessage)
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
        guard let textMessage = source as? TextMessageItem else {
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
            textMessage.textMessageData == self.textMessageData &&
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
            let messageBody = self.textMessageData?.messageBody ?? ""
            let formattedMessageBody = messageBody.replacingOccurrences(of: "%s", with: "%@")
            var mentionedNames = [String]()
            var mentionedUserDictionary = [String:String]()
            
            if let mentionedUsers = self.textMessageData?.mentionedUsers {
                mentionedUsers.forEach({
                    mentionedNames.append($0.user?.displayName?.capitalized ?? "")
                })
            }
            let taggedBodyString = String(format: formattedMessageBody, arguments: mentionedNames)
            if let mentionedUsers = self.textMessageData?.mentionedUsers?.sorted(by: { $0.order! < $1.order! }), mentionedUsers.count > 0 {
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
                        attributedString.addAttribute(.font, value: UIFont(fontStyle: .medium, size: CHCustomStyles.textMessageFont!.pointSize)!, range: nsRange)
                        attributedString.addAttribute(
                            .foregroundColor, value: self.isIncoming == true ? CHUIConstant.incomingTextMessageColor : CHUIConstant.outGoingTextMessageColor, range: nsRange)
                    }
                }
            }
            self.attributedString = attributedString
        }
    }
    
}


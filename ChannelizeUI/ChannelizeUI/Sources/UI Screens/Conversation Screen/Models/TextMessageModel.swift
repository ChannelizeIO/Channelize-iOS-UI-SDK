//
//  TextMessageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/5/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import DifferenceKit

class TextMessageModel: BaseMessageItemProtocol, Differentiable {
    
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: TextMessageModel) -> Bool {
        return self.showMessageStatusView == source.showMessageStatusView && self.showSenderName == source.showSenderName && self.showDataSeperator == source.showDataSeperator
    }
    
    var showMessageStatusView: Bool = false
    
    var showSenderName: Bool = false
    
    var showDataSeperator: Bool = false
    
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
        if self.isDeletedMessage == true {
            return .deletedMessage
        } else {
            return .text
        }
    }
    
    var isMessageSelectorOn: Bool = false
    
    var isMessageSelected: Bool = false
    
    var uploadProgress: Double = 0.0
    
    var baseMessageModel: BaseMessageModel
    
    var messageBody: String?
    
    var mentionedUsers: [CHMentionedUser]?
    
    var attributedString: NSAttributedString?
    
    var isDeletedMessage: Bool
    
    init(messageBody: String?, mentionedUsers: [CHMentionedUser]?, baseMessageModel: BaseMessageModel, isDeleted: Bool = false) {
        self.baseMessageModel = baseMessageModel
        self.messageBody = messageBody
        self.mentionedUsers = mentionedUsers
        self.messageStatus = baseMessageModel.messageStatus
        self.isDeletedMessage = isDeleted
        self.decodeHtmlBody()
        self.prepareAttributedString()
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
            let markDownMessage = MarkDown.shared.tranverseString(string: newBody, startingIndex: 0, textColor: self.isIncoming == true ? UIColor(hex: "#3A3C4C") : UIColor.white, withFont: UIFont(fontStyle: .robotoSlabRegualar, size: CHUIConstants.normalFontSize)!)
            
            var attributedString: NSMutableAttributedString!
            attributedString = markDownMessage
            
            for (_,memberName) in mentionedUserDictionary{
                let allRanges = attributedString.string.ranges(of: memberName)
                if allRanges.count > 0 {
                    for range in allRanges {
                        let nsRange = NSRange(range, in: attributedString.string)
                        attributedString.addAttribute(.font, value: UIFont(fontStyle: .robotoSlabMedium, size: CHUIConstants.normalFontSize)!, range: nsRange)
                        attributedString.addAttribute(
                            .foregroundColor, value: self.isIncoming == true ? UIColor(hex: "#1c1c1c") : UIColor.white, range: nsRange)
                    }
                }
            }
            self.attributedString = attributedString
        }

    }
}


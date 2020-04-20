//
//  MetaMessageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import DifferenceKit

class MetaMessageData {
    
    var messageType: AdminMessageType?
    var subjectId: String?
    var subjectType: String?
    var objectType: String?
    var subject: CHUser?
    var object: Any?
    var objectUsers: [CHUser]?
    
    init(type: AdminMessageType?, subId: String?, subType: String?, objType: String?, object: Any?, subjectUser: CHUser?, objectUsers: [CHUser]?) {
        self.messageType = type
        self.subjectId = subId
        self.subjectType = subType
        self.objectType = objType
        self.subject = subjectUser
        self.object = object
        self.objectUsers = objectUsers
    }
}

class MetaMessageModel: BaseMessageItemProtocol, Differentiable {
    
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: MetaMessageModel) -> Bool {
        return self.showMessageStatusView == source.showMessageStatusView && self.showSenderName == source.showSenderName && self.showDataSeperator == source.showDataSeperator
    }
    
    var showSenderName: Bool = false
    
    var showMessageStatusView: Bool = false
    
    var showDataSeperator: Bool = false
    
    var isMessageSelectorOn: Bool = false
    
    var isMessageSelected: Bool = false
    
    var uploadProgress: Double = 0.0
    
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
        return .metaMessage
    }
    var metaMessageData: MetaMessageData?
    var baseMessageModel: BaseMessageModel
    var metaMessageFormattedString: String?
    var metaMessageAttributedString: NSAttributedString?
    
    init(baseMessageModel: BaseMessageModel, metaMessageData: MetaMessageData?) {
        self.baseMessageModel = baseMessageModel
        self.metaMessageData = metaMessageData
        self.messageStatus = baseMessageModel.messageStatus
        self.prepareFormattedString()
    }
    
    private func prepareFormattedString() {
        guard let metaMessageData = self.metaMessageData else {
            return
        }
        guard let messageType = metaMessageData.messageType else {
            return
        }
        switch messageType {
        case .addMembers:
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            let subjectString = metaMessageData.subject?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
            
            var addedUsersName = [String]()
            if let objectUsers = metaMessageData.objectUsers {
                objectUsers.forEach({
                    addedUsersName.append($0.displayName?.capitalized ?? "")
                })
            }
            let addedUserString = addedUsersName.joined(separator: ", ")
            let messageLabel = String(format: "%@ added %@", arguments: [subjectString,addedUserString])
            self.metaMessageFormattedString = messageLabel
            break
        case .changeGroupPhoto:
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            let subjectString = metaMessageData.subject?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
            let messageLabel = String(format: "%@ changed group photo", subjectString)
            self.metaMessageFormattedString = messageLabel
            break
        case .changeGroupTitle:
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            let subjectString = metaMessageData.subject?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
            
            let newGroupName = metaMessageData.object as? String ?? ""
            let messageLabel = String(format: "%@ changed the title to \"%@\"", arguments: [subjectString,newGroupName])
            self.metaMessageFormattedString = messageLabel
            break
        case .groupCreate:
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            let groupName = metaMessageData.object as? String ?? ""
            
            let subjectString = metaMessageData.subject?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
            let messageLabel = String(format: "%@ created group \"%@\"", arguments: [subjectString,groupName])
            self.metaMessageFormattedString = messageLabel
            break
        case .groupLeave:
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            
            let subjectString = metaMessageData.subject?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
            
            let messageLabel = String(format: "%@ left", subjectString)
            self.metaMessageFormattedString = messageLabel
            break
        case .makeGroupAdmin:
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            let subjectString = metaMessageData.subject?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
            
            let messageLabel = String(format: "%@ are now an admin", subjectString)
            self.metaMessageFormattedString = messageLabel
            break
        case .removeMember:
            
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            let subjectString = metaMessageData.subject?.id == ChannelizeAPI.getCurrentUserId() ? "You" : subjectName
            var removedUsersName = [String]()
            if let removedMembers = metaMessageData.objectUsers {
                removedMembers.forEach({
                    removedUsersName.append($0.displayName?.capitalized ?? "")
                })
            }
            let removedMembersString = removedUsersName.joined(separator: ",")
            let messageLabel = String(format: "%@ removed %@", arguments: [subjectString,removedMembersString])
            self.metaMessageFormattedString = messageLabel
            break
        default:
            break
        }
        
        self.metaMessageAttributedString = NSAttributedString(string: self.metaMessageFormattedString ?? "", attributes: [NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)!, NSAttributedString.Key.foregroundColor: UIColor(hex: "#8a8a8a")])
        
    }
}


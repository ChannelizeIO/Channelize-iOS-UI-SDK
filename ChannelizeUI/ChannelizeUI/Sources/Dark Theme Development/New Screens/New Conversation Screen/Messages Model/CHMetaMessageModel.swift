//
//  CHMetaMessageModel.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/3/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import UIKit
import ChannelizeAPI

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

class MetaMessageItem: ChannelizeChatItem {
    var metaMessageData: MetaMessageData?
    var metaMessageAttributedString: NSAttributedString?
    var metaMessageFormattedString: String?
    init(baseMessageModel: BaseMessageModel, metaMessageData: MetaMessageData) {
        super.init(baseMessageModel: baseMessageModel, messageType: .metaMessage)
        self.metaMessageData = metaMessageData
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
            let subjectString = metaMessageData.subject?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
            
            var addedUsersName = [String]()
            if let objectUsers = metaMessageData.objectUsers {
                objectUsers.forEach({
                    addedUsersName.append($0.displayName?.capitalized ?? "")
                })
            }
            let addedUserString = addedUsersName.joined(separator: ", ")
            let messageLabel = String(format: CHLocalized(key: "pmMetaGroupAddMembers"), arguments: [subjectString,addedUserString])
            self.metaMessageFormattedString = messageLabel
            break
        case .changeGroupPhoto:
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            let subjectString = metaMessageData.subject?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
            let messageLabel = String(format: CHLocalized(key: "pmMetaGroupChangePhoto"), subjectString)
            self.metaMessageFormattedString = messageLabel
            break
        case .changeGroupTitle:
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            let subjectString = metaMessageData.subject?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
            
            let newGroupName = metaMessageData.object as? String ?? ""
            let messageLabel = String(format: CHLocalized(key: "pmMetaGroupChangeTitle"), arguments: [subjectString,newGroupName])
            self.metaMessageFormattedString = messageLabel
            break
        case .groupCreate:
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            let groupName = metaMessageData.object as? String ?? ""
            
            let subjectString = metaMessageData.subject?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
            let messageLabel = String(format: CHLocalized(key: "pmMetaGroupCreate"), arguments: [subjectString,groupName])
            self.metaMessageFormattedString = messageLabel
            break
        case .groupLeave:
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            
            let subjectString = metaMessageData.subject?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
            
            let messageLabel = String(format: CHLocalized(key: "pmMetaGroupLeave"), subjectString)
            self.metaMessageFormattedString = messageLabel
            break
        case .makeGroupAdmin:
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            let subjectString = metaMessageData.subject?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
            
            let messageLabel = String(format: CHLocalized(key: "pmMetaGroupMakeAdmin"), subjectString)
            self.metaMessageFormattedString = messageLabel
            break
        case .removeMember:
            
            let subjectName = metaMessageData.subject?.displayName?.capitalized ?? ""
            let subjectString = metaMessageData.subject?.id == Channelize.getCurrentUserId() ? CHLocalized(key: "pmYou") : subjectName
            var removedUsersName = [String]()
            if let removedMembers = metaMessageData.objectUsers {
                removedMembers.forEach({
                    removedUsersName.append($0.displayName?.capitalized ?? "")
                })
            }
            let removedMembersString = removedUsersName.joined(separator: ",")
            let messageLabel = String(format: CHLocalized(key: "pmMetaGroupRemoveMembers"), arguments: [subjectString,removedMembersString])
            self.metaMessageFormattedString = messageLabel
            break
        default:
            break
        }
        
        self.metaMessageAttributedString = NSAttributedString(string: self.metaMessageFormattedString ?? "", attributes: [NSAttributedString.Key.font: CHCustomStyles.metaMessageFont!, NSAttributedString.Key.foregroundColor: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.secondaryColor : CHLightThemeColors.secondaryColor])
        
    }
}


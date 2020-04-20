//
//  CHAllConversations.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/23/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import Alamofire
import ObjectMapper

protocol CHAllConversationsDelegate {
    func didLoadNewConversations(conversations: [CHConversation])
    func didLoadNewGroupConversations(conversations: [CHConversation])
    func didRecieveNewMessage(message: CHMessage?)
    func didConversationCleared(conversationId: String?)
    func didConversationDeleted(conversationId: String?)
    func didConversationMessagesDeleted(conversationId: String?, deletedMessagesIds: [String])
    func didConversationMessagesDeletedForEveryOne(conversationId: String?, deletedMessagesIds: [String])
    func didTypingStatusChanged(conversationId: String?, typingUserName: String?, isTyping: Bool)
    func didNewAdminAddedToConversation(conversationId: String, adminUserId: String)
    func didConversationMarkAsRead(conversationId: String, readerId: String, readedAt: Date?)
    func didNewMembersAddedToConversation(conversationId: String, addedMembers: [CHMember])
    func didMembersRemovedFromConversation(conversationId: String, removedMemberIds: [String])
    func didCurrentUserRemovedFromConversation(conversationId: String)
    func didCurrentUserAddedToConversation(conversationId: String)
    func didConversationMuteStatusUpdated(conversationId: String, isMuted: Bool)
    func didConversationInfoUpdated(updatedInfo: CHConversationUpdatedModel)
}
extension CHAllConversationsDelegate {
    func didLoadNewConversations(conversations: [CHConversation]) { }
    func didLoadNewGroupConversations(conversations: [CHConversation]) { }
    func didRecieveNewMessage(message: CHMessage?) { }
    func didConversationCleared(conversationId: String?) { }
    func didConversationDeleted(conversationId: String?) { }
    func didConversationMessagesDeleted(conversationId: String?, deletedMessagesIds: [String]) { }
    func didConversationMessagesDeletedForEveryOne(conversationId: String?, deletedMessagesIds: [String]) { }
    func didTypingStatusChanged(conversationId: String?, typingUserName: String?, isTyping: Bool) { }
    func didNewAdminAddedToConversation(conversationId: String, adminUserId: String) { }
    func didConversationMarkAsRead(conversationId: String, readerId: String, readedAt: Date?) { }
    func didNewMembersAddedToConversation(conversationId: String, addedMembers: [CHMember]) { }
    func didMembersRemovedFromConversation(conversationId: String, removedMemberIds: [String]) { }
    func didCurrentUserRemovedFromConversation(conversationId: String) { }
    func didConversationMuteStatusUpdated(conversationId: String, isMuted: Bool) { }
    func didCurrentUserAddedToConversation(conversationId: String) { }
    func didConversationInfoUpdated(updatedInfo: CHConversationUpdatedModel) { }
}

class CHAllConversations: CHConversationEventDelegate {
    
    static var instance: CHAllConversations = {
        let instance = CHAllConversations()
        return instance
    }()
    
    static var allConversations = [CHConversation]()
    static var allGroupsConversations = [CHConversation]()
    static var identifier = UUID()
    static var isAllConversationsLoaded = false
    static var isAllGroupsConversationLoaded = false
    static var defaultLimit = 30
    static var allConversationCurrentOffset = 0
    static var groupsConversationCurrentOffset = 0
    
    internal var conversationDelegates = [UUID: CHAllConversationsDelegate]()
    
    public static var onApiLoadError: ((_ error: String?) -> Void)?
    
    init() {
        ChannelizeAPI.addConversationEventDelegate(delegate: self, identifier: CHAllConversations.identifier)
    }
    
    static func addConversationDelegates(delegate: CHAllConversationsDelegate, identifier: UUID) {
        instance.conversationDelegates.updateValue(delegate, forKey: identifier)
    }
    
    static func getAllGroupsConversations() {
        var params = [String:Any]()
        params.updateValue(allConversationCurrentOffset, forKey: "skip")
        params.updateValue(defaultLimit, forKey: "limit")
        params.updateValue("members", forKey: "include")
        params.updateValue(true, forKey: "isGroup")
        
        ChannelizeAPIService.getConversationList(params: params, completion: {(conversations,errorString) in
            guard errorString == nil else {
                onApiLoadError?(errorString)
                return
            }
            if let recievedConversations = conversations {
                groupsConversationCurrentOffset += recievedConversations.count
                
                if recievedConversations.count < defaultLimit {
                    isAllGroupsConversationLoaded = true
                }
                self.instance.updateGroupConversationList(with: recievedConversations)
            }
        })
    }
    
    func updateGroupConversationList(with conversations: [CHConversation]) {
        conversations.forEach({
            let conversationObject = $0
            if CHAllConversations.allGroupsConversations.filter({
                $0.id == conversationObject.id
            }).count == 0 {
                CHAllConversations.allGroupsConversations.append(
                    conversationObject)
            }
        })
        self.conversationDelegates.values.forEach({
            $0.didLoadNewGroupConversations(conversations: conversations)
        })
    }
    
    static func getAllConversations() {
        var params = [String:Any]()
        params.updateValue(allConversationCurrentOffset, forKey: "skip")
        params.updateValue(defaultLimit, forKey: "limit")
        params.updateValue("members", forKey: "include")
        //params.updateValue(false, forKey: "includeDeleted")
        
        ChannelizeAPIService.getConversationList(params: params, completion: {(conversations,errorString) in
            guard errorString == nil else {
                onApiLoadError?(errorString)
                return
            }
            if let recievedConversations = conversations {
                allConversationCurrentOffset += recievedConversations.count
                if recievedConversations.count < defaultLimit {
                    isAllConversationsLoaded = true
                }
                self.instance.updateConversationList(with: recievedConversations)
            }
        })
        
    }
    
    func updateConversationList(with conversations: [CHConversation]) {
        conversations.forEach({
            let conversationObject = $0
            if CHAllConversations.allConversations.filter({
                $0.id == conversationObject.id
            }).count == 0 {
                CHAllConversations.allConversations.append(
                    conversationObject)
            }
        })
        self.conversationDelegates.values.forEach({
            $0.didLoadNewConversations(conversations: conversations)
        })
    }
    
    
    
    public static func removeConversationEventDelegates() {
        CHAllConversations.instance.conversationDelegates.removeAll()
    }
}

// MARK:- Conversation Events Delegates
extension CHAllConversations {
    func didRecieveNewMessage(model: CHNewMessageRecievedModel?) {
        self.conversationDelegates.values.forEach({
            $0.didRecieveNewMessage(message: model?.message)
        })
        
    }
    func didConversationCleared(model: CHConversationClearModel?) {
        self.conversationDelegates.values.forEach({
            $0.didConversationCleared(conversationId: model?.conversation?.id)
        })
    }
    
    func didConversationDeleted(model: CHConversationDeleteModel?) {
        self.conversationDelegates.values.forEach({
            $0.didConversationDeleted(conversationId: model?.conversation?.id)
        })
        if let conversationIndex = CHAllConversations.allConversations.firstIndex(where: {
            $0.id == model?.conversation?.id
        }) {
            CHAllConversations.allConversations.remove(at: conversationIndex)
        }
        
        if let conversationIndex = CHAllConversations.allGroupsConversations.firstIndex(where: {
            $0.id == model?.conversation?.id
        }) {
            CHAllConversations.allGroupsConversations.remove(at: conversationIndex)
        }
    }
    
    func didConversationMessageDeleted(model: CHMessageDeletedModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        guard let deletedMessages = model?.deletedMessages else {
            return
        }
        var messageIds = [String]()
        deletedMessages.forEach({
            messageIds.append($0.id ?? "")
        })
        self.conversationDelegates.values.forEach({
            $0.didConversationMessagesDeleted(conversationId: conversationId, deletedMessagesIds: messageIds)
        })
    }
    
    func didConversationMessageDeletedForEveryOne(model: CHMessageDeletedModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        guard let deletedMessages = model?.deletedMessages else {
            return
        }
        var messageIds = [String]()
        deletedMessages.forEach({
            messageIds.append($0.id ?? "")
        })
        self.conversationDelegates.values.forEach({
            $0.didConversationMessagesDeletedForEveryOne(conversationId: conversationId, deletedMessagesIds: messageIds)
        })
    }
    
    func didTypingUserStatusUpdated(model: CHUserTypingStatusModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        guard let typingUser = model?.user else {
            return
        }
        self.conversationDelegates.values.forEach({
            $0.didTypingStatusChanged(conversationId: conversationId, typingUserName: typingUser.displayName, isTyping: model?.isTyping ?? false)
        })
    }
    
    func didNewAdminAddedToConversation(model: CHNewAdminAddedModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        guard let adminUserId = model?.adminUser?.id else {
            return
        }
        self.conversationDelegates.values.forEach({
            $0.didNewAdminAddedToConversation(conversationId: conversationId, adminUserId: adminUserId)
        })
        
        if let firstConversation = CHAllConversations.allGroupsConversations.first(where: {
            $0.id == conversationId
        }) {
            if let adminUser = model?.adminUser {
                if let firstUser = firstConversation.members?.first(where: {
                    $0.user?.id == adminUser.id
                }) {
                    firstUser.isAdmin = true
                }
            }
        }
        
    }
    
    func didConversationInfoUpdated(model: CHConversationUpdatedModel?) {
        guard let infoModel = model else {
            return
        }
        self.conversationDelegates.values.forEach({
            $0.didConversationInfoUpdated(updatedInfo: infoModel)
        })
        if let conversation = CHAllConversations.allConversations.first(where: {
            $0.id == model?.conversationID
        }) {
            conversation.coversationTitle = model?.title
            conversation.conversationProfileImage = model?.profileImageUrl
            conversation.lastUpDatedAt = model?.timeStamp
            conversation.membersCount = model?.memberCount
        }
        if let conversation = CHAllConversations.allGroupsConversations.first(where: {
            $0.id == model?.conversationID
        }) {
            conversation.coversationTitle = model?.title
            conversation.conversationProfileImage = model?.profileImageUrl
            conversation.lastUpDatedAt = model?.timeStamp
            conversation.membersCount = model?.memberCount
        }
    }
    
    func didConversationMarkAsRead(model: CHConversationMarkReadModel?) {
        guard let conversation = model?.conversation else {
            return
        }
        guard let readerUserId = model?.user?.id else {
            return
        }
        self.conversationDelegates.values.forEach({
            $0.didConversationMarkAsRead(conversationId: conversation.id ?? "", readerId: readerUserId, readedAt: model?.timeStamp)
        })
        let dateTransformer = ISODateTransform()
        if let conversation = CHAllConversations.allGroupsConversations.first(where: {
            $0.id == conversation.id
        }) {
            if readerUserId == ChannelizeAPI.getCurrentUserId() {
                conversation.unreadMessageCount = 0
                conversation.lastReadByMe = model?.timeStamp
            }
            let dateString = dateTransformer.transformToJSON(
                model?.timeStamp)
            conversation.lastReadDictionary?.updateValue(
                dateString ?? "", forKey: readerUserId)
        }
    }
    
    func didNewMembersAddedToConversation(model: CHNewMemberAddedModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        guard let addedMembers = model?.addedMembers else {
            return
        }
        self.conversationDelegates.values.forEach({
            $0.didNewMembersAddedToConversation(conversationId: conversationId, addedMembers: addedMembers)
        })
    }
    
    func didMembersRemovedFromConversation(model: CHMembersRemovedModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        guard let removedMembers = model?.removedUsers else {
            return
        }
        var removedMembersIds = [String]()
        removedMembers.forEach({
            let userId = $0.id ?? ""
            removedMembersIds.append(userId)
        })
        self.conversationDelegates.values.forEach({
            $0.didMembersRemovedFromConversation(conversationId: conversationId, removedMemberIds: removedMembersIds)
        })
    }
    
    func didCurrentUserRemovedFromConversation(model: CHCurrentUserRemovedModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        self.conversationDelegates.values.forEach({
            $0.didCurrentUserRemovedFromConversation(conversationId: conversationId)
        })
    }
    
    func didCurrentUserJoinedConversation(model: CHCurrentUserJoinConversationModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        self.conversationDelegates.values.forEach({
            $0.didCurrentUserAddedToConversation(conversationId: conversationId)
        })
        
        if let conversation = CHAllConversations.allConversations.first(where: {
            $0.id == conversationId
        }) {
            conversation.canReplyToConversation = true
            var params = [String:Any]()
            params.updateValue(UUID().uuidString, forKey: "id")
            params.updateValue(ChannelizeAPI.getCurrentUserId(), forKey: "userId")
            params.updateValue(false, forKey: "isAdmin")
            if let member = Mapper<CHMember>().map(JSON: params) {
                
                var userParams = [String:Any]()
                userParams.updateValue(ChannelizeAPI.getCurrentUserId(), forKey: "id")
                userParams.updateValue(ChannelizeAPI.getCurrentUserDisplayName(), forKey: "displayName")
                if ChannelizeAPI.getCurrentUserProfileImageUrl() != nil {
                    userParams.updateValue(
                        ChannelizeAPI.getCurrentUserProfileImageUrl()!, forKey: "profileImageUrl")
                }
                let userObject = Mapper<CHUser>().map(JSON: userParams)
                member.user = userObject
                conversation.members?.append(member)
            }
        }
        
        if let conversation = CHAllConversations.allGroupsConversations.first(where: {
            $0.id == conversationId
        }) {
            conversation.canReplyToConversation = true
            var params = [String:Any]()
            params.updateValue(UUID().uuidString, forKey: "id")
            params.updateValue(ChannelizeAPI.getCurrentUserId(), forKey: "userId")
            params.updateValue(false, forKey: "isAdmin")
            if let member = Mapper<CHMember>().map(JSON: params) {
                
                var userParams = [String:Any]()
                userParams.updateValue(ChannelizeAPI.getCurrentUserId(), forKey: "id")
                userParams.updateValue(ChannelizeAPI.getCurrentUserDisplayName(), forKey: "displayName")
                if ChannelizeAPI.getCurrentUserProfileImageUrl() != nil {
                    userParams.updateValue(
                        ChannelizeAPI.getCurrentUserProfileImageUrl()!, forKey: "profileImageUrl")
                }
                let userObject = Mapper<CHUser>().map(JSON: userParams)
                member.user = userObject
                conversation.members?.append(member)
            }
        }
    }
    
    func didUpdateConversationMuteStatus(model: CHConversationMuteStatusModel?) {
        guard let conversationId = model?.conversation?.id else {
            return
        }
        self.conversationDelegates.values.forEach({
            $0.didConversationMuteStatusUpdated(conversationId: conversationId, isMuted: model?.conversation?.isMute ?? false)
        })
    }
}


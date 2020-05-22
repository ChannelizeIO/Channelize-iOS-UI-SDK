//
//  CHAllContacts.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/20/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import Alamofire
import ObjectMapper

protocol CHAllContactsDelegates {
    func didLoadContacts(contacts: [CHUser])
    func didUserAddedInContactList(user: CHUser)
    func didUserRemovedFromContactList(user: CHUser)
    func didUserStatusUpdated(updatedUser: CHUser)
}

class CHAllContacts: CHUserEventDelegates {
    
    static var instance: CHAllContacts = {
        let instance = CHAllContacts()
        return instance
    }()
    
    static var contactsList = [CHUser]()
    static var identifier = UUID()
    static var isAllContactsLoaded = false
    static var currentOffset = 0
    static var defaultLimit = 50
    
    internal var contactsDelegates = [UUID: CHAllContactsDelegates]()
    
    public static var onContactListUpdated: ((_ users: [CHUser]) -> Void)?
    public static var onApiLoadError: ((_ error: String?) -> Void)?
    
    init() {
        Channelize.addUserEventDelegate(delegate: self, identifier: CHAllContacts.identifier)
    }
    
    static func initializeContactClass() {
        Channelize.addUserEventDelegate(delegate: instance, identifier: CHAllContacts.identifier)
    }
    
    static func addContactsLoadDelegates(delegate: CHAllContactsDelegates, identifier: UUID) {
        instance.contactsDelegates.updateValue(delegate, forKey: identifier)
    }
    
    static func removeContactsLoadDelegates(identifier: UUID) {
        instance.contactsDelegates.removeValue(forKey: identifier)
    }
    
    static func getContacts() {
        var params = [String:Any]()
        params.updateValue(defaultLimit, forKey: "limit")
        params.updateValue(currentOffset, forKey: "skip")
        params.updateValue(false, forKey: "includeBlocked")
        ChannelizeAPIService.getFriendsList(params: params, completion: {(users,errorString) in
            guard errorString == nil else {
                onApiLoadError?(errorString)
                return
            }
            if let recievedUsers = users {
                currentOffset += recievedUsers.count
                if recievedUsers.count < defaultLimit {
                    isAllContactsLoaded = true
                }
                instance.updateContactsList(with: recievedUsers)
            }
        })
    }
    
    func updateContactsList(with users: [CHUser]) {
        users.forEach({
            let userObject = $0
            if CHAllContacts.contactsList.filter({
                $0.id == userObject.id
            }).count == 0 {
                CHAllContacts.contactsList.append(userObject)
            }
        })
        self.contactsDelegates.values.forEach({
            $0.didLoadContacts(contacts: users)
        })
    }
    
    public static func getFriendsBySkippingIds(ids: [String], completion: @escaping ([CHUser]?,String?) -> ()) {
        let idsString = ids.joined(separator: ",")
        print("========\(idsString)+++++++++")
        var params = [String:Any]()
        params.updateValue(50, forKey: "limit")
        params.updateValue(0, forKey: "skip")
        params.updateValue(idsString, forKey: "skipUserIds")
        params.updateValue(true, forKey: "includeBlocked")
        var newUsersIds = [String]()
        
        ChannelizeAPIService.getFriendsList(params: params, completion: {(users,errorString) in
            guard errorString == nil else {
                completion(nil,errorString)
                return
            }
            if let recievedUsers = users {
                completion(recievedUsers,nil)
            }
        })
    }
    
    // MARK:- User Events Delegate Functions
    func didUserStatusUpdated(model: CHUserStatusUpdatedModel?) {
        guard let updatedUser = model?.updatedUser else {
            return
        }
        self.contactsDelegates.values.forEach({
            $0.didUserStatusUpdated(updatedUser: updatedUser)
        })
    }
    
    func didUserAddedAsFriend(model: CHUserAddedFriendModel?) {
        guard let addedUer = model?.addedUser else {
            return
        }
        self.contactsDelegates.values.forEach({
            $0.didUserAddedInContactList(user: addedUer)
        })
    }
    
    func didUserRemovedAsFriend(model: CHUserRemovedFriendModel?) {
        guard let removedUser = model?.removedUser else {
            return
        }
        self.contactsDelegates.values.forEach({
            $0.didUserRemovedFromContactList(user: removedUser)
        })
    }
    
}


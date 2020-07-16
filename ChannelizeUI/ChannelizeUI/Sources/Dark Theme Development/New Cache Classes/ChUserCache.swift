//
//  CHUserCache.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/2/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import ChannelizeAPI

class ChUserCache {
    
    var users = [CHUser]()
    
    static var instance: ChUserCache = {
        let instance = ChUserCache()
        return instance
    }()
    
    func appendUsers(newUsers: [CHUser]) {
        newUsers.forEach({
            let newUser = $0
            if users.filter({
                $0.id == newUser.id
            }).count == 0 {
                users.append(newUser)
            }
        })
    }
    
    func removeUser(user: CHUser?) {
        self.users.removeAll(where: {
            $0.id == user?.id
        })
    }
    
    func updateUserStatus(userId: String?, isOnline: Bool) {
        self.users.first(where: {
            $0.id == userId
            })?.isOnline = isOnline
    }
    
}



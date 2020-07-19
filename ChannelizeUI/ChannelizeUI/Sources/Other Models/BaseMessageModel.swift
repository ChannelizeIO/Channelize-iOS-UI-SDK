//
//  BaseMessageModel.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/15/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI

class BaseMessageModel: Equatable {
    
    static func == (lhs: BaseMessageModel, rhs: BaseMessageModel) -> Bool {
        return lhs.messageId == rhs.messageId &&
            lhs.isIncoming == rhs.isIncoming &&
            lhs.senderId == rhs.senderId &&
            lhs.senderName == rhs.senderName &&
            lhs.senderImageUrl == rhs.senderImageUrl &&
            lhs.messageDate == rhs.messageDate &&
            lhs.messageStatus == rhs.messageStatus
    }
    
    var messageId: String
    var isIncoming: Bool
    var senderId: String
    var senderName: String
    var senderImageUrl: String
    var messageDate: Date
    var messageStatus: BaseMessageStatus
    
    init(uid: String, senderId: String, senderName: String, senderImageUrl: String, messageDate: Date, status: BaseMessageStatus) {
        
        self.messageId = uid
        self.senderId = senderId
        self.senderName = senderName
        self.senderImageUrl = senderImageUrl
        self.messageDate = messageDate
        self.messageStatus = status
        self.isIncoming = senderId == Channelize.getCurrentUserId() ? false : true
    }
}


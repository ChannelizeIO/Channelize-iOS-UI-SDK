//
//  QuotedViewModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/11/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation

class QuotedViewModel {
    var parentMessageId: String?
    var senderName: String?
    var senderId: String?
    var imageUrl: String?
    var textMessage: NSAttributedString?
    var isIncoming: Bool
    var typeOfMessage: BaseMessageType
    
    init(parentId: String?, senderName: String?, senderId: String?, imageUrl: String?, textMessage: NSAttributedString?, messageType: BaseMessageType, isIncoming: Bool = true) {
        self.parentMessageId = parentId
        self.senderName = senderName
        self.senderId = senderId
        self.imageUrl = imageUrl
        self.textMessage = textMessage
        self.typeOfMessage = messageType
        self.isIncoming = isIncoming
    }
}



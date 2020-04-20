//
//  BaseMessageProtocol.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/29/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import DifferenceKit

enum MessageSource {
    case local
    case remote
}

enum BaseMessageStatus {
    case sending
    case sent
    case seen
}

enum BaseMessageType {
    case text
    case image
    case video
    case deletedMessage
    case location
    case gifSticker
    case audio
    case dateSeperator
    case senderName
    case linkPreview
    case metaMessage
    case missedVideoCall
    case missedVoiceCall
    case undefined
    case groupedImages
    case unReadMessage
    case quotedMessage
}

//protocol NormalMessageItemProtocol: BaseMessageItemProtocol {
//    var senderId: String { get }
//    var isIncoming: Bool { get }
//    var senderName: String { get }
//    var senderImageUrl: String { get }
//    var messageDate: Date { get }
//}


protocol BaseMessageItemProtocol: class {
    
    var showSenderName: Bool { get set }
    var showDataSeperator: Bool { get set }
    var messageId: String { get }
    var isIncoming: Bool { get }
    var senderId: String { get }
    var senderName: String { get }
    var senderImageUrl: String { get }
    var messageDate: Date { get }
    var messageStatus: BaseMessageStatus { get set }
    var messageType: BaseMessageType { get }
    var isMessageSelectorOn: Bool { get set }
    var isMessageSelected: Bool { get set }
    var uploadProgress: Double { get set }
    var showMessageStatusView: Bool { get set }
}


class BaseMessageModel {
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
        self.isIncoming = senderId == ChannelizeAPI.getCurrentUserId() ? false : true
    }
}

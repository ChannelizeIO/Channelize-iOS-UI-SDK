//
//  MissCallMessageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/30/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation

import ChannelizeAPI
import DifferenceKit

class MissCallMessageModel: BaseMessageItemProtocol, Differentiable {
    
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: MissCallMessageModel) -> Bool {
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
    
    var myMessageReactions: [String] = []
    
    var reactionCountsInfo: [String : Int] = [:]
    
    var reactions: [ReactionModel] = []
    
    var messageStatus: BaseMessageStatus
    
    var messageType: BaseMessageType {
        return self.callType == .video ? .missedVideoCall : .missedVoiceCall
    }
    
    var isMessageSelectorOn: Bool = false
    
    var isMessageSelected: Bool = false
    
    var uploadProgress: Double = 0.0
    
    var callType: CHCallScreen
    var callerName: String?
    var callerId: String?
    var recieverName: String?
    var recieverId: String?
    var baseMessageModel: BaseMessageModel
    init(baseMessageModel: BaseMessageModel, callType: CHCallScreen, callerName: String?, callerId: String?, recieverName: String?, recieverId: String?) {
        self.baseMessageModel = baseMessageModel
        self.callType = callType
        self.callerName = callerName
        self.callerId = callerId
        self.recieverId = recieverId
        self.recieverName = recieverName
        self.messageStatus = baseMessageModel.messageStatus
    }
    
    
    
}

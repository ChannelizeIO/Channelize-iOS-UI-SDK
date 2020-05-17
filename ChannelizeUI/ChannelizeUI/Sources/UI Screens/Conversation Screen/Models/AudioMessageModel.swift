//
//  AudioMessageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import DifferenceKit

enum AudioModelStatus {
    case playing
    case loading
    case paused
    case stopped
}

class AudioMessageModel: BaseMessageItemProtocol, Differentiable {
    
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: AudioMessageModel) -> Bool {
        return self.showMessageStatusView == source.showMessageStatusView && self.showSenderName == source.showSenderName && self.showDataSeperator == source.showDataSeperator
    }
    
    var showSenderName: Bool = false
    
    var showMessageStatusView: Bool = false
    
    var showDataSeperator: Bool = false
    
    var uploadProgress: Double = 0.0
    
    var isMessageSelectorOn: Bool = false
    
    var isMessageSelected: Bool = false
    
    
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
    
    var messageType: BaseMessageType {
        return .audio
    }
    
    var myMessageReactions: [String] = []
    var reactionCountsInfo: [String : Int] = [:]
    var reactions: [ReactionModel] = []
    
    var messageStatus: BaseMessageStatus
    var messageSource: MessageSource?
    var baseMessageModel: BaseMessageModel
    var audioUrl: String?
    var audioDuration: Double?
    var playerProgress: Float = 0.0
    var playerStatus: AudioModelStatus = .stopped
    
    init(baseMessageModel: BaseMessageModel, audioUrl: String?, audioDuration: Double?, source: MessageSource? = .remote) {
        self.baseMessageModel = baseMessageModel
        self.audioUrl = audioUrl
        self.audioDuration = audioDuration
        self.messageSource = source
        self.messageStatus = baseMessageModel.messageStatus
        
    }
}


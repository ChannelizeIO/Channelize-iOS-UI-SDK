//
//  VideoMessageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/1/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import UIKit
import DifferenceKit

class VideoMessageModel: BaseMessageItemProtocol, Differentiable {
    
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: VideoMessageModel) -> Bool {
        return self.showMessageStatusView == source.showMessageStatusView && self.showSenderName == source.showSenderName && self.showDataSeperator == source.showDataSeperator
    }
    
    var showSenderName: Bool = false
    
    var showDataSeperator: Bool = false
    
    var showMessageStatusView: Bool = false
    
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
        return .video
    }
    
    var myMessageReactions: [String] = []
    var reactionCountsInfo: [String : Int] = [:]
    var reactions: [ReactionModel] = []
    
    var messageStatus: BaseMessageStatus
    var messageSource: MessageSource?
    var baseMessageModel: BaseMessageModel
    var localImage: UIImage?
    var thumbnailUrl: String?
    var videoUrl: String?
    
    init(baseMessageModel: BaseMessageModel, videoUrl: String?, thumbnailUrl: String?, source: MessageSource? = .remote, localImage: UIImage? = nil) {
        self.baseMessageModel = baseMessageModel
        self.videoUrl = videoUrl
        self.messageSource = source
        self.localImage = localImage
        self.thumbnailUrl = thumbnailUrl
        self.messageStatus = baseMessageModel.messageStatus
    }
}



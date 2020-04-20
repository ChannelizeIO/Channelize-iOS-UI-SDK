//
//  GifStickerMessageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/8/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import DifferenceKit

class GifStickerMessageModel: BaseMessageItemProtocol, Differentiable {
    
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: GifStickerMessageModel) -> Bool {
        return self.showMessageStatusView == source.showMessageStatusView && self.showSenderName == source.showSenderName && self.showDataSeperator == source.showDataSeperator
    }
    
    var showSenderName: Bool = false
    var showDataSeperator: Bool = false
    var uploadProgress: Double = 0.0
    var isMessageSelectorOn: Bool = false
    var isMessageSelected: Bool = false
    var showMessageStatusView: Bool = false
    
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
        return .gifSticker
    }
    
    var messageStatus: BaseMessageStatus
    var messageSource: MessageSource?
    var baseMessageModel: BaseMessageModel
    var downSampledUrl: String?
    var stillUrl: String?
    var originalUrl: String?
    
    init(baseMessageModel: BaseMessageModel, downSampledUrl: String?, stillUrl: String?, originalUrl: String?) {
        self.baseMessageModel = baseMessageModel
        self.downSampledUrl = downSampledUrl
        self.stillUrl = stillUrl
        self.originalUrl = originalUrl
        self.messageStatus = baseMessageModel.messageStatus
    }
}


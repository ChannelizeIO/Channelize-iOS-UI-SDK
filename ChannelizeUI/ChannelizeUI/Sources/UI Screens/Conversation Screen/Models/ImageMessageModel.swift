//
//  ImageMessageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 2/29/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import DifferenceKit

class ImageMessageModel: BaseMessageItemProtocol, Differentiable {
    
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: ImageMessageModel) -> Bool {
        return self.showMessageStatusView == source.showMessageStatusView && self.showSenderName == source.showSenderName && self.showDataSeperator == source.showDataSeperator
    }
    
    var showSenderName: Bool = false
    
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
        return .image
    }
    
    var showMessageStatusView: Bool = false
    
    var messageStatus: BaseMessageStatus
    var messageSource: MessageSource?
    var baseMessageModel: BaseMessageModel
    var localImage: UIImage?
    var imageUrl: String?
    
    init(baseMessageModel: BaseMessageModel, fileImageUrl: String?, source: MessageSource? = .remote, localImage: UIImage? = nil) {
        self.baseMessageModel = baseMessageModel
        self.imageUrl = fileImageUrl
        self.messageSource = source
        self.localImage = localImage
        self.messageStatus = baseMessageModel.messageStatus
    }
}


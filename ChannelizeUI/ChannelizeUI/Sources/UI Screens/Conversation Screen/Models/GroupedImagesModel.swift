//
//  GroupedImagesModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/13/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import DifferenceKit

class GroupedImagesModel: BaseMessageItemProtocol, Differentiable {
    
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: GroupedImagesModel) -> Bool {
        return self.showMessageStatusView == source.showMessageStatusView && self.showSenderName == source.showSenderName && self.showDataSeperator == source.showDataSeperator
    }
    
    var messageStatus: BaseMessageStatus = .sent

    var showSenderName: Bool = false
    
    var showDataSeperator: Bool = false
    
    var showMessageStatusView: Bool = false
    
    var messageId: String {
        var modelIds = [String]()
        self.imagesModel.forEach({
            modelIds.append($0.messageId)
        })
        return modelIds.joined(separator: ",")
    }
    
    var isIncoming: Bool {
        if let imageModel = self.imagesModel.first {
            return imageModel.isIncoming
        }
        return true
    }
    
    var senderId: String {
        if let imageModel = self.imagesModel.first {
            return imageModel.senderId
        }
        return Channelize.getCurrentUserId()
    }
    
    var senderName: String {
        if let imageModel = self.imagesModel.first {
            return imageModel.senderName
        }
        return Channelize.getCurrentUserDisplayName()
    }
    
    var senderImageUrl: String {
        if let imageModel = self.imagesModel.first {
            return imageModel.senderImageUrl
        }
        return Channelize.getCurrentUserProfileImageUrl() ?? ""
    }
    
    var messageDate: Date {
        if let imageModel = self.imagesModel.last {
            return imageModel.messageDate
        }
        return Date()
    }
    
    var messageType: BaseMessageType {
        return .groupedImages
    }
    
    var isMessageSelectorOn: Bool = false
    
    var isMessageSelected: Bool = false

    var uploadProgress: Double = 0.0
    
    var imagesModel = [BaseMessageItemProtocol]()
    
    init(models: [BaseMessageItemProtocol]) {
        self.imagesModel = models
    }
    
    var myMessageReactions: [String] = []
    var reactionCountsInfo: [String : Int] = [:]
    var reactions: [ReactionModel] = []
    
}


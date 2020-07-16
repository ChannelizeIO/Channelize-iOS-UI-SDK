//
//  ChannelizeChatItem.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/29/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit

extension Array where Element: NSCopying {
    func copy() -> [Element] {
          return self.map { $0.copy() as! Element }
    }
}


class ChannelizeChatItem: NSCopying, Differentiable {
    var differenceIdentifier: String {
        return messageId
    }
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
    var messageStatus: BaseMessageStatus
    var messageType: BaseMessageType
    var showUnreadMessageLabel: Bool = false
    var showSenderName: Bool = false
    var showDataSeperator: Bool = false
    var showMessageStatusView: Bool = false
    var isMessageSelectorOn: Bool = false
    var isMessageSelected: Bool = false
    var baseMessageModel: BaseMessageModel
    var myMessageReactions: [String] = []
    var reactionCountsInfo: [String:Int] = [:]
    var reactions: [ReactionModel] = []
    
    // MARK: - Message Data Objects
    //var gifStickerData: GifStickerMessageData?
    //var locationData: LocationMessageData?
    //var audioData: AudioMessageData?
    
    init(baseMessageModel: BaseMessageModel, messageType: BaseMessageType) {
        self.baseMessageModel = baseMessageModel
        self.messageType = messageType
        self.messageStatus = baseMessageModel.messageStatus
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let item = ChannelizeChatItem(baseMessageModel: self.baseMessageModel, messageType: self.messageType)
        
        //item.gifStickerData = self.gifStickerData
        //item.locationData = self.locationData
        //item.audioData = self.audioData
        
        item.messageStatus = self.messageStatus
        item.showSenderName = self.showSenderName
        item.showDataSeperator = self.showDataSeperator
        item.showMessageStatusView = self.showMessageStatusView
        item.isMessageSelectorOn = self.isMessageSelectorOn
        item.isMessageSelected = self.isMessageSelected
        return item
    }
    
    func isContentEqual(to source: ChannelizeChatItem) -> Bool {
        let check = source.baseMessageModel == self.baseMessageModel &&
            source.messageType == self.messageType &&
            source.messageStatus == self.messageStatus &&
            source.showSenderName == self.showSenderName &&
            source.showDataSeperator == self.showDataSeperator &&
            source.showMessageStatusView == self.showMessageStatusView &&
            source.isMessageSelectorOn == self.isMessageSelectorOn &&
            source.isMessageSelected == self.isMessageSelected
            //source.gifStickerData == self.gifStickerData &&
            //source.locationData == self.locationData &&
            //source.audioData == self.audioData
        return check
    }
}




//
//  CHImageMessageModel.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/30/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import UIKit
import ChannelizeAPI

class ImageMessageData: Equatable {
    var imageUrlString: String?
    var imageSource: MessageSource? = .remote
    var localImage: UIImage?
    
    init(imageUrlString: String?, imageSource: MessageSource = .remote, localImage: UIImage? = nil) {
        self.imageUrlString = imageUrlString
        self.imageSource = imageSource
        self.localImage = localImage
    }
    
    static func == (lhs: ImageMessageData, rhs: ImageMessageData) -> Bool {
        return lhs.imageUrlString == rhs.imageUrlString &&
            lhs.imageSource == rhs.imageSource &&
            lhs.localImage == rhs.localImage
    }
}

class ImageMessageItem: ChannelizeChatItem {
    var imageMessageData: ImageMessageData?
    var uploadProgress: Double?
    var isEncrypted: Bool?
    init(baseMessageModel: BaseMessageModel, imageMessageData: ImageMessageData?) {
        super.init(baseMessageModel: baseMessageModel, messageType: .image)
        self.imageMessageData = imageMessageData
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let item = ImageMessageItem(baseMessageModel: self.baseMessageModel, imageMessageData: self.imageMessageData)
        item.messageStatus = self.messageStatus
        item.showSenderName = self.showSenderName
        item.showDataSeperator = self.showDataSeperator
        item.showMessageStatusView = self.showMessageStatusView
        item.isMessageSelectorOn = self.isMessageSelectorOn
        item.isMessageSelected = self.isMessageSelected
        item.myMessageReactions = self.myMessageReactions
        item.reactions = self.reactions
        item.reactionCountsInfo = self.reactionCountsInfo
        item.showUnreadMessageLabel = self.showUnreadMessageLabel
        item.isEncrypted = self.isEncrypted
        return item
    }
    
    override func isContentEqual(to source: ChannelizeChatItem) -> Bool {
        guard let imageMessage = source as? ImageMessageItem else {
            return false
        }
        let check = imageMessage.baseMessageModel == self.baseMessageModel &&
            imageMessage.messageType == self.messageType &&
            imageMessage.messageStatus == self.messageStatus &&
            imageMessage.showSenderName == self.showSenderName &&
            imageMessage.showDataSeperator == self.showDataSeperator &&
            imageMessage.showMessageStatusView == self.showMessageStatusView &&
            imageMessage.isMessageSelectorOn == self.isMessageSelectorOn &&
            imageMessage.isMessageSelected == self.isMessageSelected &&
            imageMessage.imageMessageData == self.imageMessageData &&
            imageMessage.showUnreadMessageLabel == self.showUnreadMessageLabel &&
            imageMessage.isEncrypted == self.isEncrypted
        return check
    }
}



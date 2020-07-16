//
//  CHVideoMessageModel.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/30/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit

class VideoMessageData: Equatable {
    static func == (lhs: VideoMessageData, rhs: VideoMessageData) -> Bool {
        return lhs.videoUrlString == rhs.videoUrlString &&
            lhs.videoSource == rhs.videoSource &&
            lhs.thumbLocalImage == rhs.thumbLocalImage &&
            lhs.thumbNailUrl == rhs.thumbNailUrl
    }
    
    var videoUrlString: String?
    var videoSource: MessageSource? = .remote
    var thumbLocalImage: UIImage?
    var thumbNailUrl: String?
    
    init(videoUrlString: String?, thumbnailUrlString: String?, videoSource: MessageSource = .remote, thumbLocalImage: UIImage? = nil) {
        self.videoUrlString = videoUrlString
        self.videoSource = videoSource
        self.thumbLocalImage = thumbLocalImage
        self.thumbNailUrl = thumbnailUrlString
    }
}

class VideoMessageItem: ChannelizeChatItem {
    var videoMessageData: VideoMessageData?
    var uploadProgress: Double?
    var isEncrypted: Bool?
    init(baseMessageModel: BaseMessageModel, videoMessageData: VideoMessageData?) {
        super.init(baseMessageModel: baseMessageModel, messageType: .video)
        self.videoMessageData = videoMessageData
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let item = VideoMessageItem(baseMessageModel: self.baseMessageModel, videoMessageData: self.videoMessageData)
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
        guard let videoMessage = source as? VideoMessageItem else {
            return false
        }
        let check = videoMessage.baseMessageModel == self.baseMessageModel &&
            videoMessage.messageType == self.messageType &&
            videoMessage.messageStatus == self.messageStatus &&
            videoMessage.showSenderName == self.showSenderName &&
            videoMessage.showDataSeperator == self.showDataSeperator &&
            videoMessage.showMessageStatusView == self.showMessageStatusView &&
            videoMessage.isMessageSelectorOn == self.isMessageSelectorOn &&
            videoMessage.isMessageSelected == self.isMessageSelected &&
            videoMessage.videoMessageData == self.videoMessageData &&
            videoMessage.showUnreadMessageLabel == self.showUnreadMessageLabel &&
            videoMessage.isEncrypted == self.isEncrypted
        return check
    }
}



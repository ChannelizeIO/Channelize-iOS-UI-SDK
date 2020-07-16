//
//  CHAudioMessageModel.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/31/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import UIKit

class AudioMessageData: Equatable {
    static func == (lhs: AudioMessageData, rhs: AudioMessageData) -> Bool {
        return lhs.audioUrl == rhs.audioUrl &&
            lhs.audioDuration == rhs.audioDuration
    }
    
    var audioUrl: String?
    var audioDuration: Double?
    init(url: String?, duration: Double?) {
        self.audioUrl = url
        self.audioDuration = duration
    }
}

class AudioMessageItem: ChannelizeChatItem {
    var audioData: AudioMessageData?
    var currentUploadProgress: Double?
    var playerStatus: AudioModelStatus = .stopped
    var playerProgress: Float = 0.0
    var isEncrypted: Bool?
    
    init(baseMessageModel: BaseMessageModel, audioData: AudioMessageData?) {
        super.init(baseMessageModel: baseMessageModel, messageType: .audio)
        self.audioData = audioData
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let item = AudioMessageItem(baseMessageModel: self.baseMessageModel, audioData: self.audioData)
        item.playerStatus = self.playerStatus
        item.playerProgress = self.playerProgress
        item.messageStatus = self.messageStatus
        item.showSenderName = self.showSenderName
        item.showDataSeperator = self.showDataSeperator
        item.showMessageStatusView = self.showMessageStatusView
        item.isMessageSelectorOn = self.isMessageSelectorOn
        item.isMessageSelected = self.isMessageSelected
        item.currentUploadProgress = self.currentUploadProgress
        item.reactionCountsInfo = self.reactionCountsInfo
        item.myMessageReactions = self.myMessageReactions
        item.reactions = self.reactions
        item.isEncrypted = self.isEncrypted
        item.showUnreadMessageLabel = self.showUnreadMessageLabel
        return item
    }
    
    override func isContentEqual(to source: ChannelizeChatItem) -> Bool {
        guard let audioSource = source as? AudioMessageItem else {
            return false
        }
        let check = audioSource.baseMessageModel == self.baseMessageModel &&
            audioSource.messageType == self.messageType &&
            audioSource.messageStatus == self.messageStatus &&
            audioSource.showSenderName == self.showSenderName &&
            audioSource.showDataSeperator == self.showDataSeperator &&
            audioSource.showMessageStatusView == self.showMessageStatusView &&
            audioSource.isMessageSelectorOn == self.isMessageSelectorOn &&
            audioSource.isMessageSelected == self.isMessageSelected &&
            audioSource.audioData == self.audioData &&
            audioSource.playerStatus == self.playerStatus &&
            audioSource.playerProgress == self.playerProgress &&
            audioSource.currentUploadProgress == self.currentUploadProgress &&
            audioSource.reactionCountsInfo == self.reactionCountsInfo &&
            audioSource.reactions == self.reactions &&
            audioSource.myMessageReactions == self.myMessageReactions &&
            audioSource.showUnreadMessageLabel == self.showUnreadMessageLabel &&
            audioSource.isEncrypted == self.isEncrypted
        return check
    }
}



//
//  CHDocMessageModel.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/4/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import DifferenceKit
import UIKit

enum DocMessageStatus {
    case downloading
    case uploading
    case notAvailableLocal
    case availableLocal
}

class DocMessageData: Equatable {
    static func == (lhs: DocMessageData, rhs: DocMessageData) -> Bool {
        return lhs.fileName == rhs.fileName &&
            lhs.downloadUrl == rhs.downloadUrl &&
            lhs.fileType == rhs.fileType &&
            lhs.fileSize == rhs.fileSize &&
            lhs.mimeType == rhs.mimeType &&
            lhs.fileExtension == rhs.fileExtension
    }
    
    var fileName: String?
    var downloadUrl: String?
    var fileType: String?
    var fileSize: Int?
    var mimeType: String?
    var fileExtension: String?
    
    init(fileName: String?, downloadUrl: String?, fileType: String?, fileSize: Int?, mimeType: String?, fileExtension: String?) {
        self.fileName = fileName
        self.downloadUrl = downloadUrl
        self.fileType = fileType
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.fileExtension = fileExtension
    }
}

class DocMessageItem: ChannelizeChatItem {
    var docMessageData: DocMessageData?
    var docStatus: DocMessageStatus = .notAvailableLocal
    var uploadProgress: Double = 0.0
    init(baseMessageModel: BaseMessageModel, docMessageData: DocMessageData?) {
        super.init(baseMessageModel: baseMessageModel, messageType: .doc)
        self.docMessageData = docMessageData
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let item = DocMessageItem(baseMessageModel: self.baseMessageModel, docMessageData: self.docMessageData)
        item.messageStatus = self.messageStatus
        item.showSenderName = self.showSenderName
        item.showDataSeperator = self.showDataSeperator
        item.showMessageStatusView = self.showMessageStatusView
        item.isMessageSelectorOn = self.isMessageSelectorOn
        item.isMessageSelected = self.isMessageSelected
        item.myMessageReactions = self.myMessageReactions
        item.reactions = self.reactions
        item.reactionCountsInfo = self.reactionCountsInfo
        item.docStatus = self.docStatus
        return item
    }
    
    override func isContentEqual(to source: ChannelizeChatItem) -> Bool {
        guard let docMessage = source as? DocMessageItem else {
            return false
        }
        let check = docMessage.baseMessageModel == self.baseMessageModel &&
            docMessage.messageType == self.messageType &&
            docMessage.messageStatus == self.messageStatus &&
            docMessage.showSenderName == self.showSenderName &&
            docMessage.showDataSeperator == self.showDataSeperator &&
            docMessage.showMessageStatusView == self.showMessageStatusView &&
            docMessage.isMessageSelectorOn == self.isMessageSelectorOn &&
            docMessage.isMessageSelected == self.isMessageSelected &&
            docMessage.docMessageData == self.docMessageData &&
            docMessage.docStatus == self.docStatus &&
            docMessage.reactions == self.reactions &&
            docMessage.myMessageReactions == self.myMessageReactions &&
            docMessage.reactionCountsInfo == self.reactionCountsInfo
        print(check)
        return check
    }
    
}


//
//  DocMessageModel.swift
//  ChannelizeUI
//
//  Created by bigstep on 4/23/20.
//  Copyright © 2020 Channelize. All rights reserved.
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

class DocMessageData {
    
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

class DocMessageModel: BaseMessageItemProtocol {
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: DocMessageModel) -> Bool {
        return true
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
        return .doc
    }
    
    var docStatus: DocMessageStatus = .notAvailableLocal
    
    var showMessageStatusView: Bool = false
    
    var messageStatus: BaseMessageStatus
    var messageSource: MessageSource?
    var baseMessageModel: BaseMessageModel
    var docMessageData: DocMessageData
    
    init(baseMessageModel: BaseMessageModel, messageData: DocMessageData) {
        self.baseMessageModel = baseMessageModel
        self.docMessageData = messageData
        self.messageStatus = baseMessageModel.messageStatus
    }
}

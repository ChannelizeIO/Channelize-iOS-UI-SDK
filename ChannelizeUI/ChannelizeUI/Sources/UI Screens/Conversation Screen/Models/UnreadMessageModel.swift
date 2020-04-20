//
//  UnreadMessageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import DifferenceKit

class UnReadMessageModel: BaseMessageItemProtocol {
    
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: UnReadMessageModel) -> Bool {
        return self.showMessageStatusView == source.showMessageStatusView && self.showSenderName == source.showSenderName && self.showDataSeperator == source.showDataSeperator
    }
    
    
    
    var showSenderName: Bool = false
    
    var showDataSeperator: Bool = false
    
    var messageId: String = "unread-\(UUID().uuidString)"
    
    var isIncoming: Bool = false
    
    var senderId: String = ""
    
    var senderName: String = ""
    
    var senderImageUrl: String = ""
    
    var messageDate: Date = Date()
    
    var messageStatus: BaseMessageStatus = .sent
    
    var messageType: BaseMessageType = .unReadMessage
    
    var isMessageSelectorOn: Bool = false
    
    var isMessageSelected: Bool = false
    
    var uploadProgress: Double = 0.0
    
    var showMessageStatusView: Bool = false
}

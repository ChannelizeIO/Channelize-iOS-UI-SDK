//
//  CHLinkMessageItem.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/11/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import DifferenceKit

class LinkMetaDataModel: Equatable {
    
    static func == (lhs: LinkMetaDataModel, rhs: LinkMetaDataModel) -> Bool {
        return lhs.linkHeaderTitle == rhs.linkHeaderTitle &&
            lhs.linkDescription == rhs.linkDescription &&
            lhs.linkImageUrl == rhs.linkImageUrl &&
            lhs.parentMessageId == rhs.parentMessageId &&
            lhs.mainUrl == rhs.mainUrl
    }
    
    var linkHeaderTitle : String?
    var linkDescription : String?
    var linkImageUrl : String?
    var parentMessageId : String?
    var mainUrl : String?
    
    init(
        title: String?, description: String?, imageUrl: String?, parentId: String?, linkUrl: String?) {
        self.linkHeaderTitle = title
        self.linkDescription = description
        self.linkImageUrl = imageUrl
        self.parentMessageId = parentId
        self.mainUrl = linkUrl
    }
}

class LinkMessageItem: ChannelizeChatItem {
    var linkMetaData: LinkMetaDataModel?
    var linkTitleAttributedString: NSAttributedString?
    var linkDescriptionAttributedString: NSAttributedString?
    init(baseMessage: BaseMessageModel, linkMetaData: LinkMetaDataModel?) {
        super.init(baseMessageModel: baseMessage, messageType: .linkPreview)
        self.linkMetaData = linkMetaData
        self.prepareLinkItemAttributedStrings()
    }
    
    private func prepareLinkItemAttributedStrings() {
        let linkTitle = self.linkMetaData?.linkHeaderTitle ?? ""
        let linkTitleIncomingColor = CHUIConstant.recentConversationTitleColor
        let linkTitleOutgoingColor = UIColor.white
        
        let linkDescriptionIncomingColor = CHUIConstant.recentConversationMessageColor
        let linkDescriptionOutgoingColor = UIColor(hex: "#FEFEFE")
        
        
        self.linkTitleAttributedString = NSAttributedString(string: linkTitle, attributes: [NSAttributedString.Key.font: UIFont(fontStyle: .medium, size: 16.0)!, NSAttributedString.Key.foregroundColor: self.baseMessageModel.isIncoming == true ? linkTitleIncomingColor : linkTitleOutgoingColor])
        
        let linkDescription = self.linkMetaData?.linkDescription ?? ""
        self.linkDescriptionAttributedString = NSAttributedString(string: linkDescription, attributes: [NSAttributedString.Key.font: UIFont(fontStyle: .regular, size: 14.0)!, NSAttributedString.Key.foregroundColor: self.baseMessageModel.isIncoming == true ? linkDescriptionIncomingColor : linkDescriptionOutgoingColor])
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let item = LinkMessageItem(baseMessage: self.baseMessageModel, linkMetaData: self.linkMetaData)
        item.messageStatus = self.messageStatus
        item.showSenderName = self.showSenderName
        item.showDataSeperator = self.showDataSeperator
        item.showMessageStatusView = self.showMessageStatusView
        item.isMessageSelectorOn = self.isMessageSelectorOn
        item.isMessageSelected = self.isMessageSelected
        item.showUnreadMessageLabel = self.showUnreadMessageLabel
        return item
    }
    
    override func isContentEqual(to source: ChannelizeChatItem) -> Bool {
        guard let textMessage = source as? LinkMessageItem else {
            return false
        }
        let check = textMessage.baseMessageModel == self.baseMessageModel &&
            textMessage.messageType == self.messageType &&
            textMessage.messageStatus == self.messageStatus &&
            textMessage.showSenderName == self.showSenderName &&
            textMessage.showDataSeperator == self.showDataSeperator &&
            textMessage.showMessageStatusView == self.showMessageStatusView &&
            textMessage.linkMetaData == self.linkMetaData &&
            textMessage.showUnreadMessageLabel == self.showUnreadMessageLabel
        return check
    }
}

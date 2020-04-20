//
//  UISdkLinkPreviewModel.swift
//  Channelize-API-SDK
//
//  Created by Ashish-BigStep on 2/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import DifferenceKit

class LinkMetaDataModel {
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

class LinkPreviewModel : BaseMessageItemProtocol, Differentiable{
    
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: LinkPreviewModel) -> Bool {
        return self.showMessageStatusView == source.showMessageStatusView && self.showSenderName == source.showSenderName && self.showDataSeperator == source.showDataSeperator
    }
    
    var showSenderName: Bool = false
    
    var showMessageStatusView: Bool = false
    
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
        return .linkPreview
    }
    
    var messageStatus: BaseMessageStatus
    var messageSource: MessageSource?
    var baseMessageModel: BaseMessageModel
    var linkData: LinkMetaDataModel?
    
    var linkTitleAttributedString: NSAttributedString?
    var linkDescriptionAttributedString: NSAttributedString?
    
    init(baseMessageModel: BaseMessageModel, linkData: LinkMetaDataModel?) {
        self.baseMessageModel = baseMessageModel
        self.linkData = linkData
        self.messageStatus = baseMessageModel.messageStatus
        self.prepareLinkItemAttributedStrings()
    }
    
    private func prepareLinkItemAttributedStrings() {
        let linkTitle = self.linkData?.linkHeaderTitle ?? ""
        self.linkTitleAttributedString = NSAttributedString(string: linkTitle, attributes: [NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabMedium, size: 16.0)!, NSAttributedString.Key.foregroundColor: self.baseMessageModel.isIncoming == true ? UIColor(hex: "#1c1c1c") : UIColor.white])
        
        let linkDescription = linkData?.linkDescription ?? ""
        self.linkDescriptionAttributedString = NSAttributedString(string: linkDescription, attributes: [NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: 14.0)!, NSAttributedString.Key.foregroundColor: self.baseMessageModel.isIncoming == true ? UIColor(hex: "#1c1c1c") : UIColor.white])
    }
}

/*
 
 var height : CGFloat = 0
 //height += 150
 if (linkPreviewModel.linkMetaData?.linkImageUrl) != nil{
     height += 150
 }
 if let linkTitle = linkPreviewModel.linkMetaData?.linkHeaderTitle{
     let labelHeight = getLabelHeight(text: linkTitle, maxWidth: 240, font: UIFont.systemFont(ofSize: 15.0, weight: .bold), numberOfLines: 2)
     height += labelHeight
 }
 if let linkDescription = linkPreviewModel.linkMetaData?.linkDescription{
     let labelHeight = getLabelHeight(text: linkDescription, maxWidth: 240, font: UIFont.systemFont(ofSize: 14.0))
     height += labelHeight
 }
 
 return height+25
 */


//
//  LocationMessageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import MapKit
import DifferenceKit

class LocationMessageModel: BaseMessageItemProtocol, Differentiable {
    
    var differenceIdentifier: String {
        return messageId
    }
    
    func isContentEqual(to source: LocationMessageModel) -> Bool {
        return self.showMessageStatusView == source.showMessageStatusView && self.showSenderName == source.showSenderName && self.showDataSeperator == source.showDataSeperator
    }
    
    var showSenderName: Bool = false
    
    var showMessageStatusView: Bool = false
    
    var showDataSeperator: Bool = false
    
    var isMessageSelectorOn: Bool = false
    
    var isMessageSelected: Bool = false
    
    var uploadProgress: Double = 0.0
    
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
    
    var messageType: BaseMessageType {
        return .location
    }
    
    var myMessageReactions: [String] = []
    var reactionCountsInfo: [String : Int] = [:]
    var reactions: [ReactionModel] = []

    var baseMessageModel: BaseMessageModel
    var locationName: String?
    var locationAddress: String?
    var locationLatitude: Double?
    var locationLongitude: Double?
    var locationNameAttributedString: NSAttributedString?
    var locationAddressAttributedString: NSAttributedString?
    
    init(baseMessageModel: BaseMessageModel, locationName: String?, locationAddress: String?, locationLatitude: Double?, locationLongitude: Double?) {
        self.baseMessageModel = baseMessageModel
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
        self.messageStatus = baseMessageModel.messageStatus
        self.createAttributedString()
    }
    
    private func createAttributedString() {
        let nameAttributes: [NSAttributedString.Key:Any] = [
            NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: 17.0)!,
            NSAttributedString.Key.foregroundColor: self.isIncoming == true ? UIColor(hex: "#1c1c1c") : UIColor(hex: "#ffffff")
        ]
        
        let addressAttributes: [NSAttributedString.Key:Any] = [
            NSAttributedString.Key.font: UIFont(fontStyle: .robotoSlabRegualar, size: 15.0)!,
            NSAttributedString.Key.foregroundColor: self.isIncoming == true ? UIColor(hex: "#2c2c2c") : UIColor(hex: "#fafafa")
        ]
        
        self.locationNameAttributedString = NSAttributedString(string: self.locationName ?? "", attributes: nameAttributes)
        self.locationAddressAttributedString = NSAttributedString(string: self.locationAddress ?? "", attributes: addressAttributes)
    }
}


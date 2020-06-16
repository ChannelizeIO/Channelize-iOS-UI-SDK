//
//  CHLocationMessageModel.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 5/31/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationMessageData: Equatable {
    static func == (lhs: LocationMessageData, rhs: LocationMessageData) -> Bool {
        return lhs.locationName == rhs.locationName &&
            lhs.locationAddress == rhs.locationAddress &&
            lhs.locationLatitude == rhs.locationLatitude &&
            lhs.locationLongitude == rhs.locationLongitude
    }
    
    var locationName: String?
    var locationAddress: String?
    var locationLatitude: Double?
    var locationLongitude: Double?
    var locationNameAttributedString: NSAttributedString?
    var locationAddressAttributedString: NSAttributedString?
    
    init(locationName: String?, locationAddress: String?, locationLatitude: Double?, locationLongitude: Double?) {
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
    }
    
    func createAttributedString(isIncoming: Bool) {
        
        let incomingTitleColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#1c1c1c")
        let incomingAddressColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#e6e6e6") : UIColor(hex: "#2c2c2c")
        
        let outgoingTitleColor = UIColor(hex: "#ffffff")
        let outGoingAddressColor = UIColor(hex: "#fafafa")
        
        let nameAttributes: [NSAttributedString.Key:Any] = [
            NSAttributedString.Key.font: UIFont(fontStyle: .regular, size: 17.0)!,
            NSAttributedString.Key.foregroundColor: isIncoming == true ? incomingTitleColor : outgoingTitleColor
        ]
        
        let addressAttributes: [NSAttributedString.Key:Any] = [
            NSAttributedString.Key.font: UIFont(fontStyle: .regular, size: 15.0)!,
            NSAttributedString.Key.foregroundColor: isIncoming == true ? incomingAddressColor : outGoingAddressColor
        ]
        
        self.locationNameAttributedString = NSAttributedString(string: self.locationName ?? "", attributes: nameAttributes)
        self.locationAddressAttributedString = NSAttributedString(string: self.locationAddress ?? "", attributes: addressAttributes)
    }
}


class LocationMessageItem: ChannelizeChatItem {
    var locationData: LocationMessageData?
    init(baseMessageModel: BaseMessageModel, locationData: LocationMessageData?) {
        super.init(baseMessageModel: baseMessageModel, messageType: .location)
        self.locationData = locationData
        self.locationData?.createAttributedString(isIncoming: baseMessageModel.isIncoming)
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let item = LocationMessageItem(baseMessageModel: self.baseMessageModel, locationData: self.locationData)
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
        return item
    }
    
    override func isContentEqual(to source: ChannelizeChatItem) -> Bool {
        guard let locationDataSource = source as? LocationMessageItem else {
            return false
        }
        let check = locationDataSource.baseMessageModel == self.baseMessageModel &&
            locationDataSource.messageType == self.messageType &&
            locationDataSource.messageStatus == self.messageStatus &&
            locationDataSource.showSenderName == self.showSenderName &&
            locationDataSource.showDataSeperator == self.showDataSeperator &&
            locationDataSource.showMessageStatusView == self.showMessageStatusView &&
            locationDataSource.isMessageSelectorOn == self.isMessageSelectorOn &&
            locationDataSource.isMessageSelected == self.isMessageSelected &&
            locationDataSource.locationData == self.locationData &&
            locationDataSource.myMessageReactions == self.myMessageReactions &&
            locationDataSource.reactions == self.reactions &&
            locationDataSource.reactionCountsInfo == self.reactionCountsInfo &&
            locationDataSource.showUnreadMessageLabel == self.showUnreadMessageLabel
        return check
    }
    
}


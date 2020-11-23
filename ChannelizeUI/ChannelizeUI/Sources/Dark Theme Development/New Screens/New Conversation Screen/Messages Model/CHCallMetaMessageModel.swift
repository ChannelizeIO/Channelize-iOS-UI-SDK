//
//  CHCallMetaMessageModel.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 8/13/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI

class CHCallMetaData {
    var messageType: AdminMessageType?
    var callType: CHCallType?
    var callDuration: Int?
    var subjectId: String?
    var subjectType: String?
    var subjectUser: CHUser?
    var callCreatedAt: Date?
    
    init(messageType: AdminMessageType?, callType: CHCallType?, callDuration: Int?, subjectId: String?, subjectType: String?, subjectUser: CHUser?, callCreatedAt: Date?) {
        self.messageType = messageType
        self.callType = callType
        self.callDuration = callDuration
        self.subjectId = subjectId
        self.subjectType = subjectType
        self.subjectUser = subjectUser
        self.callCreatedAt = callCreatedAt
    }
    
}

class CHCallMetaMessageModel: ChannelizeChatItem {
    var callMetaData: CHCallMetaData?
    var callMetaMessageAttributedString: NSAttributedString?
    
    init(baseMessageModel: BaseMessageModel, metaMessageData: CHCallMetaData) {
        super.init(baseMessageModel: baseMessageModel, messageType: .callMetaMessage)
        self.callMetaData = metaMessageData
        self.prepareFormattedString()
    }
    
    private func prepareFormattedString() {
        guard let metaMessageData = self.callMetaData else {
            return
        }
        guard let messageType = metaMessageData.messageType else {
            return
        }
        /**
        switch messageType {
        case .callCompleted:
            let initialAttributedString = NSMutableAttributedString(string: "Call", attributes: [NSAttributedString.Key.font: CHCustomStyles.mediumSizeMediumFont!, NSAttributedString.Key.foregroundColor: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor])
            let callDurationString = ((Double(callMetaData?.callDuration ?? 0))).asString(style: .abbreviated)
            
            let durationAttributedString = NSMutableAttributedString(string: " \(callDurationString)", attributes: [NSAttributedString.Key.font: CHCustomStyles.metaMessageFont!, NSAttributedString.Key.foregroundColor: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.secondaryColor : CHLightThemeColors.secondaryColor])
            initialAttributedString.append(durationAttributedString)
            self.callMetaMessageAttributedString = initialAttributedString
            break
        case .callDeclined:
            let attributedString = NSAttributedString(string: "Call Declined", attributes: [NSAttributedString.Key.font: CHCustomStyles.mediumSizeMediumFont!, NSAttributedString.Key.foregroundColor: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor])
            self.callMetaMessageAttributedString = attributedString
        case .callNotAnswered:
            let attributedString = NSAttributedString(string: "No Answer", attributes: [NSAttributedString.Key.font: CHCustomStyles.mediumSizeMediumFont!, NSAttributedString.Key.foregroundColor: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor])
            self.callMetaMessageAttributedString = attributedString
        case .callMissed:
            let attributedString = NSAttributedString(string: "Missed Call", attributes: [NSAttributedString.Key.font: CHCustomStyles.mediumSizeMediumFont!, NSAttributedString.Key.foregroundColor: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.primaryColor : CHLightThemeColors.primaryColor])
            self.callMetaMessageAttributedString = attributedString
        default:
            break
        
        }
         */
    }
}


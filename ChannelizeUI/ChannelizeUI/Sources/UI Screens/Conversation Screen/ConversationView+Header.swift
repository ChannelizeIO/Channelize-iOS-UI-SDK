//
//  ConversationView+Header.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import UIKit

extension UIConversationViewController {
    
    func configureHeaderView() {
        let conversationData = self.conversation
        let conversationTitle = conversationData?.isGroup == true ? conversationData?.title : self.user?.displayName?.capitalized
        let profileImageUrl = conversationData?.isGroup == true ? conversationData?.profileImageUrl : self.user?.profileImageUrl
        let membersCountString = "\(conversationData?.membersCount ?? 0) Members"
        let memberSeenString = self.user?.isOnline == true ? "Online" : getLastSeen(lastSeenDate: self.user?.lastSeen)
        
        let conversationInfo = conversationData?.isGroup == true ? membersCountString : memberSeenString
        
        
        self.conversationHeaderView.updateConversationTitleView(
            conversationTitle: conversationTitle)
        self.conversationHeaderView.updateProfileImageView(
            imageUrlString: profileImageUrl, conversationTitle: conversationTitle)
        self.conversationHeaderView.updateConversationInfoView(
            infoString: conversationInfo)
        
        if conversationData?.isGroup == true {
            self.conversationHeaderView.hidesCallButton()
        } else {
            if CHConstants.isChannelizeCallAvailable == false {
                self.conversationHeaderView.hidesCallButton()
            }
        }
    }
    
    
    func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func callButtonPressed(callType: CHCallType) {
        if callType == .voice {
            let bundleUrl = Bundle.url(forResource: "ChannelizeCall", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
            let bundle = Bundle(url: bundleUrl!)
            bundle?.load()
            let aClass : AnyClass? = NSClassFromString("ChannelizeCall.ChannelizeCall")
            if let callMainClass = aClass as? CallSDKDelegates.Type{
                if let unwrappedUser = self.conversation?.conversationPartner {
                    callMainClass.launchCallViewController(
                        navigationController: self.navigationController, user: unwrappedUser, type: CHCallScreen.voice.rawValue)
                }
            }
        } else if callType == .video {
            let bundleUrl = Bundle.url(forResource: "ChannelizeCall", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
            let bundle = Bundle(url: bundleUrl!)
            bundle?.load()
            let aClass : AnyClass? = NSClassFromString("ChannelizeCall.ChannelizeCall")
            if let callMainClass = aClass as? CallSDKDelegates.Type{
                if let unwrappedUser = self.conversation?.conversationPartner {
                    callMainClass.launchCallViewController(
                        navigationController: self.navigationController, user: unwrappedUser, type: CHCallScreen.video.rawValue)
                }
            }
        }
    }
    
    func menuButtonPressed() {
        let optionsSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteConversation = UIAlertAction(title: "Delete Conversation", style: .destructive, handler: {(action) in
            let alertController = UIAlertController(title: "Delete Conversation", message: "Are you sure you want to delete this conversation? Once deleted, it cannot be undone.", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
                self.deleteConversation()
            })
            let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        })
        let clearConversation = UIAlertAction(title: "Clear Conversation", style: .default, handler: {(action) in
            let alertController = UIAlertController(title: "Clear Conversation", message: "Are you sure you want to clear this conversation? Once cleared, it cannot be undone.", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Clear", style: .destructive, handler: {(action) in
                self.clearConversation()
            })
            let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        })
        let blockUserAction = UIAlertAction(title: "Block User", style: .default, handler: {(action) in
            self.blockUser()
        })
        let unblockUserAction = UIAlertAction(title: "Unblock User", style: .default, handler: {(action) in
            self.unblockUser()
        })
        let muteConversationAction = UIAlertAction(title: "Mute Conversation", style: .default, handler: {(action) in
            self.muteUnMuteConversation()
        })
        let unMuteConversation = UIAlertAction(title: "UnMute Conversation", style: .default, handler: {(action) in
            self.muteUnMuteConversation()
        })
        let viewProfileAction = UIAlertAction(title: "View Profile", style: .default, handler: {(action) in
            if self.conversation?.isGroup == true {
                let controller = GroupProfileViewController()
                controller.hidesBottomBarWhenPushed = true
                controller.conversation = self.conversation
                self.navigationController?.pushViewController(
                    controller, animated: true)
            } else {
                let controller = UserProfileViewController()
                controller.hidesBottomBarWhenPushed = true
                controller.conversation = self.conversation
                controller.user = self.conversation?.conversationPartner
                self.navigationController?.pushViewController(controller, animated: true)
            }
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        
        optionsSheet.addAction(deleteConversation)
        optionsSheet.addAction(clearConversation)
        if self.conversation?.isGroup == false {
            if self.conversation?.isPartnerIsBlocked == true {
                optionsSheet.addAction(unblockUserAction)
            } else {
                optionsSheet.addAction(blockUserAction)
            }
        }
        if self.conversation?.isMute == true {
            optionsSheet.addAction(unMuteConversation)
        } else {
            optionsSheet.addAction(muteConversationAction)
        }
        optionsSheet.addAction(viewProfileAction)
        optionsSheet.addAction(cancelAction)
        self.present(optionsSheet, animated: true, completion: nil)
    }
    
    func doneButtonPressed() {
        self.setMessageSelectorOff()
    }
    
    func infoViewTapped() {
        if self.conversation?.isGroup == true {
            let controller = GroupProfileViewController()
            controller.conversation = self.conversation
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(
                controller, animated: true)
        } else {
            let controller = UserProfileViewController()
            controller.user = self.user
            controller.conversation = self.conversation
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(
                controller, animated: true)
        }
    }
}

// MARK:- Global Functions
func getLastSeen(lastSeenDate: Date?) -> String {
    if let timestampDate = lastSeenDate {
        let date = Date()
        return CHLocalized(key: "pmLastSeen")+" "+timeAgoSinceDate(
            timestampDate, currentDate: date, numericDates: false)
    }
    return ""
}

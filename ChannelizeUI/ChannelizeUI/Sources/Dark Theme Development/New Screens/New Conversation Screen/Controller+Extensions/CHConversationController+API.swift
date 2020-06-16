//
//  CHConversationController+API.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI

extension CHConversationViewController {
    // MARK: - API Functions
    
    func getMessages() {
        let queryBuilder = CHGetMessageQueryBuilder()
        queryBuilder.limit = self.messageApiCallLimit
        queryBuilder.skip = self.currentOffset
        //queryBuilder.attachmentTypes = [.video,.image,.gif,.sticker]
        //queryBuilder.types = [.normal]
        //queryBuilder.attachmentTypes = []
        ChannelizeAPIService.getConversationMessages(conversationId: self.conversation?.id ?? "", queryBuilder: queryBuilder, completion: {(messages,errorString) in
            //self.isLoadingMessage = false
            self.loaderView.hideSpinnerView()
            self.loaderView.removeFromSuperview()
            guard errorString == nil else {
                print("Failed to Recieve Messages. Error: \(errorString ?? "")")
                return
            }
            if let recievedMessages = messages {
                if recievedMessages.count < self.messageApiCallLimit {
                    self.canloadMoreMessage = false
                } else {
                    self.canloadMoreMessage = true
                }
                if self.currentOffset == 0 {
                    self.currentOffset += recievedMessages.count
                    self.isLoadingInitialMessage = false
                    self.prepareNormalMessageItems(with: recievedMessages, isInitialLoad: true)
                } else {
                    self.currentOffset += recievedMessages.count
                    if recievedMessages.count > 0 {
                        self.prepareNormalMessageItems(with: recievedMessages, isInitialLoad: false)
                    }
                }
                self.detectLinkItems()
            }
            if self.chatItems.count == 0 {
                self.view.addSubview(self.noMessageContentView)
                self.noMessageContentView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
                self.noMessageContentView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
                self.noMessageContentView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
                self.noMessageContentView.setBottomAnchor(relatedConstraint: self.inputBar.topAnchor, constant: 0)
            } else {
                self.noMessageContentView.removeFromSuperview()
            }
            //self.collectionView.reloadData()
        })
    }
    
    func markConversationRead() {
        ChannelizeAPIService.markConversationRead(conversationId: self.conversation?.id ?? "", completion: {(status,errorString) in
            if status {
                print("All Messagess Marked Successfully")
            } else {
                print("Failed To Marked ConversationRead")
                print("Error: \(errorString ?? "")")
            }
        })
    }
    
    func getConversationMembers() {
        guard let conversationId = self.conversation?.id else {
            print("Invalid Conversation Id")
            return
        }
        ChannelizeAPIService.getConversationsMembers(conversationId: conversationId, completion: {(members,errorString) in
            guard errorString == nil else {
                print("Fail to get Members")
                print("Errors: \(errorString ?? "")")
                return
            }
            self.conversation?.members = members
            self.conversation?.membersCount = self.conversation?.members?.count
            if self.conversation?.isGroup == false {
                self.headerView.updatePartnerStatus(conversation: self.conversation)
                self.headerView.updateBlockStatus(conversation: self.conversation)
                self.blockStatusView.updateBlockStatusView(conversation: self.conversation)
            } else {
                self.headerView.updateGroupMembersInfo(conversation: self.conversation)
                self.blockStatusView.updateBlockStatusView(conversation: self.conversation)
            }
        })
    }
    
    func clearConversation() {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.clearConversation(conversationId: conversationId, completion: {[weak self](status,errorString) in
            if status {
                //self?.chatItems.removeAll()
                //self?.collectionView.reloadData()
                showProgressSuccessView(superView: self?.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self?.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    func deleteConversation() {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.deleteConversation(conversationId: conversationId, completion: {[weak self](status,errorSting) in
            if status {
                self?.navigationController?.popViewController(animated: true)
                showProgressSuccessView(superView: self?.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self?.navigationController?.view, errorString: errorSting)
            }
        })
    }
    
    func blockUser() {
        guard let userId = self.conversation?.conversationPartner?.id else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.blockUser(userId: userId, completion: {[weak self](status,errorString) in
            if status {
                showProgressSuccessView(superView: self?.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self?.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    func unblockUser() {
        guard let userId = self.conversation?.conversationPartner?.id else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.unblockUser(userId: userId, completion: {[weak self](status,errorString) in
            if status {
                showProgressSuccessView(superView: self?.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self?.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    func muteUnMuteConversation() {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.navigationController?.view, string: nil)
        let isConversationMute = self.conversation?.isMute ?? false
        ChannelizeAPIService.muteConversation(conversationId: conversationId, isMute: !isConversationMute, completion: {[weak self](status,errorString) in
            if status {
                showProgressSuccessView(superView: self?.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self?.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    func deleteMessages(messageIds: [String]) {
        self.setMessageSelectorOff()
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.deleteMessages(messageIds: messageIds, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
                //self.removeItemsFromCollectionView(itemsIds: messageIds)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
    
    func deleteMessagesForEveryOne(messageIds: [String]) {
        self.setMessageSelectorOff()
        showProgressView(superView: self.navigationController?.view, string: nil)
        ChannelizeAPIService.deleteMessagesForEveryOne(messageIds: messageIds, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.navigationController?.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.navigationController?.view, errorString: errorString)
            }
        })
    }
}


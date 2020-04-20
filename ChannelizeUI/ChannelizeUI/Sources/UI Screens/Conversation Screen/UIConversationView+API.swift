//
//  UIConversationView+API.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import Alamofire
import ChannelizeAPI
import ObjectMapper

extension UIConversationViewController {
    func getConversationMessages(offset: Int) {
        var params = [String:Any]()
        params.updateValue(50, forKey: "limit")
        params.updateValue(offset, forKey: "skip")
        ChannelizeAPIService.getConversationMessages(conversationId: self.conversation?.id ?? "", params: params, completion: {(messages,errorString) in
            //self.isLoadingMessage = false
            guard errorString == nil else {
                return
            }
            if let recievedMessages = messages {
                
                // Convert Them to realm Model

                
                
                self.currentOffset += recievedMessages.count
                if recievedMessages.count < 50 {
                    self.canloadMoreMessage = false
                }
                if offset == 0 {
                    self.isLoadingInitialMessage = false
                    self.prepareNormalMessageItems(with: recievedMessages, isInitialLoad: true)
                    
                    
                    //self.prepareConversationItems(messages: recievedMessages)
                    //self.collectionView.reloadData()
                    //self.scrollToBottom(animated: false)
                    //self.collectionView.scrollToLast(animated: false)
                    ChannelizeAPIService.markConversationRead(
                        conversationId: self.conversation?.id ?? "", completion: {(status,errorString) in
                        if status {
                            print("Conversation Marked as Read")
                        } else {
                            print("Fail to Mark Conversation Read")
                        }
                    })
                    self.detectLinkItems()
                } else {
                    if recievedMessages.count > 0 {
                        self.prepareNormalMessageItems(with: recievedMessages, isInitialLoad: false)
                        //self.addMoreMessagesOnTop(messages: recievedMessages)
                    }
                }
            }
        })
    }
    
    func deleteMessages(messageIds: [String]) {
        self.setMessageSelectorOff()
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.deleteMessages(messageIds: messageIds, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
                //self.removeItemsFromCollectionView(itemsIds: messageIds)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
    
    func deleteMessagesForEveryOne(messageIds: [String]) {
        self.setMessageSelectorOff()
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.deleteMessagesForEveryOne(messageIds: messageIds, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
    
    func deleteConversation() {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.deleteConversation(conversationId: conversationId, completion: {(status,errorSting) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorSting)
            }
        })
    }
    
    func clearConversation() {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.clearConversation(conversationId: conversationId, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
    
    func muteUnMuteConversation() {
        guard let conversationId = self.conversation?.id else {
            return
        }
        showProgressView(superView: self.view, string: nil)
        let isConversationMute = self.conversation?.isMute ?? false
        ChannelizeAPIService.muteConversation(conversationId: conversationId, isMute: !isConversationMute, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
    
    func blockUser() {
        guard let userId = self.conversation?.conversationPartner?.id else {
            return
        }
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.blockUser(userId: userId, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
    
    func unblockUser() {
        guard let userId = self.conversation?.conversationPartner?.id else {
            return
        }
        showProgressView(superView: self.view, string: nil)
        ChannelizeAPIService.unblockUser(userId: userId, completion: {(status,errorString) in
            if status {
                showProgressSuccessView(superView: self.view, withStatusString: nil)
            } else {
                showProgressErrorView(superView: self.view, errorString: errorString)
            }
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0{
//            print("============================")
//            print(scrollView.contentOffset.y)
//            print(scrollView.contentSize.height)
//            print(scrollView.bounds.height)
//            print("############################")
            let contentOffset = scrollView.contentOffset.y
            let contentSize = scrollView.contentSize.height
            let collectionViewHeight = scrollView.bounds.height
            
            if contentOffset < 650{
                if self.isLoadingMessage == false {
                    if self.canloadMoreMessage == true {
                        self.isLoadingMessage = true
                        self.getConversationMessages(offset: self.currentOffset)
                        print("Loading Next Messages")
                    }
                }
            }
            if contentSize - contentOffset - collectionViewHeight > 150 {
                if self.isLoadingInitialMessage {
                    plusButton.isHidden = true
                } else {
                    plusButton.isHidden = false
                }
            } else {
                plusButton.isHidden = true
            }
        } else {
            print("============================")
            print(scrollView.contentOffset.y)
            print(scrollView.contentSize.height)
            print(scrollView.bounds.height)
            print("############################")
            let contentOffset = scrollView.contentOffset.y
            let contentSize = scrollView.contentSize.height
            let collectionViewHeight = scrollView.bounds.height
            if self.isLoadingInitialMessage {
                plusButton.isHidden = true
            } else {
                if contentSize - contentOffset - collectionViewHeight < 150 {
                    plusButton.isHidden = true
                    plusButton.removeBadgeCount()
                } else {
                    //plusButton.isHidden = false
                }
            }
        }
        
        
        /*
        if self.collectionView.contentSize.height <= self.collectionView.bounds.height {
            plusButton.isHidden = true
        } else {
            if self.isCloseToBottom(){
                plusButton.removeBadgeCount()
                plusButton.isHidden = true
            } else if self.isCloseToTop() {
                if self.isLoadingInitialMessage {
                    plusButton.isHidden = true
                } else {
                    plusButton.isHidden = false
                }
                if self.isLoadingMessage == false {
                    if self.canloadMoreMessage == true {
                        self.isLoadingMessage = true
                        self.getConversationMessages(offset: self.currentOffset)
                        print("Loading Next Messages")
                    }
                }
            } else {
                if self.isLoadingInitialMessage {
                    plusButton.isHidden = true
                } else {
                    if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0{
                        if scrollView.contentOffset.y < 200{
                            plusButton.isHidden = false
                        }
                    }
                }
            }
        }
 */
        /*
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0{
            if scrollView.contentOffset.y < 650{
                if self.isLoadingMessage == false {
                    if self.canloadMoreMessage == true {
                        self.isLoadingMessage = true
                        self.getConversationMessages(offset: self.currentOffset)
                        print("Loading Next Messages")
                    }
                }
            }
            print("Scrolling in upward direction")
        } else{
            let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems
            visibleIndexPaths.forEach({
                print("Scroll to IndexPath \($0.item)")
            })
        }
         */
    }
    
    public func visibleRect() -> CGRect {
        guard let collectionView = self.collectionView else { return CGRect.zero }
        let contentInset = collectionView.contentInset
        let collectionViewBounds = collectionView.bounds
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        return CGRect(x: CGFloat(0), y: collectionView.contentOffset.y + contentInset.top, width: collectionViewBounds.width, height: min(contentSize.height, collectionViewBounds.height - contentInset.top - contentInset.bottom))
    }
    
    public func isCloseToBottom() -> Bool {
        guard let collectionView = self.collectionView else { return true }
        guard collectionView.contentSize.height > 0 else { return true }
        return (self.visibleRect().maxY / collectionView.contentSize.height) > (1 - 0.05)
    }
    
    public func isCloseToTop() -> Bool {
        guard let collectionView = self.collectionView else { return true }
        guard collectionView.contentSize.height > 0 else { return true }
        return (self.visibleRect().minY / collectionView.contentSize.height) < 0.05
    }
    
    @objc func moveToBottom(){
        self.scrollToBottom(animated: false)
    }
    
    func scrollToBottom(animated: Bool) {
        guard let collectionView = self.collectionView else { return }
        // Cancel current scrolling
        collectionView.setContentOffset(collectionView.contentOffset, animated: false)
        
        // Note that we don't rely on collectionView's contentSize. This is because it won't be valid after performBatchUpdates or reloadData
        // After reload data, collectionViewLayout.collectionViewContentSize won't be even valid, so you may want to refresh the layout manually
        let offsetY = max(-collectionView.contentInset.top, collectionView.collectionViewLayout.collectionViewContentSize.height - collectionView.bounds.height + collectionView.contentInset.bottom)
        
        // Don't use setContentOffset(:animated). If animated, contentOffset property will be updated along with the animation for each frame update
        // If a message is inserted while scrolling is happening (as in very fast typing), we want to take the "final" content offset (not the "real time" one) to check if we should scroll to bottom again
        if animated {
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
            })
        } else {
            collectionView.contentOffset = CGPoint(x: 0, y: offsetY)
        }
    }
}

//
//  CHConversationController+Others.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import UIKit
import MapKit
import AVFoundation
import Alamofire
import QuickLook
import DifferenceKit

class CHPopOverBackView: UIPopoverBackgroundView {
    
    override class var wantsDefaultContentAppearance: Bool {
        return false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CHConversationViewController: ReactionPopOverControllerDelegate, UIPopoverPresentationControllerDelegate, AVAudioPlayerDelegate, QLPreviewControllerDataSource {
    
    func getConvertedPoint(_ targetView: UIView, baseView: UIView)->CGPoint{
        var pnt = targetView.frame.origin
        if nil == targetView.superview{
            return pnt
        }
        var superView = targetView.superview
        while superView != baseView{
            pnt = superView!.convert(pnt, to: superView!.superview)
            if nil == superView!.superview{
                break
            }else{
                superView = superView!.superview
            }
        }
        return superView!.convert(pnt, to: baseView)
    }
    
    func showPopOverForItem(chatItem: ChannelizeChatItem, sourcePoint: CGPoint, sourceFrameSize: CGSize, arrowDirection: UIPopoverArrowDirection) {
        let controller = ReactionPopOverController()
        controller.messageId = chatItem.messageId
        controller.delegate = self
        controller.myReactions = chatItem.myMessageReactions
        controller.preferredContentSize = CGSize(width: self.view.frame.width - 30, height: 60)
        controller.modalPresentationStyle = .popover
        if let popoverPresentationController = controller.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = arrowDirection
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(origin: sourcePoint, size: sourceFrameSize)
            popoverPresentationController.delegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func calculateReactionViewHeight(chatItem: ChannelizeChatItem, maxWidth: CGFloat) -> CGFloat{
        let reactionsModels = chatItem.reactions
        guard reactionsModels.count > 0 else {
            return 0
        }
        var initialOriginX: CGFloat = 5
        var initialOriginY: CGFloat = 2.5
        //let selfWidth = self.view.frame.width
        var currentItemWidth: CGFloat = 0
        reactionsModels.forEach({
            let reaction = $0
            if reaction.counts == 1 {
                currentItemWidth = 30
            } else {
                let emojiString = reaction.unicode ?? ""
                let emojiWidth = emojiString.width(withConstrainedHeight: 30, font: UIFont.systemFont(ofSize: 20.0, weight: .medium))
                let count = reaction.counts ?? 0
                let countsWidth = "\(count)".width(withConstrainedHeight: 30, font: UIFont.systemFont(ofSize: 20.0, weight: .regular))
                let totalWidth = 2.5 + emojiWidth + 2.5 + countsWidth + 2.5
                currentItemWidth = totalWidth
            }
            if initialOriginX + currentItemWidth < maxWidth - 5{
                initialOriginX = initialOriginX + currentItemWidth + 5
            } else {
                initialOriginY += 32.5
                initialOriginX = 5 + currentItemWidth + 2.5
            }
        })
        return initialOriginY + 30 + 2.5
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
     
    }
     
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        popoverPresentationController.presentingViewController.dismiss(animated: true, completion: nil)
        return true
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.presentingViewController.view.backgroundColor = .clear
    }
    
//    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
//        //presentationController.presentingViewController.dismiss(animated: false, completion: nil)
//        return true
//    }
    
    func didSelectReaction(reaction: EmojiReactionModel, messageId: String?) {
        if let firstIndex = self.chatItems.firstIndex(where: {
                    $0.messageId == messageId
            }) {
            let chatItem = self.chatItems[firstIndex]
            chatItem.myMessageReactions.append(reaction.emojiKey ?? "")
            
            if let existingReaction = chatItem.reactions.first(where: {
                $0.unicode == reaction.emojiCode
            }) {
                existingReaction.counts = (existingReaction.counts ?? 0) + 1
            } else {
                let model = ReactionModel()
                model.counts = 1
                model.unicode = reaction.emojiCode
                chatItem.reactions.append(model)
                //chatItem.reactions.insert(model, at: 0)
            }
            chatItem.reactions.sort(by: {
                $0.counts ?? 0 > $1.counts ?? 0
            })
            // Check if there is Any Reaction or Not for selected Reaction Key
            if let reactionCounts = chatItem.reactionCountsInfo["\(reaction.emojiKey ?? "")"] {
                chatItem.reactionCountsInfo.updateValue(reactionCounts+1, forKey: reaction.emojiKey ?? "")
            } else {
                chatItem.reactionCountsInfo.updateValue(1, forKey: reaction.emojiKey ?? "")
            }
            
            if chatItem.messageType == .text || chatItem.messageType == .quotedMessage {
                self.collectionView.reloadData()
            } else {
                self.collectionView.reloadData()
            }
            ChannelizeAPIService.addMessageReaction(messageId: chatItem.messageId, reactionType: reaction.emojiKey ?? "", completion: {(status,errorString) in
                if status {
                    print("Message Reaction Added Successfully")
                } else {
                    print("Failed To Add Message Reaction")
                    print("Error: \(errorString ?? "")")
                }
            })
        }
    }
    
    func didRemoveReaction(reaction: EmojiReactionModel, messageId: String?) {
        if let firstIndex = self.chatItems.firstIndex(where: {
                   $0.messageId == messageId
        }) {
            let chatItem = self.chatItems[firstIndex]
            chatItem.myMessageReactions.removeAll(where: {
                $0 == reaction.emojiKey
            })
            if let existingReactionIndex = chatItem.reactions.firstIndex(where: {
                $0.unicode == emojiCodes["\(reaction.emojiKey ?? "")"]
            }) {
                let existingReaction = chatItem.reactions[existingReactionIndex]
                if existingReaction.counts ?? 0 > 1 {
                    existingReaction.counts = (existingReaction.counts ?? 0) - 1
                } else {
                    chatItem.reactions.remove(at: existingReactionIndex)
                }
                chatItem.reactions.sort(by: {
                    $0.counts ?? 0 > $1.counts ?? 0
                })
            }
            // Check if there is Any Reaction or Not for selected Reaction Key
            if let reactionCounts = chatItem.reactionCountsInfo["\(reaction.emojiKey ?? "")"] {
                chatItem.reactionCountsInfo.updateValue(reactionCounts-1, forKey: reaction.emojiKey ?? "")
            }
            if chatItem.messageType == .text || chatItem.messageType == .quotedMessage {
                self.collectionView.reloadData()
            } else {
                self.collectionView.reloadData()
            }
           
            ChannelizeAPIService.removeMessageReaction(messageId: chatItem.messageId, reactionType: reaction.emojiKey ?? "", completion: {(status,errorString) in
                if status {
                    print("Message Reaction Removed Successfully")
                } else {
                    print("Failed To Remove Message Reaction")
                    print("Error: \(errorString ?? "")")
                }
            })
        }
    }
    
    // MARK: - UIScrollView Functions
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.viewWithTag(2056)?.removeFromSuperview()
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 {
            let contentOffset = scrollView.contentOffset.y
            let contentSize = scrollView.contentSize.height
            let collectionViewHeight = scrollView.bounds.height
            
            if contentOffset < 650{
                if self.isLoadingMessage == false {
                    if self.canloadMoreMessage == true {
                        self.isLoadingMessage = true
                        self.getMessages()
                        print("Loading Next Messages")
                    }
                }
            }
            if contentSize - contentOffset - collectionViewHeight > 150 {
                if self.isLoadingInitialMessage {
                    self.moveToBottomButton.isHidden = true
                } else {
                    moveToBottomButton.isHidden = false
                }
            } else {
                moveToBottomButton.isHidden = true
            }
        } else {
            let contentOffset = scrollView.contentOffset.y
            let contentSize = scrollView.contentSize.height
            let collectionViewHeight = scrollView.bounds.height
            if self.isLoadingInitialMessage {
                moveToBottomButton.isHidden = true
            } else {
                if contentSize - contentOffset - collectionViewHeight < 150 {
                    moveToBottomButton.isHidden = true
                    moveToBottomButton.removeBadgeCount()
                } else {
                    
                }
            }
        }
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
        return (self.visibleRect().maxY / collectionView.contentSize.height) > (1 - 0.15)
    }
    
    public func isCloseToTop() -> Bool {
        guard let collectionView = self.collectionView else { return true }
        guard collectionView.contentSize.height > 0 else { return true }
        if self.visibleRect().minY < 20 {
            return true
        } else {
            return false
        }
        //print(self.visibleRect().minY)
        //return (self.visibleRect().minY / collectionView.contentSize.height) < 0.15
    }
    
    func checkAndSetNoContentView() {
        if self.chatItems.count == 0 {
            self.moveToBottomButton.isHidden = true
            self.view.addSubview(noMessageContentView)
            self.noMessageContentView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
            self.noMessageContentView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
            self.noMessageContentView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
            self.noMessageContentView.setBottomAnchor(relatedConstraint: self.inputBar.topAnchor, constant: 0)
        } else {
            self.noMessageContentView.removeFromSuperview()
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Message Option Functions
    func showMessageOptions(messageId: String, senderId: String, isDeleted: Bool = false) {
        self.view.endEditing(true)
        let chatItem = self.chatItems.first(where: {
            $0.messageId == messageId
        })
        
        let copyAction = CHActionSheetAction(title: CHLocalized(key: "pmMenuItemCopy"), image: nil, actionType: .default, handler: {(action) in
            if let textItem = chatItem as? TextMessageItem {
                let messageString = textItem.attributedString?.string
                UIPasteboard.general.string = messageString
            }
        })
        
        let deleteAction = CHActionSheetAction(title: CHLocalized(key: "pmDeleteSingleMessage"), image: nil, actionType: .destructive, handler: {(action) in
            self.perfromMessageDelete(messageId: messageId, senderId: senderId, isDeleted: isDeleted)
        })
        
        let replyAction = CHActionSheetAction(title: CHLocalized(key: "pmReply"), image: nil, actionType: .default, handler: {(action) in
            if let chatItem = self.chatItems.first(where: {
                $0.messageId == messageId
            }) {
                let parentId = chatItem.messageId
                let senderName = chatItem.senderName
                let senderId = chatItem.senderId
                var imageUrl: String?
                var textMessage: NSAttributedString?
                switch chatItem.messageType {
                case .quotedMessage:
                    textMessage = (chatItem as? QuotedMessageItem)?.attributedString
                    break
                case .image:
                    imageUrl = (chatItem as? ImageMessageItem)?.imageMessageData?.imageUrlString
                    break
                case .video:
                    imageUrl = (chatItem as? VideoMessageItem)?.videoMessageData?.thumbNailUrl
                    break
                case .gifSticker:
                    imageUrl = (chatItem as? GifStickerMessageItem)?.gifStickerData?.stillUrl
                    break
                case .text:
                    textMessage = (chatItem as? TextMessageItem)?.attributedString
                    break
                case .doc:
                    if let docModel = chatItem as? DocMessageItem {
                        if let fileExtension = docModel.docMessageData?.fileExtension {
                            if let icon = mimeTypeIcon[fileExtension.lowercased()] {
                                textMessage = "\(docModel.docMessageData?.fileName ?? "")".with(getImage("\(icon)"))
                            } else {
                                textMessage = "\(docModel.docMessageData?.fileName ?? "")".with(getImage("chFileIcon"))
                            }
                        }
                    }
                    break
                default:
                    break
                }
                self.currentQuotedModel = QuotedViewModel(parentId: parentId, senderName: senderName, senderId: senderId, imageUrl: imageUrl, textMessage: textMessage, messageType: chatItem.messageType)
                
                self.topStackViewContainer.arrangedSubviews.first(where: {
                    $0.tag == 50001
                })?.removeFromSuperview()
                let quotedView = QuotedMessageView()
                quotedView.tag = 50001
                //quotedView.delegate = self
                quotedView.translatesAutoresizingMaskIntoConstraints = false
                self.topStackViewContainer.addArrangedSubview(quotedView)
                quotedView.heightAnchor.constraint(equalToConstant: 60).isActive = true
                quotedView.setLeftAnchor(relatedConstraint: self.topStackViewContainer.leftAnchor, constant: 0)
                quotedView.setRightAnchor(relatedConstraint: self.topStackViewContainer.rightAnchor, constant: 0)
                quotedView.quotedViewModel = self.currentQuotedModel
                quotedView.onCloseButtonPressed = {
                    self.topStackViewContainer.arrangedSubviews.first(where: {
                        $0.tag == 50001
                    })?.removeFromSuperview()
                    UIView.animate(withDuration: 0.33, animations: {
                        if self.autoCompleteTableHeightConstraint != nil {
                            self.topStackContainerHeightConstraint.constant = self.autoCompleteTableHeightConstraint.constant
                        } else {
                            self.topStackContainerHeightConstraint.constant = 0
                        }
                        self.view.layoutIfNeeded()
                    })
                }
                UIView.animate(withDuration: 0.2, animations: {
                    self.topStackContainerHeightConstraint.constant = 60
                    self.view.layoutIfNeeded()
                }, completion: { completed in
                    self.inputBar.becomeFirstResponder()
                    self.inputBar.inputTextView.becomeFirstResponder()
                })
            }
        })
        
        let forwardAction = CHActionSheetAction(title: "Forward", image: nil, actionType: .default, handler: {(action) in
            let controller = CHMessageForwardScreenController()
            controller.messageIds = [messageId]
            self.navigationController?.pushViewController(controller, animated: true)
        })
       
        let moreAction = CHActionSheetAction(title: CHLocalized(key: "pmMore"), image: nil, actionType: .default, handler: {(action) in
            self.setMessageSelectorOn(with: messageId)
        })
        
        var actionsList = [CHActionSheetAction]()
        if chatItem is TextMessageItem {
            if isDeleted == false {
                actionsList.append(copyAction)
            }
        }
        if self.conversation?.isGroup == true {
            if self.conversation?.isActive == true {
                if isDeleted == false {
                    actionsList.append(replyAction)
                }
            }
        } else {
            if self.conversation?.membersCount == 2 {
                if isDeleted == false {
                    actionsList.append(replyAction)
                }
            }
        }
        if isDeleted == false {
            actionsList.append(forwardAction)
        }
        actionsList.append(deleteAction)
        actionsList.append(moreAction)
        let controller = CHActionSheetController()
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.actions = actionsList
        self.present(controller, animated: true, completion: nil)
    }
    
    func perfromMessageDelete(messageId: String, senderId: String, isDeleted: Bool) {
        
        let deleteForMeAction = CHActionSheetAction(title: CHLocalized(key: "pmDeleteForMe"), image: nil, actionType: .destructive, handler: {(action) in
            self.deleteMessages(messageIds: [messageId])
        })
        let deleteForEveryOneAction = CHActionSheetAction(title: CHLocalized(key: "pmDeleteForEveryone"), image: nil, actionType: .destructive, handler: {(action) in
            self.deleteMessagesForEveryOne(messageIds: [messageId])
        })
        let cancelAction = CHActionSheetAction(title: CHLocalized(key: "pmCancel"), image: nil, actionType: .cancel, handler: nil)
        let controller = CHAlertViewController()
        controller.alertTitle = CHLocalized(key: "pmDeleteSingleMessage")
        controller.alertDescription = CHLocalized(key: "pmSingleDeleteSelectedConfirm")
        controller.actions.append(deleteForMeAction)
        if senderId == Channelize.getCurrentUserId() {
            if isDeleted == false {
                controller.actions.append(deleteForEveryOneAction)
            }
        }
        controller.actions.append(cancelAction)
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
    }
    
    func setMessageSelectorOn(with messageId: String) {
        self.isMessageSelectorOn = true
        self.headerView.showDoneButton()
        self.chatItems.forEach({
            if $0.messageType == .missedVideoCall || $0.messageType == .missedVoiceCall || $0.messageType == .linkPreview{
                $0.isMessageSelectorOn = false
            } else {
                $0.isMessageSelectorOn = true
            }
        })
        if let firstItem = self.chatItems.first(where: {
            $0.messageId.contains(messageId)
        }) {
            firstItem.isMessageSelected = true
            self.selectedMessages.append(messageId)
        }
        
        self.collectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
        deleteMessageToolBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didPressDeleteMessageButton(sender:)))
        deleteMessageToolBarButton.tintColor = UIColor.customSystemRed
        deleteMessageToolBarButton.isEnabled = true
        forwardMessageToolBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didPressForwardMessageButton(sender:)))
        forwardMessageToolBarButton.tintColor = CHUIConstant.appTintColor
            forwardMessageToolBarButton.isEnabled = true
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let customBarButton = UIBarButtonItem(customView: selectedMessageCountLabel)
            
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        //rightSpace.width = 10
        self.navigationController?.toolbar.barTintColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#0c0c0c") : UIColor.white
        self.toolbarItems = [deleteMessageToolBarButton,space,customBarButton,rightSpace,forwardMessageToolBarButton]
        selectedMessageCountLabel.text = "\(self.selectedMessages.count) Selected"
            self.navigationController?.setToolbarHidden(false, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            //self.topStackContainerHeightConstraint.constant = 50
            self.inputBarHeightConstraint.constant = 0
            self.inputBarBottomConstraint.constant = 50
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func didPressDeleteMessageButton(sender: UIBarButtonItem) {
        var showMessageDeleteForEveryone = true
        self.selectedMessages.forEach({
            let id = $0
            if let textModel = self.chatItems.first(where: {
                $0.messageId == id
            }) as? TextMessageItem {
                if textModel.isDeletedMessage == true {
                    showMessageDeleteForEveryone = false
                } else {
                    if textModel.senderId != Channelize.getCurrentUserId() {
                        showMessageDeleteForEveryone = false
                    }
                }
            } else {
                if let chatItem = self.chatItems.first(where: {
                    $0.messageId == id
                }) {
                    if chatItem.senderId != Channelize.getCurrentUserId() {
                        showMessageDeleteForEveryone = false
                    }
                }
            }
        })
        let deleteForMeAction = CHActionSheetAction(title: CHLocalized(key: "pmDeleteForMe"), image: nil, actionType: .destructive, handler: {(action) in
            self.deleteMessages(messageIds: self.selectedMessages)
        })
        
        let deleteForMeOnlyAction = CHActionSheetAction(title: CHLocalized(key: "pmDeleteForEveryone"), image: nil, actionType: .destructive, handler: {(action) in
            self.deleteMessagesForEveryOne(messageIds: self.selectedMessages)
        })
        let controller = CHActionSheetController()
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.actions.append(deleteForMeAction)
        if showMessageDeleteForEveryone == true {
            controller.actions.append(deleteForMeOnlyAction)
        }
        self.present(controller, animated: true, completion: nil)
    }
            
    @objc func didPressForwardMessageButton(sender: UIBarButtonItem) {
        let controller = CHMessageForwardScreenController()
        let messageIds = self.selectedMessages.compactMap({ $0 })
        controller.messageIds = messageIds
        self.navigationController?.pushViewController(controller, animated: true)
        self.setMessageSelectorOff()
    }
    
    func setMessageSelectorOff() {
        self.isMessageSelectorOn = false
        let oldItems = self.chatItems.copy()
        self.headerView.hideDoneButton()
        if conversation?.isGroup == true {
            self.headerView.hideCallButtons()
        }
        self.chatItems.forEach({
            $0.isMessageSelectorOn = false
            $0.isMessageSelected = false
        })
        self.selectedMessages.removeAll()
        let oldOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
        self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
            self.chatItems = data
        }, completion: {
            self.collectionView.setContentOffset(CGPoint(x: 0, y: self.collectionView.contentSize.height - oldOffset), animated: false)
            CATransaction.commit()
        })
        self.navigationController?.setToolbarHidden(true, animated: true)
        UIView.animate(withDuration: 0.33, animations: {
            self.inputBarBottomConstraint.constant = 0
            self.inputBarHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
        })
    }
    
    func performMessageSelectDeSelect(messageModel: ChannelizeChatItem?) {
        guard let itemModel = messageModel else {
            return
        }
        if let itemIndex = self.chatItems.firstIndex(where: {
            $0.messageId.contains(itemModel.messageId)
        }) {
            messageModel?.isMessageSelected = !(messageModel?.isMessageSelected ?? false)
            let reloadIndexPath = IndexPath(item: itemIndex, section: 0)
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [reloadIndexPath])
            }, completion: nil)
            if messageModel?.isMessageSelected == true {
                self.selectedMessages.append(itemModel.messageId)
            } else {
                self.selectedMessages.removeAll(where: {
                    $0 == messageModel?.messageId
                })
            }
            self.selectedMessageCountLabel.text = "\(self.selectedMessages.count) Selected"
            self.selectedMessageCountLabel.sizeToFit()
        }
    }
    
    // MARK: - Attachments Actions
    func openInMap(_ data: LocationMessageItem?){
        if let lat = data?.locationData?.locationLatitude, let long = data?.locationData?.locationLongitude{
            let regionDistance: CLLocationDistance = 5000
            let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = data?.locationData?.locationAddress
            MKMapItem.openMaps(with: [mapItem], launchOptions: options)
        }
    }
    
    // MARK: - Audio Attachment Functions
    func playAudioMessage(model: AudioMessageItem?) {
        guard let audioDataModel = model else {
            return
        }
        if audioModel == nil {
            audioModel = audioDataModel
            self.setupPlayer()
        } else if audioModel?.messageId != audioDataModel.messageId {
            self.audioModel?.playerStatus = .stopped
            stopAudioProgress()
            if let index = self.chatItems.firstIndex(where: {
                $0.messageId == self.audioModel?.messageId
            }) {
                let indexPath = IndexPath(item: index, section: 0)
                let audioCell = self.collectionView.cellForItem(at: indexPath) as? UIAudioMessageCell
                audioCell?.audioMessageModel?.playerStatus = .stopped
                audioCell?.audioMessageModel?.playerProgress = 0.0
                self.collectionView.reloadItems(at: [indexPath])
            }
            self.audioModel = nil
            audioModel = audioDataModel
            setupPlayer()
        } else {
            self.updateAudioCellStatus()
        }
    }
    
    func updateAudioCellStatus() {
        if let index = self.chatItems.firstIndex(where: {
            $0.messageId == self.audioModel?.messageId
        }) {
            let indexPath = IndexPath(item: index, section: 0)
            let audioCell = self.collectionView.cellForItem(at: indexPath) as? UIAudioMessageCell
            if audioCell?.audioMessageModel?.playerStatus == .playing {
                audioCell?.audioMessageModel?.playerStatus = .paused
                if(self.audioPlayer?.isPlaying ?? false){
                    self.stopAudioProgress()
                    self.audioPlayer?.stop()
                }
            } else if audioCell?.audioMessageModel?.playerStatus == .stopped {
                audioCell?.audioMessageModel?.playerStatus = .playing
            } else if audioCell?.audioMessageModel?.playerStatus == .paused {
                audioCell?.audioMessageModel?.playerStatus = .playing
                self.startAudioProgress()
                self.audioPlayer?.play()
            }
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func setupPlayer(){
        if let firstIndexPath = self.chatItems.firstIndex(where: {
            $0.messageId == audioModel?.messageId
        }) {
            let indexPath = IndexPath(item: firstIndexPath, section: 0)
            if let cell = self.collectionView.cellForItem(at: indexPath) as? UIAudioMessageCell {
                cell.audioMessageModel?.playerStatus = .loading
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadItems(at: [indexPath])
                }, completion: nil)
            }
        }
        
        if let url = audioModel?.audioData?.audioUrl {
            var data: Data?
            DispatchQueue.global(qos: .background).async {
                do {
                    data = try Data(contentsOf: URL(string: url)!)
                } catch {
                    print("Unable to load data: \(error)")
                }
                DispatchQueue.main.async {
                    do {
                        if #available(iOS 10.0, *) {
                            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: .defaultToSpeaker)
                        } else {
                            // Fallback on earlier versions
                        }
                        self.audioPlayer = try AVAudioPlayer(data: data!)
                        if self.audioPlayer?.prepareToPlay() ?? false {
                            if let firstIndexPath = self.chatItems.firstIndex(where: {
                                $0.messageId == self.audioModel?.messageId
                            }) {
                                let indexPath = IndexPath(item: firstIndexPath, section: 0)
                                if let cell = self.collectionView.cellForItem(at: indexPath) as? UIAudioMessageCell {
                                    cell.audioMessageModel?.playerStatus = .playing
                                    self.collectionView.performBatchUpdates({
                                        self.collectionView.reloadItems(at: [indexPath])
                                    }, completion: nil)
                                }
                            }
                            self.startAudioProgress()
                            self.audioPlayer?.delegate = self
                            self.audioPlayer?.play()
                        }
                    } catch {
                        print("Unable to play audio file: \(error)")
                    }
                }
            }
        }
    }
    
    func stopAudio(){
        if(self.audioPlayer?.isPlaying ?? false) {
            self.stopAudioProgress()
            self.audioPlayer?.stop()
        }
    }
    
    func stopAudioProgress(){
        if let player = self.audioPlayer {
            self.audioModel?.audioData?.audioDuration = player.currentTime*1000
            self.audioModel?.playerProgress = Float(player.currentTime/player.duration)
            if let index = self.chatItems.firstIndex(where: {
                $0.messageId == self.audioModel?.messageId
            }) {
                let indexPath = IndexPath(item: index, section: 0)
                let audioCell = self.collectionView.cellForItem(at: indexPath) as? UIAudioMessageCell
                if self.audioModel?.playerStatus != .stopped {
                    audioCell?.updateProgressView(newProgress: Float(player.currentTime/player.duration), currentTiming: player.currentTime)
                }
            }
        }
        audioProgressTimer?.invalidate()
        audioProgressTimer = nil
    }
    
    func startAudioProgress(){
        audioProgressTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateAudioProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateAudioProgress(){
        if let player = self.audioPlayer, player.isPlaying {
            self.audioModel?.audioData?.audioDuration = player.currentTime
            self.audioModel?.playerProgress = Float(player.currentTime/player.duration)
            if let index = self.chatItems.firstIndex(where: {
                $0.messageId == self.audioModel?.messageId
            }) {
                let indexPath = IndexPath(item: index, section: 0)
                let audioCell = self.collectionView.cellForItem(at: indexPath) as? UIAudioMessageCell
                audioCell?.updateProgressView(newProgress: Float(player.currentTime/player.duration), currentTiming: player.currentTime)
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioModel?.playerStatus = .stopped
        stopAudioProgress()
        if let index = self.chatItems.firstIndex(where: {
            $0.messageId == self.audioModel?.messageId
        }) {
            let indexPath = IndexPath(item: index, section: 0)
            let audioCell = self.collectionView.cellForItem(at: indexPath) as? UIAudioMessageCell
            audioCell?.audioMessageModel?.playerStatus = .stopped
            audioCell?.audioMessageModel?.playerProgress = 0.0
            audioCell?.audioMessageModel?.audioData?.audioDuration = player.duration*1000
            self.collectionView.reloadItems(at: [indexPath])
        }
        self.audioModel = nil
    }
    
    // MARK: - Image and Video Message Open
    func openImageViewer(with model: ChannelizeChatItem?) {
        var tappedPhotoIndex = 0
        var channelizeImages = [ChannelizeImages]()
        let filteredItems = self.chatItems.filter({
            $0.messageType == .image || $0.messageType == .video
        })
        if let index = filteredItems.firstIndex(where: {
            $0.messageId == model?.messageId
        }){
            tappedPhotoIndex = index
        }
        
        for object in filteredItems{
            if object.messageType == .image {
                let imageModel = object as? ImageMessageItem
                let chImage = ChannelizeImages(imageUrlString: imageModel?.imageMessageData?.imageUrlString, videoUrlString: nil, owner: imageModel?.senderName, date: imageModel?.messageDate)
                channelizeImages.append(chImage)
            } else if object.messageType == .video {
                let videoModel = object as? VideoMessageItem
                let chImage = ChannelizeImages(imageUrlString: videoModel?.videoMessageData?.thumbNailUrl, videoUrlString: videoModel?.videoMessageData?.videoUrlString, owner: videoModel?.senderName, date: videoModel?.messageDate)
                channelizeImages.append(chImage)
            }
        }
        
        if channelizeImages.count > 0 {
            let offset = 0
            let chatId = self.conversation?.id ?? ""
            let controller = PhotoViewerController(imagesArray: channelizeImages, index: tappedPhotoIndex, offset: offset, chatId: chatId, messageCount: self.chatItems.count)
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.modalPresentationStyle = .currentContext
            navigationController.modalTransitionStyle = .crossDissolve
            self.present(navigationController,animated: true,completion: nil)
        }
    }
    
    // MARK: - Document Attachment Functions
    func downloadDocFile(docMessage: DocMessageItem?) {
        guard let docMessageModel = docMessage else {
            return
        }
        if let index = self.chatItems.firstIndex(where: {
            $0.messageId == docMessageModel.messageId
        }) {
            let cellIndexPath = IndexPath(item: index, section: 0)
            docMessageModel.docStatus = .downloading
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: [cellIndexPath])
            }, completion: nil)
            if let fileUrl = URL(string: docMessageModel.docMessageData?.downloadUrl ?? "") {
                let fileName = fileUrl.lastPathComponent
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent(fileName)
                let destination: DownloadRequest.DownloadFileDestination = {_,_ in
                    return(fileURL,[])
                }
                
                Alamofire.download(fileUrl, to: destination).downloadProgress(closure: { progress  in
                    docMessageModel.uploadProgress = progress.fractionCompleted
                    if let docMessageCell = self.collectionView.cellForItem(at: cellIndexPath) as? UIDocMessageCell {
                        docMessageCell.updateProgress(fromValue: docMessageModel.uploadProgress, toValue: progress.fractionCompleted)
                    }
                    }).response(completionHandler: { (downloadResponse) in
                        print(downloadResponse.destinationURL?.absoluteString ?? "")
                        docMessageModel.docStatus = .availableLocal
                        self.collectionView.performBatchUpdates({
                            self.collectionView.reloadItems(at: [cellIndexPath])
                        }, completion: nil)
                    })
            }
            
        }
    }
        
    func openDocFile(docMessage: DocMessageItem?) {
        guard let docMessageModel = docMessage else {
            return
        }
        if let fileUrl = URL(string: docMessageModel.docMessageData?.downloadUrl ?? "") {
            let fileName = fileUrl.lastPathComponent
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(fileName)
            if NSData(contentsOf: fileURL) != nil {
                let previewController = QLPreviewController()
                previewController.dataSource = self
                self.currentDocPreviewUrl = fileURL
                self.navigationController?.pushViewController(previewController, animated: true)
                //self.present(previewController, animated: true, completion: nil)
            }
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.currentDocPreviewUrl as QLPreviewItem
    }
    
    // MARK: - Link Attachment Functions
    func detectLinkItems() {
        let textItems = self.chatItems.filter({
            $0.messageType == .text || $0.messageType == .quotedMessage
        })
        textItems.forEach({
            if let textModel = $0 as? TextMessageItem {
                self.detectAndAddLinkMessages(with: textModel)
            }
        })
    }
    
    func detectAndAddLinkMessages(with message: TextMessageItem){
        let textString = message.textMessageData?.messageBody ?? ""
        
        var shouldAddLinkModel = true
        
        self.chatItems.forEach({
            if let linkItem = $0 as? LinkMessageItem {
                if linkItem.linkMetaData?.parentMessageId == message.messageId {
                    shouldAddLinkModel = false
                }
            }
        })
        
        if shouldAddLinkModel == false{
            return
        }
        
        do{
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let range = NSRange(location: 0, length: textString.utf16.count)
            let resultArray = detector.matches(in: textString, options: [], range: range)
            
            let linkMetaData = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: DispatchQueue.main, cache: InMemoryCache())
            for result in resultArray.reversed(){
                guard let range = Range(result.range, in: textString) else { continue }
                let url = textString[range]
                print("Detected Links in Text message is \(url)")
                
                if let cached = linkMetaData.cache.slp_getCachedResponse(url: String(url)) {
                    let linkMetaModel = LinkMetaDataModel(title: cached.title, description: cached.description, imageUrl: cached.image, parentId: message.messageId, linkUrl: cached.finalUrl?.absoluteString)
                        
                        let prefixId = self.randomId(length: 4)
                        let suffixId = self.randomId(length: 4)
                        let messageId = "\(prefixId)#\(message.messageId)#\(suffixId)"
                        
                        let baseMessageModel = BaseMessageModel(uid: messageId, senderId: message.senderId, senderName: message.senderName, senderImageUrl: message.senderImageUrl, messageDate: message.messageDate, status: message.messageStatus)
                        
                        let linkPreviewModel = LinkMessageItem(baseMessage: baseMessageModel, linkMetaData: linkMetaModel)
                        if let parentMessageIndex = self.chatItems.firstIndex(where: {
                            $0.messageId == message.messageId
                        }) {
                            let oldChatItems = self.chatItems.copy()
                            self.chatItems.insert(linkPreviewModel, at: parentMessageIndex + 1)
                            self.reprepareChatItems()
                            let changeSet = StagedChangeset(source: oldChatItems, target: self.chatItems)
                            self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                                self.chatItems = data
                            }, completion: {

                            })
                        }
                        print("+++++++++++++++")
                } else {
                    // Perform preview otherwise
                    linkMetaData.preview(String(url), onSuccess: { response in
                    print("===============")
                    print(response.title ?? "")
                    print(response.description ?? "")
                    print(response.image ?? "")
                    
                    let linkMetaModel = LinkMetaDataModel(title: response.title, description: response.description, imageUrl: response.image, parentId: message.messageId, linkUrl: response.finalUrl?.absoluteString)
                    
                    let prefixId = self.randomId(length: 4)
                    let suffixId = self.randomId(length: 4)
                    let messageId = "\(prefixId)#\(message.messageId)#\(suffixId)"
                    
                    let baseMessageModel = BaseMessageModel(uid: messageId, senderId: message.senderId, senderName: message.senderName, senderImageUrl: message.senderImageUrl, messageDate: message.messageDate, status: message.messageStatus)
                    
                    let linkPreviewModel = LinkMessageItem(baseMessage: baseMessageModel, linkMetaData: linkMetaModel)
                    if let parentMessageIndex = self.chatItems.firstIndex(where: {
                        $0.messageId == message.messageId
                    }) {
                        let oldChatItems = self.chatItems.copy()
                        self.chatItems.insert(linkPreviewModel, at: parentMessageIndex + 1)
                        self.reprepareChatItems()
                        let changeSet = StagedChangeset(source: oldChatItems, target: self.chatItems)
                        self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                            self.chatItems = data
                        }, completion: {

                        })
                    }
                    print("+++++++++++++++")
                    }, onError: { error in
                        print("===============")
                        print(error.description)
                        print("+++++++++++++++")
                    })
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func randomId(length:Int=6) -> String{
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}


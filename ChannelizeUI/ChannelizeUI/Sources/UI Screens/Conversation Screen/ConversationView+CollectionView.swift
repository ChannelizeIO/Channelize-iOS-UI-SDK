//
//  ConversationView+CollectionView.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import AVFoundation
import MapKit
import Alamofire
import QuickLook

extension UIConversationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AVAudioPlayerDelegate, LongPressMessageBlurViewDelegate, QuotedMessageViewDelegate {
    func didPressCloseQuotedViewButton() {
        self.quotedMessageViewContainer.subviews.forEach({
            $0.removeFromSuperview()
        })
        self.quotedMessageViewContainer.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: {
            self.topStackContainerHeightConstraint.constant = 0
        })
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isLoadingInitialMessage == true {
            self.plusButton.isHidden = true
            return 10
        } else {
            if self.chatItems.count == 0 {
                self.plusButton.isHidden = true
                collectionView.isScrollEnabled = false
                return 1
            } else {
                collectionView.isScrollEnabled = true
                return self.chatItems.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isLoadingInitialMessage == true {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "shimmeringMessageCell", for: indexPath) as! PhotoMessageShimmeringCell
            if indexPath.item % 3 == 0 {
                cell.setUpViewsFrames(isIncoming: indexPath.item % 2 == 0)
                cell.showPhotoShimmer()
            } else if indexPath.item % 3 == 1 {
                cell.setUpViewsFrames(isIncoming: indexPath.item % 2 == 0)
                cell.showTextMessageShimmer()
            } else if indexPath.item % 3 == 2 {
                cell.setUpViewsFrames(isIncoming: indexPath.item % 2 == 0)
                cell.showTextMessageShimmer()
            }
            return cell
        } else {
            if self.chatItems.count == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noConversationMessageCell", for: indexPath)
                return cell
            } else {
                let chatItem = self.chatItems[indexPath.row]
                switch chatItem.messageType {
                case .image:
                    return self.configureImageMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
                case .video:
                    return self.configureVideoMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
                case .audio:
                    return self.configureAudioMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
                case .gifSticker:
                    return self.configureGifStickerMessageCell(
                        collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
                case .location:
                    return self.configureLocationMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
                case .text, .deletedMessage:
                    return self.configureTextMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
                case .metaMessage:
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: "metaMessageCell", for: indexPath) as! UIMetaMessageCell
                    cell.metaMessageModel = chatItem as? MetaMessageModel
                    return cell
                case .linkPreview:
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: "linkPreviewCell", for: indexPath) as! LinkPreviewCollectionCell
                    cell.linkDataModel = chatItem as? LinkPreviewModel
                    return cell
                case .quotedMessage:
                    return self.configureQuotedMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
                case .groupedImages:
                    return self.configureGroupedImagesCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
                case .unReadMessage:
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: "unreadMessageCell", for: indexPath) as! UnReadMessageHeaderCell
                    return cell
                case .missedVideoCall, .missedVoiceCall:
                    return self.configureMissCallCellItem(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
                case .doc:
                    return self.configureDocMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
                default:
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: "blankCell", for: indexPath)
                    return cell
                    //return UICollectionViewCell()
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.isLoadingInitialMessage == true {
            if indexPath.item % 3 == 0 {
                return CGSize(width: self.view.frame.width, height: 170)
            } else if indexPath.item % 3 == 1 {
                return CGSize(width: self.view.frame.width, height: 70)
            } else if indexPath.item % 3 == 2 {
                return CGSize(width: self.view.frame.width, height: 70)
            } else {
                return CGSize(width: self.view.frame.width, height: 0)
            }
        } else {
            if self.chatItems.count == 0 {
                let screenHeight = UIScreen.main.bounds.height
                let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
                let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0.0
                return CGSize(width: self.view.frame.width, height: screenHeight - navBarHeight - tabBarHeight)
            } else {
                let chatItem = self.chatItems[indexPath.row]
                switch chatItem.messageType{
                case .image:
                    return self.getImageMessageSize(chatItem: chatItem)
                case .video:
                    return self.getVideoMessageSize(chatItem: chatItem)
                case .audio:
                    return self.getAudioMessageCellSize(chatItem: chatItem)
                case .gifSticker:
                    return self.getGifStickerCellSize(chatItem: chatItem)
                case .location:
                    return self.getLocationCellheight(chatItem: chatItem)
                case .text, .deletedMessage:
                    return self.getTextMessageItemHeight(chatItem: chatItem)
                case .metaMessage:
                    return self.getMetaMessageHeight(chatItem: chatItem)
                case .linkPreview:
                    return self.getLinkPreviewMessageHeight(chatItem: chatItem)
                case .quotedMessage:
                    return self.getQuotedMessageItemHeight(chatItem: chatItem)
                case .groupedImages:
                    return self.getGroupedMessageItemHeight(chatItem: chatItem)
                case .unReadMessage:
                    return CGSize(width: self.view.frame.width, height: 45)
                case .missedVoiceCall, .missedVideoCall:
                    return self.getMissedCallItemHeight(chatItem: chatItem)
                    //return CGSize(width: self.view.frame.width, height: 100)
                case .doc:
                    return self.getDocMessageCellSize(chatItem: chatItem)
                default:
                    return .zero
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
    // MARK: - Configure Cells
    private func configureMissCallCellItem(collectionView: UICollectionView, indexPath: IndexPath, chatItem: BaseMessageItemProtocol) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "missCallMessageCell", for: indexPath) as! CHMissCallMessageCell
        cell.assignChatItem(chatItem: chatItem)
        cell.onCallBackButtonTapped = {[weak self] (callType) in
            self?.showCallSelectAlert()
        }
        return cell
    }
    
    private func configureQuotedMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: BaseMessageItemProtocol) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "newQuotedMessageCell", for: indexPath) as! CHQuotedMessageCell
        cell.assignChatItem(chatItem: chatItem)
        cell.onLongPressedBubble = {[weak self] (cell) in
            if let quotedMessageCell = cell as? CHQuotedMessageCell {
                self?.showMessageOptions(messageId: quotedMessageCell.quotedMessageModel?.messageId ?? "", senderId: quotedMessageCell.quotedMessageModel?.senderId ?? "")
            }
        }
        cell.onCellTapped = {[weak self](cell) in
            if let quotedMessageCell = cell as? CHQuotedMessageCell {
                self?.performMessageSelectDeSelect(messageModel: quotedMessageCell.quotedMessageModel)
            }
        }
        cell.onContainerViewTapped = {[weak self](messageId) in
            if let indexPath = self?.chatItems.firstIndex(where: {
                $0.messageId == messageId
            }) {
                let parentMessageIndex = IndexPath(item: indexPath, section: 0)
                self?.collectionView.scrollToItem(at: parentMessageIndex, at: .centeredVertically, animated: false)
            }
        }
        return cell
    }
    
    private func configureAudioMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: BaseMessageItemProtocol) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newAudioMessageCell", for: indexPath) as! CHAudioMessageCell
        cell.assignChatItem(chatItem: chatItem)
        cell.onPlayButtonPressed = {[weak self] (audioCell) in
            self?.playAudioMessage(model: audioCell.audioMessageModel)
        }
        cell.onPauseButtonPressed = {[weak self] (audioCell) in
            self?.playAudioMessage(model: audioCell.audioMessageModel)
        }
        cell.onCellTapped = {[weak self](cell) in
            if let audioCell = cell as? CHAudioMessageCell {
                self?.performMessageSelectDeSelect(messageModel: audioCell.audioMessageModel)
            }
        }
        cell.onLongPressedBubble = { [weak self](cell) in
            if let audioCell = cell as? CHAudioMessageCell {
                let messageModel = audioCell.audioMessageModel
                self?.showMessageOptions(messageId: messageModel?.messageId ?? "", senderId: messageModel?.senderId ?? "")
            }
        }
        return cell
    }
    
    private func configureLocationMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: BaseMessageItemProtocol) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newLocationMessageCell", for: indexPath) as! CHLocationMessageCell
        cell.assignChatItem(chatItem: chatItem)
        cell.onBubbleTapped = {[weak self] (cell) in
            if let locationCell = cell as? CHLocationMessageCell {
                self?.openInMap(locationCell.locationMessageModel)
            }
        }
        cell.onCellTapped = {[weak self] (cell) in
            if let locationCell = cell as? CHLocationMessageCell {
                self?.performMessageSelectDeSelect(messageModel: locationCell.locationMessageModel)
            }
        }
        cell.onLongPressedBubble = {[weak self] (cell) in
            if let locationCell = cell as? CHLocationMessageCell {
                let messageModel = locationCell.locationMessageModel
                self?.showMessageOptions(messageId: messageModel?.messageId ?? "", senderId: messageModel?.senderId ?? "")
            }
        }
        return cell
    }
    
    private func configureVideoMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: BaseMessageItemProtocol) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "newVideoMessageCell", for: indexPath) as! CHVideoMessageCell
        cell.assignChatItem(chatItem: chatItem)
        cell.onCellTapped = {[weak self] (cell) in
            if let videoMessageCell = cell as? CHVideoMessageCell {
                self?.performMessageSelectDeSelect(messageModel: videoMessageCell.videoMessageModel)
            }
        }
        cell.onLongPressedBubble = {[weak self] (cell) in
            if let videoMessageCell = cell as? CHVideoMessageCell {
                let model = videoMessageCell.videoMessageModel
                self?.showMessageOptions(messageId: model?.messageId ?? "", senderId: model?.senderId ?? "")
            }
        }
        cell.onBubbleTapped = {[weak self] (cell) in
            if let videoMessageCell = cell as? CHVideoMessageCell {
                self?.openImageViewer(with: videoMessageCell.videoMessageModel)
            }
        }
        return cell
    }
    
    private func configureTextMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: BaseMessageItemProtocol) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newTextMessageCell", for: indexPath) as! CHTextMessageCell
        cell.assignChatItem(chatItem: chatItem)
        cell.onCellTapped = {[weak self] (cell) in
            if let textMessageCell = cell as? CHTextMessageCell {
                self?.performMessageSelectDeSelect(messageModel: textMessageCell.textMessageModel)
            }
        }
        cell.onLongPressedBubble = {[weak self] (cell) in
            if let textMessageCell = cell as? CHTextMessageCell{
                let model = textMessageCell.textMessageModel
                self?.showMessageOptions(messageId: model?.messageId ?? "", senderId: model?.senderId ?? "", isDeleted: model?.isDeletedMessage ?? false)
            }
        }
        return cell
    }
    
    private func configureGifStickerMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: BaseMessageItemProtocol) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newGifStickerMessageCell", for: indexPath) as! CHGifStickerMessageCell
        cell.assignChatItem(chatItem: chatItem)
        cell.onCellTapped = {[weak self] (cell) in
            if let gifStickerCell = cell as? CHGifStickerMessageCell {
                self?.performMessageSelectDeSelect(messageModel: gifStickerCell.gifStickerModel)
            }
        }
        cell.onLongPressedBubble = {[weak self] (cell) in
            if let gifStickerCell = cell as? CHGifStickerMessageCell{
                let model = gifStickerCell.gifStickerModel
                self?.showMessageOptions(messageId: model?.messageId ?? "", senderId: model?.senderId ?? "")
            }
        }
        return cell
    }
    
    private func configureImageMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: BaseMessageItemProtocol) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "newImageMessageCell", for: indexPath) as! CHImageMessageCell
        cell.assignChatItem(chatItem: chatItem)
        cell.onCellTapped = {[weak self] (cell) in
            if let imageMessageCell = cell as? CHImageMessageCell {
                self?.performMessageSelectDeSelect(messageModel: imageMessageCell.imageMessageModel)
            }
        }
        cell.onLongPressedBubble = {[weak self] (cell) in
            if let imageMessageCell = cell as? CHImageMessageCell {
                let model = imageMessageCell.imageMessageModel
                
                self?.showMessageOptions(messageId: model?.messageId ?? "", senderId: model?.senderId ?? "")
//                self?.showBlurViewWithSelectedMessage(for: imageMessageCell, messageId: imageMessageCell.imageMessageModel?.messageId ?? "", cellType: .image)
            }
        }
        cell.onBubbleTapped = {[weak self] (cell) in
            if let imageMessageCell = cell as? CHImageMessageCell {
                self?.openImageViewer(with: imageMessageCell.imageMessageModel)
            }
        }
        return cell
    }
    
    
    func showMessageOptions(messageId: String, senderId: String, isDeleted: Bool = false) {
        self.view.endEditing(true)
        let chatItem = self.chatItems.first(where: {
            $0.messageId == messageId
        })
        
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let copyAction = UIAlertAction(title: "Copy", style: .default, handler: {(action) in
            if let textItem = chatItem as? TextMessageModel {
                let messageString = textItem.attributedString?.string
                UIPasteboard.general.string = messageString
            } else if let quotedItem = chatItem as? QuotedMessageModel {
                let messageString = quotedItem.attributedString?.string
                UIPasteboard.general.string = messageString
            }
        })
        
        let deleteAction = UIAlertAction(title: CHLocalized(key: "pmDeleteSingleMessage"), style: .destructive, handler: {(action) in
            self.perfromMessageDelete(messageId: messageId, senderId: senderId, isDeleted: isDeleted)
        })
        let replyAction = UIAlertAction(title: CHLocalized(key: "pmReply"), style: .default, handler: {(action) in
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
                    textMessage = (chatItem as? QuotedMessageModel)?.attributedString
                case .image:
                    imageUrl = (chatItem as? ImageMessageModel)?.imageUrl
                    break
                case .video:
                    imageUrl = (chatItem as? VideoMessageModel)?.thumbnailUrl
                    break
                case .gifSticker:
                    imageUrl = (chatItem as? GifStickerMessageModel)?.stillUrl
                    break
                case .text:
                    textMessage = (chatItem as? TextMessageModel)?.attributedString
                    break
                case .doc:
                    if let docModel = chatItem as? DocMessageModel {
                        if let fileExtension = docModel.docMessageData.fileExtension {
                            if let icon = mimeTypeIcon[fileExtension.lowercased()] {
                                textMessage = "\(docModel.docMessageData.fileName ?? "")".with(getImage("\(icon)"))
                            } else {
                                textMessage = "\(docModel.docMessageData.fileName ?? "")".with(getImage("chFileIcon"))
                            }
                        }
                    }
                    break
                default:
                    break
                }
                self.currentQuotedModel = QuotedViewModel(parentId: parentId, senderName: senderName, senderId: senderId, imageUrl: imageUrl, textMessage: textMessage, messageType: chatItem.messageType)
                let quotedView = QuotedMessageView()
                quotedView.delegate = self
                quotedView.translatesAutoresizingMaskIntoConstraints = false
                self.quotedMessageViewContainer.subviews.forEach({
                    $0.removeFromSuperview()
                })
                self.quotedMessageViewContainer.addSubview(quotedView)
                quotedView.pinEdgeToSuperView(superView: self.quotedMessageViewContainer)
                self.topStackViewContainer.addArrangedSubview(
                    self.quotedMessageViewContainer)
                self.quotedMessageViewContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
                self.quotedMessageViewContainer.setLeftAnchor(
                    relatedConstraint: self.topStackViewContainer.leftAnchor, constant: 0)
                self.quotedMessageViewContainer.setRightAnchor(
                    relatedConstraint: self.topStackViewContainer.rightAnchor, constant: 0)
                quotedView.quotedViewModel = self.currentQuotedModel
                UIView.animate(withDuration: 0.2, animations: {
                    self.topStackContainerHeightConstraint.constant = 60
                    self.view.layoutIfNeeded()
                }, completion: { completed in
                    self.textInputBarView.becomeFirstResponder()
                self.textInputBarView.inputTextView.becomeFirstResponder()
                })
            }
        })
        let forwardAction = UIAlertAction(title: "Forward", style: .default, handler: {(action) in
            let controller = MessageForwardController()
            controller.allUsers = CHAllContacts.contactsList
            controller.messageIds = [messageId]
            controller.allConversations = CHAllConversations.allConversations.filter({
                $0.isGroup == true
            })
            self.navigationController?.pushViewController(
                controller, animated: true)
        })
        let moreAction = UIAlertAction(title: CHLocalized(key: "pmMore"), style: .default, handler: {(action) in
            self.setMessageSelectorOn(with: messageId)
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        
        if chatItem is TextMessageModel || chatItem is QuotedMessageModel {
            controller.addAction(copyAction)
        }
    
        if self.conversation?.isGroup == true {
            if self.conversation?.canReplyToConversation == true {
                if isDeleted == false {
                    controller.addAction(replyAction)
                }
            }
        } else {
            if self.conversation?.isPartnerIsBlocked == false && self.conversation?.isPartenerHasBlocked == false {
                if isDeleted == false {
                    controller.addAction(replyAction)
                }
            }
        }
        if isDeleted == false {
            controller.addAction(forwardAction)
            
        }
        //controller.addAction(forwardAction)
        controller.addAction(deleteAction)
        controller.addAction(moreAction)
        controller.addAction(cancelAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            controller.overrideUserInterfaceStyle = .light
        }
        #endif
        if let popoverController = controller.popoverPresentationController {
            showIpadActionSheet(sourceView: self.view, popoverController: popoverController)
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    private func configureDocMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: BaseMessageItemProtocol) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "docMessageCell", for: indexPath) as! CHDocMessageCell
        cell.assignChatItem(chatItem: chatItem)
        cell.onDownloadButtonPressed = {[weak self] (cell) in
            self?.downloadDocFile(docMessage: cell.docMessageModel)
        }
        cell.onOpenButtonPressed = {[weak self] (cell) in
            self?.openDocFile(docMessage: cell.docMessageModel)
        }
        cell.onLongPressedBubble = {[weak self] (cell) in
            if let docMessageCell = cell as? CHDocMessageCell {
                let model = docMessageCell.docMessageModel
                    self?.showMessageOptions(messageId: model?.messageId ?? "", senderId: model?.senderId ?? "")
                }
            }
        cell.onCellTapped = {[weak self] (cell) in
            if let docMessageCell = cell as? CHDocMessageCell {
                self?.performMessageSelectDeSelect(messageModel: docMessageCell.docMessageModel)
            }
        }
        return cell
    }
    
    private func configureGroupedImagesCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: BaseMessageItemProtocol) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newGroupedImageCell", for: indexPath) as! CHGroupedPhotosCell
        cell.assignChatItem(chatItem: chatItem)
        cell.onBubbleTapped = {[weak self] (cell) in
            if let groupedImagesCell = cell as? CHGroupedPhotosCell {
                let layout = UICollectionViewFlowLayout()
                let controller = GroupedPhotosViewController(collectionViewLayout: layout)
                controller.imagesModels = groupedImagesCell.groupedImagesModel?.imagesModel as? [ImageMessageModel] ?? []
                self?.navigationController?.pushViewController(
                    controller, animated: true)
            }
        }
        cell.onLongPressedBubble = {[weak self] (cell) in
            if let groupedImagesCell = cell as? CHGroupedPhotosCell {
                self?.showGroupedMessageOptions(model: groupedImagesCell.groupedImagesModel)
            }
        }
        cell.onCellTapped = {[weak self] (cell) in
            if let groupedImagesCell = cell as? CHGroupedPhotosCell {
                self?.performMessageSelectDeSelect(messageModel: groupedImagesCell.groupedImagesModel)
            }
        }
        return cell
    }
    
    func showGroupedMessageOptions(model: GroupedImagesModel?) {
        guard let messageModel = model else {
            return
        }
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let forwardAllAction = UIAlertAction(title: "Forward All", style: .default, handler: {[weak self](action) in
            var messageIds = [String]()
            messageModel.imagesModel.forEach({
                messageIds.append($0.messageId)
            })
            let forwardMessagecontroller = MessageForwardController()
            forwardMessagecontroller.allUsers = CHAllContacts.contactsList
            forwardMessagecontroller.messageIds = messageIds
            forwardMessagecontroller.allConversations = CHAllConversations.allConversations.filter({
                $0.isGroup == true
            })
            self?.navigationController?.pushViewController(
                forwardMessagecontroller, animated: true)
            
        })
        let deleteAllAction = UIAlertAction(title: "Delete All", style: .destructive, handler: {[weak self](action) in
            var messageIds = [String]()
            messageModel.imagesModel.forEach({
                messageIds.append($0.messageId)
            })
            self?.deleteMessages(messageIds: messageIds)
        })
        let moreAction = UIAlertAction(title: CHLocalized(key: "pmMore"), style: .default, handler: {(action) in
            self.setMessageSelectorOn(with: messageModel.messageId)
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        controller.addAction(forwardAllAction)
        controller.addAction(deleteAllAction)
        controller.addAction(moreAction)
        controller.addAction(cancelAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            controller.overrideUserInterfaceStyle = .light
        }
        #endif
        if let popoverController = controller.popoverPresentationController {
            showIpadActionSheet(sourceView: self.view, popoverController: popoverController)
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Cell Items Size Calculator
    func getMissedCallItemHeight(chatItem: BaseMessageItemProtocol) -> CGSize {
        var totalHeight: CGFloat = 0
        let missCallBubbleHeight: CGFloat = 100
        totalHeight = totalHeight + missCallBubbleHeight
        if chatItem.showDataSeperator == true {
            totalHeight += 30
        }
        if chatItem.showSenderName == true {
            totalHeight += 25
        }
        if chatItem.showMessageStatusView == true {
            totalHeight += 25
        }
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getGroupedMessageItemHeight(chatItem: BaseMessageItemProtocol) -> CGSize {
        let dateSeperatorHeight: CGFloat = chatItem.showDataSeperator ? 30 : 0
        let senderNameHeight: CGFloat = chatItem.showSenderName ? 25 : 0
        let messageStatusViewHeight: CGFloat = chatItem.showMessageStatusView ? 25 : 0
        let groupedImageModel = chatItem as? GroupedImagesModel
        let groupedImagesCount = groupedImageModel?.imagesModel.count ?? 0
        switch groupedImagesCount {
        case 1:
            return CGSize(width: self.view.frame.width, height: 170 + dateSeperatorHeight + senderNameHeight + messageStatusViewHeight)
        case 2:
            return CGSize(width: self.view.frame.width, height: 170 + dateSeperatorHeight + senderNameHeight + messageStatusViewHeight)
        case 3:
            return CGSize(width: self.view.frame.width, height: 300 + dateSeperatorHeight + senderNameHeight + messageStatusViewHeight)
        case 4:
            return CGSize(width: self.view.frame.width, height: 300 + dateSeperatorHeight + senderNameHeight + messageStatusViewHeight)
        case let x where x > 4:
            return CGSize(width: self.view.frame.width, height: 300 + dateSeperatorHeight + senderNameHeight + messageStatusViewHeight)
        default:
            return CGSize(width: self.view.frame.width, height: 0)
        }
    }
    
    func getQuotedMessageItemHeight(chatItem: BaseMessageItemProtocol) -> CGSize {
        let textMessageItem = chatItem as? QuotedMessageModel
        let attributedString = textMessageItem?.attributedString ?? NSAttributedString()
        
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 280, withText: attributedString)
        
        let frameSize = frameSizeInfo.frameSize
        var containerWidth = frameSize.width + 26
        let containerHeight = frameSize.height + 24
        
        if containerWidth < 80 {
            containerWidth = 80
        }
        
        let containerSize = CGSize(width: containerWidth, height: containerHeight + 10)
        var totalHeight: CGFloat = 0
        let textViewHeight: CGFloat = containerSize.height
        totalHeight = totalHeight + textViewHeight
        if chatItem.showDataSeperator == true {
            totalHeight += 30
        }
        if chatItem.showSenderName == true {
            totalHeight += 25
        }
        if chatItem.showMessageStatusView == true {
            totalHeight += 25
        }
        return CGSize(width: self.view.frame.width, height: totalHeight+67.5)
    }
    func getLinkPreviewMessageHeight(chatItem: BaseMessageItemProtocol) -> CGSize {
        guard let linkModel = chatItem as? LinkPreviewModel else {
            return .zero
        }
        var height : CGFloat = 0
        //height += 150
        if (linkModel.linkData?.linkImageUrl) != nil{
            height += 150
        }
        if let linkAttributedString = linkModel.linkTitleAttributedString {
            let labelHeight = getAttributedLabelHeight(attributedString: linkAttributedString, maximumWidth: 240, numberOfLines: 2)
            height += labelHeight
        }
        if let descriptionAttributedString = linkModel.linkDescriptionAttributedString {
            let labelHeight = getAttributedLabelHeight(attributedString: descriptionAttributedString, maximumWidth: 240, numberOfLines: 3)
            height += labelHeight
        }
        return CGSize(width: self.view.frame.width, height: height == 0 ? 0 : height + 25)
    }
    
    func getMetaMessageHeight(chatItem: BaseMessageItemProtocol) -> CGSize {
        let metaMessageModel = chatItem as? MetaMessageModel
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 280, withText: metaMessageModel?.metaMessageAttributedString ?? NSAttributedString())
        let recalculatedHeight = frameSizeInfo.frameSize.height + 10
        return CGSize(width: self.view.frame.width, height: recalculatedHeight)
    }
    
    func getTextMessageItemHeight(chatItem: BaseMessageItemProtocol) -> CGSize {
        let textMessageItem = chatItem as? TextMessageModel
        let attributedString = textMessageItem?.attributedString ?? NSAttributedString()
        
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 280, withText: attributedString)
        
        let frameSize = frameSizeInfo.frameSize
        let containerHeight = frameSize.height + 24
        var totalHeight: CGFloat = 0
        let textViewHeight: CGFloat = containerHeight
        totalHeight = totalHeight + textViewHeight
        if chatItem.showDataSeperator == true {
            totalHeight += 30
        }
        if chatItem.showSenderName == true {
            totalHeight += 25
        }
        if chatItem.showMessageStatusView == true {
            totalHeight += 25
        }
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    func getLocationCellheight(chatItem: BaseMessageItemProtocol) -> CGSize {
        let locationModel = chatItem as? LocationMessageModel
        let imageViewHeight: CGFloat = 160
        let nameLableHeight: CGFloat = locationModel?.locationName != nil && locationModel?.locationName != "" ? 22.5 : 0
        let attributedAddress = locationModel?.locationAddressAttributedString ?? NSAttributedString()
        let height = getAttributedLabelHeight(attributedString: attributedAddress, maximumWidth: 265, numberOfLines: 2)
        
        var totalHeight = imageViewHeight + nameLableHeight + (height == 0 ? 0 : height + 12.5)
        if chatItem.showDataSeperator == true {
            totalHeight += 30
        }
        if chatItem.showSenderName == true {
            totalHeight += 25
        }
        if chatItem.showMessageStatusView == true {
            totalHeight += 25
        }
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getGifStickerCellSize(chatItem: BaseMessageItemProtocol) -> CGSize {
        var totalHeight: CGFloat = 0
        let imageViewHeight: CGFloat = 175
        totalHeight = totalHeight + imageViewHeight
        if chatItem.showDataSeperator == true {
            totalHeight += 30
        }
        if chatItem.showSenderName == true {
            totalHeight += 25
        }
        if chatItem.showMessageStatusView == true {
            totalHeight += 25
        }
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getImageMessageSize(chatItem: BaseMessageItemProtocol) -> CGSize {
        var totalHeight: CGFloat = 0
        let imageViewHeight: CGFloat = 240
        totalHeight = totalHeight + imageViewHeight
        if chatItem.showDataSeperator == true {
            totalHeight += 30
        }
        if chatItem.showSenderName == true {
            totalHeight += 25
        }
        if chatItem.showMessageStatusView == true {
            totalHeight += 25
        }
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getVideoMessageSize(chatItem: BaseMessageItemProtocol) -> CGSize {
        var totalHeight: CGFloat = 0
        let imageViewHeight: CGFloat = 270
        totalHeight = totalHeight + imageViewHeight
        if chatItem.showDataSeperator == true {
            totalHeight += 30
        }
        if chatItem.showSenderName == true {
            totalHeight += 25
        }
        if chatItem.showMessageStatusView == true {
            totalHeight += 25
        }
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getAudioMessageCellSize(chatItem: BaseMessageItemProtocol) -> CGSize {
        let dateSeperatorHeight: CGFloat = chatItem.showDataSeperator ? 30 : 0
        let senderNameHeight: CGFloat = chatItem.showSenderName ? 25 : 0
        let statusViewHeight: CGFloat = chatItem.showMessageStatusView ? 25 : 0
        let totalHeight = dateSeperatorHeight + senderNameHeight + 80 + statusViewHeight
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getDocMessageCellSize(chatItem: BaseMessageItemProtocol) -> CGSize {
        let dateSeperatorHeight: CGFloat = chatItem.showDataSeperator ? 30 : 0
        let senderNameHeight: CGFloat = chatItem.showSenderName ? 25 : 0
        let statusViewHeight: CGFloat = chatItem.showMessageStatusView ? 25 : 0
        let totalHeight = dateSeperatorHeight + senderNameHeight + 109.5 + statusViewHeight
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    
    // MARK:- Cells Functions
    func didSelectLongPressAction(messageId: String, actionType: LongPressOptionActionType) {
        switch actionType {
           case .reply:
               self.didSelectReplyMessage(messageId: messageId)
               break
           case .forward:
               self.didSelectForwardMessage(messageId: messageId)
               break
           case .delete:
               self.didSelectDeleteMessage(messageId: messageId)
               break
           case .more:
               self.didSelectMoreAction(messageId: messageId)
               break
           case .deleteAll:
               //self.didSelectDeleteAllMessage(messageId: messageId)
               break
           case .forwardAll:
               break
           default:
               break
        }
    }
    
    func performMessageSelectDeSelect(messageModel: BaseMessageItemProtocol?) {
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
                if itemModel is GroupedImagesModel {
                    (itemModel as! GroupedImagesModel).imagesModel.forEach({
                        self.selectedMessages.append($0.messageId)
                    })
                } else {
                    self.selectedMessages.append(itemModel.messageId)
                }
            } else {
                if itemModel is GroupedImagesModel {
                    (itemModel as! GroupedImagesModel).imagesModel.forEach({
                        let messageId = $0.messageId
                        self.selectedMessages.removeAll(where: {
                            $0 == messageId
                        })
                    })
                } else {
                    self.selectedMessages.removeAll(where: {
                        $0 == messageModel?.messageId
                    })
                }
            }
            self.selectedMessageCountLabel.text = "\(self.selectedMessages.count) Selected"
        }
    }
    
    
    func showBlurViewWithSelectedMessage(for cell: UICollectionViewCell, messageId: String, cellType: BaseMessageType) {
        self.view.endEditing(true)
        let blurView = LongPressMessageBlurView()
        blurView.messageId = messageId
        blurView.delegate = self
        blurView.frame.origin = .zero
        blurView.frame.size = self.view.frame.size
        self.view.addSubview(blurView)
        let deleteAction = LongPressOptionModel(label: "Delete", action: .delete)
        let replyAction = LongPressOptionModel(label: "Reply", action: .reply)
        let forwardAction = LongPressOptionModel(label: "Forward", action: .forward)
        let moreAction = LongPressOptionModel(label: "More", action: .more)
        let deleteAllAction = LongPressOptionModel(label: "Delete All", action: .deleteAll)
        let forwardAllAction = LongPressOptionModel(label: "Forward All", action: .forwardAll)
        
        
        if let indexPath = collectionView.indexPath(for: cell) {
            if let theAttributes = collectionView.layoutAttributesForItem(at: indexPath) {
                let cellFrameInSuperview = collectionView.convert(theAttributes.frame, to: collectionView.superview)
                var viewCell: UICollectionViewCell?
                switch cellType {
                case .quotedMessage:
                    let selectedCell = UIQuotedMessageCollectionCell()
                    selectedCell.frame = cellFrameInSuperview
                    selectedCell.textMessageModel = (cell as? UIQuotedMessageCollectionCell)?.textMessageModel
                    viewCell = selectedCell
                    if self.conversation?.isGroup == true {
                        if self.conversation?.canReplyToConversation == true {
                             blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                             blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    } else {
                        if self.conversation?.isPartnerIsBlocked == false && self.conversation?.isPartenerHasBlocked == false {
                            blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                            blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    }
                    break
                case .gifSticker:
                    let selectedCell = UIGifStickerMessageCollectionCell()
                    selectedCell.frame = cellFrameInSuperview
                    selectedCell.gifStickerMessageModel = (cell as? UIGifStickerMessageCollectionCell)?.gifStickerMessageModel
                    viewCell = selectedCell
                    if self.conversation?.isGroup == true {
                        if self.conversation?.canReplyToConversation == true {
                             blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                             blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    } else {
                        if self.conversation?.isPartnerIsBlocked == false && self.conversation?.isPartenerHasBlocked == false {
                            blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                            blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    }
                    break
                case .deletedMessage:
                    let selectedCell = UITextMessageCollectionCell()
                    selectedCell.frame = cellFrameInSuperview
                    selectedCell.textMessageModel = (cell as? UITextMessageCollectionCell)?.textMessageModel
                    viewCell = selectedCell
                    blurView.assignActions(actions: [deleteAction])
                    break
                case .text:
                    let selectedCell = UITextMessageCollectionCell()
                    selectedCell.frame = cellFrameInSuperview
                    selectedCell.textMessageModel = (cell as? UITextMessageCollectionCell)?.textMessageModel
                    viewCell = selectedCell
                    if self.conversation?.isGroup == true {
                        if self.conversation?.canReplyToConversation == true {
                             blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                             blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    } else {
                        if self.conversation?.isPartnerIsBlocked == false && self.conversation?.isPartenerHasBlocked == false {
                            blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                            blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    }
                    break
                case .video:
                    let selectedCell = UIVideoMessageCollectionCell()
                    selectedCell.frame = cellFrameInSuperview
                    selectedCell.videoMessageModel = (cell as? UIVideoMessageCollectionCell)?.videoMessageModel
                    viewCell = selectedCell
                    if self.conversation?.isGroup == true {
                        if self.conversation?.canReplyToConversation == true {
                             blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                             blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    } else {
                        if self.conversation?.isPartnerIsBlocked == false && self.conversation?.isPartenerHasBlocked == false {
                            blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                            blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    }
                    break
                case .image:
                    let selectedCell = CHImageMessageCell()
                    selectedCell.frame = cellFrameInSuperview
                    selectedCell.imageMessageModel = (cell as? UIImageMessageCollectionCell)?.imageMessageModel
                    viewCell = selectedCell
                    if self.conversation?.isGroup == true {
                        if self.conversation?.canReplyToConversation == true {
                             blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                             blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    } else {
                        if self.conversation?.isPartnerIsBlocked == false && self.conversation?.isPartenerHasBlocked == false {
                            blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                            blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    }
                    break
                case .groupedImages:
                    let selectedCell = UIGroupedImageCollectionCell()
                    selectedCell.frame = cellFrameInSuperview
                    selectedCell.groupedImagesModel = (cell as? UIGroupedImageCollectionCell)?.groupedImagesModel
                    viewCell = selectedCell
                    blurView.assignActions(actions: [forwardAllAction,deleteAllAction])
                    break
                case .location:
                    let selectedCell = UILocationMessageCell()
                    selectedCell.frame = cellFrameInSuperview
                    selectedCell.locationMessageModel = (cell as? UILocationMessageCell)?.locationMessageModel
                    viewCell = selectedCell
                    if self.conversation?.isGroup == true {
                        if self.conversation?.canReplyToConversation == true {
                             blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                             blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    } else {
                        if self.conversation?.isPartnerIsBlocked == false && self.conversation?.isPartenerHasBlocked == false {
                            blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                            blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    }
                    break
                case .audio:
                    let selectedCell = UIAudioMessageCollectionCell()
                    selectedCell.frame = cellFrameInSuperview
                    selectedCell.audioMessageModel = (cell as? UIAudioMessageCollectionCell)?.audioMessageModel
                    viewCell = selectedCell
                    if self.conversation?.isGroup == true {
                        if self.conversation?.canReplyToConversation == true {
                             blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                             blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    } else {
                        if self.conversation?.isPartnerIsBlocked == false && self.conversation?.isPartenerHasBlocked == false {
                            blurView.assignActions(actions: [replyAction,forwardAction,deleteAction,moreAction])
                        } else {
                            blurView.assignActions(actions: [forwardAction,deleteAction,moreAction])
                        }
                    }
                    break
                default:
                    break
                }
                if viewCell != nil {
                    blurView.insertSelectedMessage(view: viewCell!, viewHeight: cellFrameInSuperview.height)
                }
            }
        }
    }
    
    private func playAudioMessage(model: AudioMessageModel?) {
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
                let audioCell = self.collectionView.cellForItem(at: indexPath) as? CHAudioMessageCell
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
    
    private func updateAudioCellStatus() {
        if let index = self.chatItems.firstIndex(where: {
            $0.messageId == self.audioModel?.messageId
        }) {
            let indexPath = IndexPath(item: index, section: 0)
            let audioCell = self.collectionView.cellForItem(at: indexPath) as? CHAudioMessageCell
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
    
    private func setupPlayer(){
        if let firstIndexPath = self.chatItems.firstIndex(where: {
            $0.messageId == audioModel?.messageId
        }) {
            let indexPath = IndexPath(item: firstIndexPath, section: 0)
            if let cell = self.collectionView.cellForItem(at: indexPath) as? CHAudioMessageCell {
                cell.audioMessageModel?.playerStatus = .loading
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadItems(at: [indexPath])
                }, completion: nil)
            }
        }
        
        if let url = audioModel?.audioUrl {
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
                                if let cell = self.collectionView.cellForItem(at: indexPath) as? CHAudioMessageCell {
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
            self.audioModel?.audioDuration = player.currentTime*1000
            self.audioModel?.playerProgress = Float(player.currentTime/player.duration)
            if let index = self.chatItems.firstIndex(where: {
                $0.messageId == self.audioModel?.messageId
            }) {
                let indexPath = IndexPath(item: index, section: 0)
                let audioCell = self.collectionView.cellForItem(at: indexPath) as? CHAudioMessageCell
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
            self.audioModel?.audioDuration = player.currentTime
            self.audioModel?.playerProgress = Float(player.currentTime/player.duration)
            if let index = self.chatItems.firstIndex(where: {
                $0.messageId == self.audioModel?.messageId
            }) {
                let indexPath = IndexPath(item: index, section: 0)
                let audioCell = self.collectionView.cellForItem(at: indexPath) as? CHAudioMessageCell
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
            let audioCell = self.collectionView.cellForItem(at: indexPath) as? CHAudioMessageCell
            audioCell?.audioMessageModel?.playerStatus = .stopped
            audioCell?.audioMessageModel?.playerProgress = 0.0
            audioCell?.audioMessageModel?.audioDuration = player.duration*1000
            self.collectionView.reloadItems(at: [indexPath])
        }
        self.audioModel = nil
    }
    
    // MARK:- Message Actions Functions
    func didSelectReplyMessage(messageId: String) {
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
                textMessage = (chatItem as? QuotedMessageModel)?.attributedString
            case .image:
                imageUrl = (chatItem as? ImageMessageModel)?.imageUrl
                break
            case .video:
                imageUrl = (chatItem as? VideoMessageModel)?.thumbnailUrl
                break
            case .gifSticker:
                imageUrl = (chatItem as? GifStickerMessageModel)?.stillUrl
                break
            case .text:
                textMessage = (chatItem as? TextMessageModel)?.attributedString
                break
            case .doc:
                if let docModel = chatItem as? DocMessageModel {
                    if let fileExtension = docModel.docMessageData.fileExtension {
                        if let icon = mimeTypeIcon[fileExtension.lowercased()] {
                            textMessage = "\(docModel.docMessageData.fileName ?? "")".with(getImage("\(icon)"))
                        } else {
                            textMessage = "\(docModel.docMessageData.fileName ?? "")".with(getImage("chFileIcon"))
                        }
                    }
                }
                break
            default:
                break
            }
            self.currentQuotedModel = QuotedViewModel(parentId: parentId, senderName: senderName, senderId: senderId, imageUrl: imageUrl, textMessage: textMessage, messageType: chatItem.messageType)
            let quotedView = QuotedMessageView()
            quotedView.delegate = self
            quotedView.translatesAutoresizingMaskIntoConstraints = false
            self.quotedMessageViewContainer.subviews.forEach({
                $0.removeFromSuperview()
            })
            self.quotedMessageViewContainer.addSubview(quotedView)
            quotedView.pinEdgeToSuperView(superView: self.quotedMessageViewContainer)
            self.topStackViewContainer.addArrangedSubview(
                self.quotedMessageViewContainer)
            self.quotedMessageViewContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
            self.quotedMessageViewContainer.setLeftAnchor(
                relatedConstraint: self.topStackViewContainer.leftAnchor, constant: 0)
            self.quotedMessageViewContainer.setRightAnchor(
                relatedConstraint: self.topStackViewContainer.rightAnchor, constant: 0)
            quotedView.quotedViewModel = self.currentQuotedModel
            UIView.animate(withDuration: 0.2, animations: {
                self.topStackContainerHeightConstraint.constant = 60
                self.view.layoutIfNeeded()
            }, completion: { completed in
                self.textInputBarView.becomeFirstResponder()
            self.textInputBarView.inputTextView.becomeFirstResponder()
            })
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            //
            //            })

        }
    }
    
    func didSelectForwardMessage(messageId: String) {
        let controller = MessageForwardController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didSelectDeleteMessage(messageId: String) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteForMeAction = UIAlertAction(title: CHLocalized(key: "pmDeleteForMe"), style: .destructive, handler: {(action) in
            let messageIds = [messageId]
            self.deleteMessages(messageIds: messageIds)
        })
        let deleteForEveryOneAction = UIAlertAction(title: CHLocalized(key: "pmDeleteForEveryone"), style: .destructive, handler: {(action) in
            let messageIds = [messageId]
            self.deleteMessagesForEveryOne(messageIds: messageIds)
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        actionSheet.addAction(deleteForMeAction)
        actionSheet.addAction(cancelAction)
        if let chatItem = self.chatItems.first(where: {
            $0.messageId == messageId
        }) {
            if chatItem.senderId == ChannelizeAPI.getCurrentUserId() {
                actionSheet.addAction(deleteForEveryOneAction)
            }
        }
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            actionSheet.overrideUserInterfaceStyle = .light
        }
        #endif
        if let popoverController = actionSheet.popoverPresentationController {
            showIpadActionSheet(sourceView: self.view, popoverController: popoverController)
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func didSelectMoreAction(messageId: String) {
        self.setMessageSelectorOn(with: messageId)
    }
    
    
    func setMessageSelectorOn(with messageId: String) {
        self.isMessageSelectorOn = true
        self.conversationHeaderView.showDoneButton()
        self.chatItems.forEach({
            if $0.messageType == .missedVideoCall || $0.messageType == .missedVoiceCall {
                $0.isMessageSelectorOn = false
            } else {
                $0.isMessageSelectorOn = true
            }
        })
        if let firstItem = self.chatItems.first(where: {
            $0.messageId.contains(messageId)
        }) {
            firstItem.isMessageSelected = true
            if firstItem is GroupedImagesModel {
                (firstItem as! GroupedImagesModel).imagesModel.forEach({
                    self.selectedMessages.append($0.messageId)
                })
            } else {
                self.selectedMessages.append(messageId)
            }
        }
        
        self.collectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
        deleteMessageToolBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didPressDeleteMessageButton(sender:)))
        deleteMessageToolBarButton.tintColor = UIColor.customSystemRed
        deleteMessageToolBarButton.isEnabled = true
        forwardMessageToolBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didPressForwardMessageButton(sender:)))
        forwardMessageToolBarButton.tintColor = CHUIConstants.appDefaultColor
            forwardMessageToolBarButton.isEnabled = true
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            
        let customBarButton = UIBarButtonItem(customView: selectedMessageCountLabel)
            
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [deleteMessageToolBarButton,space,customBarButton,rightSpace,forwardMessageToolBarButton]
        selectedMessageCountLabel.text = "\(self.selectedMessages.count) Selected"
            self.navigationController?.setToolbarHidden(false, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            //self.topStackContainerHeightConstraint.constant = 50
            self.textViewContainerBottomConstraint.constant = 50
            self.textViewContainerHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
        
    @objc func didPressDeleteMessageButton(sender: UIBarButtonItem) {
        var showMessageDeleteForEveryone = true
        self.selectedMessages.forEach({
            let id = $0
            if let textModel = self.chatItems.first(where: {
                $0.messageId == id
            }) as? TextMessageModel {
                if textModel.isDeletedMessage == true {
                    showMessageDeleteForEveryone = false
                } else {
                    if textModel.senderId != ChannelizeAPI.getCurrentUserId() {
                        showMessageDeleteForEveryone = false
                    }
                }
            } else {
                if let chatItem = self.chatItems.first(where: {
                    $0.messageId == id
                }) {
                    if chatItem.senderId != ChannelizeAPI.getCurrentUserId() {
                        showMessageDeleteForEveryone = false
                    }
                }
            }
        })
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteForMeAction = UIAlertAction(title: CHLocalized(key: "pmDeleteForMe"), style: .destructive, handler: {(action) in
            self.deleteMessages(messageIds: self.selectedMessages)
        })
        let deleteForEveryOneAction = UIAlertAction(title: CHLocalized(key: "pmDeleteForEveryone"), style: .destructive, handler: {(action) in
            self.deleteMessagesForEveryOne(messageIds: self.selectedMessages)
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        actionSheet.addAction(deleteForMeAction)
        
        if showMessageDeleteForEveryone == true {
            actionSheet.addAction(deleteForEveryOneAction)
        }
        actionSheet.addAction(cancelAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            actionSheet.overrideUserInterfaceStyle = .light
        }
        #endif
        if let popoverController = actionSheet.popoverPresentationController {
            showIpadActionSheet(sourceView: self.view, popoverController: popoverController)
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
        
    @objc func didPressForwardMessageButton(sender: UIBarButtonItem) {
        let controller = MessageForwardController()
        controller.allUsers = CHAllContacts.contactsList
        controller.messageIds = self.selectedMessages
        controller.allConversations = CHAllConversations.allConversations.filter({
            $0.isGroup == true
        })
        self.navigationController?.pushViewController(controller, animated: true)
        self.setMessageSelectorOff()
    }
    
    func setMessageSelectorOff() {
        self.isMessageSelectorOn = false
        self.conversationHeaderView.hideDoneButton()
        if conversation?.isGroup == true {
            self.conversationHeaderView.hidesCallButton()
        }
        self.chatItems.forEach({
            $0.isMessageSelectorOn = false
            $0.isMessageSelected = false
        })
        self.selectedMessages.removeAll()
        self.collectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
        self.navigationController?.setToolbarHidden(true, animated: true)
        UIView.animate(withDuration: 0.1, animations: {
            //self.selectedMessageActionView.removeFromSuperview()
            //self.topStackContainerHeightConstraint.constant = 0
            self.textViewContainerBottomConstraint.constant = 0
            self.textViewContainerHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
        })
    }
    
    func openInMap(_ data: LocationMessageModel?){
        if let lat = data?.locationLatitude, let long = data?.locationLongitude{
            let regionDistance: CLLocationDistance = 5000
            let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = data?.locationName
            
            MKMapItem.openMaps(with: [mapItem], launchOptions: options)
        }
    }
    
    func openImageViewer(with model: BaseMessageItemProtocol?) {
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
                let imageModel = object as? ImageMessageModel
                let chImage = ChannelizeImages(imageUrlString: imageModel?.imageUrl, videoUrlString: nil, owner: imageModel?.senderName, date: imageModel?.messageDate)
                channelizeImages.append(chImage)
            } else if object.messageType == .video {
                let videoModel = object as? VideoMessageModel
                let chImage = ChannelizeImages(imageUrlString: videoModel?.thumbnailUrl, videoUrlString: videoModel?.videoUrl, owner: videoModel?.senderName, date: videoModel?.messageDate)
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
    
    // MARK: - Functions
    func perfromMessageDelete(messageId: String, senderId: String, isDeleted: Bool) {
        let alertController = UIAlertController(title: CHLocalized(key: "pmDeleteSingleMessage"), message: CHLocalized(key: "pmSingleDeleteSelectedConfirm"), preferredStyle: .alert)
        let deleteForMeAction = UIAlertAction(title: CHLocalized(key: "pmDeleteForMe"), style: .destructive, handler: {[weak self](action) in
            self?.deleteMessages(messageIds: [messageId])
        })
        let deleteForEveryOneAction = UIAlertAction(title: CHLocalized(key: "pmDeleteForEveryone"), style: .destructive, handler: {[weak self](action) in
            self?.deleteMessagesForEveryOne(messageIds: [messageId])
        })
        let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        alertController.addAction(deleteForMeAction)
        if senderId == ChannelizeAPI.getCurrentUserId() {
            if isDeleted == false {
                alertController.addAction(deleteForEveryOneAction)
            }
        }
        alertController.addAction(cancelAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            alertController.overrideUserInterfaceStyle = .light
        }
        #endif
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showCallSelectAlert() {
        
        var errorAlert : UIAlertController?
        let okAction = UIAlertAction(title: CHLocalized(key: "pmOk"), style: .default, handler: nil)
        if self.conversation?.isPartnerIsBlocked == true {
            errorAlert = UIAlertController(title: CHLocalized(key: "pmError"), message: CHLocalized(key: "pmBlockedMessage"), preferredStyle: .alert)
            errorAlert?.addAction(okAction)
            self.present(errorAlert!, animated: true, completion: nil)
        } else if self.conversation?.isPartenerHasBlocked == true {
            errorAlert = UIAlertController(title: CHLocalized(key: "pmError"), message: CHLocalized(key: "pmUserCanNotReply"), preferredStyle: .alert)
            errorAlert?.addAction(okAction)
            self.present(errorAlert!, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let videoCallOption = UIAlertAction(title: CHLocalized(key: "pmVideoCall"), style: .default, handler: {[weak self] (action) in
                self?.callButtonPressed(callType: .video)
            })
            let voiceCallOption = UIAlertAction(title: CHLocalized(key: "pmVoiceCall"), style: .default, handler: {[weak self] (action) in
                self?.callButtonPressed(callType: .voice)
            })
            let cancelAction = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
            alertController.addAction(voiceCallOption)
            alertController.addAction(videoCallOption)
            alertController.addAction(cancelAction)
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                // Always adopt a light interface style.
                alertController.overrideUserInterfaceStyle = .light
            }
            #endif
            if let popoverController = alertController.popoverPresentationController {
                showIpadActionSheet(sourceView: self.view, popoverController: popoverController)
            }
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK:- Document Message Related Functions
    private func downloadDocFile(docMessage: DocMessageModel?) {
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
            if let fileUrl = URL(string: docMessageModel.docMessageData.downloadUrl ?? "") {
                let fileName = fileUrl.lastPathComponent
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent(fileName)
                let destination: DownloadRequest.DownloadFileDestination = {_,_ in
                    return(fileURL,[])
                }
                
                Alamofire.download(fileUrl, to: destination).downloadProgress(closure: { progress  in
                    docMessageModel.uploadProgress = progress.fractionCompleted
                    if let docMessageCell = self.collectionView.cellForItem(at: cellIndexPath) as? CHDocMessageCell {
                        docMessageCell.updateProgress(fromValue: docMessageModel.uploadProgress, toValue: progress.fractionCompleted)
                    }
                    //print(progress.fractionCompleted)
                    }).response(completionHandler: { (downloadResponse) in
                        print(downloadResponse.destinationURL?.absoluteString ?? "")
                        docMessageModel.docStatus = .availableLocal
                        self.collectionView.performBatchUpdates({
                            self.collectionView.reloadItems(at: [cellIndexPath])
                        }, completion: nil)
//                        let previewController = QLPreviewController()
//                        previewController.dataSource = self
//                        print(downloadResponse.destinationURL?.absoluteString ?? "")
//                        self.previewItem = downloadResponse.destinationURL
//                        self.present(previewController, animated: true, completion: nil)
                    })
            }
            
        }
    }
    
    private func openDocFile(docMessage: DocMessageModel?) {
        guard let docMessageModel = docMessage else {
            return
        }
        if let fileUrl = URL(string: docMessageModel.docMessageData.downloadUrl ?? "") {
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
}

extension UIConversationViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.currentDocPreviewUrl as QLPreviewItem
    }
    
    
}

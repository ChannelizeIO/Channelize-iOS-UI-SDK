//
//  CHConversationController+CollectionView.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import UIKit
import SDWebImage
import VirgilE3Kit

class CHImageDecryptor: SDWebImageDownloaderDecryptor {
    var ethreeObject: EThree?
    var lookUpResults: FindUsersResult?
    var messageOwner: String?
    var messageId: String?
    
    override func decryptedData(with data: Data, response: URLResponse?) -> Data? {
        var decryptedData: Data?
        do {
            decryptedData = try ethreeObject?.authDecrypt(data: data, from: lookUpResults?[messageOwner ?? ""])
            SDImageCache.shared.storeImageData(toDisk: decryptedData, forKey: messageId)
        } catch {
            print(error.localizedDescription)
        }
        return decryptedData
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension CHConversationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chatItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let chatItem = self.chatItems[indexPath.item]
        switch chatItem.messageType {
        case .text, .deletedMessage:
            return self.configureTextMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
        case .gifSticker:
            return self.configureGifStickerMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
        case .location:
            return self.configureLocationMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
        case .audio:
            return self.configureAudioMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
        case .video:
            return self.configureVideoMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
        case .image:
            return self.configureImageMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
        case .doc:
            return self.configureDocMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
        case .metaMessage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "metaMessageCell", for: indexPath) as! CHMetaMessageCell
            cell.metaMessageModel = chatItem as? MetaMessageItem
            return cell
        case .quotedMessage:
            return self.configureQuotedMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
        case .linkPreview:
            return self.configureLinkPreviewMessageCell(collectionView: collectionView, indexPath: indexPath, chatItem: chatItem)
        case .callMetaMessage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "callMetaMessageCell", for: indexPath) as! CHCallMetaMessageCell
            cell.metaMessageModel = chatItem as? CHCallMetaMessageModel
            return cell
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "undefinedCell", for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let chatItem = self.chatItems[indexPath.item]
        switch chatItem.messageType {
        case .text, .deletedMessage:
            return self.getTextMessageItemHeight(chatItem: chatItem)
        case .gifSticker:
            return self.getGifStickerMessageItemHeight(chatItem: chatItem)
        case .location:
            return self.getLocationMessageItemHeight(chatItem: chatItem)
        case .audio:
            return self.getAudioMessageHeight(chatItem: chatItem)
        case .video:
            return self.getVideoMessageItemHeight(chatItem: chatItem)
        case .image:
            return self.getImageMessageItemHeight(chatItem: chatItem)
        case .doc:
            return self.getDocMessageCellSize(chatItem: chatItem)
        case .metaMessage:
            return self.getMetaMessageHeight(chatItem: chatItem)
        case .quotedMessage:
            return self.getQuotedMessageItemHeight(chatItem: chatItem)
        case .linkPreview:
            return self.getLinkPreviewMessageHeight(chatItem: chatItem)
        case .callMetaMessage:
            return CGSize(width: self.collectionView.frame.width, height: 45)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7.5
    }
    
    // MARK: - Configure Message Cells Functions
    
    func configureTextMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: ChannelizeChatItem) -> UICollectionViewCell {
        guard let textMessageItem = chatItem as? TextMessageItem else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "undefinedCell", for: indexPath)
        }
        let textMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "textMessageCell", for: indexPath) as! UITextMessageCell
        textMessageCell.assignChatItem(chatItem: textMessageItem)
        textMessageCell.onReactionButtonPressed = {[weak self] textMessageCell in
            if let strongSelf = self {
                let viewPoint = strongSelf.getConvertedPoint(textMessageCell.reactionButton, baseView: strongSelf.view)
                guard let chatItem = textMessageCell.textMessageItem else {
                   return
                }
                var arrowDirection: UIPopoverArrowDirection = .up
                if viewPoint.y < strongSelf.view.frame.height/2 {
                    arrowDirection = .up
                } else {
                    arrowDirection = .down
                }
                self?.showPopOverForItem(chatItem: chatItem, sourcePoint: viewPoint, sourceFrameSize: textMessageCell.reactionButton.frame.size, arrowDirection: arrowDirection)
            }
        }
        textMessageCell.onLongPressTextView = {[weak self] (textItem) in
            if let textModel = textItem {
                self?.showMessageOptions(messageId: textModel.messageId, senderId: textModel.senderId, isDeleted: textItem?.isDeletedMessage ?? false)
            }
        }
        textMessageCell.onCellTapped = {(textMessageCell) in
            self.performMessageSelectDeSelect(messageModel: textMessageCell.textMessageItem)
        }
        return textMessageCell
    }
    
    func configureGifStickerMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: ChannelizeChatItem) -> UICollectionViewCell {
        guard let gifStickerMessageItem = chatItem as? GifStickerMessageItem else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "undefinedCell", for: indexPath)
        }
        let gifStickerMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "gifStickerMessageCell", for: indexPath) as! UIGifStickerMessageCell
        gifStickerMessageCell.assignChatItem(chatItem: gifStickerMessageItem)
        gifStickerMessageCell.onReactionButtonPressed = {[weak self] gifStickerCell in
            if let strongSelf = self {
                let viewPoint = strongSelf.getConvertedPoint(gifStickerCell.reactionButton, baseView: strongSelf.view)
                guard let chatItem = gifStickerCell.gifStickerMessageItem else {
                   return
                }
                var arrowDirection: UIPopoverArrowDirection = .up
                if viewPoint.y < strongSelf.view.frame.height/2 {
                    arrowDirection = .up
                } else {
                    arrowDirection = .down
                }
                self?.showPopOverForItem(chatItem: chatItem, sourcePoint: viewPoint, sourceFrameSize: gifStickerCell.reactionButton.frame.size, arrowDirection: arrowDirection)
            }
        }
        gifStickerMessageCell.onLongPressGifStickerBubble = {[weak self] (gifStickerItem) in
            if let gifStickerModel = gifStickerItem {
                self?.showMessageOptions(messageId: gifStickerModel.messageId, senderId: gifStickerModel.senderId, isDeleted: false)
            }
        }
        gifStickerMessageCell.onCellTapped = {(gifStickerCell) in
            self.performMessageSelectDeSelect(messageModel: gifStickerCell.gifStickerMessageItem)
        }
        return gifStickerMessageCell
    }
    
    func configureLocationMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: ChannelizeChatItem) -> UICollectionViewCell {
        guard let locationMessageItem = chatItem as? LocationMessageItem else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "undefinedCell", for: indexPath)
        }
        let locationMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationMessageCell", for: indexPath) as! UILocationMessageCell
        locationMessageCell.assignChatItem(chatItem: locationMessageItem)
        locationMessageCell.onLongPressLocationBubble = {[weak self] (locationItem) in
            if let locationModel = locationItem {
                self?.showMessageOptions(messageId: locationModel.messageId, senderId: locationModel.senderId, isDeleted: false)
            }
        }
        locationMessageCell.onCellTapped = {(locationCell) in
            self.performMessageSelectDeSelect(messageModel: locationCell.locationMessageModel)
        }
        locationMessageCell.onReactionButtonPressed = {[weak self] locationCell in
            if let strongSelf = self {
                let viewPoint = strongSelf.getConvertedPoint(locationCell.reactionButton, baseView: strongSelf.view)
                guard let chatItem = locationCell.locationMessageModel else {
                   return
                }
                var arrowDirection: UIPopoverArrowDirection = .up
                if viewPoint.y < strongSelf.view.frame.height/2 {
                    arrowDirection = .up
                } else {
                    arrowDirection = .down
                }
                self?.showPopOverForItem(chatItem: chatItem, sourcePoint: viewPoint, sourceFrameSize: locationCell.reactionButton.frame.size, arrowDirection: arrowDirection)
            }
        }
        locationMessageCell.onLocationBubbleTapped = {(locationItem) in
            self.openInMap(locationItem)
        }
        return locationMessageCell
        
    }
    
    func configureAudioMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: ChannelizeChatItem) -> UICollectionViewCell {
        guard let audioMessageItem = chatItem as? AudioMessageItem else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "undefinedCell", for: indexPath)
        }
        let audioMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "audioMessageCell", for: indexPath) as! UIAudioMessageCell
        audioMessageCell.assignChatItem(chatItem: audioMessageItem)
        audioMessageCell.onLongPressAudioBubble = {[weak self] (audioItem) in
            if let audioModel = audioItem {
                self?.showMessageOptions(messageId: audioModel.messageId, senderId: audioModel.senderId, isDeleted: false)
            }
        }
        audioMessageCell.onCellTapped = {(audioCell) in
            self.performMessageSelectDeSelect(messageModel: audioCell.audioMessageModel)
        }
        audioMessageCell.onReactionButtonPressed = {[weak self] audioCell in
            if let strongSelf = self {
                let viewPoint = strongSelf.getConvertedPoint(audioCell.reactionButton, baseView: strongSelf.view)
                guard let chatItem = audioCell.audioMessageModel else {
                   return
                }
                var arrowDirection: UIPopoverArrowDirection = .up
                if viewPoint.y < strongSelf.view.frame.height/2 {
                    arrowDirection = .up
                } else {
                    arrowDirection = .down
                }
                self?.showPopOverForItem(chatItem: chatItem, sourcePoint: viewPoint, sourceFrameSize: audioCell.reactionButton.frame.size, arrowDirection: arrowDirection)
            }
        }
        audioMessageCell.onPlayButtonPressed = {[weak self] (audioCell) in
            self?.playAudioMessage(model: audioCell.audioMessageModel)
        }
        audioMessageCell.onPauseButtonPressed = {[weak self] (audioCell) in
            self?.playAudioMessage(model: audioCell.audioMessageModel)
        }
        return audioMessageCell
    }
    
    func configureVideoMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: ChannelizeChatItem) -> UICollectionViewCell {
        guard let videoMessageItem = chatItem as? VideoMessageItem else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "undefinedCell", for: indexPath)
        }
        let videoMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoMessageCell", for: indexPath) as! UIVideoMessageCell
        videoMessageCell.assignChatItem(chatItem: videoMessageItem)
        videoMessageCell.assignImageData(videoMessageModel: videoMessageItem, ethreeObject: self.ethreeObject, lookUpResult: self.myLookUpResults, messageOwner: videoMessageItem.senderId)
        videoMessageCell.onReactionButtonPressed = {[weak self] videoCell in
            if let strongSelf = self {
                let viewPoint = strongSelf.getConvertedPoint(videoCell.reactionButton, baseView: strongSelf.view)
                guard let chatItem = videoCell.videoMessageItem else {
                   return
                }
                var arrowDirection: UIPopoverArrowDirection = .up
                if viewPoint.y < strongSelf.view.frame.height/2 {
                    arrowDirection = .up
                } else {
                    arrowDirection = .down
                }
                self?.showPopOverForItem(chatItem: chatItem, sourcePoint: viewPoint, sourceFrameSize: videoCell.reactionButton.frame.size, arrowDirection: arrowDirection)
            }
        }
        videoMessageCell.onLongPressVideoBubble = {[weak self] videoItem in
            if let videoModel = videoItem {
                self?.showMessageOptions(messageId: videoModel.messageId, senderId: videoModel.senderId, isDeleted: false)
            }
        }
        videoMessageCell.onCellTapped = {(videoMessageCell) in
            self.performMessageSelectDeSelect(messageModel: videoMessageCell.videoMessageItem)
        }
        videoMessageCell.onVideoBubbleTapped = { (videoItem) in
            if let videoModel = videoItem {
                self.openImageViewer(with: videoModel)
            }
        }
        return videoMessageCell
        //videoMessageCell
    }
    
    func configureImageMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: ChannelizeChatItem) -> UICollectionViewCell {
        guard let imageMessageItem = chatItem as? ImageMessageItem else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "undefinedCell", for: indexPath)
        }
        let imageMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageMessageCell", for: indexPath) as! UIImageMessageCell
        imageMessageCell.assignChatItem(chatItem: imageMessageItem)
        imageMessageCell.assignImageData(imageMessageModel: imageMessageItem, ethreeObject: self.ethreeObject, lookUpResult: self.myLookUpResults, messageOwner: imageMessageItem.senderId)
        imageMessageCell.onReactionButtonPressed = {[weak self] cell in
            if let strongSelf = self {
                let viewPoint = strongSelf.getConvertedPoint(imageMessageCell.reactionButton, baseView: strongSelf.view)
                guard let chatItem = imageMessageCell.imageMessageItem else {
                   return
                }
                var arrowDirection: UIPopoverArrowDirection = .up
                if viewPoint.y < strongSelf.view.frame.height/2 {
                    arrowDirection = .up
                } else {
                    arrowDirection = .down
                }
                self?.showPopOverForItem(chatItem: chatItem, sourcePoint: viewPoint, sourceFrameSize: imageMessageCell.reactionButton.frame.size, arrowDirection: arrowDirection)
            }
        }
        imageMessageCell.onCellTapped = {(imageMessageCell) in
            self.performMessageSelectDeSelect(messageModel: imageMessageCell.imageMessageItem)
        }
        imageMessageCell.onImageBubbleTapped = {[weak self](imageItem) in
            if let imageModel = imageItem {
                self?.openImageViewer(with: imageModel)
            }
        }
        imageMessageCell.onLongPressImageView = {[weak self](imageItem) in
            if let imageModel = imageItem {
                self?.showMessageOptions(messageId: imageModel.messageId, senderId: imageModel.senderId, isDeleted: false)
            }
        }
        return imageMessageCell
        //imageMessageCell
    }
    
    func configureDocMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: ChannelizeChatItem) -> UICollectionViewCell {
        guard let docMessageItem = chatItem as? DocMessageItem else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "undefinedCell", for: indexPath)
        }
        let docMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "docMessageCell", for: indexPath) as! UIDocMessageCell
        docMessageCell.assignChatItem(chatItem: docMessageItem)
        docMessageCell.onReactionButtonPressed = {[weak self] docMessageCell in
            if let strongSelf = self {
                let viewPoint = strongSelf.getConvertedPoint(docMessageCell.reactionButton, baseView: strongSelf.view)
                guard let chatItem = docMessageCell.docMessageModel else {
                   return
                }
                var arrowDirection: UIPopoverArrowDirection = .up
                if viewPoint.y < strongSelf.view.frame.height/2 {
                    arrowDirection = .up
                } else {
                    arrowDirection = .down
                }
                self?.showPopOverForItem(chatItem: chatItem, sourcePoint: viewPoint, sourceFrameSize: docMessageCell.reactionButton.frame.size, arrowDirection: arrowDirection)
            }
        }
        docMessageCell.onOpenButtonPressed = { (docCell) in
            self.openDocFile(docMessage: docCell.docMessageModel)
        }
        docMessageCell.onDownloadButtonPressed = { (docCell) in
            self.downloadDocFile(docMessage: docCell.docMessageModel)
        }
        docMessageCell.onCellTapped = {(docMessageCell) in
            self.performMessageSelectDeSelect(messageModel: docMessageCell.docMessageModel)
        }
        docMessageCell.onLongPressDocumentBubble = {[weak self](docItem) in
            if let docModel = docItem {
                self?.showMessageOptions(messageId: docModel.messageId, senderId: docModel.senderId, isDeleted: false)
            }
        }
        return docMessageCell
    }
    
    func configureQuotedMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: ChannelizeChatItem) -> UICollectionViewCell {
        guard let quotedMessageItem = chatItem as? QuotedMessageItem else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "undefinedCell", for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "quotedMessageCell", for: indexPath) as! UIQuotedMessageCell
        cell.assignChatItem(chatItem: quotedMessageItem)
        cell.onContainerViewTapped = {[weak self](messageId) in
            if let indexPath = self?.chatItems.firstIndex(where: {
                $0.messageId == messageId
            }) {
                let parentMessageIndex = IndexPath(item: indexPath, section: 0)
                self?.collectionView.scrollToItem(at: parentMessageIndex, at: .centeredVertically, animated: false)
            }
        }
        cell.onReactionButtonPressed = {[weak self](cell) in
            if let strongSelf = self {
                if let quotedMessageCell = cell {
                    //strongSelf.view.viewWithTag(2056)?.removeFromSuperview()
                    let viewPoint = strongSelf.getConvertedPoint(quotedMessageCell.reactionButton, baseView: strongSelf.view)
                    guard let chatItem = quotedMessageCell.quotedItem else {
                       return
                    }
                    var arrowDirection: UIPopoverArrowDirection = .up
                    if viewPoint.y < strongSelf.view.frame.height/2 {
                        arrowDirection = .up
                    } else {
                        arrowDirection = .down
                    }
                    self?.showPopOverForItem(chatItem: chatItem, sourcePoint: viewPoint, sourceFrameSize: quotedMessageCell.reactionButton.frame.size, arrowDirection: arrowDirection)
                }
            }
        }
        cell.onLongPressQuotedView = {[weak self] (quotedItem) in
            if let quotedModel = quotedItem {
                self?.showMessageOptions(messageId: quotedModel.messageId, senderId: quotedModel.senderId, isDeleted: false)
            }
        }
        cell.onCellTapped = {(quotedCell) in
            self.performMessageSelectDeSelect(messageModel: quotedCell.quotedItem)
        }
        return cell
    }
    
    func configureLinkPreviewMessageCell(collectionView: UICollectionView, indexPath: IndexPath, chatItem: ChannelizeChatItem) -> UICollectionViewCell {
        guard let linkDataItem = chatItem as? LinkMessageItem else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "undefinedCell", for: indexPath)
        }
        let linkMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "linkPreviewMessageCell", for: indexPath) as! UILinkPreviewMessageCell
        linkMessageCell.assignChatItem(chatItem: linkDataItem)
        return linkMessageCell
        //linkPreviewMessageCell
    }
    
    // MARK: - Get Message Item Size Functions
    func getTextMessageItemHeight(chatItem: ChannelizeChatItem) -> CGSize {
        let textMessageItem = chatItem as? TextMessageItem
        let attributedString = textMessageItem?.attributedString ?? NSAttributedString()
        
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 250, withText: attributedString)
        
        let frameSize = frameSizeInfo.frameSize
        let containerHeight = frameSize.height + 24
        
        var totalHeight: CGFloat = 0
        let textViewHeight: CGFloat = containerHeight
        totalHeight = totalHeight + textViewHeight
        
        if chatItem.showUnreadMessageLabel == true {
            totalHeight += 40
        }
        
        if chatItem.showDataSeperator == true {
            totalHeight += 40
        }
        if chatItem.showSenderName == true {
            totalHeight += 25
        }
        if chatItem.showMessageStatusView == true {
            totalHeight += 7.5
        }
        let reactionsViewHeight = self.calculateReactionViewHeight(chatItem: chatItem, maxWidth: 250)
        totalHeight = totalHeight + ( reactionsViewHeight > 0 ? reactionsViewHeight - 10 : 0)
        
        if textMessageItem?.isTranslated == true {
            
            let translatedFrameSizeInfo = getTextMessageSizeInfo(maxWidth: 250, withText: textMessageItem?.translatedAttributedString ?? NSAttributedString())
            let labelHeight = translatedFrameSizeInfo.frameSize.height
            
            totalHeight += (labelHeight + 15)
            
            
            //let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 250, withText: attributedString)
            
            
            //let labelHeight = getAttributedLabelHeight(attributedString: textMessageItem?.translatedAttributedString ?? NSAttributedString(), maximumWidth: frameSize.width + 26 - 27.5, numberOfLines: 0)
            //totalHeight += labelHeight + 15//+ (reactionsViewHeight > 0 ? 12 : 0)
        }
        
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getGifStickerMessageItemHeight(chatItem: ChannelizeChatItem) -> CGSize {
        var totalHeight: CGFloat = 0
        let imageViewHeight: CGFloat = CHCustomStyles.gifStickerMessageBubbleSize.height
        totalHeight = totalHeight + imageViewHeight
        
        if chatItem.showUnreadMessageLabel == true {
            totalHeight += 40
        }
        
        if chatItem.showDataSeperator == true {
            totalHeight += 40
        }
        
        if chatItem.showSenderName == true {
            totalHeight += 25
        }
        
        if chatItem.showMessageStatusView == true {
            totalHeight += 7.5
        }
        
        let reactionsViewHeight = self.calculateReactionViewHeight(chatItem: chatItem, maxWidth: CHCustomStyles.gifStickerMessageBubbleSize.width)
        totalHeight = totalHeight + ( reactionsViewHeight > 0 ? reactionsViewHeight - 15 : 0)
        
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getLocationMessageItemHeight(chatItem: ChannelizeChatItem) -> CGSize {
        let locationModel = chatItem as? LocationMessageItem
        let imageViewHeight: CGFloat = CHCustomStyles.locationMessageBubbleImageSize.height
        let nameLableHeight: CGFloat = locationModel?.locationData?.locationName != nil && locationModel?.locationData?.locationName != "" ? 22.5 : 0
        let attributedAddress = locationModel?.locationData?.locationAddressAttributedString ?? NSAttributedString()
        let height = getAttributedLabelHeight(attributedString: attributedAddress, maximumWidth: CHCustomStyles.locationMessageBubbleImageSize.width - 10, numberOfLines: 2)
        
        var totalHeight = imageViewHeight + nameLableHeight + (height == 0 ? 0 : height + 10)
        
        if chatItem.showUnreadMessageLabel == true {
            totalHeight += 40
        }
        
        if chatItem.showDataSeperator == true {
            totalHeight += 40
        }
        if chatItem.showSenderName == true {
            totalHeight += 25
        }
        if chatItem.showMessageStatusView == true {
            totalHeight += 7.5
        }
        let reactionsViewHeight = self.calculateReactionViewHeight(chatItem: chatItem, maxWidth: 250)
        totalHeight = totalHeight + ( reactionsViewHeight > 0 ? reactionsViewHeight : 0)
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getAudioMessageHeight(chatItem: ChannelizeChatItem) -> CGSize {
        let unreadMessageLabelHeight: CGFloat = chatItem.showUnreadMessageLabel ? 40 : 0
        let dateSeperatorHeight: CGFloat = chatItem.showDataSeperator ? 40 : 0
        let senderNameHeight: CGFloat = chatItem.showSenderName ? 25 : 0
        let statusViewHeight: CGFloat = chatItem.showMessageStatusView ? 7.5 : 0
        var totalHeight = unreadMessageLabelHeight + dateSeperatorHeight + senderNameHeight + CHCustomStyles.audioMessageBubbleSize.height + statusViewHeight
        let reactionsViewHeight = self.calculateReactionViewHeight(chatItem: chatItem, maxWidth: CHCustomStyles.audioMessageBubbleSize.width)
        totalHeight = totalHeight + ( reactionsViewHeight > 0 ? reactionsViewHeight : 0)
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getVideoMessageItemHeight(chatItem: ChannelizeChatItem) -> CGSize {
        var totalHeight: CGFloat = 0
        let imageViewHeight: CGFloat = CHCustomStyles.videoMessageBubbleSize.height
        totalHeight = totalHeight + imageViewHeight
        
        if chatItem.showUnreadMessageLabel == true {
            totalHeight += 40
        }
        
        if chatItem.showDataSeperator == true {
           totalHeight += 40
        }
        if chatItem.showSenderName == true {
           totalHeight += 25
        }
        if chatItem.showMessageStatusView == true {
            totalHeight += 7.5
        }
        let reactionsViewHeight = self.calculateReactionViewHeight(chatItem: chatItem, maxWidth: CHCustomStyles.videoMessageBubbleSize.width)
        totalHeight = totalHeight + ( reactionsViewHeight > 0 ? reactionsViewHeight - 15 : 0)
       
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getImageMessageItemHeight(chatItem: ChannelizeChatItem) -> CGSize {
        var totalHeight: CGFloat = 0
        let imageViewHeight: CGFloat = CHCustomStyles.imageMessageBubbleSize.height
        totalHeight = totalHeight + imageViewHeight
        
        if chatItem.showUnreadMessageLabel == true {
            totalHeight += 40
        }
        
        if chatItem.showDataSeperator == true {
            totalHeight += 40
        }
        if chatItem.showSenderName == true {
            totalHeight += 25
        }
        if chatItem.showMessageStatusView == true {
            totalHeight += 7.5
        }
        let reactionsViewHeight = self.calculateReactionViewHeight(chatItem: chatItem, maxWidth: CHCustomStyles.imageMessageBubbleSize.width)
        totalHeight = totalHeight + ( reactionsViewHeight > 0 ? reactionsViewHeight - 15 : 0)
        
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getDocMessageCellSize(chatItem: ChannelizeChatItem) -> CGSize {
        let unreadMessageLabel: CGFloat = chatItem.showUnreadMessageLabel ? 40 : 0
        let dateSeperatorHeight: CGFloat = chatItem.showDataSeperator ? 40 : 0
        let senderNameHeight: CGFloat = chatItem.showSenderName ? 25 : 0
        let statusViewHeight: CGFloat = chatItem.showMessageStatusView ? 7.5 : 0
        var totalHeight = unreadMessageLabel + dateSeperatorHeight + senderNameHeight + CHCustomStyles.docMessageBubbleSize.height + statusViewHeight
        let reactionsViewHeight = self.calculateReactionViewHeight(chatItem: chatItem, maxWidth: CHCustomStyles.docMessageBubbleSize.width)
        totalHeight = totalHeight + ( reactionsViewHeight > 0 ? reactionsViewHeight : 0)
        return CGSize(width: self.view.frame.width, height: totalHeight)
    }
    
    func getMetaMessageHeight(chatItem: ChannelizeChatItem) -> CGSize {
        let metaMessageModel = chatItem as? MetaMessageItem
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 280, withText: metaMessageModel?.metaMessageAttributedString ?? NSAttributedString())
        let recalculatedHeight = frameSizeInfo.frameSize.height + 10
        return CGSize(width: self.view.frame.width, height: recalculatedHeight)
    }
    
    func getQuotedMessageItemHeight(chatItem: ChannelizeChatItem) -> CGSize {
        let textMessageItem = chatItem as? QuotedMessageItem
        let attributedString = textMessageItem?.attributedString ?? NSAttributedString()
        
        let frameSizeInfo = getTextMessageSizeInfo(maxWidth: 250, withText: attributedString)
        
        let frameSize = frameSizeInfo.frameSize
        var containerWidth = frameSize.width + 26
        let containerHeight = frameSize.height + 24
        
        if containerWidth < 80 {
            containerWidth = 80
        }
        
        let containerSize = CGSize(width: containerWidth, height: containerHeight)
        var totalHeight: CGFloat = 0
        let textViewHeight: CGFloat = containerSize.height
        totalHeight = totalHeight + textViewHeight
        
        if chatItem.showUnreadMessageLabel == true {
            totalHeight += 40
        }
        
        if chatItem.showDataSeperator == true {
            totalHeight += 40
        }
        
        if chatItem.showSenderName == true {
            totalHeight += 25
        }
        
        if chatItem.showMessageStatusView == true {
            totalHeight += 7.5
        }
        
        let reactionsViewHeight = self.calculateReactionViewHeight(chatItem: chatItem, maxWidth: 250)
        totalHeight = totalHeight + ( reactionsViewHeight > 0 ? reactionsViewHeight - 10 : 0)
        
        if textMessageItem?.isTranslated == true {
            
            let labelHeight = getAttributedLabelHeight(attributedString: textMessageItem?.translatedAttributedString ?? NSAttributedString(), maximumWidth: 250 - 27.5, numberOfLines: 0)
            totalHeight += (labelHeight + 15)//+ (reactionsViewHeight > 0 ? 12 : 0)
        }
        
        return CGSize(width: self.view.frame.width, height: totalHeight + 48)
    }
    
    func getLinkPreviewMessageHeight(chatItem: ChannelizeChatItem) -> CGSize {
        guard let linkModel = chatItem as? LinkMessageItem else {
            return .zero
        }
        var height : CGFloat = 0
        //height += 150
        if (linkModel.linkMetaData?.linkImageUrl) != nil{
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
    
}



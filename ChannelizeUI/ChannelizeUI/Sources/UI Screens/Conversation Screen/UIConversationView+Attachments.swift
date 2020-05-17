//
//  UIConversationView+Attachments.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import AVFoundation
import ChannelizeAPI
import Photos
import MobileCoreServices


extension UIConversationViewController: ConversationAttachmentViewDelegate, AssetListControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate, AudioCaptureViewDelegate, AVAudioRecorderDelegate, GiphyStickerSelectorDelegate, LocationSharingControllerDelegates, UIDocumentPickerDelegate {
    
    func didPressCancelButton() {
        UIView.animate(withDuration: 0.3, animations: {
            self.topStackContainerHeightConstraint.constant = 0
            self.textViewContainerHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }, completion: {(completed) in
            self.attachmentOptionView.removeFromSuperview()
            self.attachmentOptionView.delegate = nil
        })
    }
    
    func didPressAttachmentOptionCell(attachmentType: AttachmentType) {
        self.attachmentOptionView.removeFromSuperview()
        self.attachmentOptionView.delegate = nil
        UIView.animate(withDuration: 0.1, animations: {
            self.topStackContainerHeightConstraint.constant = 0
            self.textViewContainerHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }, completion: {(completed) in
            if completed {
                switch attachmentType {
                case .image:
                    self.openImageSelector()
                    break
                case .location:
                    self.openLocationShareController()
                    break
                case .video:
                    self.openVideoPicker()
                    break
                case .gif:
                    self.openGifStickerSelectorView(type: .gif)
                    break
                case .sticker:
                    self.openGifStickerSelectorView(type: .sticker)
                    break
                case .audio:
                    self.openAudioRecordingView()
                    break
                default:
                    break
                }
            }
        })
    }
    // MARK:- Location Message Functions
    func openLocationShareController() {
        let controller = LocationSearchTableController()
        controller.hidesBottomBarWhenPushed = true
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    /// Location Selector Delegate
    func didSelectLocation(coordinates: CLLocationCoordinate2D, name: String, address: String) {
        let messageId = UUID().uuidString
        let senderName = ChannelizeAPI.getCurrentUserDisplayName()
        let senderId = ChannelizeAPI.getCurrentUserId()
        let senderImageUrl = ChannelizeAPI.getCurrentUserProfileImageUrl()
        let messageDate = Date()
        let messageStatus = BaseMessageStatus.sending
        
        var messageParams = [String:Any]()
        messageParams.updateValue(messageId, forKey: "id")
        messageParams.updateValue(senderName, forKey: "ownerName")
        messageParams.updateValue(senderId, forKey: "ownerId")
        messageParams.updateValue(self.conversation?.id ?? "", forKey: "conversationId")
        
        let baseMessageModel = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl ?? "", messageDate: messageDate, status: messageStatus)
        let locationMessageModel = LocationMessageModel(baseMessageModel: baseMessageModel, locationName: name, locationAddress: address, locationLatitude: coordinates.latitude, locationLongitude: coordinates.longitude)
        self.insertNewChatItemAtBottom(chatItem: locationMessageModel)
        
        ChannelizeAPIService.sendLocationMessage(params: messageParams, locationName: name, locationAddress: address, latitude: coordinates.latitude, longitude: coordinates.longitude, completion: {(message,error) in
            if let recievedMessage = message {
                let messageId = recievedMessage.id ?? ""
                if let firstIndex = self.chatItems.firstIndex(where: {
                    $0.messageId == messageId
                }) {
                    var chatItem = self.chatItems[firstIndex]
                    chatItem.messageStatus = .sent
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
    // MARK:- Document Sharing Functions
    func openDocumentPicker() {
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .fullScreen
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            importMenu.overrideUserInterfaceStyle = .light
        } else {
        // Fallback on earlier versions
        }
        #endif
        self.present(importMenu, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
             return
        }
        let fileName = myURL.lastPathComponent
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            if let fileData = try? Data(contentsOf: myURL, options: .uncached) {
                if fileData.count > Int(CHCustomOptions.maximumDocumentSize * 1024 * 1024) {
                    self.showDocFileSizeLimit()
                    return
                }
                print(fileData.count)
                print(myURL.mimeType())
                print(myURL.lastPathComponent)
                print(myURL.pathExtension)
                
                let fileName = myURL.lastPathComponent
                let mimeType = myURL.mimeType()
                let fileSize = fileData.count
                let fileExtension = myURL.pathExtension
                
                let uniqueId = UUID()
                let messageId = uniqueId.uuidString
                let senderName = ChannelizeAPI.getCurrentUserDisplayName()
                let senderId = ChannelizeAPI.getCurrentUserId()
                let senderImageUrl = ChannelizeAPI.getCurrentUserProfileImageUrl()
                let messageDate = Date()
                let messageStatus = BaseMessageStatus.sending
                
                let baseMessageModel = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl ?? "", messageDate: messageDate, status: messageStatus)
                let docMessageData = DocMessageData(fileName: fileName, downloadUrl: nil, fileType: fileExtension, fileSize: fileSize, mimeType: mimeType, fileExtension: fileExtension)
                let docMessageModel = DocMessageModel(baseMessageModel: baseMessageModel, messageData: docMessageData)
                docMessageModel.docStatus = .uploading
                self.insertNewChatItemAtBottom(chatItem: docMessageModel)
                
                print("Doc Message Check -> UUID \(uniqueId)")
                let messageQueryBuilder = CHMessageQueryBuilder()
                messageQueryBuilder.id = uniqueId.uuidString
                print("Doc Message Check -> Message Id \(uniqueId.uuidString)")
                messageQueryBuilder.conversationId = self.conversation?.id
                messageQueryBuilder.messageType = .normal
                messageQueryBuilder.ownerId = ChannelizeAPI.getCurrentUserId()
                
                let docAttachment = CHDocAttachmentQueryBuilder()
                docAttachment.fileName = fileName
                docAttachment.mimeType = mimeType
                docAttachment.size = fileSize
                docAttachment.fileExtension = fileExtension
                docAttachment.attachMentIdentifier = uniqueId
                docAttachment.fileData = fileData
                
                messageQueryBuilder.attachments = [docAttachment]
                
                ChannelizeAPIService.sendMessage(queryBuilder: messageQueryBuilder, uploadProgress: {(identifier,progress) in
                    docMessageModel.uploadProgress = progress ?? 0.0
                    
                    if let index = self.chatItems.firstIndex(where: {
                        $0.messageId == docMessageModel.messageId
                    }) {
                        let cellIndexPath = IndexPath(item: index, section: 0)
                        if let docMessageCell = self.collectionView.cellForItem(at: cellIndexPath) as? CHDocMessageCell {
                            docMessageCell.updateProgress(fromValue: docMessageModel.uploadProgress, toValue: progress ?? 0.0)
                        }
                    }
                    print("Progress for \(identifier ?? UUID()) is \(progress ?? 0.0)")
                }, completion: {(message,errorString) in
                    guard errorString == nil else {
                        return
                    }
                    if let recievedMessage = message {
                        if let newDocMessageModel = self.createChatItemFromMessage(message: recievedMessage) as? DocMessageModel {
                            if let fileUrl = URL(string: newDocMessageModel.docMessageData.downloadUrl ?? "") {
                                let newFileName = fileUrl.lastPathComponent
                                let newFileUrl = documentsURL.appendingPathComponent(newFileName)
                                print(newFileUrl.path)
                                print(newFileUrl.absoluteString)
                                if let firstIndex = self.chatItems.firstIndex(where: {
                                    $0.messageId == newDocMessageModel.messageId
                                }) {
                                    do {
                                        try FileManager.default.moveItem(at: myURL, to: newFileUrl)
                                        let oldChatItem = self.chatItems[firstIndex]
                                        newDocMessageModel.showSenderName = oldChatItem.showSenderName
                                        newDocMessageModel.showDataSeperator = oldChatItem.showDataSeperator
                                        newDocMessageModel.showMessageStatusView = oldChatItem.showMessageStatusView
                                        newDocMessageModel.messageStatus = .sent
                                        newDocMessageModel.docStatus = .availableLocal
                                        let modifyingIndexPath = IndexPath(item: firstIndex, section: 0)
                                        self.chatItems.remove(at: firstIndex)
                                        self.chatItems.insert(newDocMessageModel, at: firstIndex)
                                        self.collectionView.performBatchUpdates({
                                            self.collectionView.deleteItems(at: [modifyingIndexPath])
                                            self.collectionView.insertItems(at: [modifyingIndexPath])
                                        }, completion: nil)
                                    } catch {
                                        let oldChatItem = self.chatItems[firstIndex]
                                        docMessageModel.showSenderName = oldChatItem.showSenderName
                                        docMessageModel.showDataSeperator = oldChatItem.showDataSeperator
                                        docMessageModel.showMessageStatusView = oldChatItem.showMessageStatusView
                                        docMessageModel.messageStatus = .sent
                                        let modifyingIndexPath = IndexPath(item: firstIndex, section: 0)
                                        self.chatItems.remove(at: firstIndex)
                                        self.chatItems.insert(docMessageModel, at: firstIndex)
                                        self.collectionView.performBatchUpdates({
                                            self.collectionView.deleteItems(at: [modifyingIndexPath])
                                            self.collectionView.insertItems(at: [modifyingIndexPath])
                                        }, completion: nil)
                                        print("Failed to move file at new Location")
                                        print("Error: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                        //Modify Existing File
                        print(recievedMessage.toJSON())
                    }
                })
            }
        }
    }
    
    private func showDocFileSizeLimit() {
        let errorController = UIAlertController(title: "Error", message: "You can upload document of size less than 50 MB", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        errorController.addAction(okAction)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            errorController.overrideUserInterfaceStyle = .light
        }
        #endif
        self.present(errorController, animated: true, completion: nil)
    }
    
    // MARK:- Media Functions
    func openImageSelector() {
        let layout = UICollectionViewFlowLayout()
        //let controller = PhotosPickerController(collectionViewLayout: layout)
        //controller.delegate = self
        //self.navigationController?.pushViewController(controller, animated: true)
        //PhotosPickerController
        
        let controller = AssetListController(collectionViewLayout: layout)
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // Video Selector Functions
    func openVideoPicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func accessAssetImages(assetImages: [UIImage]) {
        for image in assetImages{
            if let fetchedData = image.jpegData(compressionQuality: 1.0){
                if let image = UIImage(data: fetchedData) {
                    self.createImageUploadRequest(with: image)
                }
            }
        }
    }
    
    func accessSelectedAssets(assets: [PHAsset]) {
        for asset in assets{
            let imageManager = PHImageManager.default()
            let fetchOption = PHImageRequestOptions()
            fetchOption.isSynchronous = true
            fetchOption.isNetworkAccessAllowed = true
            fetchOption.deliveryMode = .highQualityFormat
            //let size = UIScreen.main.bounds.size
            //let scale = UIScreen.main.scale
            //let targetSize = CGSize(width: size.width*scale, height: size.height*scale)
            
            imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: fetchOption, resultHandler: {[weak self](image,info) in
                autoreleasepool {
                    if let _image = image {
                        DispatchQueue.main.async {
                            self?.createImageUploadRequest(with: _image)
                        }
                    }
                }
            })
        }
    }
    
    
    func createImageUploadRequest(with image: UIImage) {
        let thumbImage = createThumbsFromImage(image: image)
        let thumbnailData = thumbImage.pngData()!
        //let thumbnailData: Data?
        let imageData = image.jpegData(compressionQuality: 1.0)
        
        if imageData?.count ?? 0 > Int(CHCustomOptions.maximumImageSize * 1024 * 1024) {
            
        }
        
        let messageId = UUID().uuidString
        let senderName = ChannelizeAPI.getCurrentUserDisplayName()
        let senderId = ChannelizeAPI.getCurrentUserId()
        let senderImageUrl = ChannelizeAPI.getCurrentUserProfileImageUrl()
        let messageDate = Date()
        let messageStatus = BaseMessageStatus.sending
        
        var messageParams = [String:Any]()
        messageParams.updateValue(messageId, forKey: "id")
        messageParams.updateValue(senderName, forKey: "ownerName")
        messageParams.updateValue(senderId, forKey: "ownerId")
        messageParams.updateValue(self.conversation?.id ?? "", forKey: "conversationId")
        
        let baseMessageModel = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl ?? "", messageDate: messageDate, status: messageStatus)
        let imageMessageModel = ImageMessageModel(baseMessageModel: baseMessageModel, fileImageUrl: nil, source: .local, localImage: image)
        self.insertNewChatItemAtBottom(chatItem: imageMessageModel)
        //self.collectionView.reloadData()
        
        ChannelizeAPIService.sendImageMessage(imageData: imageData, thumbnailData: thumbnailData, conversationId: self.conversation?.id ?? "", params: messageParams, uploadProgress: { progress in
            
            if let firstIndex = self.chatItems.firstIndex(where: {
                $0.messageId == messageId
            }) {
                let indexPath = IndexPath(item: firstIndex, section: 0)
                let chatItem = self.chatItems[firstIndex]
                let oldProgress = chatItem.uploadProgress
                chatItem.uploadProgress = progress
                chatItem.uploadProgress = progress
                let cell = self.collectionView.cellForItem(at: indexPath) as? CHImageMessageCell
                cell?.updateProgress(fromValue: oldProgress, toValue: progress)
            }
            print("Total Upload Progress is \(progress)")
        }, comletion: {(message,errorString) in
            if let recievedMessage = message {
                let messageId = recievedMessage.id ?? ""
                if let firstIndex = self.chatItems.firstIndex(where: {
                    $0.messageId == messageId
                }) {
                    let chatItem = self.chatItems[firstIndex]
                    chatItem.messageStatus = .sent
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
    func createVideoUploadRequest(with url: URL) {
        let videoThumbImage = generateThumbnail(url: url)
        let thumbnailImage = createThumbsFromImage(image: videoThumbImage!)
        let thumbData = thumbnailImage.pngData()!
        do {
            let videoData = try Data(contentsOf: url)
            if videoData.count > Int(CHCustomOptions.maximumVideoSize * 1024 * 1024) {
                return
            }
            let messageId = UUID().uuidString
            let senderName = ChannelizeAPI.getCurrentUserDisplayName()
            let senderId = ChannelizeAPI.getCurrentUserId()
            let senderImageUrl = ChannelizeAPI.getCurrentUserProfileImageUrl()
            let messageDate = Date()
            let messageStatus = BaseMessageStatus.sending
            
            var messageParams = [String:Any]()
            messageParams.updateValue(messageId, forKey: "id")
            messageParams.updateValue(senderName, forKey: "ownerName")
            messageParams.updateValue(senderId, forKey: "ownerId")
            messageParams.updateValue(self.conversation?.id ?? "", forKey: "conversationId")
            
            let baseMessageModel = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl ?? "", messageDate: messageDate, status: messageStatus)
            
            let videoMessageModel = VideoMessageModel(baseMessageModel: baseMessageModel, videoUrl: nil, thumbnailUrl: nil, source: .local, localImage: videoThumbImage)
            self.insertNewChatItemAtBottom(chatItem: videoMessageModel)

            ChannelizeAPIService.sendVideoMessage(videoData: videoData, thumbnailData: thumbData, conversationId: self.conversation?.id ?? "", params: messageParams, uploadProgress: { progress in
                if let firstIndex = self.chatItems.firstIndex(where: {
                    $0.messageId == messageId
                }) {
                    let indexPath = IndexPath(item: firstIndex, section: 0)
                    let chatItem = self.chatItems[firstIndex]
                    let oldProgress = chatItem.uploadProgress
                    chatItem.uploadProgress = progress
                    let cell = self.collectionView.cellForItem(at: indexPath) as? CHVideoMessageCell
                    cell?.updateProgress(fromValue: oldProgress, toValue: progress)
                }
                print("Total Upload Progress is \(progress)")
            }, completion: {(message,errorString) in
                
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            self.createVideoUploadRequest(with: videoUrl)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.createImageUploadRequest(with: originalImage)
        }
    }
    
    // MARK: - Audio Message Functions
    func openAudioRecordingView() {
        self.recordingSession = AVAudioSession.sharedInstance()
        self.checkAudioRecordingPermission(completion: {(permission)  in
            if permission == .allowed{
                self.setUpNewRecordingView()
                self.isAudioPermissionAllowed = true
            } else if permission == .denied{
                self.showPermissionAlert()
                self.isAudioPermissionAllowed = false
            }
        })
    }
    
    func checkAudioRecordingPermission(completion : @escaping (AudioPermission) -> ()){
        let permission = self.recordingSession.recordPermission
        switch permission
        {
        case .granted:
            completion(.allowed)
            break
        case .denied:
            completion(.denied)
            break
        case .undetermined:
            self.recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        completion(.allowed)
                    } else {
                        completion(.denied)
                    }
                }
            }
            break
        }
    }
    
    func setUpNewRecordingView(){
        //self.view.endEditing(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterBackGroundWhileRecording(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredForeground(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.startRecording()
    }
    
    @objc func startRecording(){
        self.setupNewRecordingSession()
    }
    
    func setupNewRecordingSession(){
        do {
            if #available(iOS 10.0, *) {
                try self.recordingSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: .defaultToSpeaker)
            } else {
                // Fallback on earlier versions
            }
            try self.recordingSession.setActive(true)
            self.startNewAudioRecording()
        } catch {
            print("Failed To Record!")
        }
    }
    
    func startNewAudioRecording(){
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 24000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ]
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            self.audioRecorder?.delegate = self
            self.audioRecorder?.record()
            UIApplication.shared.isIdleTimerDisabled = true
            self.audioRecorderView.startTimer()
            self.audioRecorderView.isHidden = false
            self.audioRecorderView.delegate = self
            
            self.textViewContainer.insertSubview(self.audioRecorderView, at: 0)
            self.textViewContainer.bringSubviewToFront(
                self.audioRecorderView)
            UIView.transition(with: self.audioRecorderView, duration: 0.5, options: [.transitionCrossDissolve,.layoutSubviews], animations: {
                self.audioRecorderView.pinEdgeToSuperView(superView: self.textViewContainer)
            }, completion: nil)
            
            
            /*
            self.topStackViewContainer.addArrangedSubview(
                self.audioRecorderView)
            self.audioRecorderView.setLeftAnchor(relatedConstraint: self.topStackViewContainer.leftAnchor, constant: 0)
            self.audioRecorderView.setRightAnchor(relatedConstraint: self.topStackViewContainer.rightAnchor, constant: 0)
            self.audioRecorderView.heightAnchor.constraint(
                equalToConstant: 50).isActive = true
            
            UIView.animate(withDuration: 0.1, animations: {
                self.textViewContainerHeightConstraint.constant = 0
                self.topStackContainerHeightConstraint.constant = 50
                self.view.layoutIfNeeded()
            })
            */
            //self.performHideButtonOnBlock()
        } catch {
            print(error)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func showPermissionAlert()
    {
        let alert = UIAlertController(title: CHLocalized(key: "pmMicrophonePermission"), message: CHLocalized(key: "pmMicrophoneMessage"), preferredStyle: .alert)
        let cancelAlert = UIAlertAction(title: CHLocalized(key: "pmCancel"), style: .cancel, handler: nil)
        let openSetingsAlert = UIAlertAction(title: CHLocalized(key: "pmOpenAppSetting"), style: .default, handler: { (UIAlertAction) -> Void in
            
            self.openSettings()
        })
        alert.addAction(cancelAlert)
        alert.addAction(openSetingsAlert)
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            alert.overrideUserInterfaceStyle = .light
        }
        #endif
        self.present(alert, animated:true, completion:nil)
    }
    
    func openSettings()
    {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func removeNotificationObservers(){
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func appEnterBackGroundWhileRecording(notification:NSNotification){
        self.audioRecorder?.pause()
        self.audioRecorderView.backGroundTime = self.audioRecorderView.recordingTime
        self.audioRecorderView.stopTimer()
    }
    
    @objc func appEnteredForeground(notification:NSNotification){
        self.audioRecorder?.record()
        if audioRecorderView.backGroundTime > 0{
            audioRecorderView.recordingTime = audioRecorderView.backGroundTime
            audioRecorderView.recordingTimerLabel.text = audioRecorderView.timeString(time: audioRecorderView.recordingTime)
            audioRecorderView.startTimer()
        }
    }
    
    func didPressAudioSendButton() {
        self.removeNotificationObservers()
        self.audioRecorder?.stop()
        self.audioRecorderView.stopTimer()
        self.audioRecorderView.delegate = nil
        self.audioRecorderView.isHidden = true
        self.audioRecorderView.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: {
            self.topStackContainerHeightConstraint.constant = 0
            self.textViewContainerHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
        })
        do{
            try self.recordingSession.setActive(false, options: [])
        } catch{
            print(error)
        }
    }
    
    func didPressAudioDeleteButton() {
        UIApplication.shared.isIdleTimerDisabled = false
        self.removeNotificationObservers()
        self.audioRecorder?.deleteRecording()
        self.audioRecorder = nil
        self.audioRecorderView.stopTimer()
        self.audioRecorderView.delegate = nil
        self.audioRecorderView.isHidden = true
        self.audioRecorderView.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: {
            self.topStackContainerHeightConstraint.constant = 0
            self.textViewContainerHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
        })
        
        do{
            try self.recordingSession.setActive(false, options: [])
        } catch{
            print(error)
        }
    }
    
    func didPressAudioCancelButton() {
        UIApplication.shared.isIdleTimerDisabled = false
        self.removeNotificationObservers()
        self.audioRecorder?.deleteRecording()
        self.audioRecorder = nil
        self.audioRecorderView.stopTimer()
        self.audioRecorderView.delegate = nil
        self.audioRecorderView.isHidden = true
        self.audioRecorderView.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: {
            self.topStackContainerHeightConstraint.constant = 0
            self.textViewContainerHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
        })
        do{
            try self.recordingSession.setActive(false, options: [])
        } catch{
            print(error)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard flag == true else {
            print("Error In Recording Audio")
            return
        }
        let audioUrl = recorder.url
        let player = try? AVAudioPlayer(contentsOf: recorder.url)
        
        let duration = player?.duration ?? 0.0
        if duration < 2.0{
            let alert = UIAlertController(title: "Error", message: CHLocalized(key: "pmVoiceMessageError"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: CHLocalized(key: "pmOk"), style: .default, handler: {(action) in
                
            })
            alert.addAction(okAction)
            #if compiler(>=5.1)
            if #available(iOS 13.0, *) {
                // Always adopt a light interface style.
                alert.overrideUserInterfaceStyle = .light
            }
            #endif
            self.present(alert,animated: true,completion: nil)
            return
        }
        do {
            let audioData = try Data(contentsOf: audioUrl)
            if audioData.count > Int(CHCustomOptions.maximumAudioSize * 1024 * 1024) {
                return
            }
            
            let messageId = UUID().uuidString
            let senderName = ChannelizeAPI.getCurrentUserDisplayName()
            let senderId = ChannelizeAPI.getCurrentUserId()
            let senderImageUrl = ChannelizeAPI.getCurrentUserProfileImageUrl()
            let messageDate = Date()
            let messageStatus = BaseMessageStatus.sending
            
            var messageParams = [String:Any]()
            messageParams.updateValue(messageId, forKey: "id")
            messageParams.updateValue(senderName, forKey: "ownerName")
            messageParams.updateValue(senderId, forKey: "ownerId")
            messageParams.updateValue(self.conversation?.id ?? "", forKey: "conversationId")
            
            let baseMessageModel = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl ?? "", messageDate: messageDate, status: messageStatus)
            
            let audioMessageModel = AudioMessageModel(baseMessageModel: baseMessageModel, audioUrl: audioUrl.absoluteString, audioDuration: duration*1000)
            self.insertNewChatItemAtBottom(chatItem: audioMessageModel)
            ChannelizeAPIService.sendAudioMessage(params: messageParams, audioData: audioData, uploadProgress: {(progress) in }, completion: {(message,errorString) in
                
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK:- GIF and Sticker Message Functions
    func openGifStickerSelectorView(type: GiphType) {
        
        let loadingVC = GiphStickerViewController()
        loadingVC.delegate = self
        //loadingVC.searchBar.delegate = self
        self.addChild(loadingVC)
        self.view.addSubview(loadingVC.view)
        loadingVC.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 0)
        loadingVC.didMove(toParent: self)
        UIView.transition(with: loadingVC.view, duration: 0.33, options: [.transitionCrossDissolve,.curveEaseOut], animations: {
            loadingVC.view.frame.size.height = 330
            loadingVC.view.frame.origin.y = self.view.frame.height - 330
        }, completion: nil)
        
        
        
        /*
        self.gifStickerSelectorView.isHidden = false
        self.gifStickerSelectorView.delegate = self
        self.gifStickerSelectorView.requesterViewType = type
        self.gifStickerSelectorView.getGiphModels()
        
        self.topStackViewContainer.addArrangedSubview(
            self.gifStickerSelectorView)
        self.gifStickerSelectorView.setLeftAnchor(relatedConstraint: self.topStackViewContainer.leftAnchor, constant: 0)
        self.gifStickerSelectorView.setRightAnchor(relatedConstraint: self.topStackViewContainer.rightAnchor, constant: 0)
        self.gifStickerSelectorView.heightAnchor.constraint(
            equalToConstant: 350).isActive = true
        
        UIView.animate(withDuration: 0.1, animations: {
            self.textViewContainerHeightConstraint.constant = 0
            self.topStackContainerHeightConstraint.constant = 350
            self.view.layoutIfNeeded()
        })
        */
    }
    
    func didPressGiphyStickerViewCloseButton() {
        self.gifStickerSelectorView.isHidden = true
        self.gifStickerSelectorView.delegate = nil
        //self.isShowingGifStickerView = false
        self.gifStickerSelectorView.clearOnViewClose()
        self.gifStickerSelectorView.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: {
            self.textViewContainerHeightConstraint.constant = 50
            self.topStackContainerHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    func didSelectMedia(type: GiphType, model: CHGiphImageModel) {
        let messageId = UUID().uuidString
        let senderName = ChannelizeAPI.getCurrentUserDisplayName()
        let senderId = ChannelizeAPI.getCurrentUserId()
        let senderImageUrl = ChannelizeAPI.getCurrentUserProfileImageUrl()
        let messageDate = Date()
        let messageStatus = BaseMessageStatus.sending
        
        var messageParams = [String:Any]()
        messageParams.updateValue(messageId, forKey: "id")
        messageParams.updateValue(senderName, forKey: "ownerName")
        messageParams.updateValue(senderId, forKey: "ownerId")
        messageParams.updateValue(self.conversation?.id ?? "", forKey: "conversationId")
        
        let stillUrl = model.stillUrl
        let downSampledUrl = model.downSampledUrl
        let originalUrl = model.originalUrl
        
        let baseMessageModel = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl ?? "", messageDate: messageDate, status: messageStatus)
        let gifStickerModel = GifStickerMessageModel(baseMessageModel: baseMessageModel, downSampledUrl: downSampledUrl, stillUrl: stillUrl, originalUrl: originalUrl)
        self.insertNewChatItemAtBottom(chatItem: gifStickerModel)
        
        ChannelizeAPIService.sendGifStickerMessage(params: messageParams, stillUrl: stillUrl ?? "", originalUrl: originalUrl ?? "", downSampledUrl: downSampledUrl ?? "", type: type.rawValue, completion: {(message,error) in
            if let recievedMessage = message {
                let messageId = recievedMessage.id ?? ""
                if let firstIndex = self.chatItems.firstIndex(where: {
                    $0.messageId == messageId
                }) {
                    let chatItem = self.chatItems[firstIndex]
                    chatItem.messageStatus = .sent
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
}

enum AudioPermission{
    case allowed
    case denied
    case unknown
}

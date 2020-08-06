//
//  CHConversationController+Attachments.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/10/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import Foundation
import ChannelizeAPI
import MapKit
import DifferenceKit
import AVFoundation
import Photos
import SDWebImage

protocol LocationSharingControllerDelegates: class {
    func didSelectLocation(coordinates: CLLocationCoordinate2D, name: String, address: String)
}

extension CHConversationViewController: LocationSharingControllerDelegates, UIImagePickerControllerDelegate,  UINavigationControllerDelegate, UIDocumentPickerDelegate, AVAudioRecorderDelegate, AssetListControllerDelegate, GiphyStickerSelectorDelegate {
    
    // MARK: - Location Attachment Functions
    func openLocationSelectController() {
        let controller = CHLocationSharingViewController()
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didSelectLocation(coordinates: CLLocationCoordinate2D, name: String, address: String) {
        let messageId = UUID().uuidString
        let senderName = Channelize.getCurrentUserDisplayName()
        let senderId = Channelize.getCurrentUserId()
        let senderImageUrl = Channelize.getCurrentUserProfileImageUrl() ?? ""
        let messageDate = Date()
        let messageStatus = BaseMessageStatus.sending
        
        let baseMessageData = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl, messageDate: messageDate, status: messageStatus)
        let locationMessageData = LocationMessageData(locationName: name, locationAddress: address, locationLatitude: coordinates.latitude, locationLongitude: coordinates.longitude)
        let locationMessageItem = LocationMessageItem(baseMessageModel: baseMessageData, locationData: locationMessageData)
        
        let locationAttachmentBuilder = CHLocationAttachmentQueryBuilder()
        locationAttachmentBuilder.locationAddress = address
        locationAttachmentBuilder.locationTitle = name
        locationAttachmentBuilder.locationLatitude = coordinates.latitude
        locationAttachmentBuilder.locationLongitude = coordinates.longitude
        
        let locationMessageQueryBuilder = CHMessageQueryBuilder()
        locationMessageQueryBuilder.id = messageId
        locationMessageQueryBuilder.body = nil
        if self.conversation?.id != nil {
            locationMessageQueryBuilder.conversationId = self.conversation?.id
        } else {
            locationMessageQueryBuilder.userId = self.conversation?.conversationPartner?.id
        }
        locationMessageQueryBuilder.messageType = .normal
        locationMessageQueryBuilder.ownerId = senderId
        locationMessageQueryBuilder.attachments = [locationAttachmentBuilder]
        locationMessageQueryBuilder.createdAt = messageDate
        self.conversation?.lastReadDictionary?.updateValue(ISODateTransform().transformToJSON(messageDate) ?? "", forKey: Channelize.getCurrentUserId())
        self.conversation?.updateLastMessageOldestRead()
        
        self.noMessageContentView.removeFromSuperview()
        
        let oldItems = self.chatItems.copy()
        self.chatItems.append(locationMessageItem)
        self.reprepareChatItems()
        let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
        self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
            self.chatItems = data
        }, completion: {
            self.scrollToBottom(animated: true)
        })
        
        
        ChannelizeAPIService.sendMessage(queryBuilder: locationMessageQueryBuilder, uploadProgress: { _,_ in }, completion: {(message,errorString) in
            guard errorString == nil else {
                return
            }
            if message != nil {
                let oldItems = self.chatItems.copy()
                locationMessageItem.messageStatus = .sent
                let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
                self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                    self.chatItems = data
                })
                if self.conversation?.id == nil {
                    self.getConversationWithId(conversationId: message?.conversationId)
                }
            }
        })
    }
    
    // MARK: - Video Attachment Functions
    func openVideoPicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            self.createVideoUploadRequest(with: videoUrl)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //self.createImageUploadRequest(with: originalImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createVideoUploadRequest(with url: URL) {
        let videoThumbImage = generateThumbnail(url: url)
        let thumbnailImage = createThumbsFromImage(image: videoThumbImage!)
        do {
            let videoData = try Data(contentsOf: url)
            if videoData.count > Int(CHCustomOptions.maximumVideoSize * 1024 * 1024) {
                self.showAttachmentSizeLimitError(messageError: "Video Size Limit Exceeds. Please send file below 25 MB.")
                return
            }
            let uniqueId = UUID()
            let messageId = uniqueId.uuidString
            let senderName = Channelize.getCurrentUserDisplayName()
            let senderId = Channelize.getCurrentUserId()
            let senderImageUrl = Channelize.getCurrentUserProfileImageUrl() ?? ""
            let messageDate = Date()
            let messageStatus = BaseMessageStatus.sending
            
            let baseMessageData = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl, messageDate: messageDate, status: messageStatus)
            let videoMessageData = VideoMessageData(videoUrlString: nil, thumbnailUrlString: nil, videoSource: .local, thumbLocalImage: thumbnailImage)
            let videoMessageItem = VideoMessageItem(baseMessageModel: baseMessageData, videoMessageData: videoMessageData)
            
            
            var apiThumbNailData: Data?
            var apiVideoData: Data?
            
            if ChVirgilE3Kit.isEndToEndEncryptionEnabled {
                apiThumbNailData = try self.ethreeObject?.authEncrypt(data: thumbnailImage.pngData() ?? Data(), for: self.myLookUpResults)
                apiVideoData = try self.ethreeObject?.authEncrypt(data: videoData, for: self.myLookUpResults)
                videoMessageItem.isEncrypted = true
            } else {
                apiThumbNailData = thumbnailImage.pngData()
                apiVideoData = videoData
                videoMessageItem.isEncrypted = false
            }
            let videoAttachmentQueryBuilder = CHVideoAttachmentQueryBuilder()
            videoAttachmentQueryBuilder.attachMentIdentifier = uniqueId
            videoAttachmentQueryBuilder.fileExtension = "mov"
            videoAttachmentQueryBuilder.mimeType = ""
            videoAttachmentQueryBuilder.thumbNailData = apiThumbNailData
            videoAttachmentQueryBuilder.videoData = apiVideoData
            
            let videoMessageQueryBuilder = CHMessageQueryBuilder()
            videoMessageQueryBuilder.id = messageId
            videoMessageQueryBuilder.body = nil
            if self.conversation?.id != nil {
                videoMessageQueryBuilder.conversationId = self.conversation?.id
            } else {
                videoMessageQueryBuilder.userId = self.conversation?.conversationPartner?.id
            }
            videoMessageQueryBuilder.messageType = .normal
            videoMessageQueryBuilder.ownerId = senderId
            videoMessageQueryBuilder.attachments = [videoAttachmentQueryBuilder]
            videoMessageQueryBuilder.isEncrypted = ChVirgilE3Kit.isEndToEndEncryptionEnabled
            videoMessageQueryBuilder.createdAt = messageDate
            self.noMessageContentView.removeFromSuperview()
            
            self.conversation?.lastReadDictionary?.updateValue(
                ISODateTransform().transformToJSON(messageDate) ?? "", forKey: Channelize.getCurrentUserId())
            self.conversation?.updateLastMessageOldestRead()
            
            let oldItems = self.chatItems.copy()
            self.chatItems.append(videoMessageItem)
            self.reprepareChatItems()
            let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
            self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                self.chatItems = data
            }, completion: {
                self.scrollToBottom(animated: true)
            })
            
            ChannelizeAPIService.sendMessage(queryBuilder: videoMessageQueryBuilder, uploadProgress: { identifier,progress in
                if let firstIndex = self.chatItems.firstIndex(where: {
                    $0.messageId == identifier?.uuidString
                }) {
                    let indexPath = IndexPath(item: firstIndex, section: 0)
                    let chatItem = self.chatItems[firstIndex] as? VideoMessageItem
                    let oldProgress = chatItem?.uploadProgress
                    chatItem?.uploadProgress = progress
                    let cell = self.collectionView.cellForItem(at: indexPath) as? UIVideoMessageCell
                    cell?.updateProgress(fromValue: oldProgress ?? 0.0, toValue: progress ?? 0.0)
                }
            }, completion: {(message,errorString) in
                guard errorString == nil else {
                    return
                }
                if message != nil {
                    let oldItems = self.chatItems.copy()
                    videoMessageItem.messageStatus = .sent
                    videoMessageItem.videoMessageData?.thumbNailUrl = message?.attachments?.first?.thumbnailUrl
                    videoMessageItem.videoMessageData?.videoUrlString = message?.attachments?.first?.fileUrl
                    let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
                    self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                        self.chatItems = data
                    })
                    if self.conversation?.id == nil {
                        self.getConversationWithId(conversationId: message?.conversationId)
                    }
                }
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Document Picker Functions
    func openDocumentPicker() {
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            importMenu.overrideUserInterfaceStyle = CHAppConstant.themeStyle == .dark ? .dark : .light
        } else {
            
        }
        self.present(importMenu, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
             return
        }
        let fileName = myURL.lastPathComponent
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            if let fileData = try? Data(contentsOf: myURL, options: .uncached) {
                if fileData.count > Int(CHCustomOptions.maximumDocumentSize * 1024 * 1024) {
                    self.showAttachmentSizeLimitError(messageError: "You can upload document of size less than 50 MB")
                    return
                }
                let fileName = myURL.lastPathComponent
                let mimeType = myURL.mimeType()
                let fileSize = fileData.count
                let fileExtension = myURL.pathExtension
                
                let uniqueId = UUID()
                let messageId = uniqueId.uuidString
                let senderName = Channelize.getCurrentUserDisplayName()
                let senderId = Channelize.getCurrentUserId()
                let senderImageUrl = Channelize.getCurrentUserProfileImageUrl()
                let messageDate = Date()
                let messageStatus = BaseMessageStatus.sending
                
                let baseMessageModel = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl ?? "", messageDate: messageDate, status: messageStatus)
                let docMessageData = DocMessageData(fileName: fileName, downloadUrl: nil, fileType: fileExtension, fileSize: fileSize, mimeType: mimeType, fileExtension: fileExtension)
                let docMessageItem = DocMessageItem(baseMessageModel: baseMessageModel, docMessageData: docMessageData)
                docMessageItem.docStatus = .uploading
                
                var apiDocumentData: Data?
                
                if ChVirgilE3Kit.isEndToEndEncryptionEnabled {
                    apiDocumentData = try self.ethreeObject?.authEncrypt(data: fileData, for: self.myLookUpResults)
                    docMessageItem.isEncrypted = true
                } else {
                    apiDocumentData = fileData
                    docMessageItem.isEncrypted = false
                }
                
                let docAttachment = CHDocAttachmentQueryBuilder()
                docAttachment.fileName = fileName
                docAttachment.mimeType = mimeType
                docAttachment.size = fileSize
                docAttachment.fileExtension = fileExtension
                docAttachment.attachMentIdentifier = uniqueId
                docAttachment.fileData = apiDocumentData
                
                let messageQueryBuilder = CHMessageQueryBuilder()
                messageQueryBuilder.id = uniqueId.uuidString
                if self.conversation?.id != nil {
                    messageQueryBuilder.conversationId = self.conversation?.id
                } else {
                    messageQueryBuilder.userId = self.conversation?.conversationPartner?.id
                }
                messageQueryBuilder.messageType = .normal
                messageQueryBuilder.ownerId = Channelize.getCurrentUserId()
                messageQueryBuilder.attachments = [docAttachment]
                messageQueryBuilder.isEncrypted = ChVirgilE3Kit.isEndToEndEncryptionEnabled
                messageQueryBuilder.createdAt = messageDate
                self.noMessageContentView.removeFromSuperview()
                
                self.conversation?.lastReadDictionary?.updateValue(
                    ISODateTransform().transformToJSON(messageDate) ?? "", forKey: Channelize.getCurrentUserId())
                self.conversation?.updateLastMessageOldestRead()
                
                let oldItems = self.chatItems.copy()
                self.chatItems.append(docMessageItem)
                self.reprepareChatItems()
                let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
                self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                    self.chatItems = data
                }, completion: {
                    self.scrollToBottom(animated: true)
                })
                
                ChannelizeAPIService.sendMessage(queryBuilder: messageQueryBuilder, uploadProgress: {(identifier,progress) in
                    docMessageItem.uploadProgress = progress ?? 0.0
                    
                    if let index = self.chatItems.firstIndex(where: {
                        $0.messageId == docMessageItem.messageId
                    }) {
                        let cellIndexPath = IndexPath(item: index, section: 0)
                        if let docMessageCell = self.collectionView.cellForItem(at: cellIndexPath) as? UIDocMessageCell {
                            docMessageCell.updateProgress(fromValue: docMessageItem.uploadProgress, toValue: progress ?? 0.0)
                        }
                    }
                    print("Progress for \(identifier ?? UUID()) is \(progress ?? 0.0)")
                }, completion: {(message,errorString) in
                    guard errorString == nil else {
                        return
                    }
                    if let recievedMessage = message {
                        if let newDocMessageModel = self.prepareChatItems(message: recievedMessage) as? DocMessageItem {
                            if let fileUrl = URL(string: newDocMessageModel.docMessageData?.downloadUrl ?? "") {
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
                                        docMessageItem.showSenderName = oldChatItem.showSenderName
                                        docMessageItem.showDataSeperator = oldChatItem.showDataSeperator
                                        docMessageItem.showMessageStatusView = oldChatItem.showMessageStatusView
                                        docMessageItem.messageStatus = .sent
                                        docMessageItem.docStatus = .notAvailableLocal
                                        let modifyingIndexPath = IndexPath(item: firstIndex, section: 0)
                                        self.chatItems.remove(at: firstIndex)
                                        self.chatItems.insert(docMessageItem, at: firstIndex)
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
                        if self.conversation?.id == nil {
                            self.getConversationWithId(conversationId: message?.conversationId)
                        }
                    }
                })
            }
        } catch {
            print(error.localizedDescription)
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
            let audioview = CHAudioCaptureView()
            audioview.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#2c2c2c") : UIColor.white
            audioview.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(audioview)
            audioview.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
            audioview.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
            audioview.setBottomAnchor(relatedConstraint: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
            audioview.setHeightAnchor(constant: 50)
            self.headerView.disableCallButtons()
            audioview.onCancelAudioButtonPressed = {
                UIApplication.shared.isIdleTimerDisabled = false
                self.removeNotificationObservers()
                self.audioRecorder?.deleteRecording()
                self.audioRecorder = nil
                self.headerView.enableCallButtons()
                audioview.stopTimer()
                UIView.animate(withDuration: 0.33, delay: 0.0, options: [.layoutSubviews], animations: {
                    audioview.alpha = 0.0
                }, completion: {(completed) in
                    if completed {
                        audioview.isHidden = true
                        audioview.removeFromSuperview()
                    }
                })
                
                do{
                    try self.recordingSession.setActive(false, options: [])
                } catch{
                    print(error)
                }
            }
            audioview.onDeleteAudioButtonPressed = {
                
                UIApplication.shared.isIdleTimerDisabled = false
                self.removeNotificationObservers()
                self.audioRecorder?.deleteRecording()
                self.audioRecorder = nil
                self.headerView.enableCallButtons()
                audioview.stopTimer()
                UIView.animate(withDuration: 0.33, delay: 0.0, options: [.layoutSubviews], animations: {
                    audioview.alpha = 0.0
                }, completion: {(completed) in
                    if completed {
                        audioview.isHidden = true
                        audioview.removeFromSuperview()
                    }
                })
                do{
                    try self.recordingSession.setActive(false, options: [])
                } catch{
                    print(error)
                }
            }
            audioview.onSendAudioButtonPressed = {
                UIApplication.shared.isIdleTimerDisabled = false
                self.removeNotificationObservers()
                self.audioRecorder?.stop()
                audioview.stopTimer()
                self.headerView.enableCallButtons()
                UIView.animate(withDuration: 0.33, delay: 0.0, options: [.layoutSubviews], animations: {
                    audioview.alpha = 0.0
                }, completion: {(completed) in
                    if completed {
                        audioview.isHidden = true
                        audioview.removeFromSuperview()
                    }
                })
                do{
                    try self.recordingSession.setActive(false, options: [])
                } catch{
                    print(error)
                }
            }
            audioview.startTimer()
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
        let permissionAlert = CHAlertViewController()
        permissionAlert.alertTitle = CHLocalized(key: "pmMicrophonePermission")
        permissionAlert.alertDescription = CHLocalized(key: "pmMicrophoneMessage")
        let cancelAction = CHActionSheetAction(title: CHLocalized(key: "pmCancel"), image: nil, actionType: .cancel, handler: nil)
        let openSettingAction = CHActionSheetAction(title: CHLocalized(key: "pmOpenAppSetting"), image: nil, actionType: .default, handler: {(action) in
            self.openSettings()
        })
        permissionAlert.modalPresentationStyle = .overCurrentContext
        permissionAlert.modalTransitionStyle = .crossDissolve
        permissionAlert.actions = [openSettingAction,cancelAction]
        self.present(permissionAlert, animated:true, completion:nil)
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
        guard let audioRecordingView = self.view.viewWithTag(30001) as? CHAudioCaptureView else {
            return
        }
        self.audioRecorder?.pause()
        audioRecordingView.backGroundTime = audioRecordingView.recordingTime
        audioRecordingView.stopTimer()
    }
    
    @objc func appEnteredForeground(notification:NSNotification){
        guard let audioRecordingView = self.view.viewWithTag(30001) as? CHAudioCaptureView else {
            return
        }
        self.audioRecorder?.record()
        if audioRecordingView.backGroundTime > 0{
            audioRecordingView.recordingTime = audioRecordingView.backGroundTime
            audioRecordingView.recordingTimerLabel.text = audioRecordingView.timeString(time: audioRecordingView.recordingTime)
            audioRecordingView.startTimer()
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
            let alert = CHAlertViewController()
            alert.alertTitle = CHLocalized(key: "pmError")
            alert.alertDescription = CHLocalized(key: "pmVoiceMessageError")
            let okAction = CHActionSheetAction(title: CHLocalized(key: "pmOk"), image: nil, actionType: .cancel, handler: nil)
            alert.actions = [okAction]
            alert.modalPresentationStyle = .overCurrentContext
            alert.modalTransitionStyle = .crossDissolve
            self.present(alert,animated: true,completion: nil)
            return
        }
        do {
            let audioData = try Data(contentsOf: audioUrl)
            if audioData.count > Int(CHCustomOptions.maximumAudioSize * 1024 * 1024) {
                self.showAttachmentSizeLimitError(messageError: "Please send audio file below 20 MB.")
                return
            }
            
            let uniqueId = UUID()
            let messageId = uniqueId.uuidString
            let senderName = Channelize.getCurrentUserDisplayName()
            let senderId = Channelize.getCurrentUserId()
            let senderImageUrl = Channelize.getCurrentUserProfileImageUrl() ?? ""
            let messageDate = Date()
            let messageStatus = BaseMessageStatus.sending
            
            let baseMessageData = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl, messageDate: messageDate, status: messageStatus)
            let audioMessageData = AudioMessageData(url: nil, duration: duration*1000)
            let audioMessageItem = AudioMessageItem(baseMessageModel: baseMessageData, audioData: audioMessageData)
            
            var apiAudioData: Data?
            if ChVirgilE3Kit.isEndToEndEncryptionEnabled {
                apiAudioData = try self.ethreeObject?.authEncrypt(data: audioData, for: self.myLookUpResults)
                audioMessageItem.isEncrypted = true
            } else {
                apiAudioData = audioData
                audioMessageItem.isEncrypted = false
            }
            
            let audioAttachmentQueryBuilder = CHAudioAttachmentQueryBuilder()
            audioAttachmentQueryBuilder.attachMentIdentifier = uniqueId
            audioAttachmentQueryBuilder.audioData = apiAudioData
            audioAttachmentQueryBuilder.duration = duration*1000
            audioAttachmentQueryBuilder.fileExtension = "m4a"
            audioAttachmentQueryBuilder.mimeType = "audio/m4a"
            
            let audioMessageQueryBuilder = CHMessageQueryBuilder()
            audioMessageQueryBuilder.id = messageId
            audioMessageQueryBuilder.body = nil
            if self.conversation?.id != nil {
                audioMessageQueryBuilder.conversationId = self.conversation?.id
            } else {
                audioMessageQueryBuilder.userId = self.conversation?.conversationPartner?.id
            }
            audioMessageQueryBuilder.messageType = .normal
            audioMessageQueryBuilder.ownerId = senderId
            audioMessageQueryBuilder.attachments = [audioAttachmentQueryBuilder]
            audioMessageQueryBuilder.isEncrypted = ChVirgilE3Kit.isEndToEndEncryptionEnabled
            audioMessageQueryBuilder.createdAt = messageDate
            self.noMessageContentView.removeFromSuperview()
            
            self.conversation?.lastReadDictionary?.updateValue(
                ISODateTransform().transformToJSON(messageDate) ?? "", forKey: Channelize.getCurrentUserId())
            self.conversation?.updateLastMessageOldestRead()
            
            let oldItems = self.chatItems.copy()
            self.chatItems.append(audioMessageItem)
            self.reprepareChatItems()
            let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
            self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                self.chatItems = data
            }, completion: {
                self.scrollToBottom(animated: true)
            })
            
            ChannelizeAPIService.sendMessage(queryBuilder: audioMessageQueryBuilder, uploadProgress: { _,_ in }, completion: {(message,errorString) in
                guard errorString == nil else {
                    return
                }
                if message != nil {
                    let oldItems = self.chatItems.copy()
                    audioMessageItem.messageStatus = .sent
                    audioMessageItem.audioData?.audioUrl = message?.attachments?.first?.fileUrl
                    let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
                    self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                        self.chatItems = data
                    })
                    if self.conversation?.id == nil {
                        self.getConversationWithId(conversationId: message?.conversationId)
                    }
                }
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Image Attachment Functions
    func openImageSelector() {
        let layout = UICollectionViewFlowLayout()
        let controller = AssetListController(collectionViewLayout: layout)
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func accessAssetImages(assetImages: [UIImage]) {
        for image in assetImages{
            if let fetchedData = image.jpegData(compressionQuality: 1.0){
                if let image = UIImage(data: fetchedData) {
                    self.createImageUploadRequest(with: image, messageId: UUID())
                }
            }
        }
    }
    
    func accessSelectedAssets(assets: [PHAsset]) {
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                var allAssets = assets
                for asset in allAssets{
                    let imageManager = PHImageManager.default()
                    let fetchOption = PHImageRequestOptions()
                    fetchOption.isSynchronous = false
                    fetchOption.isNetworkAccessAllowed = true
                    fetchOption.deliveryMode = .highQualityFormat
                    imageManager.requestImageData(for: asset, options: fetchOption, resultHandler: { (data,utiType,orientation,info) in
                        DispatchQueue.main.async {
                            if let imageData = data {
                                let imageExtension : ImageFormat = ImageFormat.get(from: imageData)
                                let messageId = UUID()
                                let imageName = "\(messageId.uuidString.lowercased()).\(imageExtension.rawValue)"
                                let fileName = self.getDocumentsDirectory().appendingPathComponent(imageName)
                                do {
                                    try imageData.write(to: fileName)
                                } catch {
                                    print(error.localizedDescription)
                                }
                                let originalImage = UIImage(contentsOfFile: fileName.path)
                                
                                let resources = PHAssetResource.assetResources(for: asset)
                                let resourceFileName = resources.first?.originalFilename ?? "\(UUID().uuidString).\(imageExtension.rawValue)"
                                let storageUrl = self.getDocumentsDirectory().appendingPathComponent(resourceFileName)
                                let imageFormat = ImageEncoder().get(from: imageData)
                                
                                let isImageEncoded = ImageEncoder().encodeImage(storageUrl: storageUrl, image: originalImage, format: imageFormat, maxPixelSize: CGSize(width: 1500, height: 1500))
                                
                                if isImageEncoded {
                                    if let encodedImage = UIImage(contentsOfFile: storageUrl.path) {
                                        do {
                                            try FileManager.default.removeItem(atPath: fileName.path)
                                            //try FileManager.default.removeItem(atPath: storageUrl.path)
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                        self.createImageUploadRequest(with: encodedImage, messageId: messageId)
                                    }
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    func createImageUploadRequest(with image: UIImage, messageId: UUID) {
        let thumbImage = createThumbsFromImage(image: image)
        let thumbnailData = thumbImage.pngData()!
        //let thumbnailData: Data?
        let imageData = image.jpegData(compressionQuality: 1.0)
        
        if imageData?.count ?? 0 > Int(CHCustomOptions.maximumImageSize * 1024 * 1024) {
            self.showAttachmentSizeLimitError(messageError: "Please send Photo file below 20 MB.")
            return
        }
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useBytes,.useKB,.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(imageData?.count ?? 0))
        print("Image Size is \(string)")
        let uniqueId = messageId
        let messageId = uniqueId.uuidString
        let senderName = Channelize.getCurrentUserDisplayName()
        let senderId = Channelize.getCurrentUserId()
        let senderImageUrl = Channelize.getCurrentUserProfileImageUrl() ?? ""
        let messageDate = Date()
        let messageStatus = BaseMessageStatus.sending
            
        let imageFormat : ImageFormat = ImageFormat.get(from: imageData ?? Data())
        let mimeType = imageFormat.contentType
        
        let baseMessageData = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl, messageDate: messageDate, status: messageStatus)
        
        SDImageCache.shared.store(image, forKey: messageId, toDisk: true, completion: nil)
        //SDImageCache.shared.store(image, forKey: messageId, completion: nil)
        
        
        let imageMessageData = ImageMessageData(imageUrlString: nil, imageSource: .local, localImage: nil)
        let imageMessageItem = ImageMessageItem(baseMessageModel: baseMessageData, imageMessageData: imageMessageData)
        
        var apiImageData: Data?
        var apiThumbNailData: Data?
        
        if ChVirgilE3Kit.isEndToEndEncryptionEnabled {
            do {
                apiImageData = try self.ethreeObject?.authEncrypt(data: imageData ?? Data(), for: self.myLookUpResults)
                apiThumbNailData = try self.ethreeObject?.authEncrypt(data: thumbnailData, for: self.myLookUpResults)
                imageMessageItem.isEncrypted = true
            } catch {
                print(error.localizedDescription)
            }
        } else {
            apiImageData = imageData
            apiThumbNailData = thumbnailData
            imageMessageItem.isEncrypted = false
        }
        
        let imageAttachmentQueryBuilder = CHImageAttachmentQueryBuilder()
        imageAttachmentQueryBuilder.attachMentIdentifier = uniqueId
        imageAttachmentQueryBuilder.fileExtension = imageFormat.rawValue
        imageAttachmentQueryBuilder.mimeType = mimeType
        imageAttachmentQueryBuilder.fileName = "\(self.randomString()).\(imageFormat.rawValue)"
        imageAttachmentQueryBuilder.imageData = apiImageData
        imageAttachmentQueryBuilder.thumbNailData = apiThumbNailData
        
        let imageMessageQueryBuilder = CHMessageQueryBuilder()
        imageMessageQueryBuilder.id = messageId
        imageMessageQueryBuilder.body = nil
        imageMessageQueryBuilder.isEncrypted = ChVirgilE3Kit.isEndToEndEncryptionEnabled
        if self.conversation?.id != nil {
            imageMessageQueryBuilder.conversationId = self.conversation?.id
        } else {
            imageMessageQueryBuilder.userId = self.conversation?.conversationPartner?.id
        }
        imageMessageQueryBuilder.messageType = .normal
        imageMessageQueryBuilder.ownerId = senderId
        imageMessageQueryBuilder.attachments = [imageAttachmentQueryBuilder]
        imageMessageQueryBuilder.createdAt = messageDate
        self.conversation?.lastReadDictionary?.updateValue(
            ISODateTransform().transformToJSON(messageDate) ?? "", forKey: Channelize.getCurrentUserId())
        self.conversation?.updateLastMessageOldestRead()
        
        self.noMessageContentView.removeFromSuperview()
        
        let oldItems = self.chatItems.copy()
        self.chatItems.append(imageMessageItem)
        self.reprepareChatItems()
        let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
        self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500}, setData: { data in
            self.chatItems = data
        }, completion: {
            self.scrollToBottom(animated: true)
        })
        
        ChannelizeAPIService.sendMessage(queryBuilder: imageMessageQueryBuilder, uploadProgress: { identifier,progress in
            if let firstIndex = self.chatItems.firstIndex(where: {
                $0.messageId == identifier?.uuidString
            }) {
                let indexPath = IndexPath(item: firstIndex, section: 0)
                let chatItem = self.chatItems[firstIndex] as? ImageMessageItem
                let oldProgress = chatItem?.uploadProgress
                chatItem?.uploadProgress = progress
                let cell = self.collectionView.cellForItem(at: indexPath) as? UIImageMessageCell
                cell?.updateProgress(fromValue: oldProgress ?? 0.0, toValue: progress ?? 0.0)
            }
        }, completion: {(message,errorString) in
            guard errorString == nil else {
                return
            }
            if message != nil {
                let oldItems = self.chatItems.copy()
                imageMessageItem.messageStatus = .sent
                imageMessageItem.imageMessageData?.localImage = nil
                imageMessageItem.imageMessageData?.imageUrlString = message?.attachments?.first?.fileUrl
                let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
                self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                    self.chatItems = data
                })
                if self.conversation?.id == nil {
                    self.getConversationWithId(conversationId: message?.conversationId)
                }
            }
        })
    }
    
    func randomString(length:Int = 6) -> String{
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    // MARK: - GIF and Sticker Search Controller
    func openGiphyStickerViewController() {
        let loadingVC = CHGiphStickerViewController()
        loadingVC.delegate = self
        self.addChild(loadingVC)
        self.view.addSubview(loadingVC.view)
        loadingVC.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 0)
        loadingVC.didMove(toParent: self)
        UIView.transition(with: loadingVC.view, duration: 0.33, options: [.transitionCrossDissolve,.curveEaseOut], animations: {
            loadingVC.view.frame.size.height = 330
            loadingVC.view.frame.origin.y = self.view.frame.height - 330
        }, completion: nil)
    }
    
    func didSelectMedia(type: GiphType, model: CHGiphImageModel) {
        let messageId = UUID().uuidString
        let senderName = Channelize.getCurrentUserDisplayName()
        let senderId = Channelize.getCurrentUserId()
        let senderImageUrl = Channelize.getCurrentUserProfileImageUrl() ?? ""
        let messageDate = Date()
        let messageStatus = BaseMessageStatus.sending
        
        let baseMessageData = BaseMessageModel(uid: messageId, senderId: senderId, senderName: senderName, senderImageUrl: senderImageUrl, messageDate: messageDate, status: messageStatus)
        let gifStickerData = GifStickerMessageData(stillUrl: model.stillUrl, downSampledUrl: model.downSampledUrl, originalUrl: model.originalUrl)
        let gifStickerMessageItem = GifStickerMessageItem(baseMessageModel: baseMessageData, gifStickerData: gifStickerData)
        
        let gifStickerMessageQueryBuilder = CHMessageQueryBuilder()
        gifStickerMessageQueryBuilder.id = messageId
        gifStickerMessageQueryBuilder.body = nil
        if self.conversation?.id != nil {
            gifStickerMessageQueryBuilder.conversationId = self.conversation?.id
        } else {
            gifStickerMessageQueryBuilder.userId = self.conversation?.conversationPartner?.id
        }
        gifStickerMessageQueryBuilder.messageType = .normal
        gifStickerMessageQueryBuilder.ownerId = senderId
        gifStickerMessageQueryBuilder.createdAt = messageDate
        if type == .gif {
            let gifAttachmentQueryBuilder = CHGifAttachmentQueryBuilder()
            gifAttachmentQueryBuilder.gifStillUrl = model.stillUrl
            gifAttachmentQueryBuilder.gifDownSampledUrl = model.downSampledUrl
            gifAttachmentQueryBuilder.gifOriginalUrl = model.originalUrl
            gifStickerMessageQueryBuilder.attachments = [gifAttachmentQueryBuilder]
        } else {
            let stickerAttachmentQueryBuilder = CHStickerAttachmentQueryBuilder()
            stickerAttachmentQueryBuilder.stickerStillUrl = model.stillUrl
            stickerAttachmentQueryBuilder.stickerDownSampledUrl = model.downSampledUrl
            stickerAttachmentQueryBuilder.stickerOriginalUrl = model.originalUrl
            gifStickerMessageQueryBuilder.attachments = [stickerAttachmentQueryBuilder]
        }
        
        self.conversation?.lastReadDictionary?.updateValue(
            ISODateTransform().transformToJSON(messageDate) ?? "", forKey: Channelize.getCurrentUserId())
        self.conversation?.updateLastMessageOldestRead()
        
        self.noMessageContentView.removeFromSuperview()
        
        let oldItems = self.chatItems.copy()
        self.chatItems.append(gifStickerMessageItem)
        self.reprepareChatItems()
        let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
        self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
            self.chatItems = data
        }, completion: {
            self.scrollToBottom(animated: true)
        })
        
        ChannelizeAPIService.sendMessage(queryBuilder: gifStickerMessageQueryBuilder, uploadProgress: { _,_ in }, completion: {(message,errorString) in
            guard errorString == nil else {
                return
            }
            if message != nil {
                let oldItems = self.chatItems.copy()
                gifStickerMessageItem.messageStatus = .sent
                let changeSet = StagedChangeset(source: oldItems, target: self.chatItems)
                self.collectionView.reload(using: changeSet, interrupt: { $0.changeCount > 500 }, setData: { data in
                    self.chatItems = data
                })
                if self.conversation?.id == nil {
                    self.getConversationWithId(conversationId: message?.conversationId)
                }
            }
        })
    }
    
    private func showAttachmentSizeLimitError(messageError: String?) {
        let errorAlertController = CHAlertViewController()
        errorAlertController.alertTitle = CHLocalized(key: "pmError")
        errorAlertController.alertDescription = messageError
        
        let okAction = CHActionSheetAction(title: CHLocalized(key: "pmOk"), image: nil, actionType: .cancel, handler: nil)
        errorAlertController.actions = [okAction]
        errorAlertController.modalTransitionStyle = .crossDissolve
        errorAlertController.modalPresentationStyle = .overCurrentContext
        self.present(errorAlertController, animated: true, completion: nil)
    }
    
}

enum CoreGraphics {
    static func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
        precondition(size != .zero)

        guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            return nil
        }
        print(image.height)
        print(image.width)
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: image.bitsPerComponent,
                                bytesPerRow: image.bytesPerRow,
                                space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: image.bitmapInfo.rawValue)
        context?.interpolationQuality = .high
        context?.draw(image, in: CGRect(origin: .zero, size: size))
        
        guard let scaledImage = context?.makeImage() else { return nil }
        
        return UIImage(cgImage: scaledImage)
    }
}

enum UIKit {
    static func resizedImage(image: UIImage, for size: CGSize) -> UIImage? {
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

enum ImageFormat: String {
    case png, jpg, gif, tiff, webp, heic, unknown
}

extension ImageFormat {
    static func get(from data: Data) -> ImageFormat {
        switch data[0] {
        case 0x89:
            return .png
        case 0xFF:
            return .jpg
        case 0x47:
            return .gif
        case 0x49, 0x4D:
            return .tiff
        case 0x52 where data.count >= 12:
            let subdata = data[0...11]
            
            if let dataString = String(data: subdata, encoding: .ascii),
                dataString.hasPrefix("RIFF"),
                dataString.hasSuffix("WEBP")
            {
                return .webp
            }
            
        case 0x00 where data.count >= 12 :
            let subdata = data[8...11]
            
            if let dataString = String(data: subdata, encoding: .ascii),
                Set(["heic", "heix", "hevc", "hevx"]).contains(dataString)
                ///OLD: "ftypheic", "ftypheix", "ftyphevc", "ftyphevx"
            {
                return .heic
            }
        default:
            break
        }
        return .unknown
    }
    
    var contentType: String {
        return "image/\(rawValue)"
    }
}



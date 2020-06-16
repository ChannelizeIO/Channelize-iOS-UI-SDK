//
//  CHConversationViewController.swift
//  ChannelizeUI
//
//  Created by bigstep on 6/9/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import DifferenceKit
import InputBarAccessoryView
import ObjectMapper
import MapKit
import AVFoundation
import Photos
import SDWebImage

class CHConversationViewController: UIViewController, UIGestureRecognizerDelegate {

    var headerView: CHConversationHeaderView = {
        let view = CHConversationHeaderView()
        view.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.conversationHeaderBackGroundColor : CHLightThemeColors.conversationHeaderBackGroundColor
        return view
    }()
    
    var blockStatusView: CHConversationBlockStatusView = {
        let view = CHConversationBlockStatusView()
        view.backgroundColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.conversationHeaderBackGroundColor : CHLightThemeColors.conversationHeaderBackGroundColor
        view.hideAllViews()
        return view
    }()
    
    var noMessageContentView: NoMessageView = {
        let view = NoMessageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var inputBar: InputTextBarView = {
        let inputBar = InputTextBarView()
        inputBar.addTopBorder(with: CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.seperatorColor : CHLightThemeColors.instance.seperatorColor, andWidth: 1.0)
        return inputBar
    }()
    
    var selectedMessageCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = CHUIConstant.recentConversationTitleColor
        label.textAlignment = .center
        label.font = UIFont(fontStyle: .medium, size: 17.0)
        label.backgroundColor = .clear
        return label
    }()
    
    open lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.inputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        return manager
    }()
    
    var topStackViewContainer: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white
        return view
    }()
    
    var moveToBottomButton: SimpleFloatingActionButton = {
        let button = SimpleFloatingActionButton()
        button.rippleColor = UIColor.white
        button.rippleBackgroundColor = UIColor(hex: "#1c1c1c")
        return button
    }()
    
    var loaderView: MessageLoaderView = {
        let view = MessageLoaderView()
        return view
    }()
    
    var keyBoardManager: KeyboardManager?
    var keyboardHeight: CGFloat = 0
    var isShowingKeyboard = false
    var isShowingGifStickerView = false
    
    // Mark: - SubViews Constraints
    var inputBarBottomConstraint: NSLayoutConstraint!
    var inputBarHeightConstraint: NSLayoutConstraint!
    var topStackContainerHeightConstraint: NSLayoutConstraint!
    var autoCompleteTableHeightConstraint: NSLayoutConstraint!
    
    var collectionView: UICollectionView!
    
    var conversation: CHConversation?
    var screenIdentifier = UUID()
    let calendar = Calendar.current
    var isLoadingMessage = false
    var isLoadingInitialMessage = true
    var currentOffset = 0
    var canloadMoreMessage = false
    var messageApiCallLimit = 50
    
    var noMessageView = UIView()
    
    var chatItems = [ChannelizeChatItem]()
    
    var isMessageSelectorOn = false
    var selectedMessages = [String]()
    var deleteMessageToolBarButton: UIBarButtonItem!
    var forwardMessageToolBarButton: UIBarButtonItem!
    
    
    lazy var audioModel: AudioMessageItem? = nil
    lazy var audioPlayer: AVAudioPlayer? = nil
    lazy var audioProgressTimer:Timer? = nil
    
    var recordingSession : AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    var isAudioPermissionAllowed : Bool = false
    
    var currentDocPreviewUrl: URL!
    var currentQuotedModel: QuotedViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1a1a1a") : UIColor.white
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // Add Delegates For MQTT Events
        Channelize.addUserEventDelegate(delegate: self, identifier: self.screenIdentifier)
        Channelize.addConversationEventDelegate(delegate: self, identifier: self.screenIdentifier)
        
        self.keyBoardManager = KeyboardManager()
        self.configureKeyBoardManager()
        
        self.configureHeaderView()
        self.configureInputTextBar()
        self.configureCollectionView()
        self.configureBlockStatusView()
        self.configureAutoCompleter()
        self.configureBottomViewTopStackContainer()
        self.setupTapGestureRecognizer()
        if self.conversation?.id == nil {
            ChannelizeAPIService.getConversationWithUser(userId: self.conversation?.conversationPartner?.id ?? "", completion: {(conversation,errorString) in
                self.conversation = conversation
                ChannelizeAPIService.joinReactionsSubscribers(conversationId: self.conversation?.id ?? "")
                self.headerView.updateBlockStatus(conversation: self.conversation)
                self.blockStatusView.updateBlockStatusView(conversation: self.conversation)
                self.getMessages()
            })
        } else {
            ChannelizeAPIService.joinReactionsSubscribers(conversationId: self.conversation?.id ?? "")
            if self.conversation?.members == nil {
                self.getConversationMembers()
            } else {
                self.headerView.updateBlockStatus(conversation: self.conversation)
                self.blockStatusView.updateBlockStatusView(conversation: self.conversation)
            }
            self.getMessages()
        }
        self.view.addSubview(moveToBottomButton)
        self.moveToBottomButton.addTarget(self, action: #selector(moveToBottom), for: .touchUpInside)
        self.moveToBottomButton.isHidden = true
        
        self.view.addSubview(loaderView)
        self.loaderView.frame.size = CGSize(width: 50, height: 50)
        self.loaderView.center.x = self.view.center.x
        self.loaderView.center.y = self.view.frame.height/2 - 50
        self.loaderView.setUpViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isMovingToParent {
            if self.conversation?.id != nil {
                self.getConversationMembers()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            ChUI.instance.chCurrentChatId = nil
            self.keyBoardManager = nil
            self.audioPlayer?.stop()
            self.audioPlayer = nil
            self.audioModel = nil
            self.audioRecorder?.stop()
            self.audioRecorder = nil
            self.tabBarController?.tabBar.isHidden = false
            Channelize.removeUserEventDelegate(identifier: self.screenIdentifier)
            Channelize.removeConversationDelegate(identifier: self.screenIdentifier)
            ChannelizeAPIService.leaveReactionsSubscribers(conversationId: self.conversation?.id ?? "")
        }
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    @objc func moveToBottom(){
        self.scrollToBottom(animated: false)
    }
    
    // MARK: - Configure Header View
    private func configureHeaderView() {
        self.navigationItem.titleView = self.headerView
        self.headerView.assignData(conversation: self.conversation)
        self.headerView.backButtonPressed = {
            self.navigationController?.popViewController(animated: true)
        }
        
        // When Voice Call Button is Pressed in Header View
        self.headerView.voiceCallButtonPressed = {
            let bundleUrl = Bundle.url(forResource: "ChannelizeCall", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
            let bundle = Bundle(url: bundleUrl!)
            bundle?.load()
            let aClass : AnyClass? = NSClassFromString("ChannelizeCall.CHCall")
            if let callMainClass = aClass as? CallSDKDelegates.Type{
                if let unwrappedUser = self.conversation?.conversationPartner {
                    callMainClass.launchCallViewController(navigationController: self.navigationController, user: unwrappedUser, type: CHCallScreen.voice.rawValue)
                }
            }
        }
        
        // When Video Call Button is Pressed in Header View
        self.headerView.videoCallButtonPressed = {
            let bundleUrl = Bundle.url(forResource: "ChannelizeCall", withExtension: "framework", subdirectory: "Frameworks", in: Bundle.main.bundleURL)
            let bundle = Bundle(url: bundleUrl!)
            bundle?.load()
            let aClass : AnyClass? = NSClassFromString("ChannelizeCall.CHCall")
            if let callMainClass = aClass as? CallSDKDelegates.Type{
                if let unwrappedUser = self.conversation?.conversationPartner {
                    callMainClass.launchCallViewController(navigationController: self.navigationController, user: unwrappedUser, type: CHCallScreen.video.rawValue)
                }
            }
        }
        
        // When Menu Button Is pressed
        self.headerView.menuButtonPressed = {
            self.view.endEditing(true)
            let deleteConversationAction = CHActionSheetAction(title: CHLocalized(key: "pmDeleteConversation"), image: nil, actionType: .destructive, handler: {[weak self](action) in
                
                
                let chAlert = CHAlertViewController()
                chAlert.alertTitle = CHLocalized(key: "pmDeleteConversation")
                chAlert.alertDescription = CHLocalized(key: "pmDeleteConversationAlert")
                let deleteAction = CHActionSheetAction(title: CHLocalized(key: "pmDelete"), image: nil, actionType: .destructive, handler: {[weak self](action) in
                    self?.deleteConversation()
                })
                let cancelAction = CHActionSheetAction(title: CHLocalized(key: "pmCancel"), image: nil, actionType: .cancel, handler: nil)
                chAlert.actions = [deleteAction,cancelAction]
                chAlert.modalPresentationStyle = .overCurrentContext
                chAlert.modalTransitionStyle = .crossDissolve
                self?.present(chAlert, animated: true, completion: nil)
                
            })
            
            
            let clearConversation = CHActionSheetAction(title: CHLocalized(key: "pmClearConversation"), image: nil, actionType: .default, handler: {[weak self](action) in
                
                
                let chAlert = CHAlertViewController()
                chAlert.alertTitle = CHLocalized(key: "pmClearConversation")
                chAlert.alertDescription = CHLocalized(key: "pmClearConversationAlert")
                let clearAction = CHActionSheetAction(title: CHLocalized(key: "pmClearConversation"), image: nil, actionType: .default, handler: {[weak self](action) in
                    self?.clearConversation()
                })
                let cancelAction = CHActionSheetAction(title: CHLocalized(key: "pmCancel"), image: nil, actionType: .cancel, handler: nil)
                chAlert.actions = [clearAction,cancelAction]
                chAlert.modalPresentationStyle = .overCurrentContext
                chAlert.modalTransitionStyle = .crossDissolve
                self?.present(chAlert, animated: true, completion: nil)
                
            })
            
            
            let blockUserAction = CHActionSheetAction(title: CHLocalized(key: "pmBlockUser"), image: nil, actionType: .default, handler: {[weak self](action) in
                self?.blockUser()
            })
            
            
            let unblockUserAction = CHActionSheetAction(title: CHLocalized(key: "pmUnblock"), image: nil, actionType: .default, handler: {[weak self](action) in
                self?.unblockUser()
            })
            
            
            let muteConversation = CHActionSheetAction(title: CHLocalized(key: "pmMuteConversation"), image: nil, actionType: .default, handler: {[weak self](action) in
                self?.muteUnMuteConversation()
            })
            
            let unmuteConversation = CHActionSheetAction(title: CHLocalized(key: "pmUnmuteConversation"), image: nil, actionType: .default, handler: {[weak self](action) in
                self?.muteUnMuteConversation()
            })
            
            
            let viewProfileAction = CHActionSheetAction(title: CHLocalized(key: "pmViewProfile"), image: nil, actionType: .default, handler: {[weak self](action) in
                if self?.conversation?.isGroup == true {
                    let groupProfileController = CHGroupProfileViewController()
                    groupProfileController.conversation = Mapper<CHConversation>().map(JSON: self?.conversation?.toJSON() ?? [:])
                    groupProfileController.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(groupProfileController, animated: true)
                } else {
                    let userProfileController = CHUserProfileViewController()
                    userProfileController.hidesBottomBarWhenPushed = true
                    userProfileController.conversation = Mapper<CHConversation>().map(JSON: self?.conversation?.toJSON() ?? [:])
                    userProfileController.user = self?.conversation?.conversationPartner
                    self?.navigationController?.pushViewController(userProfileController, animated: true)
                }
            })
            var controllerActions = [CHActionSheetAction]()
            controllerActions.append(viewProfileAction)
            controllerActions.append(clearConversation)
            controllerActions.append(deleteConversationAction)
            if self.conversation?.isGroup == false {
                if self.conversation?.members?.count ?? 0 < 2 {
                    if self.conversation?.members?.contains(where: {
                        $0.user?.id == Channelize.getCurrentUserId()
                    }) == true {
                        controllerActions.append(blockUserAction)
                    } else {
                        controllerActions.append(unblockUserAction)
                    }
                } else {
                    controllerActions.append(blockUserAction)
                }
            }
            if self.conversation?.isMute == true {
                controllerActions.append(unmuteConversation)
            } else {
                controllerActions.append(muteConversation)
            }
            
            let controller = CHActionSheetController()
            controller.modalPresentationStyle = .overFullScreen
            controller.modalTransitionStyle = .crossDissolve
            controller.actions = controllerActions
            self.present(controller, animated: true, completion: nil)
            
        }
        self.headerView.onInfoContainerPressed = {
            if self.conversation?.isGroup == true {
                let profileViewController = CHGroupProfileViewController()
                profileViewController.conversation = Mapper<CHConversation>().map(JSON: self.conversation?.toJSON() ?? [:])
                self.navigationController?.pushViewController(profileViewController, animated: true)
            } else {
                let profileViewController = CHUserProfileViewController()
                profileViewController.user = self.conversation?.conversationPartner
                self.navigationController?.pushViewController(profileViewController, animated: true)
            }
        }
        
        self.headerView.onDonebuttonPressed = {
            self.setMessageSelectorOff()
        }
    }
    
    
    // MARK: - Configure CollectionView
    private func configureCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.backgroundColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#0c0c0c") : UIColor.white
        self.collectionView.showsHorizontalScrollIndicator = true
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate.normal
        self.collectionView.allowsSelection = false
        self.collectionView.indicatorStyle = CHAppConstant.themeStyle == .dark ? .white : .black
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset.bottom = 20
        self.collectionView.contentInset.top = 15
        self.collectionView.tintColor = .white
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.register(UITextMessageCell.self, forCellWithReuseIdentifier: "textMessageCell")
        self.collectionView.register(UIGifStickerMessageCell.self, forCellWithReuseIdentifier: "gifStickerMessageCell")
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "undefinedCell")
        self.collectionView.register(UILocationMessageCell.self, forCellWithReuseIdentifier: "locationMessageCell")
        self.collectionView.register(UIAudioMessageCell.self, forCellWithReuseIdentifier: "audioMessageCell")
        self.collectionView.register(UIVideoMessageCell.self, forCellWithReuseIdentifier: "videoMessageCell")
        self.collectionView.register(UIImageMessageCell.self, forCellWithReuseIdentifier: "imageMessageCell")
        self.collectionView.register(UIDocMessageCell.self, forCellWithReuseIdentifier: "docMessageCell")
        self.collectionView.register(CHMetaMessageCell.self, forCellWithReuseIdentifier: "metaMessageCell")
        self.collectionView.register(UIQuotedMessageCell.self, forCellWithReuseIdentifier: "quotedMessageCell")
        self.collectionView.register(UILinkPreviewMessageCell.self, forCellWithReuseIdentifier: "linkPreviewMessageCell")
        
        
        self.view.addSubview(self.collectionView)
        self.collectionView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.collectionView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.collectionView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
        self.collectionView.setBottomAnchor(relatedConstraint: self.inputBar.topAnchor, constant: 0)
    }
    
    // MARK: - Configure Input Bar
    private func configureInputTextBar() {
        self.view.addSubview(inputBar)
        self.inputBar.delegate = self
        self.inputBar.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.inputBar.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.inputBarHeightConstraint = NSLayoutConstraint(item: self.inputBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50)
        self.inputBarHeightConstraint.isActive = true
        self.inputBarBottomConstraint = NSLayoutConstraint(item: self.inputBar, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0)
        self.inputBarBottomConstraint.isActive = true
        self.view.addConstraints([self.inputBarBottomConstraint,self.inputBarHeightConstraint])
        
        self.inputBar.onMicButtonPressed = {
            self.openAudioRecordingView()
        }
        
        self.inputBar.onAttachmentButtonPressed = {
            self.view.endEditing(true)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            let photoAction = CHActionSheetAction(title: "Share Photos", image: nil, actionType: .default, handler: {(action) in
                self.openImageSelector()
            })
            
            let videoAction = CHActionSheetAction(title: "Share Video", image: nil, actionType: .default, handler: {(action) in
                self.openVideoPicker()
            })
            
            let documentAction = CHActionSheetAction(title: "Share Document", image: nil, actionType: .default, handler: {(action) in
                self.openDocumentPicker()
            })
            
            let locationAction = CHActionSheetAction(title: "Share Location", image: nil, actionType: .default, handler: {(action) in
                self.openLocationSelectController()
            })
            
            let gifStickerAction = CHActionSheetAction(title: "Share Stickers and GIFs", image: nil, actionType: .default, handler: {(action) in
                self.openGiphyStickerViewController()
            })
            
            var actionSheetActions = [CHActionSheetAction]()
            if CHCustomOptions.enableImageMessages {
                actionSheetActions.append(photoAction)
            }
            if CHCustomOptions.enableVideoMessages {
                actionSheetActions.append(videoAction)
            }
            if CHCustomOptions.enableDocSharingMessage {
                actionSheetActions.append(documentAction)
            }
            if CHCustomOptions.enableLocationMessages {
                actionSheetActions.append(locationAction)
            }
            if CHCustomOptions.enableStickerAndGifMessages {
                actionSheetActions.append(gifStickerAction)
            }
            let controller = CHActionSheetController()
            controller.actions = actionSheetActions
            controller.modalPresentationStyle = .overCurrentContext
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        }
    }

    // MARK: - Configure KeyBoard Manger
    private func configureKeyBoardManager() {
        self.keyBoardManager?.on(event: .willShow, do: {[weak self] notification in
            if let strongSelf = self {
                if strongSelf.isShowingKeyboard == false {
                    strongSelf.isShowingKeyboard = true
                    strongSelf.moveToBottomButton.frame.origin.y = strongSelf.view.frame.height - notification.endFrame.height - 130
                    strongSelf.keyboardHeight = notification.endFrame.height
                    UIView.animate(withDuration: notification.timeInterval, animations: {
                        strongSelf.inputBarBottomConstraint.constant = -strongSelf.keyboardHeight
                        var lastYOffset = strongSelf.collectionView.contentOffset.y
                        lastYOffset = lastYOffset + notification.endFrame.height - strongSelf.inputBarBottomConstraint.constant
                        strongSelf.collectionView.setContentOffset(CGPoint(x: 0, y: lastYOffset), animated: false)
                        strongSelf.view.layoutIfNeeded()
                    })
                }
            }
        }).on(event: .willHide, do: {[weak self] notification in
            if let strongSelf = self {
                var lastYOffset = strongSelf.collectionView.contentOffset.y
                lastYOffset = lastYOffset - strongSelf.keyboardHeight - strongSelf.inputBarBottomConstraint.constant
                strongSelf.collectionView.setContentOffset(CGPoint(x: 0, y: lastYOffset), animated: false)
                strongSelf.moveToBottomButton.frame.origin.y = strongSelf.view.frame.height - 120
                UIView.animate(withDuration: notification.timeInterval, animations: {
                    strongSelf.inputBarBottomConstraint.constant = 0
                    strongSelf.isShowingKeyboard = false
                    strongSelf.keyboardHeight = 0
                    strongSelf.view.layoutIfNeeded()
                })
            }
        })
    }
    
    // MARK: - Configure Block Status View
    private func configureBlockStatusView() {
        self.view.addSubview(blockStatusView)
        self.blockStatusView.isHidden = true
        self.blockStatusView.setHeightAnchor(constant: 50)
        self.blockStatusView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.blockStatusView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.blockStatusView.setBottomAnchor(relatedConstraint: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
    }
    
    // MARK: - Configure Input Bar Top Stack
    func configureBottomViewTopStackContainer() {
        self.view.addSubview(topStackViewContainer)
        self.topStackViewContainer.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.topStackViewContainer.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.topStackViewContainer.setBottomAnchor(relatedConstraint: self.inputBar.topAnchor, constant: 0)
        self.topStackContainerHeightConstraint = NSLayoutConstraint(item: self.topStackViewContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0)
        self.topStackContainerHeightConstraint.isActive = true
        self.view.addConstraint(topStackContainerHeightConstraint)
    }
    
    // MARK:- Other Functions
    private func setupTapGestureRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(userDidTapOnCollectionView))
        gesture.delegate = self
        self.collectionView.addGestureRecognizer(gesture)
    }
    
    @objc func userDidTapOnCollectionView() {
        self.view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

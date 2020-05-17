//
//  UIConversationViewController.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/26/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import AVFoundation
import InputBarAccessoryView
import ObjectMapper

class UIConversationViewController: ChannelizeController {

    lazy var audioModel: AudioMessageModel? = nil
    lazy var audioPlayer: AVAudioPlayer? = nil
    lazy var audioProgressTimer:Timer? = nil
    
    var selectedMessages = [String]()
    
    var recordingSession : AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    var isAudioPermissionAllowed : Bool = false
    
    var currentQuotedModel: QuotedViewModel?
    
    internal var seconds = 0
    internal var timer:Timer?
    var isTyping = false
    
    var keyboardManager : KeyboardManager?
    var keyboardHeight: CGFloat = 0
    var isShowingKeyboard = false
    var isShowingGifStickerView = false
    
    var deleteMessageToolBarButton: UIBarButtonItem!
    var forwardMessageToolBarButton: UIBarButtonItem!
    
    var isMessageSelectorOn = false
    var conversationId: String?
    var plusButton: SimpleFloatingActionButton = {
        let button = SimpleFloatingActionButton()
        return button
    }()
    
    var selectedMessageCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont(fontStyle: .robotoSlabMedium, size: 17.0)
        label.backgroundColor = .clear
        return label
    }()
    
    var quotedMessageViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    open lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.textInputBarView.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        return manager
    }()
    
    var gifStickerSelectorView: GiphyStickerView = {
        let view = GiphyStickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var audioRecorderView: AudioCaptureView = {
        let view = AudioCaptureView()
        view.backgroundColor = CHUIConstants.appDefaultColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var conversationHeaderView: ConversationHeaderView = {
        let view = ConversationHeaderView()
        return view
    }()
    
    var textViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var textInputBarView: CHInputTextBarView = {
        let view = CHInputTextBarView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var blockStatusView: BlockStatusView = {
        let view = BlockStatusView()
        view.backgroundColor = CHUIConstants.appDefaultColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var topStackViewContainer: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .vertical
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var attachmentOptionViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var attachmentOptionView: ConversationAttachmentView = {
        let view = ConversationAttachmentView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var textViewContainerHeightConstraint: NSLayoutConstraint!
    var textViewContainerBottomConstraint: NSLayoutConstraint!
    var topStackContainerHeightConstraint: NSLayoutConstraint!
    var autoCompleteTableHeightConstraint: NSLayoutConstraint!
    
    var collectionView: UICollectionView!
    
    var isLoadingMessage = true
    var isLoadingInitialMessage = true
    var currentOffset = 0
    var canloadMoreMessage = true
    let calendar = Calendar.current
    
    var conversation: CHConversation?
    var user: CHUser?
    var chatItems = [BaseMessageItemProtocol]()
    
    var currentDocPreviewUrl: URL!
    var screenIdentifier: UUID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.edgesForExtendedLayout = []
        self.view.backgroundColor = .white
        //definesPresentationContext = true
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.titleView = conversationHeaderView
        
        self.screenIdentifier = UUID()
        ChannelizeAPI.addConversationEventDelegate(delegate: self, identifier: self.screenIdentifier)
        ChannelizeAPI.addUserEventDelegate(delegate: self, identifier: self.screenIdentifier)
        
        self.configureHeaderView()
        self.conversationHeaderView.onBackButtonPressed = {[weak self] (sender) in
            self?.backButtonPressed()
        }
        self.conversationHeaderView.onVideoCallButtonPressed = {[weak self](sender) in
            self?.callButtonPressed(callType: .video)
        }
        self.conversationHeaderView.onVoiceCallButtonPressed = {[weak self](sender) in
            self?.callButtonPressed(callType: .voice)
        }
        self.conversationHeaderView.onMenuButtonPressed = {[weak self](sender) in
            self?.menuButtonPressed()
        }
        self.conversationHeaderView.onInfoContainerViewPressed = {[weak self] (gesture) in
            self?.infoViewTapped()
        }
        self.conversationHeaderView.onDoneButtonPressed = {[weak self](sender) in
            self?.doneButtonPressed()
        }
        //self.configureCollectionView()
        
//        let realm = RealmService.shared.realm
//        let objects = realm.objects(CHRealmMessageModel.self).filter("conversationId == %@", self.conversation?.id ?? "")
//        let sortedObjects = objects.sorted(byKeyPath: "createdAt", ascending: false)
//        if sortedObjects.count > 0 {
//            self.isLoadingInitialMessage = false
//            DispatchQueue.main.async {
//                autoreleasepool {
//                    if sortedObjects.count > 0 {
//                        var savedMessages = [CHMessage]()
//                        sortedObjects.forEach({
//                            let realmMessage = $0
//                            if let message = Mapper<CHMessage>().map(JSON: realmMessage.toJSON()) {
//                                savedMessages.append(message)
//                            }
//                        })
//
//                        self.prepareNormalMessageItems(with: savedMessages, isInitialLoad: true)
//                    }
//                }
//            }
//        }
        self.configureCollectionView()
        self.setUpViews()
        if self.conversation != nil {
            ChannelizeUI.instance.chCurrentChatId = self.conversation?.id
            ChannelizeAPIService.joinReactionsSubscribers(conversationId: self.conversation?.id ?? "")
//            self.configureCollectionView()
//            self.setUpViews()
            self.configureTextInputBar()
            self.configureKeyBoardManager()
            self.setupTapGestureRecognizer()
            self.getConversationMessages(offset: 0)
            self.updateBlockViewStatus()
        } else if let chatId = self.conversationId {
            ChannelizeAPIService.getConversationWithId(conversationId: chatId, completion: {(conversation,errorString) in
                if let recievedConversation = conversation {
                    self.conversation = recievedConversation
                    ChannelizeAPIService.joinReactionsSubscribers(conversationId: self.conversation?.id ?? "")
                    self.user = recievedConversation.conversationPartner
                    self.configureHeaderView()
                    self.configureTextInputBar()
                    self.configureKeyBoardManager()
                    self.setupTapGestureRecognizer()
                    self.getConversationMessages(offset: 0)
                    self.updateBlockViewStatus()
                    ChannelizeUI.instance.chCurrentChatId = self.conversation?.id
                }
            })
        }
        
        self.view.addSubview(plusButton)
        self.plusButton.addTarget(self, action: #selector(moveToBottom), for: .touchUpInside)
        self.plusButton.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            ChannelizeUI.instance.chCurrentChatId = nil
            self.keyboardManager = nil
            self.audioPlayer?.stop()
            self.audioPlayer = nil
            self.audioModel = nil
            self.audioRecorder?.stop()
            self.audioRecorder = nil
            self.tabBarController?.tabBar.isHidden = false
            ChannelizeAPI.removeUserEventDelegate(identifier: self.screenIdentifier)
            ChannelizeAPI.removeConversationDelegate(identifier: self.screenIdentifier)
            ChannelizeAPIService.leaveReactionsSubscribers(conversationId: self.conversation?.id ?? "")
        }
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true;
        if self.isMessageSelectorOn {
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
        if isMovingToParent {
            if self.conversation == nil {
                if self.user != nil {
                    //showProgressView(superView: self.view, string: nil)
                    ChannelizeAPIService.getConversationWithUser(
                        userId: self.user?.id ?? "", completion: {(conversation,errorString) in
                        //disMissProgressView()
                        guard errorString == nil else {
                            showProgressErrorView(superView: self.view, errorString: errorString)
                            return
                        }
                        if let recievedConversation = conversation {
                            ChannelizeUI.instance.chCurrentChatId = recievedConversation.id
                            self.conversation = recievedConversation
                            ChannelizeAPIService.joinReactionsSubscribers(conversationId: self.conversation?.id ?? "")
                            self.configureTextInputBar()
                            self.configureKeyBoardManager()
                            self.setupTapGestureRecognizer()
                            self.getConversationMessages(offset: 0)
                            self.updateBlockViewStatus()
                            
                        }
                    })
                } else {
                    //fatalError("Wrong Chat Screen Opens")
                }
            }
        }
    }
    
    // MARK:- Collection View Configure Functions
    func configureCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.backgroundColor = UIColor(hex: "#ffffff")
        self.collectionView.showsHorizontalScrollIndicator = true
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate.normal
        self.collectionView.allowsSelection = false
        self.collectionView.indicatorStyle = .default
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset.bottom = 20
        self.collectionView.contentInset.top = 15
        self.collectionView.tintColor = .white
        self.collectionView.alwaysBounceVertical = true
        
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCell")
        self.collectionView.register(NoMessageCollectionCell.self, forCellWithReuseIdentifier: "noConversationMessageCell")
        self.collectionView.register(CHImageMessageCell.self, forCellWithReuseIdentifier: "newImageMessageCell")
        self.collectionView.register(CHGifStickerMessageCell.self, forCellWithReuseIdentifier: "newGifStickerMessageCell")
        self.collectionView.register(CHTextMessageCell.self, forCellWithReuseIdentifier: "newTextMessageCell")
        self.collectionView.register(CHVideoMessageCell.self, forCellWithReuseIdentifier: "newVideoMessageCell")
        self.collectionView.register(CHLocationMessageCell.self, forCellWithReuseIdentifier: "newLocationMessageCell")
        self.collectionView.register(CHAudioMessageCell.self, forCellWithReuseIdentifier: "newAudioMessageCell")
        self.collectionView.register(CHGroupedPhotosCell.self, forCellWithReuseIdentifier: "newGroupedImageCell")
        self.collectionView.register(UnReadMessageHeaderCell.self, forCellWithReuseIdentifier: "unreadMessageCell")
        self.collectionView.register(CHQuotedMessageCell.self, forCellWithReuseIdentifier: "newQuotedMessageCell")
        self.collectionView.register(PhotoMessageShimmeringCell.self, forCellWithReuseIdentifier: "shimmeringMessageCell")
        self.collectionView.register(CHMissCallMessageCell.self, forCellWithReuseIdentifier: "missCallMessageCell")
        self.collectionView.register(CHDocMessageCell.self, forCellWithReuseIdentifier: "docMessageCell")
        self.collectionView.register(UIMetaMessageCell.self, forCellWithReuseIdentifier: "metaMessageCell")
        self.collectionView.register(LinkPreviewCollectionCell.self, forCellWithReuseIdentifier: "linkPreviewCell")
       
        self.collectionView.register(
            LinkPreviewCollectionCell.self, forCellWithReuseIdentifier: "linkPreviewCell")
    }
    
    private func setUpViews() {
        self.view.addSubview(self.collectionView)
        self.view.addSubview(textViewContainer)
        self.view.addSubview(topStackViewContainer)
        
        self.textViewContainer.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.textViewContainer.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.textViewContainerBottomConstraint = NSLayoutConstraint(item: self.textViewContainer, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0)
        self.textViewContainerBottomConstraint.isActive = true
        self.view.addConstraint(self.textViewContainerBottomConstraint)
        
        self.textViewContainerHeightConstraint = NSLayoutConstraint(item: self.textViewContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50)
        self.textViewContainerHeightConstraint.isActive = true
        self.view.addConstraint(self.textViewContainerHeightConstraint)
        
        
        self.topStackViewContainer.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.topStackViewContainer.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.topStackViewContainer.setBottomAnchor(relatedConstraint: self.textViewContainer.topAnchor, constant: 0)
        self.topStackContainerHeightConstraint = NSLayoutConstraint(item: self.topStackViewContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0)
        self.topStackContainerHeightConstraint.isActive = true
        self.view.addConstraint(topStackContainerHeightConstraint)
        
        
        self.collectionView.setLeftAnchor(relatedConstraint: self.view.leftAnchor, constant: 0)
        self.collectionView.setRightAnchor(relatedConstraint: self.view.rightAnchor, constant: 0)
        self.collectionView.setTopAnchor(relatedConstraint: self.view.topAnchor, constant: 0)
        self.collectionView.setBottomAnchor(relatedConstraint: self.textViewContainer.topAnchor, constant: 0)
        self.collectionView.reloadData()
    }
    
    func updateBlockViewStatus() {
        if self.conversation?.isGroup == true {
            if self.conversation?.canReplyToConversation == false {
                self.blockStatusView.showGroupConversationStatusView()
                self.textViewContainer.addSubview(self.blockStatusView)
                self.blockStatusView.pinEdgeToSuperView(superView: self.textViewContainer)
                self.textViewContainerHeightConstraint.constant = 50
                self.view.layoutIfNeeded()
            } else {
                self.blockStatusView.removeFromSuperview()
                self.textViewContainerHeightConstraint.constant = 50
                self.view.layoutIfNeeded()
            }
        } else {
            if self.conversation?.isPartnerIsBlocked == true {
                self.conversationHeaderView.disableCallButtons()
                self.blockStatusView.showUserIsBlockedStatusView()
                self.textViewContainer.addSubview(self.blockStatusView)
                self.blockStatusView.pinEdgeToSuperView(superView: self.textViewContainer)
                self.textViewContainerHeightConstraint.constant = 50
                self.conversationHeaderView.updateConversationInfoView(
                    infoString: nil)
                self.view.layoutIfNeeded()
                
            } else if self.conversation?.isPartenerHasBlocked == true {
                self.conversationHeaderView.disableCallButtons()
                self.blockStatusView.showUserHasBlockedStatusView()
                self.textViewContainer.addSubview(self.blockStatusView)
                self.blockStatusView.pinEdgeToSuperView(superView: self.textViewContainer)
                self.textViewContainerHeightConstraint.constant = 50
                self.conversationHeaderView.updateConversationInfoView(
                infoString: nil)
                self.view.layoutIfNeeded()
            } else {
                self.conversationHeaderView.enableCallButtons()
                self.blockStatusView.removeFromSuperview()
                self.textViewContainerHeightConstraint.constant = 50
                if self.user?.isOnline == true {
                    self.conversationHeaderView.updateConversationInfoView(
                    infoString: "Online")
                } else {
                    self.conversationHeaderView.updateConversationInfoView(
                    infoString: getLastSeen(lastSeenDate: self.user?.lastSeen))
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Text View Input Bar Configure
    private func configureTextInputBar() {
        self.textViewContainer.addSubview(textInputBarView)
        self.textInputBarView.pinEdgeToSuperView(superView: self.textViewContainer)
        self.textInputBarView.delegate = self
        self.textInputBarView.buttonDelegate = self
        if self.conversation?.isGroup == true {
            configureAutoCompleter()
        }
    }

    // MARK:- Configure Keyboard Manager
    func configureKeyBoardManager() {
        self.keyboardManager = KeyboardManager()
        keyboardManager?.bind(inputAccessoryView: self.textInputBarView)
        
        // Add some extra handling to manage content inset
        keyboardManager?.on(event: .didChangeFrame) { (notification) in
            
            }.on(event: .willHide) { [weak self] (notification) in
                if let strongSelf = self {
                    var lastYOffset = strongSelf.collectionView.contentOffset.y
                    lastYOffset = lastYOffset - strongSelf.keyboardHeight - strongSelf.textViewContainerBottomConstraint.constant
                    strongSelf.collectionView.setContentOffset(CGPoint(x: 0, y: lastYOffset), animated: false)
                    strongSelf.textViewContainerBottomConstraint.constant = 0
                    strongSelf.plusButton.frame.origin.y = strongSelf.view.frame.height - 120
                    strongSelf.view.layoutIfNeeded()
                    strongSelf.isShowingKeyboard = false
                    strongSelf.keyboardHeight = 0
                }
                
            }.on(event: .willShow, do: {[weak self] (notification) in
                print(notification.endFrame.height)
                
                if let strongSelf = self {
                    if strongSelf.isShowingKeyboard == false {
                        strongSelf.isShowingKeyboard = true
                        strongSelf.plusButton.frame.origin.y = strongSelf.view.frame.height - notification.endFrame.height - 130
                        strongSelf.keyboardHeight = notification.endFrame.height
                        strongSelf.textViewContainerBottomConstraint.constant = -strongSelf.keyboardHeight
                        var lastYOffset = strongSelf.collectionView.contentOffset.y
                        lastYOffset = lastYOffset + notification.endFrame.height - strongSelf.textViewContainerBottomConstraint.constant
                        strongSelf.collectionView.setContentOffset(CGPoint(x: 0, y: lastYOffset), animated: false)
                        strongSelf.view.layoutIfNeeded()
                    }
                }
            })
    }
    
    // MARK:- Other Functions
    private func setupTapGestureRecognizer() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(userDidTapOnCollectionView))
        gesture.delegate = self
        self.collectionView.addGestureRecognizer(gesture)
//        self.view.addGestureRecognizer(
//            UITapGestureRecognizer(target: self, action: #selector(userDidTapOnCollectionView)))
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

extension UIConversationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

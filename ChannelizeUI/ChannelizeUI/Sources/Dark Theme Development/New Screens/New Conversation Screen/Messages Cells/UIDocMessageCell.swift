//
//  CHDocMessageCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/4/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialProgressView

class UIDocMessageCell: CHBaseMessageCell {
    
    private var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
        
    private var fileIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = getImage("chFileIcon")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()
        
    private var fileNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.backgroundColor = .clear
        label.font = UIFont(fontStyle: .medium, size: 14.5)
        return label
    }()
    
    private var dividerLine: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        return view
    }()
        
    private var fileTypeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont(fontStyle: .regular, size: 13.5)
        return label
    }()
    
    private var fileSizeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
        
    private var downloadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(getImage("icloudDownloadButton"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 3.5, left: 3.5, bottom: 3.5, right: 3.5)
        return button
    }()
    
    private var loadingIndicator: MDCActivityIndicator = {
        let indicator = MDCActivityIndicator()
        indicator.cycleColors = [.white]
        indicator.radius = 12.5
        return indicator
    }()
    
    private var openFileButton: UIButton = {
        let button = UIButton()
        button.setTitle("Open", for: .normal)
        button.titleLabel?.font = UIFont(fontStyle: .medium, size: 12.0)
        button.backgroundColor = .white
        button.setTitleColor(CHAppConstant.themeStyle == .dark ? UIColor(hex: "#1c1c1c") : UIColor.white, for: .normal)
        button.layer.masksToBounds = true
        return button
    }()
        
    var reactionButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setImage(getImage("chReactionIcon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = UIColor(hex: "#c5c5c5")
        button.imageView?.layer.masksToBounds = true
        return button
    }()
    
    var messageStatusViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var messageTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(fontStyle: .regular, size: 11.0)
        label.textAlignment = .right
        label.textColor = CHAppConstant.themeStyle == .dark ? UIColor.white : UIColor(hex: "#8b8b8b")
        return label
    }()
    
    var messageStatusView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    var docMessageModel: DocMessageItem?
    
    var onDownloadButtonPressed: ((_ cell: UIDocMessageCell) -> Void)?
    var onOpenButtonPressed: ((_ cell: UIDocMessageCell) -> Void)?
    var onReactionButtonPressed: ((_ model: UIDocMessageCell) -> Void)?
    var onLongPressDocumentBubble: ((_ chatItem: DocMessageItem?) -> Void)?
    var onCellTapped: ((_ cell: UIDocMessageCell) -> Void)?
    var longPressGesture: UILongPressGestureRecognizer!
    var cellTappedGesture: UITapGestureRecognizer!
    //var onPlayButtonPressed: ((_ cell: CHDocMessageCell) -> Void)?
    //var onPauseButtonPressed: ((_ cell: CHDocMessageCell) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setUpViews() {
        self.bubbleContainerView.addSubview(containerView)
        self.bubbleContainerView.addSubview(reactionButton)
        self.bubbleContainerView.addSubview(self.reactionsContainerView)
        self.bubbleContainerView.addSubview(self.messageStatusViewContainer)
        self.containerView.addSubview(fileIconView)
        self.containerView.addSubview(fileNameLabel)
        self.containerView.addSubview(dividerLine)
        self.containerView.addSubview(fileTypeLabel)
        self.containerView.addSubview(downloadButton)
        self.containerView.addSubview(loadingIndicator)
        self.containerView.addSubview(openFileButton)
        
        self.messageStatusViewContainer.addSubview(self.messageStatusView)
        self.messageStatusViewContainer.addSubview(self.messageTimeLabel)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(docBubbleLongPressed(gesture:)))
        self.containerView.addGestureRecognizer(longPressGesture)
        
        cellTappedGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(gesture:)))
        self.addGestureRecognizer(cellTappedGesture)
        
        self.downloadButton.addTarget(self, action: #selector(onDownloadButtonPressed(sender:)), for: .touchUpInside)
        self.openFileButton.addTarget(self, action: #selector(onOpenButtonPressed(sender:)), for: .touchUpInside)
        self.reactionButton.addTarget(self, action: #selector(didTapOnReactionButton(sender:)), for: .touchUpInside)
    }
    
    @objc private func docBubbleLongPressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.onLongPressDocumentBubble?(self.docMessageModel)
        }
    }
       
    @objc private func cellTapped(gesture: UITapGestureRecognizer) {
        self.onCellTapped?(self)
    }
    
    @objc private func onOpenButtonPressed(sender: UIButton) {
        self.onOpenButtonPressed?(self)
    }
    
    @objc private func onDownloadButtonPressed(sender: UIButton) {
        self.onDownloadButtonPressed?(self)
    }
    
    @objc private func didTapOnReactionButton(sender: UIButton) {
        self.onReactionButtonPressed?(self)
    }
    
    override func assignChatItem(chatItem: ChannelizeChatItem) {
        super.assignChatItem(chatItem: chatItem)
        guard let docMessageModel = chatItem as? DocMessageItem else {
            return
        }
        self.docMessageModel = docMessageModel
        
        if docMessageModel.messageStatus == .sending {
            self.cellTappedGesture.isEnabled = false
            self.openFileButton.isEnabled = false
            self.downloadButton.isEnabled = false
            self.longPressGesture.isEnabled = false
            self.reactionButton.isEnabled = false
        } else {
            if docMessageModel.isMessageSelectorOn {
                self.cellTappedGesture.isEnabled = true
                self.longPressGesture.isEnabled = false
                self.openFileButton.isEnabled = false
                self.downloadButton.isEnabled = false
                self.reactionButton.isEnabled = false
            } else {
                self.cellTappedGesture.isEnabled = false
                self.longPressGesture.isEnabled = true
                self.openFileButton.isEnabled = true
                self.downloadButton.isEnabled = true
                self.reactionButton.isEnabled = true
            }
        }
        
        var containerHeight: CGFloat = CHCustomStyles.docMessageBubbleSize.height
        let containerWidth: CGFloat = CHCustomStyles.docMessageBubbleSize.width
        
        containerHeight = chatItem.reactions.count > 0 ? CHCustomStyles.docMessageBubbleSize.height + 15 : CHCustomStyles.docMessageBubbleSize.height
        
        self.containerView.frame.size = CGSize(width: containerWidth, height: containerHeight)
        self.containerView.frame.origin.y = 0
        self.containerView.frame.origin.x = docMessageModel.isIncoming ? 15 : self.bubbleContainerView.frame.width - containerWidth - 15
        
        
        self.messageStatusViewContainer.frame.size = CGSize(width: 80, height: 35)
        self.messageStatusViewContainer.frame.origin.y = getViewEndOriginY(view: self.containerView) - self.messageStatusViewContainer.frame.size.height - 2.5
        if docMessageModel.isIncoming {
            self.messageStatusViewContainer.frame.origin.x = getViewEndOriginX(view: self.containerView) + 5
        } else {
            self.messageStatusViewContainer.frame.origin.x = self.containerView.frame.origin.x - self.messageStatusViewContainer.frame.width - 5
        }
        
        self.messageStatusView.frame.size = CGSize(width: 20, height: 20)
        self.messageStatusView.frame.origin.y = 0
        self.messageStatusView.frame.origin.x = docMessageModel.isIncoming == true ? 0 : self.messageStatusViewContainer.frame.width - self.messageStatusView.frame.width
        
        self.messageTimeLabel.frame.size = CGSize(width: 80, height: 15)
        self.messageTimeLabel.frame.origin.x = 0
        self.messageTimeLabel.frame.origin.y = getViewEndOriginY(view: self.messageStatusView)
        
        
        self.reactionButton.frame.size = CGSize(width: 22, height: 22)
        self.reactionButton.frame.origin.x = getViewEndOriginX(view: self.containerView) + 2.5
        self.reactionButton.frame.origin.y = self.containerView.frame.origin.y
        
        if docMessageModel.isIncoming {
            self.reactionButton.isHidden = false
        } else {
            self.reactionButton.isHidden = true
        }
        
        self.fileIconView.frame.origin.x = 7.5
        self.fileIconView.frame.origin.y = 20
        self.fileIconView.frame.size = CGSize(width: 30, height: 30)
        
        self.fileNameLabel.frame.origin.y = 15
        self.fileNameLabel.frame.origin.x = getViewEndOriginX(view: self.fileIconView) + 2.5
        self.fileNameLabel.frame.size.height = 40
        self.fileNameLabel.frame.size.width = containerWidth - fileNameLabel.frame.origin.x - 10
        
        self.dividerLine.frame.origin.x = 7.5
        self.dividerLine.frame.origin.y = getViewEndOriginY(view: self.fileNameLabel) + 7.5
        self.dividerLine.frame.size.width = containerWidth - 15
        self.dividerLine.frame.size.height = 2
        
        self.downloadButton.frame.origin.y = getViewEndOriginY(view: self.dividerLine) + 5
        self.downloadButton.frame.size = CGSize(width: 35, height: 35)
        self.downloadButton.frame.origin.x = containerWidth - 35 - 10
        
        self.loadingIndicator.frame.origin.y = getViewEndOriginY(view: self.dividerLine) + 5
        self.loadingIndicator.frame.size = CGSize(width: 35, height: 35)
        self.loadingIndicator.frame.origin.x = containerWidth - 35 - 10
        
        self.openFileButton.frame.size = CGSize(width: 70, height: 25)
        self.openFileButton.frame.origin.x = containerWidth - 70 - 15
        self.openFileButton.layer.cornerRadius = 10
        self.openFileButton.center.y = self.downloadButton.center.y
        
        self.fileTypeLabel.frame.size.width = containerWidth - 70 - 7.5 - 5
        self.fileTypeLabel.frame.size.height = 20
        self.fileTypeLabel.frame.origin.x = 7.5
        self.fileTypeLabel.center.y = self.downloadButton.center.y
        
        let reactionViewHeight = super.calculateReactionViewHeight(chatItem: chatItem)
        let reactionViewWidth: CGFloat = CHCustomStyles.docMessageBubbleSize.width
        
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = self.containerView.frame.origin.x
        self.reactionsContainerView.frame.origin.y = getViewEndOriginY(view: self.containerView) - 15
        
        self.reactionsContainerView.assignReactions(reactions: docMessageModel.reactions)
        
        self.assignData(data: docMessageModel)
        
        let messageTime = chatItem.messageDate
        self.messageTimeLabel.text = messageTime.toRelateTimeString()
        
        switch chatItem.messageStatus {
        case .sending:
            self.messageStatusView.tintColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#E6E6E6") : UIColor(hex: "#8a8a8a")
            self.messageStatusView.image = getImage("chSendingIcon")
            break
        case .sent:
            self.messageStatusView.tintColor = CHAppConstant.themeStyle == .dark ? UIColor(hex: "#E6E6E6") : UIColor(hex: "#8a8a8a")
            self.messageStatusView.image = getImage("chSingleTickIcon")
            break
        case .seen:
            self.messageStatusView.tintColor = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.tintColor : CHLightThemeColors.tintColor
            self.messageStatusView.image = getImage("chDoubleTickIcon")
            break
        }
        
        if chatItem.isIncoming {
            self.messageStatusView.isHidden = true
            self.messageTimeLabel.textAlignment = .left
        } else {
            self.messageStatusView.isHidden = false
            self.messageTimeLabel.textAlignment = .right
        }
        
        if chatItem.showMessageStatusView {
            self.messageStatusViewContainer.isHidden = false
        } else {
            self.messageStatusViewContainer.isHidden = true
        }
        
    }
    
    private func assignData(data: DocMessageItem) {
        if data.isIncoming {
            //self.loadingIndicator.cycleColors = [CHCustomStyles.incomingMessageTextColor]
            self.containerView.backgroundColor = CHUIConstant.incomingTextMessageBackGroundColor
            self.fileNameLabel.textColor = CHUIConstant.incomingTextMessageColor
            self.fileTypeLabel.textColor = CHUIConstant.incomingTextMessageColor
            self.dividerLine.backgroundColor = CHUIConstant.incomingTextMessageColor
            self.downloadButton.imageView?.tintColor = CHUIConstant.incomingTextMessageColor
            self.fileIconView.tintColor = CHUIConstant.incomingTextMessageColor
            self.openFileButton.backgroundColor = CHUIConstant.incomingTextMessageColor
            self.openFileButton.setTitleColor(CHUIConstant.outGoingTextMessageBackGroundColor, for: .normal)
            
        } else {
            //self.loadingIndicator.cycleColors = [.white]
            self.containerView.backgroundColor = CHUIConstant.outGoingTextMessageBackGroundColor
            self.fileNameLabel.textColor = CHUIConstant.outGoingTextMessageColor
            self.fileTypeLabel.textColor = CHUIConstant.outGoingTextMessageColor
            self.dividerLine.backgroundColor = CHUIConstant.outGoingTextMessageColor
            self.downloadButton.imageView?.tintColor = CHUIConstant.outGoingTextMessageColor
            self.fileIconView.tintColor = CHUIConstant.outGoingTextMessageColor
            self.openFileButton.backgroundColor = UIColor.white
            self.openFileButton.setTitleColor(CHUIConstant.outGoingTextMessageBackGroundColor, for: .normal)
        }
        
        if let fileExtension = data.docMessageData?.fileExtension?.lowercased() {
            if let fileIcon = mimeTypeIcon[fileExtension] {
                self.fileIconView.image = getImage("\(fileIcon)")
            } else {
                self.fileIconView.image = getImage("chFileIcon")
            }
        } else {
            self.fileIconView.image = getImage("chFileIcon")
        }
        
        loadingIndicator.cycleColors = data.isIncoming ? [CHUIConstant.incomingTextMessageColor] : [UIColor.white]
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useBytes,.useKB,.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(data.docMessageData?.fileSize ?? 0))
        
        self.fileNameLabel.text = data.docMessageData?.fileName
        self.fileTypeLabel.text = "\(data.docMessageData?.fileType?.capitalized ?? "") - \(string)"
        
        self.downloadButton.isHidden = true
        self.loadingIndicator.isHidden = true
        self.openFileButton.isHidden = false
        self.loadingIndicator.startAnimating()
        
        switch data.docStatus {
        case .availableLocal:
            self.openFileButton.isHidden = false
            self.downloadButton.isHidden = true
            self.loadingIndicator.isHidden = true
            self.loadingIndicator.stopAnimating()
            break
        case .notAvailableLocal:
            self.openFileButton.isHidden = true
            self.downloadButton.isHidden = false
            self.loadingIndicator.isHidden = true
            self.loadingIndicator.stopAnimating()
            break
        case .downloading:
            self.openFileButton.isHidden = true
            self.downloadButton.isHidden = true
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimating()
            break
        case .uploading:
            self.openFileButton.isHidden = true
            self.downloadButton.isHidden = true
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimating()
            break
        }
    }
    
    func updateProgress(fromValue: Double, toValue: Double) {
        if toValue != 1.0 {
            self.loadingIndicator.setIndicatorMode(.determinate, animated: true)
            self.loadingIndicator.progress = Float(toValue)
            self.loadingIndicator.startAnimating()
        } else {
            self.loadingIndicator.setIndicatorMode(.indeterminate, animated: true)
            self.loadingIndicator.startAnimating()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var view = reactionButton.hitTest(reactionButton.convert(point, from: self), with: event)
        if view == nil {
            view = super.hitTest(point, with: event)
        }

        return view
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) {
            return true
        }

        return !reactionButton.isHidden && reactionButton.point(inside: reactionButton.convert(point, from: self), with: event)
    }
}



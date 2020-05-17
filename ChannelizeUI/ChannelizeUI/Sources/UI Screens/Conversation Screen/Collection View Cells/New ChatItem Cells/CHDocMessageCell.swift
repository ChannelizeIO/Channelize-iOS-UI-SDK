//
//  CHDocMessageCell.swift
//  ChannelizeUI
//
//  Created by bigstep on 4/23/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialProgressView

class CHDocMessageCell: BaseChatItemCollectionCell {
    
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
        label.font = UIFont(fontStyle: .robotoSlabMedium, size: 14.5)
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
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 13.5)
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
        button.titleLabel?.font = UIFont(fontStyle: .robotoSlabMedium, size: 12.0)
        button.backgroundColor = .white
        button.setTitleColor(CHUIConstants.appDefaultColor, for: .normal)
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
    
    var docMessageModel: DocMessageModel?
    
    var onDownloadButtonPressed: ((_ cell: CHDocMessageCell) -> Void)?
    var onOpenButtonPressed: ((_ cell: CHDocMessageCell) -> Void)?
    var onReactionButtonPressed: ((_ model: CHDocMessageCell?) -> Void)?
    
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
        self.containerView.addSubview(fileIconView)
        self.containerView.addSubview(fileNameLabel)
        self.containerView.addSubview(dividerLine)
        self.containerView.addSubview(fileTypeLabel)
        self.containerView.addSubview(downloadButton)
        self.containerView.addSubview(loadingIndicator)
        self.containerView.addSubview(openFileButton)
        
        self.downloadButton.addTarget(self, action: #selector(onDownloadButtonPressed(sender:)), for: .touchUpInside)
        self.openFileButton.addTarget(self, action: #selector(onOpenButtonPressed(sender:)), for: .touchUpInside)
        self.reactionButton.addTarget(self, action: #selector(didTapOnReactionButton(sender:)), for: .touchUpInside)
    }
    
    override func assignChatItem(chatItem: BaseMessageItemProtocol) {
        super.assignChatItem(chatItem: chatItem)
        guard let docMessageModel = chatItem as? DocMessageModel else {
            return
        }
        self.docMessageModel = docMessageModel
        
        var containerHeight = CHCustomStyles.docMessageSize.height
        let containerWidth = CHCustomStyles.docMessageSize.width
        
//        let nonZeroCountReactions = self.docMessageModel?.reactionCountsInfo.filter({
//            $0.value > 0
//        })
        containerHeight = chatItem.reactions.count > 0 ? CHCustomStyles.docMessageSize.height + 15 : CHCustomStyles.docMessageSize.height
        
        self.containerView.frame.size = CGSize(width: containerWidth, height: containerHeight)
        self.containerView.frame.origin.y = 0
        self.containerView.frame.origin.x = docMessageModel.isIncoming ? 15 : self.bubbleContainerView.frame.width - containerWidth - 15
        
        self.reactionButton.frame.size = CGSize(width: 22, height: 22)
        self.reactionButton.frame.origin.x = getViewOriginXEnd(view: self.containerView) + 2.5
        self.reactionButton.frame.origin.y = self.containerView.frame.origin.y
        
        if docMessageModel.isIncoming {
            if CHCustomOptions.enableMessageReactions {
                self.reactionButton.isHidden = false
            } else {
                self.reactionButton.isHidden = true
            }
        } else {
            self.reactionButton.isHidden = true
        }
        
        self.fileIconView.frame.origin.x = 7.5
        self.fileIconView.frame.origin.y = 20
        self.fileIconView.frame.size = CGSize(width: 30, height: 30)
        
        self.fileNameLabel.frame.origin.y = 15
        self.fileNameLabel.frame.origin.x = getViewOriginXEnd(view: self.fileIconView) + 2.5
        self.fileNameLabel.frame.size.height = 40
        self.fileNameLabel.frame.size.width = containerWidth - fileNameLabel.frame.origin.x - 10
        
        self.dividerLine.frame.origin.x = 7.5
        self.dividerLine.frame.origin.y = getViewOriginYEnd(view: self.fileNameLabel) + 7.5
        self.dividerLine.frame.size.width = containerWidth - 15
        self.dividerLine.frame.size.height = 2
        
        self.downloadButton.frame.origin.y = getViewOriginYEnd(view: self.dividerLine) + 5
        self.downloadButton.frame.size = CGSize(width: 35, height: 35)
        self.downloadButton.frame.origin.x = containerWidth - 35 - 10
        
        self.loadingIndicator.frame.origin.y = getViewOriginYEnd(view: self.dividerLine) + 5
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
        let reactionViewWidth = CHCustomStyles.docMessageSize.width
        
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = self.containerView.frame.origin.x
        self.reactionsContainerView.frame.origin.y = getViewOriginYEnd(view: self.containerView) - 15
        
        //self.reactionsContainerView.assignReactions(reactions: super.createReactionModels(chatItem: chatItem))
        
        self.reactionsContainerView.assignReactions(reactions: docMessageModel.reactions)
        
        self.assignData(data: docMessageModel)
    }
    
    private func assignData(data: DocMessageModel) {
        if data.isIncoming {
            //self.loadingIndicator.cycleColors = [CHCustomStyles.incomingMessageTextColor]
            self.containerView.backgroundColor = CHCustomStyles.baseMessageIncomingBackgroundColor
            self.fileNameLabel.textColor = CHCustomStyles.incomingMessageTextColor
            self.fileTypeLabel.textColor = CHCustomStyles.incomingMessageTextColor
            self.dividerLine.backgroundColor = CHCustomStyles.incomingMessageTextColor
            self.downloadButton.imageView?.tintColor = CHCustomStyles.incomingMessageTextColor
            self.fileIconView.tintColor = CHCustomStyles.incomingMessageTextColor
            
            self.openFileButton.backgroundColor = CHCustomStyles.incomingMessageTextColor
            self.openFileButton.setTitleColor(.white, for: .normal)
            
        } else {
            //self.loadingIndicator.cycleColors = [.white]
            self.containerView.backgroundColor = CHCustomStyles.baseMessageOutgoingBackgroundColor
            self.fileNameLabel.textColor = CHCustomStyles.outgoingMessageTextColor
            self.fileTypeLabel.textColor = CHCustomStyles.outgoingMessageTextColor
            self.dividerLine.backgroundColor = CHCustomStyles.outgoingMessageTextColor
            self.downloadButton.imageView?.tintColor = CHCustomStyles.outgoingMessageTextColor
            self.fileIconView.tintColor = .white
            
            self.openFileButton.backgroundColor = UIColor.white
            self.openFileButton.setTitleColor(CHUIConstants.appDefaultColor, for: .normal)
            
        }
        
        if let fileExtension = data.docMessageData.fileExtension?.lowercased() {
            if let fileIcon = mimeTypeIcon[fileExtension] {
                self.fileIconView.image = getImage("\(fileIcon)")
            } else {
                self.fileIconView.image = getImage("chFileIcon")
            }
        } else {
            self.fileIconView.image = getImage("chFileIcon")
        }
        
        loadingIndicator.cycleColors = data.isIncoming ? [CHCustomStyles.incomingMessageTextColor] : [UIColor.white]
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useBytes,.useKB,.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(data.docMessageData.fileSize ?? 0))
        
        self.fileNameLabel.text = data.docMessageData.fileName
        self.fileTypeLabel.text = "\(data.docMessageData.fileType?.capitalized ?? "") - \(string)"
        
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
    
//    override func didTapOnBubble(tapGesture: UITapGestureRecognizer) {
//        guard self.docMessageModel?.messageStatus != .sending else {
//            return
//        }
//        self.onBubbleTapped?(self)
//    }
    @objc private func didTapOnReactionButton(sender: UIButton) {
        self.onReactionButtonPressed?(self)
    }
    
    override func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
        guard self.docMessageModel?.messageStatus != .sending else {
            return
        }
        if longPressGesture.state == .began {
            self.onLongPressedBubble?(self)
        }
    }
    
    override func didSelectDeSelectCell(tapGesture: UITapGestureRecognizer) {
        guard self.docMessageModel?.messageStatus != .sending else {
            return
        }
        self.onCellTapped?(self)
    }
    
    @objc private func onOpenButtonPressed(sender: UIButton) {
        self.onOpenButtonPressed?(self)
    }
    
    @objc private func onDownloadButtonPressed(sender: UIButton) {
        self.onDownloadButtonPressed?(self)
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

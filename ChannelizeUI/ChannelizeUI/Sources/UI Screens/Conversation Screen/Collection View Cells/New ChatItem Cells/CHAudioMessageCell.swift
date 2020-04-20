//
//  CHAudioMessageCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/28/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialProgressView

class CHAudioMessageCell: BaseChatItemCollectionCell {
    
    var audioContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.customSystemTeal
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        view.layer.borderColor = UIColor(hex: "#f1f1f1").cgColor
        view.layer.borderWidth = 1.0
        return view
    }()
    
    private var timeLabelContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = CHUIConstants.appDefaultColor
        return view
    }()
    
    private var timerLabel: UILabel = {
        let label = UILabel()
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .white
        label.text = "00:00"
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.font = UIFont(fontStyle: .robotoSlabMedium, size: 16.0)
        return label
    }()
    
    private var audioIconView: UIImageView = {
        let imageView = UIImageView()
        //imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        imageView.tintColor = .white
        imageView.image = getImage("chMicIcon")
        return imageView
    }()
    
    private var playButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.layer.masksToBounds = true
        button.setImage(getImage("playButtonIcon"), for: .normal)
        return button
    }()
    
    private var pauseButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.layer.masksToBounds = true
        button.setImage(getImage("pauseButtonIcon"), for: .normal)
        return button
    }()
    
    private var loadingIndicator: MDCActivityIndicator = {
        let indicator = MDCActivityIndicator()
        indicator.cycleColors = [.white]
        indicator.radius = 15
        return indicator
    }()

    private var audioProgressView: MDCProgressView = {
        let view = MDCProgressView()
        return view
    }()
    
    var onPlayButtonPressed: ((_ cell: CHAudioMessageCell) -> Void)?
    var onPauseButtonPressed: ((_ cell: CHAudioMessageCell) -> Void)?
    
    var audioMessageModel: AudioMessageModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.bubbleContainerView.addSubview(audioContainerView)
        self.audioContainerView.addSubview(timeLabelContainerView)
        self.timeLabelContainerView.addSubview(timerLabel)
        self.timeLabelContainerView.addSubview(audioIconView)
        
        self.audioContainerView.addSubview(loadingIndicator)
        self.audioContainerView.addSubview(playButton)
        self.audioContainerView.addSubview(pauseButton)
        self.audioContainerView.addSubview(audioProgressView)
        
        self.playButton.addTarget(self, action: #selector(playButtonPressed(sender:)), for: .touchUpInside)
        self.pauseButton.addTarget(self, action: #selector(pauseButtonPressed(sender:)), for: .touchUpInside)
    }
    
    @objc private func playButtonPressed(sender: UIButton) {
        self.onPlayButtonPressed?(self)
    }
    
    @objc private func pauseButtonPressed(sender: UIButton) {
        self.onPauseButtonPressed?(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: BaseMessageItemProtocol) {
        super.assignChatItem(chatItem: chatItem)
        guard let audioMessageModel = chatItem as? AudioMessageModel else {
            return
        }
        self.audioMessageModel = audioMessageModel
        let bubbleContainerWidth: CGFloat = 280
        
        let messageBubbleOriginX: CGFloat = audioMessageModel.isIncoming ? 15 : self.bubbleContainerView.frame.width - bubbleContainerWidth - 15
        
        self.audioContainerView.frame.size = CGSize(width: bubbleContainerWidth, height: self.bubbleContainerView.frame.height)
        self.audioContainerView.frame.origin.y = 0
        self.audioContainerView.frame.origin.x = messageBubbleOriginX
        
        self.timeLabelContainerView.frame.size.height = 65
        self.timeLabelContainerView.frame.size.width = 65
        self.timeLabelContainerView.frame.origin.x = 7.5
        self.timeLabelContainerView.frame.origin.y = 7.5
        
        self.audioIconView.frame.size = CGSize(width: 25, height: 25)
        self.audioIconView.center.x = self.timeLabelContainerView.frame.width/2
        self.audioIconView.frame.origin.y = 7.5
        
        self.timerLabel.frame.size = CGSize(width: self.timeLabelContainerView.frame.width - 5, height: 20)
        self.timerLabel.frame.origin.x = 2.5
        self.timerLabel.frame.origin.y = getViewOriginYEnd(view: self.audioIconView) + 2.5
        
        self.playButton.frame.size = CGSize(width: 40, height: 40)
        self.playButton.frame.origin.x = getViewOriginXEnd(view: self.timeLabelContainerView) + 5
        self.playButton.center.y = self.audioContainerView.frame.height/2
        
        self.pauseButton.frame.size = CGSize(width: 40, height: 40)
        self.pauseButton.frame.origin.x = getViewOriginXEnd(view: self.timeLabelContainerView) + 5
        self.pauseButton.center.y = self.audioContainerView.frame.height/2
        
        self.loadingIndicator.frame.size = CGSize(width: 35, height: 35)
        self.loadingIndicator.frame.origin.x = getViewOriginXEnd(view: self.timeLabelContainerView) + 5
        self.loadingIndicator.center.y = self.audioContainerView.frame.height/2
        
        self.audioProgressView.frame.size = CGSize(width: self.audioContainerView.frame.width - getViewOriginXEnd(view: self.pauseButton) - 12.5, height: 5)
        self.audioProgressView.frame.origin.x = getViewOriginXEnd(view: self.pauseButton) + 5
        self.audioProgressView.center.y = self.audioContainerView.frame.height/2
        audioProgressView.setProgress(audioMessageModel.playerProgress, animated: false)
        
        if audioMessageModel.messageStatus == .sending {
            self.playButton.isHidden = true
            self.pauseButton.isHidden = true
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimating()
        } else {
            switch audioMessageModel.playerStatus {
            case .loading:
                self.playButton.isHidden = true
                self.pauseButton.isHidden = true
                self.loadingIndicator.isHidden = false
                self.loadingIndicator.startAnimating()
                break
            case .playing:
                self.playButton.isHidden = true
                self.pauseButton.isHidden = false
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                break
            case .paused, .stopped:
                self.playButton.isHidden = false
                self.pauseButton.isHidden = true
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
                break
            }
        }
        
        if let audioDuration = audioMessageModel.audioDuration {
            let timeString = (audioDuration/1000).stringFromTimeInterval()
            self.timerLabel.text = timeString
        }
        
        loadingIndicator.cycleColors = audioMessageModel.isIncoming ? [CHUIConstants.appDefaultColor] : [UIColor.white]
        audioProgressView.trackTintColor = audioMessageModel.isIncoming ? CHUIConstants.appDefaultColor.lighter(by: 20) : UIColor.lightGray
        audioProgressView.progressTintColor = audioMessageModel.isIncoming ? CHUIConstants.appDefaultColor : UIColor.white
        
        self.audioIconView.tintColor = audioMessageModel.isIncoming ? CHUIConstants.incomingTextMessageBackgroundColor : CHUIConstants.outgoingTextMessageBackgroundColor
        
        self.timerLabel.textColor = audioMessageModel.isIncoming ? CHUIConstants.incomingTextMessageBackgroundColor : CHUIConstants.outgoingTextMessageBackgroundColor
        
        self.timeLabelContainerView.backgroundColor = audioMessageModel.isIncoming ? CHUIConstants.outgoingTextMessageBackgroundColor : UIColor.white
        
        self.playButton.imageView?.tintColor = audioMessageModel.isIncoming ? CHUIConstants.outgoingTextMessageBackgroundColor : UIColor.white
        
        self.pauseButton.imageView?.tintColor = audioMessageModel.isIncoming ? CHUIConstants.outgoingTextMessageBackgroundColor : UIColor.white
        
        self.audioContainerView.backgroundColor = audioMessageModel.isIncoming ? CHUIConstants.incomingTextMessageBackgroundColor : CHUIConstants.outgoingTextMessageBackgroundColor
    }
    
    @objc override func didTapOnBubble(tapGesture: UITapGestureRecognizer) {
        guard self.audioMessageModel?.messageStatus != .sending else {
            return
        }
        self.onBubbleTapped?(self)
    }
    
    @objc override func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
        guard self.audioMessageModel?.messageStatus != .sending else {
            return
        }
        if longPressGesture.state == .began {
            self.onLongPressedBubble?(self)
        }
    }
    
    @objc override func didSelectDeSelectCell(tapGesture: UITapGestureRecognizer) {
        guard self.audioMessageModel?.messageStatus != .sending else {
            return
        }
        self.onCellTapped?(self)
    }
    
    func updateProgressView(newProgress: Float, currentTiming: Double) {
        print(newProgress)
        guard self.audioMessageModel?.playerStatus != .loading else {
            return
        }
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.isHidden = true
        if newProgress == 0.0 {
            self.playButton.isHidden = false
            self.pauseButton.isHidden = true
        } else {
            self.pauseButton.isHidden = false
            self.playButton.isHidden = true
        }
        self.audioProgressView.setProgress(newProgress, animated: true)
        self.timerLabel.text = currentTiming.stringFromTimeInterval()
    }
}

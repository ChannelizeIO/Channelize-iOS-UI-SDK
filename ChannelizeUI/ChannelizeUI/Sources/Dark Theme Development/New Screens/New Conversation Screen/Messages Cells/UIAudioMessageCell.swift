//
//  CHAudioMessageCell.swift
//  ChannelizeUIKit
//
//  Created by bigstep on 6/7/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialProgressView

class UIAudioMessageCell: CHBaseMessageCell {
    var audioContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        view.layer.borderColor = UIColor(hex: "#f1f1f1").cgColor
        view.layer.borderWidth = 0.25
        return view
    }()
    
    private var timeLabelContainerView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        return view
    }()
    
    private var timerLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.text = "00:00"
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.font = UIFont(fontStyle: .medium, size: 16.0)
        return label
    }()
    
    private var audioIconView: UIImageView = {
        let imageView = UIImageView()
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
        button.layer.masksToBounds = true
        button.setImage(getImage("chPlayButton"), for: .normal)
        return button
    }()
    
    private var pauseButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.masksToBounds = true
        button.setImage(getImage("chPauseButton"), for: .normal)
        return button
    }()
    
    private var loadingIndicator: MDCActivityIndicator = {
        let indicator = MDCActivityIndicator()
        indicator.cycleColors = [.white]
        indicator.radius = 15
        return indicator
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

    private var audioProgressView: MDCProgressView = {
        let view = MDCProgressView()
        return view
    }()
    
    var onPlayButtonPressed: ((_ cell: UIAudioMessageCell) -> Void)?
    var onPauseButtonPressed: ((_ cell: UIAudioMessageCell) -> Void)?
    var onReactionButtonPressed: ((_ model: UIAudioMessageCell) -> Void)?
    var onLongPressAudioBubble: ((_ chatItem: AudioMessageItem?) -> Void)?
    var onCellTapped: ((_ cell: UIAudioMessageCell) -> Void)?
    var audioMessageModel: AudioMessageItem?
    var longPressGesture: UILongPressGestureRecognizer!
    var cellTappedGesture: UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bubbleContainerView.addSubview(messageStatusViewContainer)
        self.bubbleContainerView.addSubview(audioContainerView)
        self.bubbleContainerView.addSubview(reactionButton)
        self.bubbleContainerView.addSubview(reactionsContainerView)
        
        self.audioContainerView.addSubview(timeLabelContainerView)
        self.timeLabelContainerView.addSubview(timerLabel)
        self.timeLabelContainerView.addSubview(audioIconView)
        
        self.audioContainerView.addSubview(loadingIndicator)
        self.audioContainerView.addSubview(playButton)
        self.audioContainerView.addSubview(pauseButton)
        self.audioContainerView.addSubview(audioProgressView)
        
        self.messageStatusViewContainer.addSubview(self.messageTimeLabel)
        self.messageStatusViewContainer.addSubview(self.messageStatusView)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(audioBubbleLongPressed(gesture:)))
        self.audioContainerView.addGestureRecognizer(longPressGesture)
        
        cellTappedGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(gesture:)))
        self.addGestureRecognizer(cellTappedGesture)
        
        
        self.playButton.addTarget(self, action: #selector(playButtonPressed(sender:)), for: .touchUpInside)
        self.pauseButton.addTarget(self, action: #selector(pauseButtonPressed(sender:)), for: .touchUpInside)
        self.reactionButton.addTarget(self, action: #selector(didTapOnReactionButton(sender:)), for: .touchUpInside)
    }
    
    @objc private func playButtonPressed(sender: UIButton) {
        self.onPlayButtonPressed?(self)
    }
    
    @objc private func pauseButtonPressed(sender: UIButton) {
        self.onPauseButtonPressed?(self)
    }
    
    @objc private func audioBubbleLongPressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.onLongPressAudioBubble?(self.audioMessageModel)
        }
    }
       
    @objc private func cellTapped(gesture: UITapGestureRecognizer) {
        self.onCellTapped?(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func assignChatItem(chatItem: ChannelizeChatItem) {
        super.assignChatItem(chatItem: chatItem)
        guard let audioMessageModel = chatItem as? AudioMessageItem else {
            return
        }
        self.audioMessageModel = audioMessageModel
        
        if audioMessageModel.messageStatus == .sending {
            self.cellTappedGesture.isEnabled = false
            self.playButton.isEnabled = false
            self.pauseButton.isEnabled = false
            self.longPressGesture.isEnabled = false
            self.reactionButton.isEnabled = false
        } else {
            if audioMessageModel.isMessageSelectorOn {
                self.cellTappedGesture.isEnabled = true
                self.longPressGesture.isEnabled = false
                self.playButton.isEnabled = false
                self.pauseButton.isEnabled = false
                self.reactionButton.isEnabled = false
            } else {
                self.cellTappedGesture.isEnabled = false
                self.longPressGesture.isEnabled = true
                self.playButton.isEnabled = true
                self.pauseButton.isEnabled = true
                self.reactionButton.isEnabled = true
            }
        }
        
        let bubbleContainerWidth: CGFloat = CHCustomStyles.audioMessageBubbleSize.width
        let messageBubbleOriginX: CGFloat = audioMessageModel.isIncoming ? 15 : self.bubbleContainerView.frame.width - bubbleContainerWidth - 15
        self.audioContainerView.frame.size.width = CHCustomStyles.audioMessageBubbleSize.width
        self.audioContainerView.frame.size.height = chatItem.reactions.count > 0 ? CHCustomStyles.audioMessageBubbleSize.height + 15 : CHCustomStyles.audioMessageBubbleSize.height
        self.audioContainerView.frame.origin.y = 0
        self.audioContainerView.frame.origin.x = messageBubbleOriginX
            
        
        self.messageStatusViewContainer.frame.size = CGSize(width: 80, height: 35)
        self.messageStatusViewContainer.frame.origin.y = getViewEndOriginY(view: self.audioContainerView) - self.messageStatusViewContainer.frame.size.height
        if audioMessageModel.isIncoming {
            self.messageStatusViewContainer.frame.origin.x = getViewEndOriginX(view: self.audioContainerView) + 5
        } else {
            self.messageStatusViewContainer.frame.origin.x = self.audioContainerView.frame.origin.x - self.messageStatusViewContainer.frame.width - 5
        }
        
        self.messageStatusView.frame.size = CGSize(width: 20, height: 20)
        self.messageStatusView.frame.origin.y = 0
        self.messageStatusView.frame.origin.x = audioMessageModel.isIncoming == true ? 0 : self.messageStatusViewContainer.frame.width - self.messageStatusView.frame.width
        
        self.messageTimeLabel.frame.size = CGSize(width: 80, height: 15)
        self.messageTimeLabel.frame.origin.x = 0
        self.messageTimeLabel.frame.origin.y = getViewEndOriginY(view: self.messageStatusView)
        
        
        self.reactionButton.frame.size = CGSize(width: 22, height: 22)
        self.reactionButton.frame.origin.x = getViewEndOriginX(view: self.audioContainerView) + 2.5
        self.reactionButton.frame.origin.y = self.audioContainerView.frame.origin.y
            
        if audioMessageModel.isIncoming {
            self.reactionButton.isHidden = false
        } else {
            self.reactionButton.isHidden = true
        }
            
        self.timeLabelContainerView.frame.size.height = 65
        self.timeLabelContainerView.frame.size.width = 65
        self.timeLabelContainerView.frame.origin.x = 7.5
        self.timeLabelContainerView.frame.origin.y = 7.5
            
        self.audioIconView.frame.size = CGSize(width: 25, height: 25)
        self.audioIconView.center.x = self.timeLabelContainerView.frame.width/2
        self.audioIconView.frame.origin.y = 7.5
            
        self.timerLabel.frame.size = CGSize(width: self.timeLabelContainerView.frame.width - 5, height: 20)
        self.timerLabel.frame.origin.x = 2.5
        self.timerLabel.frame.origin.y = getViewEndOriginY(view: self.audioIconView) + 2.5
            
        self.playButton.frame.size = CGSize(width: 40, height: 40)
        self.playButton.frame.origin.x = getViewEndOriginX(view: self.timeLabelContainerView) + 5
        self.playButton.center.y = self.timeLabelContainerView.center.y
            
        self.pauseButton.frame.size = CGSize(width: 40, height: 40)
        self.pauseButton.frame.origin.x = getViewEndOriginX(view: self.timeLabelContainerView) + 5
        self.pauseButton.center.y = self.timeLabelContainerView.center.y
            
        self.loadingIndicator.frame.size = CGSize(width: 35, height: 35)
        self.loadingIndicator.frame.origin.x = getViewEndOriginX(view: self.timeLabelContainerView) + 5
        self.loadingIndicator.center.y = self.timeLabelContainerView.center.y
            
        self.audioProgressView.frame.size = CGSize(width: self.audioContainerView.frame.width - getViewEndOriginX(view: self.pauseButton) - 12.5, height: 5)
        self.audioProgressView.frame.origin.x = getViewEndOriginX(view: self.pauseButton) + 5
        self.audioProgressView.center.y = self.timeLabelContainerView.center.y//self.audioContainerView.frame.height/2
        audioProgressView.setProgress(audioMessageModel.playerProgress, animated: false)
            
            
        let reactionViewHeight = super.calculateReactionViewHeight(chatItem: chatItem)
        let reactionViewWidth: CGFloat = 250
            
        self.reactionsContainerView.frame.size = CGSize(width: reactionViewWidth, height: reactionViewHeight)
        self.reactionsContainerView.frame.origin.x = messageBubbleOriginX
        self.reactionsContainerView.frame.origin.y = getViewEndOriginY(view: self.audioContainerView) - 15
            
        self.reactionsContainerView.assignReactions(reactions: audioMessageModel.reactions)
            
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
            
        if let audioDuration = audioMessageModel.audioData?.audioDuration {
            let timeString = (audioDuration/1000).stringFromTimeInterval()
            self.timerLabel.text = timeString
        }
        
        let loadingIndicatorCycleColorsIn = CHAppConstant.themeStyle == .dark ? [CHDarkThemeColors.instance.buttonTintColor] : [.white]
        let loadingIndicatorCycleColorsOut = [UIColor.white]
    
        self.loadingIndicator.cycleColors = audioMessageModel.isIncoming ? loadingIndicatorCycleColorsIn : loadingIndicatorCycleColorsOut
        
        let audioProgessViewTrackColorsIn = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.buttonTintColor.darker(by: 50) : CHLightThemeColors.instance.buttonTintColor.lighter(by: 20)
        let audioProgressViewTrackColorsOut = UIColor.lightGray
        self.audioProgressView.trackTintColor = audioMessageModel.isIncoming ? audioProgessViewTrackColorsIn : audioProgressViewTrackColorsOut
        
        let audioProgressTintColorIn = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.buttonTintColor : CHLightThemeColors.instance.buttonTintColor
        let audioProgressTintColorOut = UIColor.white
        self.audioProgressView.progressTintColor = audioMessageModel.isIncoming ? audioProgressTintColorIn : audioProgressTintColorOut
        
        
        self.audioIconView.tintColor = audioMessageModel.isIncoming ? UIColor.black : CHUIConstant.outGoingTextMessageBackGroundColor
        self.timerLabel.textColor = audioMessageModel.isIncoming ? UIColor.black : CHUIConstant.outGoingTextMessageBackGroundColor
        self.timeLabelContainerView.backgroundColor = UIColor.white
        
        let playPauseButtonTintColorIn = CHAppConstant.themeStyle == .dark ? CHDarkThemeColors.instance.buttonTintColor : CHLightThemeColors.instance.buttonTintColor
        
        
        self.playButton.imageView?.tintColor = audioMessageModel.isIncoming ? playPauseButtonTintColorIn : .white
        self.pauseButton.imageView?.tintColor = audioMessageModel.isIncoming ? playPauseButtonTintColorIn : .white
        self.audioContainerView.backgroundColor = audioMessageModel.isIncoming ? CHUIConstant.incomingTextMessageBackGroundColor : CHUIConstant.outGoingTextMessageBackGroundColor
        
        
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
    
    @objc private func didTapOnReactionButton(sender: UIButton) {
        self.onReactionButtonPressed?(self)
    }
    
    func updateProgressView(newProgress: Float, currentTiming: Double) {
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



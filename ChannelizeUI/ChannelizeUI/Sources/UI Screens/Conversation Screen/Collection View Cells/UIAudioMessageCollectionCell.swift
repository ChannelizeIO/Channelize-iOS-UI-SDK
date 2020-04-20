//
//  UIAudioMessageCollectionCell.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/19/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialActivityIndicator

class UIAudioMessageCollectionCell: UICollectionViewCell {
    
    var dateSeperatorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        return label
    }()
    
    var senderNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.black
        label.font = UIFont(fontStyle: .robotoSlabRegualar, size: 16.0)
        return label
    }()
    
    var unSelectedCircleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .gray
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chUnSelectedCircelcon")
        return imageView
    }()
    
    var selectedCirlceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = CHUIConstants.appDefaultColor
        imageView.backgroundColor = .white
        imageView.layer.masksToBounds = true
        imageView.image = getImage("chSelectedCircleIcon")
        return imageView
    }()
    
    var bubbleContainerView: UIView = {
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
        button.setImage(getImage("chPlayButton"), for: .normal)
        return button
    }()
    
    private var pauseButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.tintColor = CHUIConstants.appDefaultColor
        button.layer.masksToBounds = true
        button.setImage(getImage("chPauseButton"), for: .normal)
        return button
    }()
    
    private var loadingIndicator2: MDCActivityIndicator = {
        let indicator = MDCActivityIndicator()
        indicator.cycleColors = [.white]
        return indicator
    }()
    
    private var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        return indicator
    }()

    private var audioProgressView: MDCProgressView = {
        let view = MDCProgressView()
        return view
    }()
    
    private var messageStatusContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        view.layer.masksToBounds = true
        return view
    }()
    
    private var messageTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont(fontStyle: .robotoSlabMedium, size: 13.0)
        return label
    }()
    
    private var messageStatusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.masksToBounds = true
        imageView.tintColor = .white
        return imageView
    }()
    
    var audioMessageModel: AudioMessageModel? {
        didSet {
            self.setUpViewsFrames()
        }
    }
    
    var bubbleTapGesture: UITapGestureRecognizer!
    var longPressTapGesture: UILongPressGestureRecognizer!
    var cellTapGesture: UITapGestureRecognizer!
    
    var onBubbleTapped: ((_ cell: UIAudioMessageCollectionCell) -> Void)?
    var onLongPressedBubble: ((_ cell: UIAudioMessageCollectionCell) -> Void)?
    var onCellTapped: ((_ cell: UIAudioMessageCollectionCell) -> Void)?
    
    var onPlayButtonPressed: ((_ cell: UIAudioMessageCollectionCell) -> Void)?
    var onPauseButtonPressed: ((_ cell: UIAudioMessageCollectionCell) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpViews()
        
        bubbleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnBubble(tapGesture:)))
        longPressTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressBubble(longPressGesture:)))
        cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectDeSelectCell(tapGesture:)))
        
        self.bubbleContainerView.addGestureRecognizer(
        longPressTapGesture)
        self.bubbleContainerView.addGestureRecognizer(bubbleTapGesture)
        self.addGestureRecognizer(cellTapGesture)
        self.cellTapGesture.isEnabled = false
        self.bubbleTapGesture.isEnabled = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        self.addSubview(dateSeperatorLabel)
        self.addSubview(senderNameLabel)
        self.addSubview(bubbleContainerView)
        self.addSubview(unSelectedCircleImageView)
        self.addSubview(selectedCirlceImageView)
        self.bubbleContainerView.addSubview(timeLabelContainerView)
        self.timeLabelContainerView.addSubview(timerLabel)
        self.timeLabelContainerView.addSubview(audioIconView)
        
        self.bubbleContainerView.addSubview(loadingIndicator2)
        self.bubbleContainerView.addSubview(playButton)
        self.bubbleContainerView.addSubview(pauseButton)
        self.bubbleContainerView.addSubview(audioProgressView)
        self.bubbleContainerView.addSubview(messageTimeLabel)
        self.bubbleContainerView.addSubview(messageStatusImageView)
        
        self.playButton.addTarget(self, action: #selector(playButtonPressed(sender:)), for: .touchUpInside)
        self.pauseButton.addTarget(self, action: #selector(pauseButtonPressed(sender:)), for: .touchUpInside)
        
    }
    
    @objc private func playButtonPressed(sender: UIButton) {
        self.onPlayButtonPressed?(self)
    }
    
    @objc private func pauseButtonPressed(sender: UIButton) {
        self.onPauseButtonPressed?(self)
    }
    
    private func setUpViewsFrames() {
        guard let modelData = self.audioMessageModel else {
            return
        }
        self.playButton.isHidden = false
        self.pauseButton.isHidden = true
        if modelData.isMessageSelectorOn {
            self.cellTapGesture.isEnabled = true
            self.bubbleTapGesture.isEnabled = false
            self.longPressTapGesture.isEnabled = false
            
            if modelData.isMessageSelected {
                self.selectedCirlceImageView.isHidden = false
                self.unSelectedCircleImageView.isHidden = true
            } else {
                self.selectedCirlceImageView.isHidden = true
                self.unSelectedCircleImageView.isHidden = false
            }
            
        } else {
            self.cellTapGesture.isEnabled = false
            self.bubbleTapGesture.isEnabled = true
            self.longPressTapGesture.isEnabled = true
        }
        
        let selectedCircleOriginX: CGFloat = modelData.isMessageSelectorOn ? 15 : -30
        let unselectedCircleOririginX: CGFloat = modelData.isMessageSelectorOn ? 15 : -30
        
        let selectedCircleWidthHeight: CGFloat = modelData.isMessageSelectorOn ? 30 : 0
        let unSelectedCircleWidthHeight: CGFloat = modelData.isMessageSelectorOn ? 30 : 0
        
        let dateSeperatorHeight: CGFloat = modelData.showDataSeperator ? 30 : 0
        let dateSeperatorWidth = self.frame.width
        
        let senderNameHeight: CGFloat = modelData.showSenderName ? 25 : 0
        let senderNameWidth = self.frame.width - 40
        
        let bubbleContainerWidth: CGFloat = 280
        let bubbleContainerHeight = self.frame.height - dateSeperatorHeight - senderNameHeight
        
        var messageBubbleOriginX: CGFloat = 0
        if modelData.isIncoming {
            messageBubbleOriginX = modelData.isMessageSelectorOn ? 60 : 15
        } else {
            messageBubbleOriginX = self.frame.width - bubbleContainerWidth - 15
        }
        
        let messageTime = modelData.messageDate
        self.messageTimeLabel.text = messageTime.toRelateTimeString()
        self.messageTimeLabel.sizeToFit()
        let messageTimeLabelWidth = self.messageTimeLabel.frame.width + 10
        let messageTimeLabelHeight = self.messageTimeLabel.frame.height + 10
        let messageStatusViewHeight: CGFloat = 15
        let messageStatusViewWidth = modelData.isIncoming ? 0 : messageStatusViewHeight
        
        self.dateSeperatorLabel.frame.origin = .zero
        self.dateSeperatorLabel.frame.size = CGSize(width: dateSeperatorWidth, height: dateSeperatorHeight)
        
        self.senderNameLabel.frame.size = CGSize(width: senderNameWidth, height: senderNameHeight)
        self.senderNameLabel.frame.origin.x = messageBubbleOriginX
        self.senderNameLabel.frame.origin.y = getViewOriginYEnd(view: self.dateSeperatorLabel)
        
        self.bubbleContainerView.frame.size = CGSize(width: bubbleContainerWidth, height: bubbleContainerHeight)
        self.bubbleContainerView.frame.origin.y = getViewOriginYEnd(view: self.senderNameLabel)
        self.bubbleContainerView.frame.origin.x = messageBubbleOriginX
        
        self.selectedCirlceImageView.frame.size = CGSize(width: selectedCircleWidthHeight, height: selectedCircleWidthHeight)
        self.selectedCirlceImageView.frame.origin.x = selectedCircleOriginX
        self.selectedCirlceImageView.center.y = bubbleContainerView.center.y//selectedCircleCenterY
        self.selectedCirlceImageView.layer.cornerRadius = selectedCircleWidthHeight/2
        
        
        self.unSelectedCircleImageView.frame.size = CGSize(width: unSelectedCircleWidthHeight, height: unSelectedCircleWidthHeight)
        self.unSelectedCircleImageView.frame.origin.x = unselectedCircleOririginX
        self.unSelectedCircleImageView.center.y = bubbleContainerView.center.y//unselectedCircleCenterY
        self.unSelectedCircleImageView.layer.cornerRadius = unSelectedCircleWidthHeight/2
        
        self.messageStatusImageView.frame.size = CGSize(width: messageStatusViewWidth, height: messageStatusViewHeight)
        self.messageStatusImageView.frame.origin.x = self.bubbleContainerView.frame.width - 12.5 - messageStatusViewWidth
        self.messageStatusImageView.frame.origin.y = self.bubbleContainerView.frame.height - 7.5 - messageStatusViewHeight
        
        self.messageTimeLabel.frame.size = CGSize(width: messageTimeLabelWidth, height: messageTimeLabelHeight)
        self.messageTimeLabel.center.y = self.messageStatusImageView.center.y
        self.messageTimeLabel.frame.origin.x = self.messageStatusImageView.frame.origin.x - messageTimeLabelWidth - 2.5
        
        self.timeLabelContainerView.frame.size.height = 65
        self.timeLabelContainerView.frame.size.width = 65
        self.timeLabelContainerView.frame.origin.x = 7.5
        self.timeLabelContainerView.center.y = self.bubbleContainerView.frame.size.height/2
        
        self.audioIconView.frame.size = CGSize(width: 25, height: 25)
        self.audioIconView.center.x = self.timeLabelContainerView.frame.width/2
        self.audioIconView.frame.origin.y = 5
        
        self.timerLabel.frame.size = CGSize(width: self.timeLabelContainerView.frame.width - 5, height: 25)
        self.timerLabel.frame.origin.x = 2.5
        self.timerLabel.frame.origin.y = getViewOriginYEnd(view: self.audioIconView) + 5
        
        self.playButton.frame.size = CGSize(width: 35, height: 35)
        self.playButton.frame.origin.x = getViewOriginXEnd(view: self.timeLabelContainerView) + 5
        self.playButton.center.y = self.bubbleContainerView.frame.height/2
        
        self.pauseButton.frame.size = CGSize(width: 35, height: 35)
        self.pauseButton.frame.origin.x = getViewOriginXEnd(view: self.timeLabelContainerView) + 5
        self.pauseButton.center.y = self.bubbleContainerView.frame.height/2
        
        self.loadingIndicator2.frame.size = CGSize(width: 35, height: 35)
        self.loadingIndicator2.frame.origin.x = getViewOriginXEnd(view: self.timeLabelContainerView) + 5
        self.loadingIndicator2.center.y = self.bubbleContainerView.frame.height/2
        
        self.audioProgressView.frame.size = CGSize(width: self.bubbleContainerView.frame.width - getViewOriginXEnd(view: self.pauseButton) - 10, height: 5)
        self.audioProgressView.frame.origin.x = getViewOriginXEnd(view: self.pauseButton) + 5
        self.audioProgressView.center.y = self.bubbleContainerView.frame.height/2
        audioProgressView.setProgress(modelData.playerProgress, animated: false)
        
        
        if modelData.messageStatus == .sending {
            self.playButton.isHidden = true
            self.pauseButton.isHidden = true
            self.loadingIndicator2.isHidden = false
            self.loadingIndicator.style = .white
            self.loadingIndicator2.startAnimating()
        } else {
            switch modelData.playerStatus {
            case .loading:
                self.playButton.isHidden = true
                self.pauseButton.isHidden = true
                self.loadingIndicator2.isHidden = false
                self.loadingIndicator2.startAnimating()
                break
            case .playing:
                self.playButton.isHidden = true
                self.pauseButton.isHidden = false
                self.loadingIndicator2.stopAnimating()
                self.loadingIndicator2.isHidden = true
                break
            case .paused:
                self.playButton.isHidden = false
                self.pauseButton.isHidden = true
                self.loadingIndicator2.stopAnimating()
                self.loadingIndicator2.isHidden = true
                break
            default:
                break
            }
        }
        self.assignData(audioData: modelData)
        
    }
    
    private func assignData(audioData: AudioMessageModel) {
        
        if let audioDuration = audioData.audioDuration {
            let timeString = (audioDuration/1000).stringFromTimeInterval()
            self.timerLabel.text = timeString
        }
        
        loadingIndicator2.cycleColors = audioData.isIncoming ? [CHUIConstants.appDefaultColor] : [UIColor.white]
        audioProgressView.trackTintColor = audioData.isIncoming ? CHUIConstants.appDefaultColor.lighter(by: 20) : UIColor.lightGray
        audioProgressView.progressTintColor = audioData.isIncoming ? CHUIConstants.appDefaultColor : UIColor.white
        
        self.audioIconView.tintColor = audioData.isIncoming ? CHUIConstants.incomingTextMessageBackgroundColor : CHUIConstants.outgoingTextMessageBackgroundColor
        
        self.timerLabel.textColor = audioData.isIncoming ? CHUIConstants.incomingTextMessageBackgroundColor : CHUIConstants.outgoingTextMessageBackgroundColor
        
        self.timeLabelContainerView.backgroundColor = audioData.isIncoming ? CHUIConstants.outgoingTextMessageBackgroundColor : UIColor.white
        
        self.playButton.imageView?.tintColor = audioData.isIncoming ? CHUIConstants.outgoingTextMessageBackgroundColor : UIColor.white
        
        self.pauseButton.imageView?.tintColor = audioData.isIncoming ? CHUIConstants.outgoingTextMessageBackgroundColor : UIColor.white
        
        self.bubbleContainerView.backgroundColor = audioData.isIncoming ? CHUIConstants.incomingTextMessageBackgroundColor : CHUIConstants.outgoingTextMessageBackgroundColor
        
        self.senderNameLabel.text = audioData.senderName.capitalized
        self.dateSeperatorLabel.text = audioData.messageDate.toRelativeDateString()
        
        self.messageTimeLabel.textColor = audioData.isIncoming ? UIColor(hex: "#1c1c1c") : UIColor.white
        
        switch audioData.messageStatus {
        case .sending:
            self.messageStatusImageView.image = getImage("chSendingIcon")
            break
        case .sent:
            self.messageStatusImageView.image = getImage("chSingleTickIcon")
            break
        case .seen:
            self.messageStatusImageView.image = getImage("chDoubleTickIcon")
            break
        }
    }
    
    @objc func didTapOnBubble(tapGesture: UITapGestureRecognizer) {
        self.onBubbleTapped?(self)
    }
    
    @objc func didLongPressBubble(longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == .began {
            self.onLongPressedBubble?(self)
        }
    }
    
    @objc func didSelectDeSelectCell(tapGesture: UITapGestureRecognizer) {
        self.onCellTapped?(self)
    }
    
    func updateProgressView(newProgress: Float, currentTiming: Double) {
        print(newProgress)
        guard self.audioMessageModel?.playerStatus != .loading else {
            return
        }
        self.loadingIndicator2.stopAnimating()
        self.loadingIndicator2.isHidden = true
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


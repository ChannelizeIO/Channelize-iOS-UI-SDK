//
//  AudioCaptureView.swift
//  ChannelizeUI
//
//  Created by Ashish-BigStep on 3/15/20.
//  Copyright © 2020 Channelize. All rights reserved.
//

import UIKit
import ChannelizeAPI
import SDWebImage

protocol AudioCaptureViewDelegate {
    func didPressAudioCancelButton()
    func didPressAudioDeleteButton()
    func didPressAudioSendButton()
}

class AudioCaptureView: UIView {

    var recordingTime = 0
    var timer = Timer()
    var backGroundTime = 0
    
    var animatingAudioView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.image = getImage("chMicIcon")
        imageView.tintColor = UIColor.customSystemGreen
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var recordingTimerLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(fontStyle: .robotoSlabMedium, size: 20.0)
        label.text = "0:00"
        label.backgroundColor = .clear
        label.textColor = .white
        return label
    }()
    
    var sendAudioButton : UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setImage(getImage("chMessageSendButton"), for: .normal)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var cancelAudioButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 20.0)
        button.setTitle(CHLocalized(key: "pmCancel"), for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    
    var deleteAudioButton : UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(fontStyle: .robotoSlabRegualar, size: 20.0)
        button.setTitle(CHLocalized(key: "pmDelete"), for: .normal)
        button.setTitleColor(UIColor.customSystemRed, for: .normal)
        button.backgroundColor = .clear
        button.isHidden = true
        return button
    }()
    
    var delegate: AudioCaptureViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTopBorder(with: .lightGray, andWidth: 1.0)
        self.setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView(){
        self.addSubview(animatingAudioView)
        self.addSubview(recordingTimerLabel)
        self.addSubview(cancelAudioButton)
        self.addSubview(deleteAudioButton)
        self.addSubview(sendAudioButton)
        self.deleteAudioButton.isHidden = true
        
        self.cancelAudioButton.addTarget(self, action: #selector(didPressCancelAudioButton(sender:)), for: .touchUpInside)
        self.deleteAudioButton.addTarget(self, action: #selector(didPressAudioDeleteButton(sender:)), for: .touchUpInside)
        self.sendAudioButton.addTarget(self, action: #selector(didPressAudioSendButton(sender:)), for: .touchUpInside)
        
        self.animatingAudioView.setViewsAsSquare(squareWidth: 30)
        self.animatingAudioView.setLeftAnchor(relatedConstraint: self.leftAnchor, constant: 10)
        self.animatingAudioView.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
        
        self.recordingTimerLabel.setLeftAnchor(relatedConstraint: self.animatingAudioView.rightAnchor, constant: 10)
        self.recordingTimerLabel.setWidthAnchor(constant: 70)
        self.recordingTimerLabel.setTopAnchor(relatedConstraint: self.topAnchor, constant: 0)
        self.recordingTimerLabel.setBottomAnchor(relatedConstraint: self.bottomAnchor, constant: 0)
        
        self.cancelAudioButton.setWidthAnchor(constant: 120)
        self.cancelAudioButton.setCenterXAnchor(relatedConstraint: self.centerXAnchor, constant: 0)
        self.cancelAudioButton.setTopAnchor(relatedConstraint: self.topAnchor, constant: 0)
        self.cancelAudioButton.setBottomAnchor(relatedConstraint: self.bottomAnchor, constant: 0)
        
        self.deleteAudioButton.setWidthAnchor(constant: 120)
        self.deleteAudioButton.setCenterXAnchor(relatedConstraint: self.centerXAnchor, constant: 0)
        self.deleteAudioButton.setTopAnchor(relatedConstraint: self.topAnchor, constant: 0)
        self.deleteAudioButton.setBottomAnchor(relatedConstraint: self.bottomAnchor, constant: 0)
        
        self.sendAudioButton.setViewsAsSquare(squareWidth: 30)
        self.sendAudioButton.setRightAnchor(relatedConstraint: self.rightAnchor, constant: -10)
        self.sendAudioButton.setCenterYAnchor(relatedConstraint: self.centerYAnchor, constant: 0)
    }
    
    @objc func updateTimer()
    {
        self.animatingAudioView.flash(animation: .opacity)
        self.recordingTime += 1
        self.recordingTimerLabel.text = timeString(time: self.recordingTime)
    }
    
    func timeString(time:Int) -> String {
        //let hours = Int(time) / 3600
        let minutes = time / 60 % 60
        let seconds = time % 60
        return String(format:"%02i:%02i", minutes, seconds)
        //return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func startTimer()
    {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func pauseTimer(){
        timer.invalidate()
        self.animatingAudioView.layer.removeAllAnimations()
    }
    
    func stopTimer()
    {
        timer.invalidate()
        self.recordingTimerLabel.text = "00:00"
        self.recordingTime = 0
    }
    
    @objc private func didPressCancelAudioButton(sender: UIButton) {
        self.delegate?.didPressAudioCancelButton()
    }
    
    @objc private func didPressAudioDeleteButton(sender: UIButton) {
        self.delegate?.didPressAudioDeleteButton()
    }
    
    @objc private func didPressAudioSendButton(sender: UIButton) {
        self.delegate?.didPressAudioSendButton()
    }
    /*
     
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

